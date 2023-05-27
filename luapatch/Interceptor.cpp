#include "Interceptor.h"
#include "minhook/MinHook.h"
#include "trampoline.h"

#include "../LuaJIT/src/luajit.h"
#include "../LuaJIT/src/lj_ctype.h"
#include "helper.h"
#include "locker.h"
#include <assert.h>
#include "Trace.hpp"

#include "luapool.h"
EXTERN_C{
	#include "lua-seri.h"
}

#include "StackWalker.h"

#define _NAKED_ __declspec(naked)

#if defined(_M_X64) || defined(__x86_64__)
#define _DEFALUT_ABI_ __fastcall
#else
#define _DEFALUT_ABI_
#endif

#include "myrpc_h.h"
#include "myrpcitf.h"

#if !(defined(_M_X64) || defined(__x86_64__))


#endif


GState Interceptor::G;
CLock Interceptor::lock_hook;
ThreadPool* Interceptor::pool = nullptr;
DWORD Interceptor::myself_threadid[];

#include "lua-seri.h"

void print_stack(lua_State* L)
{
#ifdef _DEBUG
	for (int i = 1; i <= lua_gettop(L); ++i)
	{
		printf("\n%d\t%p\t%s", i, (uintptr_t)lua_asintrinsic(L, i), luaL_typename(L, i));
	}
	puts("");
#endif // DEBUG
}


/* thread info */
#define	MAX_THREADS 1024
struct Tls {
	DWORD in;
	DWORD tid;
	struct Tls* next;
} tidtls[MAX_THREADS] = { 0 };

static struct Tls* freelist = NULL, * hotlist = NULL;
void init_alloc()
{
	int i;
	struct Tls* tmp = (struct Tls*)malloc(sizeof(struct Tls) * MAX_THREADS);
	if (tmp)
	{
		freelist = tmp;
		for (i = 0; i < MAX_THREADS - 1; i++) {
			tmp[i].next = &tmp[i + 1];
		}
		tmp[i].next = NULL;
	}
}

/* lookup thread data, for the current thread */
static struct Tls*
lookup_tid(DWORD tid)
{
	DWORD ind, inc;
	struct Tls* tmp = NULL, * prev = NULL;

	for (tmp = hotlist; tmp != NULL; tmp = tmp->next) {
		if (tmp->tid == tid) {
			return tmp;
		}
	}

	for (tmp = hotlist; tmp != NULL; tmp = tmp->next) {
		if (InterlockedCompareExchange(&tmp->tid, tid, 0) == 0) {
			//if (tmp->tid == 0) {
			tmp->tid = tid;
			///InterlockedExchange(&_malloc, 0);
			return tmp;
		}
		prev = tmp;
	}

	assert(freelist != NULL);

	do {
		tmp = freelist;
		//freelist = tmp->next;
	} while (InterlockedCompareExchangePointer((volatile PVOID*) & freelist, tmp->next, tmp) != tmp);
	tmp->tid = tid;
	tmp->in = 0;
	tmp->next = NULL;
	if (prev == NULL)
		hotlist = tmp;
	else
		prev->next = tmp;


	return tmp;

}

