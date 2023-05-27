
#include <windows.h>
#include <stdio.h>
#pragma comment(lib,"ntdll.lib")


#define printf(...) {}

// #define printf YZMDD::DBGSTR

#define ulong unsigned long
#define ulonglong unsigned long long
#define ULONG unsigned long
#define ULONGLONG unsigned long long
#define ushort unsigned short
#define USHORT unsigned short

typedef enum _LPC_TYPE {
	LPC_NEW_MESSAGE, // A new message
	LPC_REQUEST, // A request message
	LPC_REPLY, // A reply to a request message
	LPC_DATAGRAM, //
	LPC_LOST_REPLY, //
	LPC_PORT_CLOSED, // Sent when port is deleted
	LPC_CLIENT_DIED, // Messages to thread termination ports
	LPC_EXCEPTION, // Messages to thread exception port
	LPC_DEBUG_EVENT, // Messages to thread debug port
	LPC_ERROR_EVENT, // Used by ZwRaiseHardError
	LPC_CONNECTION_REQUEST // Used by ZwConnectPort
}LPC_TYPE;



// int AlpcSend(const wchar_t* PortName, void* buff, size_t sz, int MaxMsgLen /*=0x2000*/);
typedef int(__stdcall* _PFNCALLBACK)(void* msg, size_t sz);
//int AlpcServer(const wchar_t* PortName, _PFNCALLBACK CB, int MaxMsgLen /*=0x2000*/);


struct _UNICODE_STRING
{
	unsigned short Length;
	unsigned short MaxLength;
	unsigned long Pad;
	wchar_t* Buffer;
};
typedef struct _OBJECT_ATTRIBUTES {
	ULONGLONG           Length;
	HANDLE          RootDirectory;
	_UNICODE_STRING* ObjectName;
	ULONGLONG           Attributes;
	PVOID           SecurityDescriptor;
	PVOID           SecurityQualityOfService;
} OBJECT_ATTRIBUTES;




struct _ALPC_PORT_ATTRIBUTES
{
	ulong Flags;
	_SECURITY_QUALITY_OF_SERVICE SecurityQos;
	ulonglong MaxMessageLength;
	ulonglong MemoryBandwidth;
	ulonglong MaxPoolUsage;
	ulonglong MaxSectionSize;
	ulonglong MaxViewSize;
	ulonglong MaxTotalSectionSize;
	ulong DupObjectTypes;
	ulong Reserved;
};

struct _CLIENT_ID
{
	unsigned long long UniqueProcess;
	unsigned long long UniqueThread;
};
typedef struct _PORT_MESSAGE
{
	union //at 0x0
	{
		unsigned long Length;
		struct
		{
			unsigned short DataLength;
			unsigned short TotalLength;
		}s1;
	}u1;
	union //at 0x4
	{
		unsigned long ZeroInit;
		struct
		{
			unsigned short Type;
			unsigned short DataInfoOffset;
		}s2;
	}u2;
	_CLIENT_ID ClientId;//at 0x8
	unsigned long MessageId;//at 0x18
	unsigned long Pad;//at 0x1C
	union //at 0x20
	{
		unsigned long long ClientViewSize;
		unsigned long CallbackId;
	}u3;
}PORT_MESSAGE;

struct _REMOTE_PORT_VIEW
{
	unsigned long Length;
	unsigned long Pad;
	unsigned long long ViewSize;
	unsigned long long ViewBase;
};

typedef struct _PORT_VIEW
{
	ULONG Length;
	ULONG Pad1;
	HANDLE SectionHandle;
	ULONG SectionOffset;
	ULONG Pad2;
	ULONGLONG ViewSize;
	ULONGLONG ViewBase;
	ULONGLONG ViewRemoteBase;
}PORT_VIEW;


struct _ALPC_MESSAGE_ATTRIBUTES
{
	ulong AllocatedAttributes;
	ulong ValidAttributes;
};


//Taken from conhost.exe
struct _CONTEXT_X
{
	_LIST_ENTRY List0;//AT 0x0
	HANDLE hRemoteProcess;//at 0x10
	ulong Unk;//At 0x18
	ulong unkx;//at 0x1C
	_CLIENT_ID ClientId;//at 0x20
	ulonglong Pad0;//at 0x30
	ulonglong Pad1;//at 0x38
	_LIST_ENTRY List1;//at 0x40
};

