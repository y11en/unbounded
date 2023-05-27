local ffi = require 'ffi'
local stdapi = {}

-- hook 列表
local ntapi = {}

ffi.cdef [[
typedef unsigned int UINT;
typedef const char* LPCSTR;
typedef const char* PCSTR;
typedef void* HMODULE;
typedef const wchar_t* LPCWSTR;
typedef wchar_t* LPWSTR;
typedef wchar_t* PWSTR;
typedef wchar_t WSTR;
typedef unsigned long ULONG;
typedef long RPC_STATUS;
typedef unsigned char BYTE;
typedef uintptr_t ULONG_PTR;
typedef int  BOOL;
typedef long NTSTATUS;
typedef void* HANDLE;
typedef intptr_t SIZE_T;
typedef unsigned long       DWORD;
typedef long HRESULT;
typedef void* (__cdecl *_malloc)(size_t);
typedef void (__cdecl *_free)(void*);
typedef void* LPVOID;


typedef char CCHAR;
typedef short CSHORT;
typedef ULONG CLONG;

typedef CCHAR *PCCHAR;
typedef CSHORT *PCSHORT;
typedef CLONG *PCLONG;

typedef PCSTR PCSZ;

typedef UINT (__stdcall *pfWinExec)(
  LPCSTR lpCmdLine,
  UINT   uCmdShow
);

typedef NTSTATUS (__stdcall* pfnNtClose)(HANDLE Handle);

UINT __stdcall WinExec(
  LPCSTR lpCmdLine,
  UINT   uCmdShow
);

intptr_t LoadLibraryA(
  LPCSTR lpLibFileName
);

intptr_t GetProcAddress(
  HMODULE hModule,
  LPCSTR  lpProcName
);

void OutputDebugStringA(
  LPCSTR lpOutputString
);



bool ReadProcessMemory(
  HANDLE  	hProcess,
  intptr_t  lpBaseAddress,
  intptr_t  lpBuffer,
  SIZE_T  	nSize,
  SIZE_T*   lpNumberOfBytesRead
);

typedef  uint64_t* (__stdcall *pfnStackTrace)(void* ptr, uintptr_t ip, uintptr_t sp, int limit, int aframes);
typedef int  (__stdcall *pfnattach)(void* address);
typedef int  (__stdcall *pfnattach_name)(void* address, const char* name);


typedef int (__stdcall *pfnis_invalid_ptr)(void* ptr);
typedef int (__stdcall *pfnlstrlenW)(LPCWSTR lpString);

typedef bool(__stdcall* _EnumDllCallback)(void* start, ULONG size, const wchar_t* path);
typedef void (__stdcall *pfnEnumLdrDll)(_EnumDllCallback ecb);
	
// ----------------------------- RPC ----------------------------------
typedef struct _GUID {
    unsigned long  Data1;
    unsigned short Data2;
    unsigned short Data3;
    unsigned char  Data4[ 8 ];
} GUID;

typedef struct _RPC_VERSION {
	unsigned short MajorVersion;
	unsigned short MinorVersion;
} RPC_VERSION;

typedef struct _RPC_SYNTAX_IDENTIFIER {
	GUID SyntaxGUID;
	RPC_VERSION SyntaxVersion;
} RPC_SYNTAX_IDENTIFIER, *PRPC_SYNTAX_IDENTIFIER;

typedef void(__stdcall * RPC_DISPATCH_FUNCTION) (void* Message);

typedef struct {
    unsigned int DispatchTableCount;
    RPC_DISPATCH_FUNCTION* DispatchTable;
    void*        Reserved;
} RPC_DISPATCH_TABLE, *PRPC_DISPATCH_TABLE;

typedef struct _RPC_PROTSEQ_ENDPOINT
{
    unsigned char  * RpcProtocolSequence;
    unsigned char  * Endpoint;
} RPC_PROTSEQ_ENDPOINT, * PRPC_PROTSEQ_ENDPOINT;



typedef long (__stdcall* SERVER_ROUTINE)();

/*
 * Stub thunk used for some interpreted server stubs.
 */
typedef void (__stdcall* STUB_THUNK)(void*);

/*
 * Server Interpreter's information strucuture.
 */
typedef struct  _MIDL_SERVER_INFO_
{
	void* pStubDesc;
	const SERVER_ROUTINE* DispatchTable;
	void* ProcString;
	const unsigned short* FmtStringOffset;
	const STUB_THUNK* ThunkTable;
	PRPC_SYNTAX_IDENTIFIER    pTransferSyntax;
	ULONG_PTR                 nCount;
	void* pSyntaxInfo;
} MIDL_SERVER_INFO, * PMIDL_SERVER_INFO;

typedef struct _RPC_SERVER_INTERFACE
{
	unsigned int Length;
	RPC_SYNTAX_IDENTIFIER InterfaceId;
	RPC_SYNTAX_IDENTIFIER TransferSyntax;
	PRPC_DISPATCH_TABLE DispatchTable;
	unsigned int RpcProtseqEndpointCount;
	PRPC_PROTSEQ_ENDPOINT RpcProtseqEndpoint;
	void* DefaultManagerEpv;
	PMIDL_SERVER_INFO InterpreterInfo;		// <---------
	unsigned int Flags;
} RPC_SERVER_INTERFACE, * PRPC_SERVER_INTERFACE;

typedef struct _RPC_MESSAGE
{
	void* Handle;
	unsigned long DataRepresentation;
	void * Buffer;
	unsigned int BufferLength;
	unsigned int ProcNum;
	PRPC_SYNTAX_IDENTIFIER TransferSyntax;
	void * RpcInterfaceInformation;
	void * ReservedForRuntime;
	void* ManagerEpv;
	void * ImportContext;
	unsigned long RpcFlags;
} RPC_MESSAGE, *PRPC_MESSAGE;

// OLE 消息的 RPC_MESSAGE 实体
typedef ULONG RPCOLEDATAREP;
typedef struct tagRPCOLEMESSAGE
    {
    void *reserved1;				// CAsyncCall
    RPCOLEDATAREP dataRepresentation;
    void *Buffer;
    ULONG cbBuffer;
    ULONG iMethod;
    void *reserved2[ 5 ];  // reserved2[1] 指向 GUID
    ULONG rpcFlags;
    } 	RPCOLEMESSAGE;

typedef RPCOLEMESSAGE *PRPCOLEMESSAGE;

 typedef struct tagMInterfacePointer {
   unsigned long ulCntData;
   /*[size_is(ulCntData)]*/ BYTE abData[];
 } MInterfacePointer, *PMInterfacePointer;

typedef void(__stdcall *pfnNdr64AsyncServerCall64)(PRPC_MESSAGE pRpcMsg);
typedef void(__stdcall *pfnNdr64AsyncServerCallAll)(PRPC_MESSAGE pRpcMsg);
typedef void(__stdcall *pfnNdrAsyncServerCall)(PRPC_MESSAGE pRpcMsg);
typedef long(__stdcall *pfnNdrStubCall2)(
		void* pThis,                // struct IRpcStubBuffer
		void* pChannel,             // struct IRpcChannelBuffer
		PRPC_MESSAGE                pRpcMsg,
		unsigned long*              pdwStubPhase
		);
typedef void(__stdcall *pfnNdrServerCallAll)(PRPC_MESSAGE pRpcMsg);
typedef void(__stdcall *pfnNdrServerCallNdr64)(PRPC_MESSAGE pRpcMsg);
typedef RPC_STATUS (__stdcall *pfnRpcBindingServerFromClient)(void* ClientBinding, void** ServerBinding);
typedef RPC_STATUS (__stdcall *pfnRpcBindingToStringBindingA)( void* Binding, unsigned char ** StringBinding);
typedef RPC_STATUS (__stdcall *pfnI_RpcServerInqRemoteConnAddress)(void* Binding,void* Buffer,unsigned long* BufferSize, unsigned long* AddressFormat);
typedef RPC_STATUS (__stdcall *pfnI_RpcServerInqLocalConnAddress)(void* Binding,void* Buffer,unsigned long* BufferSize, unsigned long* AddressFormat);
typedef RPC_STATUS(__stdcall* pfnRpcBindingFree)(void* Binding);

typedef RPC_STATUS (__stdcall *pfnRpcStringFree)( void* );
typedef RPC_STATUS (__stdcall *pfnUuidToStringA)(GUID *Uuid, unsigned char* *StringUuid);

typedef int (__stdcall *pfnparse_rpcmsg)(void*);
typedef unsigned short (__stdcall *pfngetAddressAndPortFromBuffer)(BYTE* obuff, int szbuff, BYTE* buff);



typedef enum tagRpcCallType
{
    rctInvalid = 0,
    rctNormal,
    rctTraining,
    rctGuaranteed
} RpcCallType;

typedef enum tagRpcLocalAddressFormat
{
    rlafInvalid = 0,
    rlafIPv4,
    rlafIPv6
} RpcLocalAddressFormat;

typedef struct _RPC_CALL_LOCAL_ADDRESS_V1
{
    unsigned int Version;
    void* Buffer;
    unsigned long BufferSize;
    RpcLocalAddressFormat AddressFormat;
} RPC_CALL_LOCAL_ADDRESS_V1, * PRPC_CALL_LOCAL_ADDRESS_V1;

typedef struct tagRPC_CALL_ATTRIBUTES_V2_A {
    unsigned int              Version;
    unsigned long             Flags;
    unsigned long             ServerPrincipalNameBufferLength;
    unsigned char*            ServerPrincipalName;
    unsigned long             ClientPrincipalNameBufferLength;
    unsigned char*            ClientPrincipalName;
    unsigned long             AuthenticationLevel;
    unsigned long             AuthenticationService;
    BOOL                      NullSession;
    BOOL                      KernelModeCaller;
    unsigned long             ProtocolSequence;
    unsigned long             IsClientLocal;
    HANDLE                    ClientPID;
    unsigned long             CallStatus;
    RpcCallType               CallType;
    RPC_CALL_LOCAL_ADDRESS_V1* CallLocalAddress;
    unsigned short            OpNum;
    GUID                      InterfaceUuid;
} RPC_CALL_ATTRIBUTES_V2_A;

typedef struct _CLIENT_ID
{
    HANDLE UniqueProcess;
    HANDLE UniqueThread;
} CLIENT_ID, *PCLIENT_ID;


typedef enum tagIPCCallType
{
    ctNoReply = 0,
    ctNeedReply = 1,
} RpcCallType;

typedef struct _PORT_MESSAGE
{
    union
    {
        struct
        {
            CSHORT DataLength;
            CSHORT TotalLength;
        } s1;
        ULONG Length;
    } u1;
    union
    {
        struct
        {
            CSHORT Type;
            CSHORT DataInfoOffset;
        } s2;
        ULONG ZeroInit;
    } u2;
    union
    {
        CLIENT_ID ClientId;
        double DoNotUseThisField;
    };
    ULONG MessageId;
    union
    {
        SIZE_T ClientViewSize; // only valid for LPC_CONNECTION_REQUEST messages
        ULONG CallbackId; // only valid for LPC_REQUEST messages
    };
} PORT_MESSAGE, *PPORT_MESSAGE;


typedef
RPC_STATUS (__stdcall *pfnRpcServerInqCallAttributesA)(
    void* ClientBinding,
    void* RpcCallAttributes
);


typedef
unsigned long (__stdcall *pfnRpcSend)(const char* pszProtocolSequence, const char* pszNetworkAddress, const char* pszEndpoint, char* buff, int sz);

// ----------------------------- RPC ----------------------------------


typedef 
RPC_STATUS (__stdcall *pfnI_RpcOpenClientThread)( void* ClientBinding, unsigned int DesiredAccess, HANDLE*);
typedef
RPC_STATUS
( __stdcall *pfnI_RpcOpenClientProcess)(void* ClientBinding, unsigned int DesiredAccess, HANDLE*);


typedef DWORD (__stdcall *pfnGetProcessId)(
  HANDLE Process
);

typedef DWORD (__stdcall *pfnGetThreadId)(
  HANDLE Thread
);

typedef DWORD (__stdcall *pfnGetCurrentThreadId)(void);
typedef DWORD (__stdcall *pfnGetCurrentProcessId)(void);

// ------------------------------ 远程服务 ------------------------------


typedef RPC_STATUS (__stdcall *pfnRpcBindingInqObject)(void* Binding,GUID *ObjectUuid);
typedef unsigned int (__stdcall *pfnCoGetCallerTID)(DWORD* lpdwTID);

typedef RPC_STATUS ( __stdcall *pfnI_RpcBindingInqLocalClientPID)(void* Binding, DWORD* Pid);


// ------------------------------ 远程服务 ------------------------------


typedef HRESULT(__stdcall* pfnDllGetClassObject)(GUID* rclsid, GUID*  riid, LPVOID* ppv);
typedef HRESULT(__stdcall* pfnQueryInterface)(void* _this, GUID* iid, LPVOID* ppv);
typedef HRESULT(__stdcall* pfnCCF_CreateInstance)(void* _this, GUID* rclsid, GUID*  iid, LPVOID* ppv);

typedef HRESULT (__stdcall* pfnRelease)(void* _this);

typedef bool (__stdcall *pfnAddressHasHooked)(void* p);

typedef uint64_t (__stdcall* pfnGetTimeNow)();
]]