void __stdcall Interceptor::pre_hook(void* ud, void* sp)
{

	struct Tls* tls = NULL;
	Hookport* hp = *(Hookport**)ud;
	uintptr_t regs = 0, stack = 0;

	DWORD tid = GetCurrentThreadId();
	extern DWORD g_mytid;


	for (int i = 0; i < sizeof(Interceptor::myself_threadid) / sizeof(Interceptor::myself_threadid[0]); ++i)
	{
		if(Interceptor::myself_threadid[i] == tid)
			return;
	}
	if ((tls = lookup_tid(tid)) == NULL || tls->in)
	{
		// YZMDD::DoTrace("!!! DIGUI");
		return;
	}

	tls->in = 1;

	// printf("-%s- %p\n", __FUNCDNAME__, hp->address);


#ifdef DEBUG
	printf("IN %s %d\n", __FUNCTION__, tid);
#endif // DEBUG

#if !(defined(_M_X64) || defined(__x86_64__))
	// x86
	regs = (uintptr_t)sp;
	stack = (uintptr_t)sp + 0x28;   // Flag + 8个GPR + retaddr
#else
	regs = (uintptr_t)sp + 0x60;
#define RSP_IDX 11
	((uintptr_t*)regs)[RSP_IDX] = (uintptr_t)sp + 232;		// 重新修正调用现场的RSP值
	stack = (uintptr_t)sp + 232 + 0x28; // 232 8=返回地址, 0x20是 x64调用者保留的4个GPR空间
#endif

	vm_ctx* ctx = acquire_vm(&Interceptor::G);
	
	__try
	{
		MYCTX* myctx = (MYCTX*) ctx->ud;
		myctx->ctx = hp;
		lua_rawgeti(ctx->L, LUA_REGISTRYINDEX, ctx->reg_idx_cb);
		lua_pushlightuserdata(ctx->L, myctx);
		lua_pushlightuserdata(ctx->L, hp->address);
		lua_pushlightuserdata(ctx->L, (void*)regs);
		lua_pushlightuserdata(ctx->L, (void*)stack);
		lua_pushstring(ctx->L, hp->name);
		if (lua_pcall(ctx->L, lua_gettop(ctx->L) - 1, 0, 0))
		{
			printf("runerr=%s\n", lua_tostring(ctx->L, -1));
		}
	}
	__except (1)
	{
		OutputDebugStringA("crash ... ");
	}

	lua_settop(ctx->L, 0);
	release_vm(&Interceptor::G, ctx);

	tls->tid = 0;
	tls->in = 0;
}

static void __stdcall post_call(void* ud, void* sp)
{
	// not used
}


int do_hook(intptr_t address, Hookport* hp)
{

	void* orgin_call = 0;
	int oep = 0;
	void* buff = 0;

	if (address == 0)
		return -1;

	buff = VirtualAlloc(NULL, 0x1000, MEM_RESERVE | MEM_COMMIT, PAGE_EXECUTE_READWRITE);

	if (NULL == buff)
	{
		return -3;
	}

#if !(defined(_M_X64) || defined(__x86_64__))
	uint8_t opcode[] = { 0x00, 0x00, 0x00, 0x00, 0xE9, 0x6F, 0x56, 0x34, 0x12, 0xE9, 0x6A, 0x56, 0x34, 0x12, 0x9C, 0x60,
	0x8D, 0x04, 0x24, 0x50, 0xE8, 0x00, 0x00, 0x00, 0x00, 0x58, 0x8D, 0x40, 0xE7, 0x50, 0xE8, 0xE6,
	0xFF, 0xFF, 0xFF, 0x61, 0x9D, 0xEB, 0xDD, 0x90, 0x90 };

	void* hook_pointer = (void*)((uint32_t)buff + 14);
	void* real_address = (void*)address;
	MH_STATUS status = MH_CreateHook((void*)(real_address), (void*)hook_pointer, &orgin_call);
	*((uint32_t*)&opcode[0]) = (uint32_t)hp;
	*((uint32_t*)&opcode[5]) = (uint32_t)orgin_call - ((uint32_t)buff + 4) - 5;
	*((uint32_t*)&opcode[10]) = (uint32_t)Interceptor::pre_hook - ((uint32_t)buff + 9) - 5;

#else
	uint8_t opcode[] = { 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0xff,0x25,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0xff,0x25,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0xff,0x25,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0xff,0x25,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x90,0x9c,0x50,0x51,0x52,0x53,0x6a,0xff,0x55,0x56,0x57,0x41,0x50,0x41,0x51,0x41,0x52,0x41,0x53,0x41,0x54,0x41,0x55,0x41,0x56,0x41,0x57,0x48,0x83,0xec,0x60,0xf,0x29,0x4,0x24,0xf,0x29,0x4c,0x24,0x10,0xf,0x29,0x54,0x24,0x20,0xf,0x29,0x5c,0x24,0x30,0xf,0x29,0x64,0x24,0x40,0xf,0x29,0x6c,0x24,0x50,0x48,0x8d,0xd,0x7d,0xff,0xff,0xff,0x48,0x8d,0x14,0x24,0x48,0x83,0xec,0x20,0xe8,0x86,0xff,0xff,0xff,0x48,0x83,0xc4,0x20,0xf,0x28,0x4,0x24,0xf,0x28,0x4c,0x24,0x10,0xf,0x28,0x54,0x24,0x20,0xf,0x28,0x5c,0x24,0x30,0xf,0x28,0x64,0x24,0x40,0xf,0x28,0x6c,0x24,0x50,0x48,0x83,0xc4,0x60,0x41,0x5f,0x41,0x5e,0x41,0x5d,0x41,0x5c,0x41,0x5b,0x41,0x5a,0x41,0x59,0x41,0x58,0x5f,0x5e,0x5d,0x48,0x83,0xc4,0x8,0x5b,0x5a,0x59,0x58,0x9d,0x90,0xe9,0x31,0xff,0xff,0xff,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90 };
	void* hook_pointer = (void*)((uint64_t)buff + 64);
	void* real_address = (void*)address;
	MH_STATUS status = MH_CreateHook((void*)(real_address), (void*)hook_pointer, &orgin_call);
	*((uint64_t*)&opcode[0]) = (uint64_t)hp;
	*((uint64_t*)&opcode[14]) = (uint64_t)orgin_call;
	*((uint64_t*)&opcode[28]) = (uint64_t)Interceptor::pre_hook;
#endif

	hp->address = (void*)address;
	memcpy(buff, &opcode[0], sizeof(opcode));

	status = MH_EnableHook((void*)address);
	return status;
}