extern "C"
{

	int ZwAlpcConnectPort(HANDLE* PortHandle,
		_UNICODE_STRING* PortName,
		_OBJECT_ATTRIBUTES* ObjectAttributes,
		_ALPC_PORT_ATTRIBUTES* PortAttributes,
		ulonglong Flags,
		PSID RequiredServerSid,
		_PORT_MESSAGE* ConnectionMessage,
		ulonglong* BufferLength,
		_ALPC_MESSAGE_ATTRIBUTES* OutMessageAttributes,
		_ALPC_MESSAGE_ATTRIBUTES* InMessageAttributes,
		_LARGE_INTEGER* Timeout);


	int ZwClose(HANDLE Handle);

	int	AlpcInitializeMessageAttribute(ulonglong AttributeFlags,
		_ALPC_MESSAGE_ATTRIBUTES* Buffer,
		ulonglong BufferSize,
		ulonglong* RequiredBufferSize);

	ulonglong	AlpcGetMessageAttribute(_ALPC_MESSAGE_ATTRIBUTES* Buffer, ulonglong AttributeFlag);


	int ZwCreatePort(HANDLE* pPortHandle,
		_OBJECT_ATTRIBUTES* ObjectAttributes,
		ulonglong MaxConnectInfoLength,
		ulonglong MaxDataLength,

		void* Reserved);
	int ZwAlpcCreatePort(HANDLE* pPortHandle, _OBJECT_ATTRIBUTES* ObjectAttributes, _ALPC_PORT_ATTRIBUTES* PortAttributes);

	int ZwReplyWaitReceivePort(HANDLE PortHandle,
		void** PortContext,
		_PORT_MESSAGE* ReplyMessage,
		_PORT_MESSAGE* ReceiveMessage);

	int ZwAcceptConnectPort
	(HANDLE* PortHandle,
		void* PortContext,
		_PORT_MESSAGE* ConnectionRequest,
		bool AcceptConnection,
		void* ServerView,
		_REMOTE_PORT_VIEW* ClientView);


	int ZwReplyPort(HANDLE PortHandle, _PORT_MESSAGE* ReplyMessage);

	int ZwRequestWaitReplyPort
	(HANDLE PortHandle,
		_PORT_MESSAGE* RequestMessage,
		_PORT_MESSAGE* ReplyMessage);
	int ZwOpenProcess
	(HANDLE* ProcessHandle,
		ACCESS_MASK DesiredAccess,
		_OBJECT_ATTRIBUTES* ObjectAttributes,
		_CLIENT_ID* ClientId);

	int ZwAlpcOpenSenderProcess(HANDLE* ProcessHandle,
		HANDLE PortHandle,
		_PORT_MESSAGE* PortMessage,
		ulonglong Flags,
		ACCESS_MASK DesiredAccess,
		_OBJECT_ATTRIBUTES* ObjectAttributes);

	int ZwAlpcOpenSenderThread(HANDLE* ThreadHandle,
		HANDLE PortHandle,
		_PORT_MESSAGE* PortMessage,
		ulonglong Flags,
		ACCESS_MASK DesiredAccess,
		_OBJECT_ATTRIBUTES* ObjectAttributes);

	int ZwListenPort(HANDLE PortHandle, _PORT_MESSAGE* ConnectionRequest);
	int ZwReplyPort(HANDLE PortHandle, _PORT_MESSAGE* ReplyMessage);

	int ZwAlpcSendWaitReceivePort(HANDLE PortHandle, ulonglong Flags,
		_PORT_MESSAGE* SendMessage, _ALPC_MESSAGE_ATTRIBUTES* SendMessageAttributes,
		_PORT_MESSAGE* ReceiveMessage, ulonglong* BufferLength,
		_ALPC_MESSAGE_ATTRIBUTES* ReceiveMessageAttributes, _LARGE_INTEGER* Timeout);

	int ZwAlpcAcceptConnectPort(HANDLE* PortHandle,
		HANDLE ConnectionPortHandle,
		ulonglong Flags,
		_OBJECT_ATTRIBUTES* ObjectAttributes,
		_ALPC_PORT_ATTRIBUTES* PortAttributes,
		void* PortContext,
		_PORT_MESSAGE* ConnectionRequest,
		_ALPC_MESSAGE_ATTRIBUTES* ConnectionMessageAttributes,
		bool AcceptConnection);
}

// #define MaxMsgLen 0x2000

