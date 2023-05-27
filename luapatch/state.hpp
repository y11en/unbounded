#pragma once

#include "one.h"
#include <setjmp.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>

#include "..\LuaJIT\src\lua.hpp"
namespace lua
{
	struct lua_context
	{
		jmp_buf panic_jump = {};
	};

	lua_State* init();
	void destroy(lua_State* L);
	lua_context* get_context(lua_State* L);
	void exec_string(lua_State* L, const char* buf);
};

uintptr_t lua_asintrinsic(lua_State* L, int i);
void* lua_adressof(lua_State* L, int i);