local function uuidstr(uuid)
    local ret = ffi.new('unsigned char*[1]')
    if ret and stdapi.UuidToStringA(uuid, ret) == 0 then
        if not stdapi.badptr(ret[0]) then
            local s = ffi.string(ret[0])
            stdapi.RpcStringFree(ret)
            return s
        end
    end
end

local Interceptor = {}
Interceptor.hook = ffi.cast('pfnattach', _attach)
Interceptor.hookname = ffi.cast('pfnattach_name', _attach_name)



local function install_hookname(address, name)
    address = ffi.cast('void*', address)
    local status = Interceptor.hookname(address, name)
    print("install " .. tostring(name) .. ' ' .. tostring(address) .. ' =' .. tostring(status))
    return status
end

local function install_hook(address)
    address = ffi.cast('void*', address)
    local status = Interceptor.hook(address)
    print("install " .. tostring(address) .. ' =' .. tostring(status))
    return status
end

local function uninstall_hook(address)
    address = ffi.cast('void*', address)
    return Interceptor.unhook(address)
end

local k32 = ffi.cast('intptr_t*', ffi.C.LoadLibraryA('kernel32.dll'))
local ntdll = ffi.cast('intptr_t*', ffi.C.LoadLibraryA('ntdll.dll'))
local sl32 = ffi.cast('intptr_t*', ffi.C.LoadLibraryA('shell32.dll'))
local rpcrt4 = ffi.cast('intptr_t*', ffi.C.LoadLibraryA('rpcrt4.dll'))
local ole32 = ffi.cast('intptr_t*', ffi.C.LoadLibraryA('ole32.dll'))