HANDLE AlpcCreate(wchar_t* PortName, DWORD MaxMsgLen)
{
	HANDLE hPort = 0;
	// wchar_t PortName[] = L"\\BaseNamedObjects\\portw";

	_UNICODE_STRING UniS = { 0 };
	UniS.Length = wcslen(PortName) * 2;
	UniS.MaxLength = (UniS.Length) + 2;
	UniS.Buffer = PortName;

	_OBJECT_ATTRIBUTES ObjAttr = { sizeof(ObjAttr) };
	ObjAttr.Attributes = 0x40;//insensitive
	ObjAttr.ObjectName = &UniS;
	//ObjAttr.RootDirectory=0;

	_ALPC_PORT_ATTRIBUTES PortAtt = { 0 };
	PortAtt.Flags = 0x20000;
	PortAtt.MaxMessageLength = MaxMsgLen;
	PortAtt.MemoryBandwidth = 0;
	PortAtt.MaxPoolUsage = 0x11600;

	int retValue = ZwAlpcCreatePort(&hPort, &ObjAttr, &PortAtt);
	if (retValue < 0)
	{
		printf("Error creating ALPC port, ret: %X\r\n", retValue);
		return INVALID_HANDLE_VALUE;
	}
	return hPort;
}


int AlpcServer(const wchar_t* PortName, _PFNCALLBACK CB, int MaxMsgLen /*=0x2000*/)
{
	DWORD retValue;
	//--------------------
	bool bFirst = true;
	_PORT_MESSAGE* pReceiveMessage = 0;

	HANDLE hPort = AlpcCreate((wchar_t*)PortName, MaxMsgLen);
	ulonglong AttX;
	ulonglong BufferLength = MaxMsgLen;

	if (INVALID_HANDLE_VALUE == hPort)
	{
		goto _Exit;
	}

	pReceiveMessage = (_PORT_MESSAGE*)malloc(BufferLength + sizeof(_PORT_MESSAGE));

	if (pReceiveMessage)
	{
		memset(pReceiveMessage, 0, BufferLength + sizeof(_PORT_MESSAGE));

		while (1)
		{
			_ALPC_MESSAGE_ATTRIBUTES pReceiveMsgAttributes = { 0 };

			// _ALPC_MESSAGE_ATTRIBUTES* pReceiveMsgAttributes = (_ALPC_MESSAGE_ATTRIBUTES*)LocalAlloc(LMEM_ZEROINIT, 0x78);
			ulonglong ReqLength = 0;

			int retYY = AlpcInitializeMessageAttribute(0x30000001, &pReceiveMsgAttributes, 0x78, &ReqLength);
			if (retYY < 0)
			{
				printf("AlpcInitializeMessageAttribute, ret: %X\r\n", retYY);
				// ExitProcess(0);
				break;
			}

			retValue = ZwAlpcSendWaitReceivePort(hPort, 0 /*Flags*/,
				0, 0,
				pReceiveMessage, &BufferLength,
				&pReceiveMsgAttributes, 0 /* TimeOut */);

			printf("ZwAlpcSendWaitReceivePort, ret: %X\r\n", retValue);


			AttX = AlpcGetMessageAttribute(&pReceiveMsgAttributes, 0x20000000);


			if (retValue >= 0)
			{
				if (retValue == 0x102)//STATUS_TIMEOUT
				{
					break;

				}
				else
				{
					AttX = AlpcGetMessageAttribute(&pReceiveMsgAttributes, 0x10000000);
					// HANDLE hShit = (HANDLE)(*(ulonglong*)(AttX + 0x8));
					ulong Typ = (pReceiveMessage->u2.s2.Type) & 0xFF;

					printf("Type: %X\r\n", Typ);
					if (Typ == 0xA)//LPC_CONNECTION_REQUEST
					{
						HANDLE hPort_Remote = INVALID_HANDLE_VALUE;

						printf("New Connection\r\n");
						retValue = ZwAlpcAcceptConnectPort(&hPort_Remote, hPort, 0, 0, 0, 0, pReceiveMessage, 0, true);
						printf("ZwAlpcAcceptConnectPort, ret: %X, hPort_Remote: %I64X\r\n", retValue, hPort_Remote);
					}
					else if (Typ == LPC_PORT_CLOSED)
					{

					}
					else if (Typ == 1)//LPC_REQUEST
					{
						printf("New Request\r\n");
						_OBJECT_ATTRIBUTES ObjAtt_SenderP = { sizeof(_OBJECT_ATTRIBUTES) };
						_OBJECT_ATTRIBUTES ObjAtt_SenderT = { sizeof(_OBJECT_ATTRIBUTES) };


						ulong Offset = pReceiveMessage->u2.s2.DataInfoOffset;
						char* pData = ((char*)pReceiveMessage) + sizeof(_PORT_MESSAGE) + Offset;
						printf("Data: %p len=%d\r\n", pData, pReceiveMessage->u1.s1.DataLength);


						if (CB)
						{
							CB(pData, pReceiveMessage->u1.s1.DataLength);
						}

						ulonglong BufferLengthX = BufferLength;
						_PORT_MESSAGE* pSendMessage = (_PORT_MESSAGE*)malloc(BufferLengthX + sizeof(PORT_MESSAGE));

						if (pSendMessage)
						{
							// 先不回复消息
							memset(pSendMessage, 0, BufferLengthX + sizeof(PORT_MESSAGE));
							memcpy(pSendMessage, pReceiveMessage, sizeof(PORT_MESSAGE));

							retValue = ZwAlpcSendWaitReceivePort(hPort, 0x10000 /*Flags*/, pSendMessage, 0, 0, 0, 0, 0);
							free(pSendMessage);
						}
					}
					else if (Typ == LPC_DATAGRAM)//from ZwRequestPort
					{

					}
				}
			}
			else
			{
				printf("Closing port, bye\r\n");
				break;
			}
		}
	}
_Exit:
	if (pReceiveMessage)
	{
		free(pReceiveMessage);
	}

	if (hPort && (hPort != INVALID_HANDLE_VALUE))
	{
		ZwClose(hPort);
	}

	return 0;
}

