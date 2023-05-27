#include "helper.h"
#include "Interceptor.h"
#include "Trace.hpp"

#include "luapool.h"



#define PBYTE unsigned char*

void* __stdcall CopyMemoryEx(void* Destination, const void* Source, size_t Length)
{
	PBYTE D = (PBYTE)Destination;
	PBYTE S = (PBYTE)Source;

	while (Length--)
		*D++ = *S++;

	return Destination;
}
char* __stdcall LoadFile(const TCHAR* filePath, unsigned int* fileSize)
{
	FILE* f = NULL;
	const char* s;
	unsigned t = 0;
	unsigned n = 0;
	//#ifndef _AMD64_
	//	PVOID OldValue;
	//	if (Wow64DisableWow64FsRedirection(&OldValue))
	//	{
	//#endif

#ifdef _MSC_VER
	_wfopen_s(&f, filePath, _T("rb"));
#else
	f = fopen(filePath, "rb");
#endif

	//#ifndef _AMD64_
	//		Wow64RevertWow64FsRedirection(OldValue);
	//	}
	//#endif

	if (!f)
	{
		return 0;
	}

	if (fseek(f, 0, SEEK_END) < 0)
	{
		fclose(f);
		return 0;
	}

	n = ftell(f);
	if (n < 0)
	{
		fclose(f);
		return 0;
	}

	if (fseek(f, 0, SEEK_SET) < 0)
	{
		fclose(f);
		return 0;
	}

	s = (const char*)malloc(n + 1);
	if (!s)
	{
		fclose(f);
		return 0;
	}

	t = fread((void*)s, 1, n, f);
	if (t != n)
	{
		free((void*)s);
		fclose(f);
		return 0;
	}

	if (fileSize)
		*fileSize = t;

	fclose(f);
	return (char*)s;
}
#ifndef _KERNEL_MODE
#define NtCurrentProcess() ((HANDLE)-1)
#define NtCurrentThread() ((HANDLE)-2)

static inline void* __teb()
{
#ifdef _AMD64_
	return (void*)__readgsqword(0x30);
#else
	return (void*)__readfsdword(0x18);
#endif
}

static inline void* __peb()
{
#ifdef _AMD64_
	return (void*)__readgsqword(0x60);
#else
	return (void*)__readfsdword(0x30);
#endif
}

static inline unsigned int __pid()
{
	// TEB::ClientId.UniqueProcessId:
#ifdef _AMD64_
	return *(unsigned int*)((unsigned char*)__teb() + 0x40);
#else
	return *(unsigned int*)((unsigned char*)__teb() + 0x20);
#endif
}

static inline unsigned int __tid()
{
	// TEB::ClientId.UniqueThreadId:
#ifdef _AMD64_
	return *(unsigned int*)((unsigned char*)__teb() + 0x48);
#else
	return *(unsigned int*)((unsigned char*)__teb() + 0x24);
#endif
}

#endif



void __stdcall EnumLdrDll(_EnumDllCallback ecb)
{
	PEB* peb = (PEB*)__peb();
	PLDR_DATA_TABLE_ENTRY pLdrDataEntry = NULL;
	PLIST_ENTRY pHeader = NULL;
	PLIST_ENTRY pCur = NULL;

	if (NULL == ecb)
		return;

	if (peb->LoaderLock)
		EnterCriticalSection(peb->LoaderLock);

	__try {
		pCur = peb->Ldr->InMemoryOrderModuleList.Flink;
		pHeader = &(peb->Ldr->InMemoryOrderModuleList);

		while (pCur != pHeader)
		{
			pLdrDataEntry = (PLDR_DATA_TABLE_ENTRY)CONTAINING_RECORD(pCur, LDR_DATA_TABLE_ENTRY, InMemoryOrderLinks);
			pCur = pCur->Flink;

			if (!ecb(pLdrDataEntry->DllBase, pLdrDataEntry->SizeOfImage, pLdrDataEntry->FullDllName.Buffer))
			{
				break;
			}
		}
	}
	__except (EXCEPTION_EXECUTE_HANDLER) {
	}

	if (peb->LoaderLock)
		LeaveCriticalSection(peb->LoaderLock);
}