stdapi = {
    malloc = ffi.cast('_malloc', _malloc),
    free = ffi.cast('_free', _free),
    stacktrace = ffi.cast('pfnStackTrace', _stacktrace),
    strlenW = ffi.cast('pfnlstrlenW', _lstrlen_w),
    ws2s = WS2S,
    addr2str = ffi.cast('pfngetAddressAndPortFromBuffer', _addr2str),
    -- badptr = ffi.cast('pfnis_invalid_ptr', _is_invalid_ptr),
    enumldr = ffi.cast('pfnEnumLdrDll', _enumldrdll),
    parse_rpcmsg = ffi.cast('pfnparse_rpcmsg', _parse_rpcmsg),
    check_hook = ffi.cast('pfnAddressHasHooked', _check_hook),
    enumwo = _enumwobj, -- WMI 参数枚举 EnumIWbemClassObject
    enumdisp = _enumdisp, -- disp 参数枚举
    dump_var = _dump_var, -- VARIANT 转换 字符串
  
    pack = _pack,   -- 序列化 lua
    unpack = _unpack, -- 反序列化
    unpack_revome = _unpack_revome, --反序列化并且释放内存buff
    pack_free = _pack_free, -- 只释放内存buff
    time = ffi.cast('pfnGetTimeNow', _time),
    send = ffi.cast('pfnRpcSend', _send),

    ntclose = ffi.cast('pfnNtClose', ffi.C.GetProcAddress(ntdll, 'NtClose')),

    

    -- RPC
    RpcBindingServerFromClient = ffi.cast('pfnRpcBindingServerFromClient',
        ffi.C.GetProcAddress(rpcrt4, 'RpcBindingServerFromClient')),

    RpcBindingToStringBindingA = ffi.cast('pfnRpcBindingToStringBindingA',
        ffi.C.GetProcAddress(rpcrt4, 'RpcBindingToStringBindingA')),

    I_RpcServerInqRemoteConnAddress = ffi.cast('pfnI_RpcServerInqRemoteConnAddress',
        ffi.C.GetProcAddress(rpcrt4, 'I_RpcServerInqRemoteConnAddress')),

    I_RpcServerInqLocalConnAddress = ffi.cast('pfnI_RpcServerInqLocalConnAddress',
        ffi.C.GetProcAddress(rpcrt4, 'I_RpcServerInqLocalConnAddress')),

    I_RpcOpenClientThread = ffi.cast('pfnI_RpcOpenClientThread', ffi.C.GetProcAddress(rpcrt4, 'I_RpcOpenClientThread')),

    I_RpcOpenClientProcess = ffi.cast('pfnI_RpcOpenClientProcess',
        ffi.C.GetProcAddress(rpcrt4, 'I_RpcOpenClientProcess')),

    GetProcessId = ffi.cast('pfnGetProcessId', ffi.C.GetProcAddress(k32, 'GetProcessId')),
    GetThreadId = ffi.cast('pfnGetThreadId', ffi.C.GetProcAddress(k32, 'GetThreadId')),

    GetCurrentThreadId = ffi.cast('pfnGetCurrentThreadId', ffi.C.GetProcAddress(k32, 'GetCurrentThreadId')),
    GetCurrentProcessId = ffi.cast('pfnGetCurrentProcessId', ffi.C.GetProcAddress(k32, 'GetCurrentProcessId')),

    UuidToStringA = ffi.cast('pfnUuidToStringA', ffi.C.GetProcAddress(rpcrt4, 'UuidToStringA')),
    RpcStringFree = ffi.cast('pfnRpcStringFree', ffi.C.GetProcAddress(rpcrt4, 'RpcStringFreeA')),
    RpcBindingFree = ffi.cast('pfnRpcBindingFree', ffi.C.GetProcAddress(rpcrt4, 'RpcBindingFree')),
    RpcServerInqCallAttributesA = ffi.cast('pfnRpcServerInqCallAttributesA',
        ffi.C.GetProcAddress(rpcrt4, 'RpcServerInqCallAttributesA')),
    RpcBindingInqObject = ffi.cast('pfnRpcBindingInqObject', ffi.C.GetProcAddress(rpcrt4, 'RpcBindingInqObject')),

    CoGetCallerTID = ffi.cast('pfnCoGetCallerTID', ffi.C.GetProcAddress(ole32, 'CoGetCallerTID')),
    I_RpcBindingInqLocalClientPID = ffi.cast('pfnI_RpcBindingInqLocalClientPID',
        ffi.C.GetProcAddress(rpcrt4, 'I_RpcBindingInqLocalClientPID')),



}