int __stdcall attach_name(intptr_t address, const char* name)
{
	// https://blog.csdn.net/linuxheik/article/details/53157445
	// void* address = (void*)luaL_checkunsigned(L, 1);

	// 关掉该函数及其子函数的JIT，不然会崩溃，因为调用栈不是0x10对齐，导致XMM寄存器访问错误
	//luaJIT_setmode(L, -1, LUAJIT_MODE_FUNC | LUAJIT_MODE_OFF);
	//luaJIT_setmode(L, -1, LUAJIT_MODE_ALLSUBFUNC | LUAJIT_MODE_OFF);
	//luaJIT_setmode(L, -1, LUAJIT_MODE_ALLFUNC | LUAJIT_MODE_OFF);

	int status = 0;
	Hookport* hp = (Hookport*)malloc(sizeof(*hp));

	if (!hp)
	{
		return 1;
	}

	memset(hp, 0, sizeof(*hp));
	if (name)
	{
		int len = strlen(name);
		if (len < sizeof(hp->name))
		{
			memcpy(hp->name, name, len);
		}
	}

	Interceptor::lock_hook.Lock();

	status = do_hook(address, hp);
	
	Interceptor::lock_hook.Unlock();

	return status;
}

int Interceptor::attach(intptr_t address)
{
	if (address)
		return attach_name(address, NULL);

	return 1;
}

void Interceptor::DbgMsg(const char* msg)
{

	Interceptor::G.lock_print.Lock();

	if (msg)
		YZMDD::DoTrace("%s", msg);

	Interceptor::G.lock_print.Unlock();
}

int hnbapi_dbgprint(lua_State* L)
{
	if (lua_isstring(L, -1))
		Interceptor::DbgMsg(lua_tostring(L, -1));
	return 0;
}

uint64_t* WINAPI wrap_StackTrace(void* ptr, uintptr_t ip, uintptr_t sp, int limit, int aframes)
{
	MYCTX* ctx = (MYCTX*)ptr;
	if (ctx)
	{
		// sp 
		// 32位 ebp

		// Hookport* hp =(Hookport*) ctx->ctx;
		limit = limit > sizeof(ctx->stack) ? sizeof(ctx->stack) : limit;
		memset(&ctx->stack[0], 0, sizeof(ctx->stack));
		StackTrace(ctx->stack, ip, sp, limit, aframes);
		return &ctx->stack[0];
	}
	return NULL;
}

int wrap_ws2s(lua_State* L)
{
	std::string str;
	wchar_t* p = NULL;

	if (lua_type(L, -1) == LUA_TCDATA)
	{
		p = *(wchar_t**)lua_topointer(L, -1);
		if (p)
		{
			str = ws2s(p);
			lua_pushstring(L, str.c_str());
			return 1;
		}
	}

	lua_settop(L, 0);
	lua_pushnil(L);
	return 1;
}