//https://blog.csdn.net/libaineu2004/article/details/119393505
// std::wstring_convert()

std::wstring s2ws(std::string input)
{
	// std::wstring_convert<std::codecvt_utf8<wchar_t>> cvt;
	// return cvt.from_bytes(input);

	return Utils::AnsiToWstring(input);
}

std::string ws2s(std::wstring input)
{
	// std::wstring_convert<std::codecvt_utf8<wchar_t>> cvt;
	// return cvt.to_bytes(input);

	return Utils::WstringToAnsi(input);
}


static decltype(&RtlIpv6AddressToStringW) pfnRtlIpv6AddressToStringW = 0;
static decltype(&RtlIpv4AddressToStringW) pfnRtlIpv4AddressToStringW = 0;

PCWSTR _inet_ntopW(INT Family, const void* pAddr, PWSTR pStringBuf, ULONG StringBufSize)
{

	PWSTR p = NULL;
	if (Family == AF_INET6)
	{
		if (!pfnRtlIpv6AddressToStringW)
		{
			pfnRtlIpv6AddressToStringW = (decltype(&RtlIpv6AddressToStringW))
				GetProcAddress(LoadLibraryA("ntdll.dll"), "RtlIpv6AddressToStringW");
		}

		if (pfnRtlIpv6AddressToStringW)
		{
			return pfnRtlIpv6AddressToStringW((const struct in6_addr*)pAddr, pStringBuf);
		}
	}
	else
	{

		if (!pfnRtlIpv4AddressToStringW)
		{
			pfnRtlIpv4AddressToStringW = (decltype(&RtlIpv4AddressToStringW))
				GetProcAddress(LoadLibraryA("ntdll.dll"), "RtlIpv4AddressToStringW");
		}
		if (pfnRtlIpv4AddressToStringW)
		{
			return pfnRtlIpv4AddressToStringW((const struct in_addr*)pAddr, pStringBuf);
		}
	}
	return 0;
}


unsigned short __stdcall getAddressAndPortFromBuffer(BYTE* obuff, int szbuff, BYTE* buff)
{
	if (IsBadReadPtr(buff, sizeof(sockaddr)))
	{
		return 0;
	}

	sockaddr* sockAddr = (sockaddr*)(buff);
	wchar_t outStr[0x100] = { 0 };
	ULONG buff_sz = sizeof(outStr) / sizeof(outStr[0]);

	PCWSTR addrPtr = nullptr;
	unsigned short port = 0;
	switch (sockAddr->sa_family)
	{
	case AF_INET:
		addrPtr = _inet_ntopW(AF_INET, &(((struct sockaddr_in*)sockAddr)->sin_addr), &outStr[0], buff_sz);
		port = _byteswap_ushort(((struct sockaddr_in*)sockAddr)->sin_port);
		if (addrPtr)
		{
			int x = (lstrlenW(outStr) + 1) * 2;
			if (x < szbuff)
			{
				memcpy(obuff, outStr, x);
			}

		}

		break;
	case AF_INET6:
		addrPtr = _inet_ntopW(AF_INET6, &(((struct sockaddr_in6*)sockAddr)->sin6_addr), &outStr[0], buff_sz);
		port = _byteswap_ushort(((struct sockaddr_in6*)sockAddr)->sin6_port);
		if (addrPtr)
		{
			int x = (lstrlenW(outStr) + 1) * 2;
			if (x < szbuff)
			{
				memcpy(obuff, outStr, x);
			}
		}
		break;
	default:
		break;
	}
	return port;
}



pfnRpcBindingServerFromClient get_client = 0;
pfnRpcBindingToStringBindingA get_bindstr = 0;
pfnI_RpcServerInqRemoteConnAddress get_remoteaddr = 0;
pfnI_RpcServerInqLocalConnAddress get_local_addr = 0;
pfnRpcStringFree free_str = 0;
pfnUuidToStringA uuid_str = 0;
pfnRpcBindingFree free_bind = 0;
pfnRpcStringBindingParseA parse_bind = 0;