local function do_wmi_hook()
    -- WMI HOOK , 走的OLE通道
    local wmi_framedynos_dll_vt_IWbemServices_exportname = "??_7CWbemProviderGlue@@6BIWbemServices@@@"

    local framedynos = ffi.cast('intptr_t*', ffi.C.LoadLibraryA('framedynos.dll'))
    local vt_IWbemServices = ffi.C.GetProcAddress(framedynos, wmi_framedynos_dll_vt_IWbemServices_exportname)

    if vt_IWbemServices then

        local vt = ffi.cast('uintptr_t*', vt_IWbemServices)

        if vt then
            local id_GetObjectAsync = 7
            local id_PutInstanceAsync = 15
            local id_DeleteInstanceAsync = 17
            local id_CreateInstanceEnumAsync = 19
            local id_ExecQueryAsync = 21
            local id_ExecMethodAsync = 25

            install_hookname(vt[id_GetObjectAsync], "IWbemServices::GetObjectAsync")
            install_hookname(vt[id_PutInstanceAsync], "IWbemServices::PutInstanceAsync")
            install_hookname(vt[id_DeleteInstanceAsync], "IWbemServices::DeleteInstanceAsync")
            install_hookname(vt[id_CreateInstanceEnumAsync], "IWbemServices::CreateInstanceEnumAsync")
            install_hookname(vt[id_ExecQueryAsync], "IWbemServices::ExecQueryAsync")
            install_hookname(vt[id_ExecMethodAsync], "IWbemServices::ExecMethodAsync")
        end
    end
