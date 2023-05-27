#pragma once

#include "state.hpp"
#include "locker.h"
#include "stackwalker.h"

#include <phnt_windows.h>
#include <phnt.h>
#include <mutex>
#include <vector>
#include <list>

#include <map>
#include "ThreadPool.h"

extern "C"
{
#include "lua-seri.h"
}
#include "luapool.h"

extern "C"
{
	void HOOK_STUB();
	void HOOK_STUB_END();
}


#define IPC_BUFFER_SIZE 0x1000
typedef struct _MyCtx
{
	BYTE ipc_recv[IPC_BUFFER_SIZE];
	uint64_t stack[STACKSIZE];
	void* ctx;					  // C->lua->C 使用
}MYCTX, * PMYCTX;

struct Hookport
{
	void* ctx;
	void* address;
	void* sp;
	int reffunc;
	char name[64];	// 支持动态安装hook
};

struct Interceptor
{
	static const DWORD MAX_WORK_THREADS = 0x8;

	static constexpr const char* export_name = "Interceptor";	
	static void __stdcall pre_hook(void* ud, void* sp);
	static int attach(intptr_t address);
	static void DbgMsg(const char* msg);
	
	static int init();

	static 	GState G;
	static  CLock lock_hook;
	static  ThreadPool* pool;

	// 注册表
	static void declare(lua_State* L)
	{
		static const luaL_Reg method_table[] = {
			{nullptr, nullptr}
		};
		// 5.2 + 替换方案
		lua_getglobal(L, export_name);
		if (lua_isnil(L, -1))
		{
			lua_pop(L, 1);
			lua_newtable(L);
		}
		luaL_setfuncs(L, method_table, 0);
		lua_setglobal(L, export_name);	// 全局方法
	}

	static DWORD myself_threadid[Interceptor::MAX_WORK_THREADS + 1];

};


int __stdcall  init_libs(lua_State* L);
void init_alloc();
bool __stdcall is_invalid_ptr(void* ptr);