int __stdcall parse_rpcmsg(void* pArg)
{
	return 0;
}



void Var2Str(CComBSTR bstrName, CComVariant Value, CIMTYPE type, LONG lFlavor, std::vector<std::wstring>& wstrvec)
{
	wstrvec.push_back(bstrName.m_str);
	// wprintf(L"%s\t", bstrName.m_str);
	switch (Value.vt) {
	case VT_BSTR: {
		// wprintf(L"%s", Value.bstrVal);
		wstrvec.push_back(Value.bstrVal);
		break;
	}
	case VT_I1:
	case VT_I2:
	case VT_I4:
	case VT_I8:
	case VT_INT:
	{
		wstrvec.push_back(std::to_wstring(Value.intVal));
		// wprintf(L"%d", Value.intVal);
	}break;
	case VT_UI8:
	case VT_UI1:
	case VT_UI2:
	case VT_UI4:
	case VT_UINT:
	{
		wstrvec.push_back(std::to_wstring(Value.uintVal));
		// wprintf(L"0x%u", Value.intVal);
	}break;
	case VT_BOOL:
	{
		// wprintf(L"%s", Value.boolVal ? L"TRUE" : L"FASLE");
		wstrvec.push_back(Value.boolVal ? L"TRUE" : L"FASLE");
	}break;
	case VT_NULL:
	{
		wstrvec.push_back(L"V_NULL");
		break;
	}
	case VT_EMPTY:
	{
		wstrvec.push_back(L"V_EMPTY");
		break;
	}
	case VT_UNKNOWN:
	{
		wstrvec.push_back(L"V_UNKNOWN");
		break;
	}
	default:
		wstrvec.push_back(L"V_OTHERS");
		break;
	}
	// wprintf(L"\n");
}

//HRESULT DealWithUnknownTypeItem(CComBSTR bstrName, CComVariant Value, CIMTYPE type, LONG lFlavor)
//{
//	HRESULT hr = WBEM_S_NO_ERROR;
//	std::vector<std::wstring> args;
//	if (NULL == Value.punkVal) {
//		return hr;
//	}
//	// object类型转换成IWbemClassObject接口指针，通过该指针枚举其他属性
//	CComPtr<IWbemClassObject> pObjInstance = (IWbemClassObject*)Value.punkVal;
//	hr = pObjInstance->BeginEnumeration(WBEM_FLAG_LOCAL_ONLY);
//	do {
//
//		if (hr != WBEM_S_NO_ERROR) break;
//		
//		std::vector<std::wstring> wstrvec;
//		CComBSTR bstrNewName;
//		CComVariant NewValue;
//		CIMTYPE newtype;
//		LONG lnewFlavor = 0;
//		hr = pObjInstance->Next(0, &bstrNewName, &NewValue, &newtype, &lnewFlavor);
//		if (hr != WBEM_S_NO_ERROR) break;
//		Var2Str(bstrNewName, NewValue, newtype, lnewFlavor, wstrvec);
//
//	} while (WBEM_S_NO_ERROR == hr);
//	hr = pObjInstance->EndEnumeration();
//	return WBEM_S_NO_ERROR;
//}

int EnumIWbemClassObject(IWbemClassObject* pclsObj, std::vector<std::wstring>& args)
{
	HRESULT hr = WBEM_S_NO_ERROR;
	if (!pclsObj) return hr;

	YZMDD::DoTrace("%s IN ", __FUNCDNAME__);

	pclsObj->AddRef();
	hr = pclsObj->BeginEnumeration(WBEM_FLAG_LOCAL_ONLY);
	do
	{
		CComBSTR bstrName;
		CComVariant Value;
		CIMTYPE type;
		LONG lFlavor = 0;
		std::vector<std::wstring> wstrvec;
		hr = pclsObj->Next(0, &bstrName, &Value, &type, &lFlavor);
		if (hr != WBEM_S_NO_ERROR) break;

		Var2Str(bstrName, Value, type, lFlavor, wstrvec);

		YZMDD::DoTrace(L"[%s %s]", wstrvec[0].c_str(), wstrvec[1].c_str());

		args.insert(args.end(), wstrvec.begin(), wstrvec.end());
	} while (WBEM_S_NO_ERROR == hr);

	pclsObj->Release();

	YZMDD::DoTrace("%s OUT ", __FUNCDNAME__);

	return hr;
}


