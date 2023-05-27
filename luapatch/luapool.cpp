#include "luapool.h"
#include "Interceptor.h"
#include <Windows.h>


int init_vmpool(GState* G, int num, uint8_t* code, int code_len, INITCB cb)
{
	// extern GState G;

	for (int i = 0; i < num; ++i)
	{
		lua_State* L = luaL_newstate();
		vm_ctx* ctx = (vm_ctx*)malloc(sizeof(*ctx));
		if (ctx)
		{
			memset(ctx, 0, sizeof(*ctx));
			ctx->L = L;

			if (cb) cb(L);
			
			// init_libs(L);
			
			if (LUA_OK == luaL_loadbuffer(L, (const char*)code, code_len, "") && LUA_OK == lua_pcall(L, 0, 0, 0))
			{
				// printf("初始化成功 %p\n", ctx);
				G->free_list.push_back(ctx);
			}
			else
			{
				printf("错误=%s\n", lua_tostring(L, -1));
			}
		}
	}
	return 0;
}

int init_vmpool2(GState* G, const char* callback, INITCB2 cb)
{
	vm_ctx* ctx = NULL;
	// extern GState G;
	int err = 0;

	// std::unique_lock<std::mutex> lock(G.mut_free);

	G->lock_free.Lock();
	if (G->free_list.size() > 0)
	{
		for (auto x : G->free_list)
		{
			ctx = x;
			
			if (callback)
			{
				lua_getglobal(ctx->L, callback);
				if (lua_isfunction(ctx->L, -1))
				{
					ctx->reg_idx_cb = luaL_ref(ctx->L, LUA_REGISTRYINDEX);
				}
				else {
					// printf("获取回调函数失败\n");
					err = 1;
				}
				lua_settop(ctx->L, 0);
			}

			if (cb)
			{
				cb(ctx);
			}
		}
	}
	G->lock_free.Unlock();
	return err;
}

vm_ctx* acquire_vm(GState* G)
{
	vm_ctx* ctx = NULL;
	bool found = false;

	if (!G) return NULL;

	do {
		G->lock_free.Lock();

		if (G->free_list.size() > 0)
		{
			for (auto x : G->free_list)
			{
				ctx = x;
				found = true;
				break;
			}
			if (ctx)
				G->free_list.remove(ctx);
		}

		G->lock_free.Unlock();
		Sleep(0);
	} while (!found);
	{

		G->lock_buzy.Lock();
		G->buzy_list.push_back(ctx);
		G->lock_buzy.Unlock();
	}

	// printf("\n--申请成功--\n");
	return ctx;
}

void release_vm(GState* G, vm_ctx* ctx)
{
	if (G && ctx)
	{
		{

			G->lock_buzy.Lock();
			G->buzy_list.remove(ctx);
			G->lock_buzy.Unlock();
		}
		{

			G->lock_free.Lock();
			G->free_list.push_back(ctx);
			G->lock_free.Unlock();
		}
	}
	// printf("\n--释放成功--\n");
}