end

local function do_shell_dispatch_hook()
    local shell32 = ffi.cast('intptr_t*', ffi.C.LoadLibraryA('shell32.dll'))
    local DllGetClassObject = ffi.cast('pfnDllGetClassObject', ffi.C.GetProcAddress(shell32, "DllGetClassObject"))

    local CLSID_Shell = ffi.new('GUID[1]',
        {{0x13709620, 0xC279, 0x11CE, {0xa4, 0x9e, 0x44, 0x45, 0x53, 0x54, 0x0, 0x0}}})
    local IID_IDispatch = ffi.new('GUID[1]', {{0x00020400, 0x0000, 0x0000, {0xc0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x46}}}) -- IID_IDispatch

    local IID_IDispatch2 = ffi.new('GUID[1]',
        {{0xA4C6892C, 0x3BA9, 0x11d2, {0x9d, 0xea, 0x0, 0xc0, 0x4f, 0xb1, 0x61, 0x62}}}) -- IID_IDispatch2

    local IID_IClassFactory = ffi.new('GUID[1]',
        {{0x00000001, 0x0000, 0x0000, {0xc0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x46}}})

    local obj = ffi.new('uintptr_t[1]')
    local vt = ffi.new('uintptr_t[1]')
    local vt2 = ffi.new('uintptr_t[1]')
    local vt3 = ffi.new('uintptr_t[1]')

    if obj and DllGetClassObject and vt and CLSID_Shell and IID_IDispatch and IID_IClassFactory and IID_IDispatch2 and
        vt2 and vt3 then

        local status = DllGetClassObject(CLSID_Shell, IID_IClassFactory, ffi.cast('void**', obj))
        if 0 == status then
            print(DllGetClassObject, CLSID_Shell, IID_IDispatch, IID_IClassFactory, obj, obj[0])

            -- 获取 VT[0] 就是 QueryInterface 接口
            local ccf_obj = ffi.cast('uintptr_t*', obj[0])
            local ccf_vt = ffi.cast('uintptr_t*', ccf_obj[0])

            --[[

		shell32 里
.rdata:000000000046B8E0 c_CFVtbl        dq offset CCF_QueryInterface
.rdata:000000000046B8E0                                         ; DATA XREF: .rdata:c_clsmap↑o
.rdata:000000000046B8E0                                         ; .rdata:00000000004686A0↑o ...
.rdata:000000000046B8E8                 dq offset ?AddRef@CMVPRichEditOleCallback@@UEAAKXZ ; CMVPRichEditOleCallback::AddRef(void)
.rdata:000000000046B8F0                 dq offset ?AppliesTo@CQueueItem@@UEAAJPEAUIUnknown@@@Z ; CQueueItem::AppliesTo(IUnknown *)
.rdata:000000000046B8F8                 dq offset CCF_CreateInstance
.rdata:000000000046B900                 dq offset ?DragLeave@CAutoPlayVerb@@UEAAJXZ ; CAutoPlayVerb::DragLeave(void)

			]]
            local CCF_CreateInstance = ffi.cast('pfnCCF_CreateInstance', ccf_vt[3])

            if CCF_CreateInstance then

                status = CCF_CreateInstance(ccf_obj, nil, IID_IDispatch, ffi.cast('void**', vt))

                local _this = ffi.cast('uintptr_t*', vt[0])
                if status == 0 and not stdapi.badptr(_this) then
                    -- VT = this[0]
                    vt2 = ffi.cast('uintptr_t*', _this[0])

                    print('vt2=', vt2, _this)

                    if status == 0 then
                        local id_GetTypeInfoCount = 3
                        local id_GetTypeInfo = 4
                        local id_GetIDsOfNames = 5
                        local id_Invoke = 6

                        local QueryInterface = ffi.cast('pfnQueryInterface', vt2[0])
                        -- local Release1 = ffi.cast('pfnRelease', vt[2])

                        install_hookname(vt2[id_GetTypeInfoCount], "IDispatch::GetTypeInfoCount")
                        install_hookname(vt2[id_GetTypeInfo], "IDispatch::GetTypeInfo")
                        install_hookname(vt2[id_GetIDsOfNames], "IDispatch::GetIDsOfNames")
                        install_hookname(vt2[id_Invoke], "IDispatch::Invoke")

                        status = QueryInterface(_this, IID_IDispatch2, ffi.cast('void**', vt3))

                        if status == 0 then

                            -- Release()

                            print('vt3=', vt3)

                            local obj = ffi.cast('uintptr_t*', vt3[0])

                            -- VT = this[0]
                            vt3 = ffi.cast('uintptr_t*', obj[0])

                            -- local Release2 = ffi.cast('pfnRelease', vt3[2])
                            -- Release2(obj)

                            local id_Open = 12
                            local id_FileRun = 16
                            local id_ShellExecuteW = 31

                            install_hookname(vt3[id_Open], "IDispatch::Open")
                            install_hookname(vt3[id_FileRun], "IDispatch::FileRun")
                            install_hookname(vt3[id_ShellExecuteW], "IDispatch::ShellExecuteW")
                        end

                        -- Release1(_this)
                    end
                end
            end
        end
    end