int wrap_EnumDISPPARAMS(lua_State* L)
{

	std::vector<std::wstring> args;
	if (lua_type(L, -1) == LUA_TCDATA)
	{
		DISPPARAMS* p = *(DISPPARAMS**)lua_topointer(L, -1);
	
		if (p)
		{
			EnumDISPPARAMS(p, args);
			lua_settop(L, 0);
			lua_newtable(L);

			int i = 1;
			for (auto w : args)
			{
				std::string str = ws2s(w);

				lua_pushinteger(L, i++);
				lua_pushstring(L, str.c_str());
				lua_rawset(L, -3);
			}
			return 1;
		}
	}

	lua_settop(L, 0);
	lua_pushnil(L);
	return 1;

}
int wrap_EnumIWbemClassObject(lua_State* L)
{
	// int EnumIWbemClassObject(IWbemClassObject* pclsObj, std::vector<std::wstring>& args);

	std::vector<std::wstring> args;

	if (lua_type(L, -1) == LUA_TCDATA)
	{
		IWbemClassObject* p = *(IWbemClassObject**)lua_topointer(L, -1);
		if (p)
		{

			// YZMDD::DoTrace("%s IN EnumIWbemClassObject", __FUNCDNAME__);
			EnumIWbemClassObject(p, args);
			// YZMDD::DoTrace("%s OUT EnumIWbemClassObject", __FUNCDNAME__);

			lua_settop(L, 0);
			lua_newtable(L);

			int i = 1;
			for (auto w : args)
			{
				std::string str = ws2s(w);
				
				lua_pushinteger(L, i ++ );
				lua_pushstring(L, str.c_str());
				lua_rawset(L, -3);
			
				// YZMDD::DoTrace(">> %s", str.c_str());
			}

			return 1;
		}
	}
	lua_settop(L, 0);
	lua_pushnil(L);
	return 1;
}

int wrap_Var2Str(lua_State* L)
{
	
	std::wstring wstr;
	if (lua_type(L, -1) == LUA_TCDATA)
	{
		VARIANT* p = *(VARIANT**)lua_topointer(L, -1);
		BOOL ok = Var2Str(p, wstr);
		if (ok)
		{
			std::string str = ws2s(wstr);
			lua_settop(L, 0);
			lua_pushstring(L, str.c_str());
			return 1;
		}
	}
	lua_settop(L, 0);
	lua_pushnil(L);
	return 1;
}

int wrap_addr2ippt(lua_State* L)
{
	//BYTE* p = NULL;
	//if (lua_type(L, -1) == LUA_TCDATA)
	//{
	//	p = *(BYTE**)lua_topointer(L, -1);
	//	// printf("%s %p\n",__FUNCDNAME__, p);
	//	if (p)
	//	{
	//		std::wstring wstr;
	//		unsigned short port = getAddressAndPortFromBuffer(wstr, p);
	//		// printf("%s %d\n", __FUNCDNAME__, port);
	//		if (port)
	//		{
	//			std::string str = ws2s(wstr);
	//			lua_pushstring(L, str.c_str());
	//			lua_pushinteger(L, port);
	//			return 2;
	//		}

	//	}
	//}
	//lua_settop(L, 0);
	//lua_pushnil(L);lua_pushnil(L);

	return 2;
}

#pragma optimize( "", off )

bool __stdcall is_invalid_ptr(void* ptr)
{
	__try{
		return *((uintptr_t*)ptr) ? 0 : 0;
	}
	__except (1){}

	return 1;
}

#pragma optimize( "", on )


bool __stdcall AddressHasHooked(void* p)
{
	return MH_AddressHasHooked(p);
}



//int __stdcall AlpcServerA(const char* PortName, _PFNCALLBACK CB, int MaxMsgLen /*=0x2000*/)
//{
//	if (PortName)
//	{
//		std::wstring wstr = Utils::AnsiToWstring(PortName);
//		return AlpcServer(wstr.c_str(), CB, MaxMsgLen);
//	}
//}
//
//int __stdcall AlpcSendA(const char* PortName, void* buff, size_t sz, int MaxMsgLen /*=0x2000*/)
//{
//	if (PortName)
//	{
//		std::wstring wstr = Utils::AnsiToWstring(PortName);
//		return AlpcSend(wstr.c_str(), buff, sz, MaxMsgLen);
//	}
//	return 1;
//}
//int __stdcall AlpcPostA(const char* PortName, void* buff, size_t sz, int MaxMsgLen /*=0x2000*/)
//{
//	if (Interceptor::pool)
//	{
//		Interceptor::pool->enqueue_nonreturn(AlpcSendA, PortName, buff, sz, MaxMsgLen);
//		return 0;
//	}
//	return 1;
//}