int AlpcSend(const wchar_t* PortName, void* buff, size_t sz, int MaxMsgLen /*=0x120*/)
{
	_UNICODE_STRING UniS = { 0 };

	int dwRet = 0;

	UniS.Length = wcslen(PortName) * 2;
	UniS.MaxLength = (UniS.Length) + 2;
	UniS.Buffer = (wchar_t*)PortName;

	HANDLE hPort_Remote = 0;
	_ALPC_PORT_ATTRIBUTES PortAtt = { 0 };

	_OBJECT_ATTRIBUTES ObjAttr = { sizeof(ObjAttr) };
	ObjAttr.Attributes = 0x40;

	if (MaxMsgLen > 0)
	{
		MaxMsgLen = MaxMsgLen + sizeof(_PORT_MESSAGE);
	}
	else {
		return 1;
	}


	int retValue = ZwAlpcConnectPort(&hPort_Remote, &UniS, &ObjAttr, 0, 0x20000 /*FLags*/, 0, 0, 0, 0, 0, 0);
	printf("ZwAlpcConnectPort, ret: %X\r\n", retValue);
	if (retValue < 0)
	{
		const char* Err = 0;
		if (retValue == 0xC0000034)
		{
			Err = "STATUS_OBJECT_NAME_NOT_FOUND";
		}
		else if (retValue == 0xC0000041)
		{
			Err = "STATUS_PORT_CONNECTION_REFUSED";
		}
		printf("Error creating ALPC port, ret: %X, %s\r\n", retValue, Err);
		// retValue= -5;
		dwRet = retValue;
	}

	_PORT_MESSAGE* pReq = NULL;
	_PORT_MESSAGE* pRpl = NULL;
	if (dwRet == 0)
	{
		pReq = (_PORT_MESSAGE*)malloc(MaxMsgLen);
		pRpl = (_PORT_MESSAGE*)malloc(MaxMsgLen);

		if (pReq && pRpl)
		{
			memset(pReq, 0, MaxMsgLen);
			memset(pRpl, 0, MaxMsgLen);
			do
			{
				{


					pReq->u1.s1.DataLength = sz; // TotalLength - sizeof(_PORT_MESSAGE);
					pReq->u1.s1.TotalLength = sz + sizeof(_PORT_MESSAGE);// TotalLength;

					pReq->u2.s2.DataInfoOffset = 0;
					pReq->u2.s2.Type = LPC_REQUEST;

					pReq->MessageId = 0;

					memcpy(((char*)pReq) + sizeof(_PORT_MESSAGE) + (pReq->u2.s2.DataInfoOffset),
						buff, sz > MaxMsgLen ? MaxMsgLen : sz);


					printf("===Attempt\r\n");

					retValue = ZwRequestWaitReplyPort(hPort_Remote, pReq, pRpl);
					printf("ZwRequestWaitReplyPort, ret: %X\r\n", retValue);
					if (retValue < 0)
					{
						printf("Error ZwRequestWaitReplyPort, ret: %X\r\n", retValue);
						dwRet = retValue;
						break;
					}
					printf("===Done\r\n");

				}
			} while (0);
		}
	}

	if (hPort_Remote && (hPort_Remote != INVALID_HANDLE_VALUE))
		ZwClose(hPort_Remote);

	if (pReq)
		free(pReq);

	if (pRpl)
		free(pRpl);

	return dwRet;
}

