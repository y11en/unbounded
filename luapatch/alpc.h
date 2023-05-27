#pragma once

int AlpcSend(const wchar_t* PortName, void* buff, size_t sz, int MaxMsgLen /*=0x100*/);


typedef int(__stdcall* _PFNCALLBACK)(void* msg, size_t sz);
int AlpcServer(const wchar_t* PortName, _PFNCALLBACK CB, int MaxMsgLen /*=0x100*/);