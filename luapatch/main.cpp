// luapatch.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//


#include "state.hpp"
#include "native_function.h"
#include "Interceptor.h"
#include "minhook/MinHook.h"
#include "helper.h"

#include <phnt_windows.h>
#include <phnt.h>

#include <vector>
#include <iostream>

#include <codecvt>
#include <WS2tcpip.h>
#include "luapool.h"



// https://frida.re/docs/javascript-api/
// 参考 FRIDA 制作 LUA hook 框架

/*
	1, module
	2, memory
	3, NativeFunction

	https://evilpan.com/2022/04/05/frida-internal/
	http://bikong0411.github.io/2016/05/31/lua-ffi-summary.html
*/


static void export_func(lua_State* L, const char* name, const void* ptr)
{
	native_function* fn = native_function::push(L);
	fn->address = ptr;
	lua_setglobal(L, name);
}

// http://lua-users.org/wiki/SimpleLuaApiExample
DWORD g_mytid;

// powershell HOOK
// https://georgeplotnikov.github.io/articles/just-in-time-hooking.html
// https://learn.microsoft.com/en-us/windows/win32/etw/nt-kernel-logger-constants
// https://ntcore.com/files/netint_injection.htm
// https://vx.zone/2023/01/03/jithooking-utku.html
// https://www.anquanke.com/post/id/176089
// CLR 运行时
// https://github.com/dotnet/runtime/blob/eb03112e4e715dc0c33225670c60c6f97e382877/src/coreclr/inc/corjit.h#L93
// RPC
// https://zhuanlan.zhihu.com/p/500415108
// 检测
// https://blog.f-secure.com/endpoint-detection-of-remote-service-creation-and-psexec/

// UUID MAP
// https://docs.zeek.org/en/v3.0.14/scripts/base/protocols/dce-rpc/consts.zeek.html
// https://www.rc.sb/impacket-1/





DWORD WINAPI Main(void*)
{
	
	const int pool_works = 4;
	
	printf("%llu", GetTimeNow());
	setlocale(LC_ALL, ".UTF8");
	init_alloc();

	MH_Initialize();

	Interceptor::init();

	if (!Interceptor::pool)
	{
		printf("pool init failed\n");
		return 1;
	}

	unsigned int file_size_main = 0;
	unsigned int file_size_hook = 0;
	char* file_buff_main = NULL;
	char* file_buff_hook = NULL;


#ifdef _DEBUG
//#if 0
	file_buff_main = LoadFile(L"D:\\other\\vs23\\luapatch\\luapatch\\script\\main.lua", &file_size_main);
	file_buff_hook = LoadFile(L"D:\\other\\vs23\\luapatch\\luapatch\\script\\hook.lua", &file_size_hook);
#else
	file_buff_main = LoadFile(L"c:\\main.lua", &file_size_main);
	file_buff_hook = LoadFile(L"c:\\hook.lua", &file_size_hook);
#endif // _DEBUG

	std::vector<uint8_t> script_hook;
	script_hook.resize(file_size_main + file_size_hook);
	memcpy(&script_hook[0], file_buff_main, file_size_main);
	memcpy(&script_hook[file_size_main], file_buff_hook, file_size_hook);

	// main + hook
	


	init_vmpool(&Interceptor::G, pool_works, & script_hook[0], script_hook.size(), (INITCB)init_libs);
	init_vmpool2(&Interceptor::G, "on_callback", 
		[] (vm_ctx* ctx){
			MYCTX* myctx = (MYCTX*)malloc(sizeof(*myctx));
			
			// 这里需要判断，暂时没判断
			memset(myctx, 0, sizeof(*myctx));
			memset(myctx->ipc_recv, 0, sizeof(myctx->ipc_recv));
			ctx->ud = myctx;
		});

	lua_State* GL = luaL_newstate();
	init_libs(GL);
	Interceptor::declare(GL);

	if (luaL_loadbuffer(GL, file_buff_main, file_size_main, NULL) || lua_pcall(GL, 0, 0, 0))
	{
		printf("err=%s\n", lua_tostring(GL, -1));
	}
	lua_getglobal(GL, "start");
	if (lua_pcall(GL, 0, 0, 0))
	{
		printf("err=%s\n", lua_tostring(GL, -1));
	}

	return 0;
}
#if (defined DEBUG || defined _DEBUG)
//#if 0
int main()
{

	printf("%d", is_invalid_ptr((void*)1281587366930701572ULL));
	
	Main(NULL);
	auto func = [](void* arg)->DWORD {
		
		while (true)
		{
			STARTUPINFOA si = {};
			PROCESS_INFORMATION pi = {};
			STARTUPINFOW siw = {};

			DWORD rc, exitcode;

			const char* cmdline = "This is Test call CreateProcessA 红红火火恍恍惚惚";
			wchar_t cmdlinew[] = { L"This is Test call CreateProcessA 红红火火恍恍惚惚!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" };

			if (!CreateProcessA(
				NULL, (LPSTR)cmdline,
				NULL, NULL, TRUE/*inherit*/,
				0, NULL, NULL, &si, &pi))
			{
				// printf("创建进程失败了 %p\n", &si);
			}

			memset(&pi, 0, sizeof(pi));

			if (!CreateProcessW(
				NULL, (LPWSTR)cmdlinew,
				NULL, NULL, TRUE/*inherit*/,
				0, NULL, NULL, &siw, &pi))
			{
				// printf("创建进程失败了 %p\n", &si);
			}

			WinExec("winexec_test ####!!gfdijdfsg0j0uj", 10);

			Sleep(1);
		}

		return 0;
	};

	std::wstring wstr;

	
	BYTE buff[] = { 0x02 ,0x00 ,0xce ,0x18 ,0xc0,0xa8,0x6f,0x01,0x00 };
	// addrSrv.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");
	// addrSrv.sin_family = AF_INET;
	// addrSrv.sin_port = htons(4000);



	getchar();
	CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)func, NULL, NULL, NULL);
	//CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)func, NULL, NULL, NULL);
	//CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)func, NULL, NULL, NULL);
	//CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)func, NULL, NULL, NULL);
	//CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)func, NULL, NULL, NULL);
	//CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)func, NULL, NULL, NULL);
	getchar();

	MH_DisableHook(MH_ALL_HOOKS);
	// lua_close(GL);
	// MH_Uninitialize();

	

	return 0;

}
#else

__declspec(dllexport)
BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD ul_reason_for_call,
	LPVOID lpReserved)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		DisableThreadLibraryCalls(hModule);

		AllocConsole();
		freopen_s((FILE**)stdout, "CONOUT$", "w", stdout);

		CreateThread(NULL, NULL, Main, NULL, 0, NULL);
		break;
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

#endif