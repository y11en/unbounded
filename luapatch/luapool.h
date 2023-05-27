#pragma once
#include <stdint.h>
#include <list>

#include "..\LuaJIT\src\lua.hpp"
#include "locker.h"



// #define POOL_SIZE 4
typedef struct
{
	lua_State* L;
	unsigned int reg_idx_cb;
	void* ud;
}vm_ctx;

typedef struct _GState
{
	std::list<vm_ctx*> free_list;
	std::list<vm_ctx*> buzy_list;
	CLock lock_free, lock_buzy;
	CLock lock_print;			// dbgprint µ÷ÊÔÊä³öËø
	CLock lock_wdog;
}GState, *PGState;

typedef void (__stdcall *INITCB)  (lua_State* );
typedef void(__stdcall* INITCB2)  (vm_ctx*);

int init_vmpool(GState* G, int num, uint8_t* code, int code_len, INITCB cb);
int init_vmpool2(GState* G, const char* callback, INITCB2 cb);
vm_ctx* acquire_vm(GState* G);
void release_vm(GState* G, vm_ctx* ctx);