end


ntapi.CreateProcessA = ffi.C.GetProcAddress(k32, 'CreateProcessA')
ntapi.WinExec = ffi.C.GetProcAddress(k32, 'WinExec')
ntapi.VirtualAlloc = ffi.C.GetProcAddress(k32, 'VirtualAlloc')
ntapi.CreateThread = ffi.C.GetProcAddress(k32, 'CreateThread')
ntapi.ReadProcessMemory = ffi.C.GetProcAddress(k32, 'ReadProcessMemory')
ntapi.WriteProcessMemory = ffi.C.GetProcAddress(k32, 'WriteProcessMemory')
ntapi.VirtualAllocEx = ffi.C.GetProcAddress(k32, 'VirtualAllocEx')
ntapi.CreateRemoteThread = ffi.C.GetProcAddress(k32, 'CreateRemoteThread')
ntapi.CreateProcessW = ffi.C.GetProcAddress(k32, 'CreateProcessW')
ntapi.VirtualProtectEx = ffi.C.GetProcAddress(k32, 'VirtualProtectEx')
ntapi.VirtualProtect = ffi.C.GetProcAddress(k32, 'VirtualProtect')
ntapi.OpenProcess = ffi.C.GetProcAddress(k32, 'OpenProcess')
ntapi.LoadLibraryA = ffi.C.GetProcAddress(k32, 'LoadLibraryA')
ntapi.LoadLibraryW = ffi.C.GetProcAddress(k32, 'LoadLibraryW')
ntapi.GetProcAddress = ffi.C.GetProcAddress(k32, 'GetProcAddress')
ntapi.HeapCreate = ffi.C.GetProcAddress(k32, 'HeapCreate')
ntapi.ShellExecuteA = ffi.C.GetProcAddress(sl32, 'ShellExecuteA')
ntapi.ShellExecuteW = ffi.C.GetProcAddress(sl32, 'ShellExecuteW')
ntapi.ShellExecuteExA = ffi.C.GetProcAddress(sl32, 'ShellExecuteExA')
ntapi.ShellExecuteExW = ffi.C.GetProcAddress(sl32, 'ShellExecuteExW')


