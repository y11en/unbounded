#pragma once



unsigned long __stdcall RpcSrvStart(const char* pszProtocolSequence, const char* pszEndPoint, BOOL fDontWait);
unsigned long __stdcall RpcSend(const char* pszProtocolSequence, const char* pszNetworkAddress, const char* pszEndpoint, char* buff, int sz);