BOOL Var2Str(VARIANT* var, std::wstring& wstr)
{
	BOOL ret = TRUE;

	if (!var)
		return FALSE;

	switch (var->vt) {
	case VT_BSTR: {

		if (var->bstrVal)
		{
			wstr = var->bstrVal;
		}
		break;
	}
	case VT_I1:
	case VT_I2:
	case VT_I4:
	case VT_I8:
	case VT_INT:
	{
		wstr = std::to_wstring(var->intVal);
		break;
	}
	case VT_UI8:
	case VT_UI1:
	case VT_UI2:
	case VT_UI4:
	case VT_UINT:
	{
		wstr = std::to_wstring(var->uintVal);
		break;
	}
	case VT_BOOL:
	{
		wstr = var->boolVal ? L"TRUE" : L"FASLE";
		break;
	}
	case VT_NULL:
	{
		wstr = L"V_NULL";
		break;
	}
	case VT_EMPTY:
	{
		wstr = (L"V_EMPTY");
		break;
	}
	case VT_UNKNOWN:
	{
		wstr = L"V_UNKNOWN";
		break;
	}
	default:
		wstr = L"V_OTHERS";
		ret = FALSE;
		break;
	}

	YZMDD::DoTrace(L"%s [%d] %s", __FUNCTIONW__, ret, wstr.c_str());
	return ret;
}

int EnumDISPPARAMS(DISPPARAMS* params, std::vector<std::wstring>& wstrvec)
{
	if (params)
	{
		for (int i = 0; i < params->cArgs; ++i)
		{
			std::wstring wstr;
			Var2Str(&params->rgvarg[i], wstr);
			wstrvec.push_back(wstr);
		}
	}
	return 0;
}

uint64_t __stdcall GetTimeNow()
{
	FILETIME ft = { 0 };

	ULARGE_INTEGER ul = { 0 };
	::GetSystemTimeAsFileTime(&ft);

	ul.LowPart = ft.dwLowDateTime;
	ul.HighPart = ft.dwHighDateTime;

	// UTC 时间
	// SYSTEMTIME systemTime;
	// FileTimeToSystemTime(&ft, &systemTime);

	return ul.QuadPart;
}

/// <summary>
/// Convert ANSI string to wide char one
/// </summary>
/// <param name="input">ANSI string.</param>
/// <param name="locale">String locale</param>
/// <returns>wide char string</returns>
std::wstring Utils::AnsiToWstring(const std::string& input, DWORD locale /*= CP_ACP*/)
{
	wchar_t buf[2048] = { 0 };
	MultiByteToWideChar(locale, 0, input.c_str(), (int)input.length(), buf, ARRAYSIZE(buf));
	return buf;
}

/// <summary>
/// Convert wide char string to ANSI one
/// </summary>
/// <param name="input">wide char string.</param>
/// <param name="locale">String locale</param>
/// <returns>ANSI string</returns>
std::string Utils::WstringToAnsi(const std::wstring& input, DWORD locale /*= CP_ACP*/)
{
	char buf[2048] = { 0 };
	WideCharToMultiByte(locale, 0, input.c_str(), (int)input.length(), buf, ARRAYSIZE(buf), nullptr, nullptr);
	return buf;
}

/// <summary>
/// Convert UTF-8 string to wide char one
/// </summary>
/// <param name="str">UTF-8 string</param>
/// <returns>wide char string</returns>
std::wstring Utils::UTF8ToWstring(const std::string& str)
{
	return AnsiToWstring(str, CP_UTF8);
}

/// <summary>
/// Convert wide string to UTF-8
/// </summary>
/// <param name="str">Wide char string</param>
/// <returns>UTF-8 string</returns>
std::string Utils::WstringToUTF8(const std::wstring& str)
{
	return WstringToAnsi(str, CP_UTF8);
}
