#pragma once
#include "state.hpp"

struct native_function
{
	static constexpr const char* export_name = "native_function";
	const void* address = nullptr;

	static int create(lua_State* L);
	static native_function* push(lua_State* L);
	static native_function* check(lua_State* L, int index);


	static int get_address(lua_State* L);
	// static int invoke(lua_State* L);
	static int to_string(lua_State* L);

	// 注册表
	static void declare(lua_State* L)
	{
		static const luaL_Reg method_table[] = {
			{"new", create},
			{"address", get_address},
			{nullptr, nullptr}
		};

		static const luaL_Reg metatable[] = {
			{"__tostring", to_string},
		// 	{"__call", invoke},
			{nullptr, nullptr}
		};

		
		luaL_newmetatable(L, export_name);	

		lua_pushliteral(L, "__index");		// metatable.__index
		lua_pushvalue(L, -2);				// metatable
		lua_rawset(L, -3);					// metatable.__index = metatable

		lua_pushliteral(L, "__metatable");
		lua_pushvalue(L, -2);
		lua_rawset(L, -3);					// metatable.__metatable = metatable

		luaL_setfuncs(L, metatable, 0);		// export_name = metatable


			// 5.2 + 替换方案
			lua_getglobal(L, export_name);
			if (lua_isnil(L, -1))
			{
				lua_pop(L, 1);
				lua_newtable(L);
			}
			luaL_setfuncs(L, method_table, 0);
			lua_setglobal(L, export_name);	// 全局方法


		
		lua_pop(L, 1);

	}


};