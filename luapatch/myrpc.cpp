#include "myrpc_h.h"
#include <stdio.h>
#pragma comment( lib, "Rpcrt4.lib" )
#include "..\luapatch\locker.h"

#define printf(...)

#if _RPC_SERVER_

unsigned long __stdcall RpcSrvStart(const char* pszProtocolSequence, const char* pszEndPoint, BOOL fDontWait)
{
	/*
	// 注册，HelloWorld_v1_0_s_ifspec定义域头文件test.h
	// 注意：从Windows XP SP2开始，增强了安全性的要求，如果用RpcServerRegisterIf()注册接口，客户端调用时会出现
	// RpcExceptionCode() == 5，即Access Denied的错误，因此，必须用RpcServerRegisterIfEx带RPC_IF_ALLOW_CALLBACKS_WITH_NO_AUTH标志
	// 允许客户端直接调用
	RpcServerRegisterIfEx(HelloWorld_v1_0_s_ifspec, NULL, NULL, RPC_IF_ALLOW_CALLBACKS_WITH_NO_AUTH, 0, NULL);
	————————————————
	版权声明：本文为CSDN博主「王大地X」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
	原文链接：https://blog.csdn.net/herojuice/article/details/81015325
	*/
	unsigned char* pszSecurity = NULL;
	//#if 1   //local
	//    unsigned char pszProtocolSequence[] = "ncalrpc";
	//    // unsigned char pszEndPoint[] = "\\pipe\\RPCServer"; //命名管道，使用 ncacn_np
	//    unsigned char pszEndPoint[] = "Endpointer3"; //使用 ncalrpc
	//#else   //tcp-ip
	//    unsigned char pszProtocolSequence[] = "ncacn_ip_tcp";
	//    unsigned char pszEndPoint[] = "13521";
	//#endif

	unsigned long dwRet = 0;

	do
	{
		RPC_STATUS rpcStats = RpcServerUseProtseqEpA((RPC_CSTR)pszProtocolSequence, RPC_C_LISTEN_MAX_CALLS_DEFAULT, (RPC_CSTR)pszEndPoint, pszSecurity);
		printf("rpcStats=%d,RpcServerUseProtseqEp\n", rpcStats);
		if (rpcStats)
		{
			dwRet = rpcStats;
			break;
		}


		rpcStats = RpcServerRegisterIfEx(RPCServer_v1_0_s_ifspec, NULL, NULL, RPC_IF_ALLOW_CALLBACKS_WITH_NO_AUTH, 0, NULL);
		printf("rpcStats=%d,RpcServerRegisterIf\n", rpcStats);
		if (rpcStats)
		{
			dwRet = rpcStats;
			break;
		}

		// unsigned int fDontWait = TRUE;
		rpcStats = RpcServerListen(1, RPC_C_LISTEN_MAX_CALLS_DEFAULT, fDontWait);
		printf("rpcStats=%d,RpcServerListen\n", rpcStats);
		if (rpcStats)
		{
			dwRet = rpcStats;
			break;
		}
	} while (0);


	return dwRet;
}

#else

static CLock lock_rpc;
unsigned long __stdcall RpcSend(const char* pszProtocolSequence, const char* pszNetworkAddress, const char* pszEndpoint, char* buff, int sz)
{
	unsigned char* pszUuid = NULL;
	unsigned char* pszOptions = NULL;
	unsigned char* pszStringBinding = NULL;
	unsigned long ulCode = 0;
	MYSTRING* msg = NULL;

	//#if 1  //local
	//	unsigned char pszProtocolSequence[] = "ncalrpc";
	//	unsigned char* pszNetworkAddress = NULL;
	//	// unsigned char pszEndpoint[] = "\\pipe\\RPCServer"; //命名管道，使用 ncacn_np
	//	unsigned char pszEndpoint[] = "Endpointer3"; //使用 ncalrpc
	//#else  //tpc-ip
	//	unsigned char pszProtocolSequence[] = "ncacn_ip_tcp";
	//	unsigned char pszNetworkAddress[] = "192.168.111.141";
	//	unsigned char pszEndpoint[] = "13521";
	//#endif
	lock_rpc.Lock();
	do
	{

		RPC_STATUS rpcStatus = RpcStringBindingComposeA(pszUuid, (RPC_CSTR)pszProtocolSequence, (RPC_CSTR)pszNetworkAddress, (RPC_CSTR)pszEndpoint, pszOptions, &pszStringBinding);
		printf("rpcStats=%d,RpcStringBindingCompose\n", rpcStatus);
		if (rpcStatus)
		{
			ulCode = rpcStatus;
			break;
		}

		rpcStatus = RpcBindingFromStringBindingA(pszStringBinding, &RPCServer_v1_0_c_ifspec);
		printf("rpcStats=%d,RpcBindingFromStringBinding\n", rpcStatus);
		if (rpcStatus)
		{
			ulCode = rpcStatus;
			break;
		}

		DWORD off = offsetof(MYSTRING, string);

		msg = (MYSTRING*)malloc(sz + offsetof(MYSTRING, string));

		if (msg)
		{
			memset(msg, 0, sz + offsetof(MYSTRING, string));
			msg->size = sz;
			msg->length = sz;
			memcpy((char*)msg + offsetof(MYSTRING, string), buff, sz);

			{

				RpcTryExcept{
					rpc_Upload(RPCServer_v1_0_c_ifspec, msg);
				}
					RpcExcept(1)
				{
					ulCode = RpcExceptionCode();
					printf("thow exception: 0x%lx = %ld.\n", ulCode, ulCode);
				}
				RpcEndExcept
			}

			free(msg);
			msg = NULL;

		}

	} while (0);

	if (pszStringBinding)
		RpcStringFreeA(&pszStringBinding);

	RpcBindingFree(&RPCServer_v1_0_c_ifspec);

	if (msg)
	{
		free(msg);
	}

	lock_rpc.Unlock();
	return ulCode;
}

#endif // _RPC_SERVER_



void __RPC_FAR* __RPC_USER midl_user_allocate(size_t len)
{
	void* ret = malloc(len);
	if (ret)
	{
		memset(ret, 0, len);
	}
	return ret;
}
void __RPC_USER midl_user_free(void __RPC_FAR* ptr)
{
	free(ptr);
}
