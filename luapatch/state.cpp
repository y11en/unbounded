#include "state.hpp"
#include "helper.h"

namespace lua
{

	struct allocation_header
	{
		uint64_t size;

		static allocation_header* of(void* p) {
			return ((allocation_header*)p) - 1;
		}

		void* data() { return this + 1; }
		const void* data()  const { return this + 1; }

	};

	
	static void* allocator(void*, void* odata, size_t osize, size_t nsize)
	{

		// 释放内存
		if (!nsize)
		{
			if (osize) free(allocation_header::of(odata));
			return nullptr;
		}

		// 新的申请
		if (!odata)
		{
			return ((allocation_header*)(malloc(nsize + sizeof(allocation_header))))->data();
		}


		// 当前大小足够，直接返回原始buff
		allocation_header* hdr = allocation_header::of(odata);
		if (hdr->size >= nsize && nsize >= (hdr->size / 2))
			return odata;

		// realloc

#define max(x,y) ((x)>(y)?(x):(y))
#define min(x,y) ((x)>(y)?(y):(x))

		nsize = max(min(pow(nsize, 1.2), 4096), nsize);
		allocation_header* nhdr = (allocation_header*)malloc(nsize + sizeof(allocation_header));
		nhdr->size = nsize;

		memcpy(nhdr->data(), odata, min(osize, nsize));

		return nhdr->data();
	}

	static int panic(lua_State* L)
	{
		longjmp(get_context(L)->panic_jump, 1);
		return 0;
	}
	lua_State* init()
	{
		lua_State* L = lua_newstate(&allocator, new lua_context);
		if (!L) return nullptr;
		lua_atpanic(L, &panic);
		luaL_openlibs(L);
		return L;
	}

	void destroy(lua_State* L)
	{
		delete get_context(L);
		lua_close(L);
	}

	lua_context* get_context(lua_State* L)
	{
		void* ctx;
		lua_getallocf(L, &ctx);
		return (lua_context*)ctx;

	}

	void exec_string(lua_State* L, const char* buf)
	{
		size_t len = strlen(buf);
		if (!len) return;

		
		// 处理 lua panic, 默认的是exit
		
		if (setjmp(lua::get_context(L)->panic_jump) == 0)
		{
			if (luaL_loadbuffer(L, buf, len, "code"))
			{
				printf("代码解析错误: %s\n", lua_tostring(L, -1));
				return;
			}

			__try {

				if (lua_pcall(L, 0, 0, 0))
				{
					printf("代码执行错误: %s\n", lua_tostring(L, -1));
				}
			}
			__except (1)
			{
				printf("SEH错误: %x\n",GetExceptionCode());
			}

		}
		else
		{
			// 当返回1的时候 longjmp 这里
			printf("lua严重错误!");
		}
	
	}
}


// Some helpers we need in Lua style.
//
uintptr_t lua_asintrinsic(lua_State* L, int i)
{
	switch (lua_type(L, i))
	{
	case LUA_TSTRING:
		return (uintptr_t)lua_tostring(L, i);
	case LUA_TLIGHTUSERDATA:
	case LUA_TTABLE:
	case LUA_TFUNCTION:
	case LUA_TUSERDATA:
	case LUA_TTHREAD:
		return (uintptr_t)lua_topointer(L, i);
	case LUA_TNIL:
	case LUA_TBOOLEAN:
	case LUA_TNUMBER:
		return lua_tointeger(L, i);
	default:
		return (uintptr_t)lua_topointer(L, i);
	}
}

void* lua_adressof(lua_State* L, int i)
{
	switch (lua_type(L, i))
	{
	case LUA_TSTRING:
		return (void*)lua_tostring(L, i);
	case LUA_TLIGHTUSERDATA:
	case LUA_TTABLE:
	case LUA_TFUNCTION:
	case LUA_TUSERDATA:
	case LUA_TTHREAD:
		return (void*)lua_topointer(L, i);
	case LUA_TNIL:
	case LUA_TBOOLEAN:
	case LUA_TNUMBER:
		return 0;
	default:
		return (void*)lua_topointer(L, i);
	}
}