ntapi.NtAlpcSendWaitReceivePort = ffi.C.GetProcAddress(ntdll, 'NtAlpcSendWaitReceivePort')
ntapi.Ndr64AsyncServerCall64 = ffi.C.GetProcAddress(rpcrt4, 'Ndr64AsyncServerCall64')
ntapi.Ndr64AsyncServerCallAll = ffi.C.GetProcAddress(rpcrt4, 'Ndr64AsyncServerCallAll')
ntapi.NdrAsyncServerCall = ffi.C.GetProcAddress(rpcrt4, 'NdrAsyncServerCall')
ntapi.NdrStubCall2 = ffi.C.GetProcAddress(rpcrt4, 'NdrStubCall2')
ntapi.NdrServerCallAll = ffi.C.GetProcAddress(rpcrt4, 'NdrServerCallAll')
ntapi.NdrServerCallNdr64 = ffi.C.GetProcAddress(rpcrt4, 'NdrServerCallNdr64')
ntapi.NdrClientCall3 = ffi.C.GetProcAddress(rpcrt4, 'NdrClientCall3')
ntapi.NdrClientCall2 = ffi.C.GetProcAddress(rpcrt4, 'NdrClientCall2')


local winet = ffi.cast('intptr_t*', ffi.C.LoadLibraryA('Wininet.dll'))

