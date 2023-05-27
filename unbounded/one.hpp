#pragma once

#include <Windows.h>
#include <windows.h> 
#include <stdio.h>
#include <tchar.h>
#include <strsafe.h>
#include <tchar.h>



typedef DWORD(__stdcall* _PFNCALLBACK)(void*);

#define PIPE_TIMEOUT 5000
#define BUFSIZE 4096

typedef struct
{
	OVERLAPPED oOverlap;
	HANDLE hPipeInst;
	BYTE chRequest[BUFSIZE];
	DWORD cbRead;
	BYTE chReply[BUFSIZE];
	DWORD cbToWrite;
	_PFNCALLBACK cb;

} PIPEINST, * LPPIPEINST;

int PipeServer(LPCWSTR name, _PFNCALLBACK cb);