unsigned long __stdcall ASyncRpcSend(const char* pszProtocolSequence, const char* pszNetworkAddress, const char* pszEndpoint, char* buff, int sz)
{

	if (Interceptor::pool)
	{
		Interceptor::pool->enqueue_nonreturn([pszProtocolSequence, pszNetworkAddress, pszEndpoint, buff, sz]()-> void{
			if (buff)
			{
				RpcSend(pszProtocolSequence, pszNetworkAddress, pszEndpoint, buff, sz);
				free(buff);
			}

		});
		return 0;
	}
	return 1;
}


int __stdcall  init_libs(lua_State* L)
{
	luaL_openlibs(L);
	lua_pushcfunction(L, hnbapi_dbgprint);
	lua_setglobal(L, "DbgPrint");

	lua_pushlightuserdata(L, &malloc);
	lua_setglobal(L, "_malloc");

	lua_pushlightuserdata(L, &free);
	lua_setglobal(L, "_free");

	lua_pushlightuserdata(L, &wrap_StackTrace);
	lua_setglobal(L, "_stacktrace");

	lua_pushlightuserdata(L, &EnumLdrDll);
	lua_setglobal(L, "_enumldrdll");

	lua_pushlightuserdata(L, (void*) & Interceptor::attach);
	lua_setglobal(L, "_attach");
	
	lua_pushlightuserdata(L, &attach_name);
	lua_setglobal(L, "_attach_name");

	lua_pushlightuserdata(L, &lstrlenW);
	lua_setglobal(L, "_lstrlen_w");

	lua_pushcfunction(L, &wrap_ws2s);
	lua_setglobal(L, "WS2S");

	lua_pushlightuserdata(L, &is_invalid_ptr);
	lua_setglobal(L, "_is_invalid_ptr");

	lua_pushlightuserdata(L, &getAddressAndPortFromBuffer);
	lua_setglobal(L, "_addr2str");

	lua_pushlightuserdata(L, &parse_rpcmsg);
	lua_setglobal(L, "_parse_rpcmsg");

	lua_pushlightuserdata(L, &AddressHasHooked);
	lua_setglobal(L, "_check_hook");

	lua_pushcfunction(L, &wrap_EnumIWbemClassObject);
	lua_setglobal(L, "_enumwobj");

	lua_pushcfunction(L, &wrap_EnumDISPPARAMS);
	lua_setglobal(L, "_enumdisp");

	lua_pushcfunction(L, &wrap_Var2Str);
	lua_setglobal(L, "_dump_var");

	lua_pushcfunction(L, &luaseri_pack);
	lua_setglobal(L, "_pack");
	
	lua_pushcfunction(L, &luaseri_unpack);
	lua_setglobal(L, "_unpack");

	lua_pushcfunction(L, &luaseri_unpack_remove);
	lua_setglobal(L, "_unpack_revome");

	lua_pushcfunction(L, &luaseri_remove);
	lua_setglobal(L, "_pack_free");

	lua_pushlightuserdata(L, &GetTimeNow);
	lua_setglobal(L, "_time");

	
	// int AlpcSend(wchar_t* PortName, void* buff, size_t sz, int MaxMsgLen /*=0x2000*/);
	lua_pushlightuserdata(L, &ASyncRpcSend);
	lua_setglobal(L, "_send");

	// lua_pushlightuserdata(L, &AlpcPostA);
	// lua_setglobal(L, "_post");

	// BOOL Var2Str(VARIANT * var, std::wstring & wstr);

	return 0;
}

int  Interceptor::init()
{
	Interceptor::pool = new ThreadPool(Interceptor::MAX_WORK_THREADS);
	if (pool)
	{
		std::vector<DWORD> g_ids;

		Interceptor::pool->get_workerid(g_ids);
		g_ids.push_back(GetCurrentThreadId());

		for (int i = 0; i < g_ids.size(); ++i)
		{
			Interceptor::myself_threadid[i] = g_ids[i];
		}
	
		return 0;
	}
	
	return 1;
}