ntapi.InternetOpenA = ffi.C.GetProcAddress(winet, 'InternetOpenA')
ntapi.InternetOpenW = ffi.C.GetProcAddress(winet, 'InternetOpenW')
ntapi.InternetOpenUrlA = ffi.C.GetProcAddress(winet, 'InternetOpenUrlA')
ntapi.InternetOpenUrlW = ffi.C.GetProcAddress(winet, 'InternetOpenUrlW')
ntapi.InternetConnectW = ffi.C.GetProcAddress(winet, 'InternetConnectW')
ntapi.InternetConnectA = ffi.C.GetProcAddress(winet, 'InternetConnectA')
ntapi.InternetCrackUrlA = ffi.C.GetProcAddress(winet, 'InternetCrackUrlA')
ntapi.InternetCrackUrlW = ffi.C.GetProcAddress(winet, 'InternetCrackUrlW')
ntapi.InternetCreateUrlA = ffi.C.GetProcAddress(winet, 'InternetCreateUrlA')
ntapi.InternetCreateUrlW = ffi.C.GetProcAddress(winet, 'InternetCreateUrlW')


local function do_hook_all()

    -- 实际hook的时候根据进程信息来

	-- init_risk_api()
	-- init_alpc_rpc_api()
	do_wmi_hook()
	do_shell_dispatch_hook()

    for func_name, addr in pairs(ntapi) do
        addr = ffi.cast('intptr_t*', addr)
        print(func_name, addr)
        local status = install_hook(addr)
        if status == 0 then
            -- msg = ' ok!'
        else
            print('install hook=' .. func_name .. 'failed ' .. tostring(status))
        end
    end

end


stdapi.badptr = (function(ptr)
    local g_checkbadptr = ffi.cast('pfnis_invalid_ptr', _is_invalid_ptr)
    return function(ptr)
        local ptr = ffi.cast('void*', ptr)

        if ptr == nil then -- null check
            return true
        end

        local status = g_checkbadptr(ptr)
        if status == 1 then
            return true
        end
    end
end)()

-- 只执行一次
function start()
    DbgPrint('Run......................')
    do_hook_all()
    print(jit.status())
end

function stop()

end
