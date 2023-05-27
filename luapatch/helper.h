#pragma once

#define _WIN32_DCOM
#include "phnt_windows.h"
#include <phnt.h>
#include <ks.h>
#include <tchar.h>
#include <string>
#include <WbemCli.h>
#include <comdef.h>
#include <atlcomcli.h>



#include <guiddef.h>
#include <stdio.h>
#include <tchar.h>
#include <stdlib.h>
#include <codecvt>
#include <ws2tcpip.h>
#include <stdint.h>
#include <vector>

#define RPC_STATUS long 
typedef RPC_STATUS(__stdcall* pfnRpcBindingServerFromClient)(void* ClientBinding, void** ServerBinding);
typedef RPC_STATUS(__stdcall* pfnRpcBindingToStringBindingA)(void* Binding, unsigned char** StringBinding);
typedef RPC_STATUS(__stdcall* pfnI_RpcServerInqRemoteConnAddress)(void* Binding, void* Buffer, unsigned long* BufferSize, unsigned long* AddressFormat);
typedef RPC_STATUS(__stdcall* pfnI_RpcServerInqLocalConnAddress)(void* Binding, void* Buffer, unsigned long* BufferSize, unsigned long* AddressFormat);
typedef RPC_STATUS(__stdcall* pfnRpcStringFree)(void*);
typedef RPC_STATUS(__stdcall* pfnUuidToStringA)(GUID* Uuid, unsigned char** StringUuid);
typedef RPC_STATUS(__stdcall* pfnRpcBindingFree)(void* Binding);

typedef
RPC_STATUS(__stdcall* pfnRpcStringBindingParseA)(
	char* StringBinding,
	char** ObjUuid,
	char** Protseq,
	char** NetworkAddr,
	char** Endpoint,
	char** NetworkOptions
	);



unsigned short __stdcall getAddressAndPortFromBuffer(BYTE* obuff, int szbuff, BYTE* buff);

extern "C"
{
    void* __stdcall CopyMemoryEx(void* Destination, const void* Source, size_t Length);

}

char* __stdcall LoadFile(const TCHAR* filePath, unsigned int* fileSize);
typedef bool(__stdcall* _EnumDllCallback)(void* start, ULONG size, const wchar_t* path);
void __stdcall EnumLdrDll(_EnumDllCallback ecb);

std::string ws2s(std::wstring input);
std::wstring s2ws(std::string input);

int __stdcall parse_rpcmsg(void* pArg);
void DbgMsg(const char* msg);

int EnumIWbemClassObject(IWbemClassObject* pclsObj, std::vector<std::wstring>& args);
int EnumDISPPARAMS(DISPPARAMS* params, std::vector<std::wstring>& wstrvec);
BOOL Var2Str(VARIANT* var, std::wstring& wstr);

uint64_t __stdcall GetTimeNow();


namespace Utils
{
#define BLACKBONE_API
    /// <summary>
      /// Convert UTF-8 string to wide char one
      /// </summary>
      /// <param name="str">UTF-8 string</param>
      /// <returns>wide char string</returns>
    BLACKBONE_API std::wstring UTF8ToWstring(const std::string& str);

    /// <summary>
    /// Convert wide string to UTF-8
    /// </summary>
    /// <param name="str">UTF-8 string</param>
    /// <returns>wide char string</returns>
    BLACKBONE_API std::string WstringToUTF8(const std::wstring& str);

    /// <summary>
    /// Convert ANSI string to wide char one
    /// </summary>
    /// <param name="input">ANSI string.</param>
    /// <param name="locale">String locale</param>
    /// <returns>wide char string</returns>
    BLACKBONE_API std::wstring AnsiToWstring(const std::string& input, DWORD locale = CP_ACP);

    /// <summary>
    /// Convert wide char string to ANSI one
    /// </summary>
    /// <param name="input">wide char string.</param>
    /// <param name="locale">String locale</param>
    /// <returns>ANSI string</returns>
    BLACKBONE_API std::string WstringToAnsi(const std::wstring& input, DWORD locale = CP_ACP);
};