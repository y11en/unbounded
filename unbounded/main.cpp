// unbounded.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//


#include "../luapatch/helper.h"
#include <iostream>
#include "..\LuaJIT\src\lua.hpp"

extern "C"
{
#include "..\lsqlite3_fsl09y\sqlite3.h"

	int luaopen_lsqlite3(lua_State* L);

#include "..\luapatch\lua-seri.h"
}
#include "..\luapatch\luapool.h"
#include "../luapatch/alpc.h"

#include "..\luapatch\myrpcitf.h"

#include "../luapatch/myrpc_h.h"


// http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki#sqlite3_open_ptr

HANDLE g_hEvent;
GState G;
sqlite3* dbc = nullptr;

char* __stdcall LoadFile(const TCHAR* filePath, unsigned int* fileSize);

static bool EnablePrivilege(PCWSTR privilege) {
	HANDLE hToken;
	if (!::OpenProcessToken(::GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &hToken))
		return false;

	TOKEN_PRIVILEGES tp;
	tp.PrivilegeCount = 1;
	tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
	if (!::LookupPrivilegeValue(nullptr, privilege, &tp.Privileges[0].Luid))
		return false;

	BOOL success = ::AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(tp), nullptr, nullptr);
	::CloseHandle(hToken);

	return success && ::GetLastError() == ERROR_SUCCESS;
}

int __stdcall ServerRountie(void* arg, size_t sz)
{
	vm_ctx* ctx = acquire_vm(&G);
	__try {

		lua_rawgeti(ctx->L, LUA_REGISTRYINDEX, ctx->reg_idx_cb);
		
		lua_pushlightuserdata(ctx->L, ctx->ud);
		lua_pushlightuserdata(ctx->L, (char*)arg);
		lua_pushinteger(ctx->L, sz);
		
		//printf("%p, %d\n", arg, sz);
		if (lua_pcall(ctx->L, lua_gettop(ctx->L) - 1, 0, 0))
		{
			printf("%s\n", lua_tostring(ctx->L, -1));
		}

		lua_settop(ctx->L, 0);
	}
	__except (1)
	{
		printf("WTF Crash ....\n");
	}
	
	release_vm(&G, ctx);

	return 0;
}

extern "C"
void rpc_Upload(
	/* [in] */ handle_t IDL_handle,
	/* [in] */ PMYSTRING msg)
{
	ServerRountie((char*)msg + offsetof(MYSTRING, string), msg->size);
}

int work()
{
	char name[] = { "Unbounded03" };
	char prot[] = {"ncalrpc"};
	RpcSrvStart(prot, name, true);
	return 0;
}


int main()
{

	setlocale(LC_ALL, ".UTF8");

	EnablePrivilege(SE_DEBUG_NAME);

	g_hEvent = ::CreateEvent(nullptr, FALSE, FALSE, nullptr);

	::SetConsoleCtrlHandler([](auto type) {
		if (type == CTRL_C_EVENT) {

			::SetEvent(g_hEvent);
			return TRUE;
		}
		return FALSE;
		}, TRUE);
	
	unsigned int luacode_sz = 0;
#ifdef _DEBUG
	const char* luacode = (const char*)LoadFile(L"D:\\other\\vs23\\luapatch\\script\\server.lua", &luacode_sz);
#else
	const char* luacode = (const char*)LoadFile(L"c:\\server.lua", &luacode_sz);
#endif // _DEBUG



	init_vmpool(&G, 4, (uint8_t*)luacode, strlen(luacode),
		[](lua_State* L) {
			luaL_openlibs(L);
			luaopen_lsqlite3(L);

			lua_pushcfunction(L, luaseri_pack);
			lua_setglobal(L, "pack");

			lua_pushcfunction(L, luaseri_unpack);
			lua_setglobal(L, "unpack");

			lua_pushcfunction(L, luaseri_unpack_remove);
			lua_setglobal(L, "unpack_remove");
		});
	

	sqlite3_open_v2(":memory:", &dbc, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, NULL);

	// 初始化 DB
	auto L = luaL_newstate();
	
	if (L)
	{
		luaL_openlibs(L);
		luaopen_lsqlite3(L);
		if(luaL_loadbuffer(L, luacode, luacode_sz, "code") || 
			lua_pcall(L, 0, 0, 0))
		{
			// 失败
			printf("err=%s\n", lua_tostring(L, -1));
		}
		lua_settop(L, 0);
		lua_getglobal(L, "on_start");
		lua_pushlightuserdata(L, dbc);
		if (lua_pcall(L, lua_gettop(L) -1 , 0, 0))
		{
			// 失败
			printf("err=%s\n",lua_tostring(L, -1));
		}
		lua_close(L);
	}


	init_vmpool2(&G, "on_callback", [](vm_ctx* ctx) {
	
		ctx->ud = dbc;
	});


//	BYTE buff[] = {
//		0xff,0xff,0x00,0x00,0x05,0x2b,0x6c,0x61,0x64,0x64,0x72,0x9b,0x31,0x39,0x32,0x2e,
//
//0x31,0x36,0x38,0x2e,0x31,0x31,0x31,0x2e,0x31,0x34,0x30,0x3a,0x31,0x33,0x35,0x1b,
//
//0x74,0x69,0x64,0x11,0x74,0x13,0x13,0x74,0x73,0x41,0x7a,0x8c,0x7b,0xa4,0xb2,0x94,
//
//0x7d,0x43,0x0b,0x74,0x1b,0x52,0x50,0x43,0x1b,0x70,0x69,0x64,0x11,0xc8,0x02,0x2b,
//
//0x72,0x61,0x64,0x64,0x72,0x9b,0x31,0x39,0x32,0x2e,0x31,0x36,0x38,0x2e,0x31,0x31,
//	};
//
//	lua_settop(L, 0);
//
//	lua_pushlightuserdata(L, buff);
//	luaseri_unpack(L);
//	printf("%p, %d", lua_touserdata(L, 1), lua_touserdata(L, 2));
	


	work();


	::WaitForSingleObject(g_hEvent, INFINITE);
	::CloseHandle(g_hEvent);


	return 0;
}


char* __stdcall LoadFile(const TCHAR* filePath, unsigned int* fileSize)
{
	FILE* f = NULL;
	const char* s;
	unsigned t = 0;
	unsigned n = 0;
	//#ifndef _AMD64_
	//	PVOID OldValue;
	//	if (Wow64DisableWow64FsRedirection(&OldValue))
	//	{
	//#endif

#ifdef _MSC_VER
	_wfopen_s(&f, filePath, _T("rb"));
#else
	f = fopen(filePath, "rb");
#endif

	//#ifndef _AMD64_
	//		Wow64RevertWow64FsRedirection(OldValue);
	//	}
	//#endif

	if (!f)
	{
		return 0;
	}

	if (fseek(f, 0, SEEK_END) < 0)
	{
		fclose(f);
		return 0;
	}

	n = ftell(f);
	if (n < 0)
	{
		fclose(f);
		return 0;
	}

	if (fseek(f, 0, SEEK_SET) < 0)
	{
		fclose(f);
		return 0;
	}

	s = (const char*)malloc(n + 1);
	if (!s)
	{
		fclose(f);
		return 0;
	}

	t = fread((void*)s, 1, n, f);
	if (t != n)
	{
		free((void*)s);
		fclose(f);
		return 0;
	}

	if (fileSize)
		*fileSize = t;

	fclose(f);
	return (char*)s;
}