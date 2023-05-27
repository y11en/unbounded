#pragma once

#include <cstdio>
#include <cstdlib>
#include <tchar.h>
#pragma warning(push)
#pragma warning(disable : 4091)
#include <DbgHelp.h>
#pragma warning(pop)

#define APPNAME_A "[MPatch] %s\r\n"
#define APPNAME_W _T("[MPatch] %ls\r\n")

#define ENABLE_DBGSTR

namespace YZMDD
{
#ifndef BLACKBONE_NO_TRACE

inline void DoTraceV( const char* fmt, va_list va_args )
{
	char buf[2048]={0}, userbuf[1024]={0};
    vsprintf_s( userbuf, fmt, va_args );
	sprintf_s(buf, APPNAME_A, userbuf );
    OutputDebugStringA( buf );

#ifdef CONSOLE_TRACE
    printf_s( buf );
#endif
}

inline void DoTraceV( const wchar_t* fmt, va_list va_args )
{
	wchar_t buf[2048]={0}, userbuf[1024]={0};

    vswprintf_s( userbuf, fmt, va_args );
	swprintf_s( buf, APPNAME_W, userbuf );
    OutputDebugStringW( buf );

#ifdef CONSOLE_TRACE
    wprintf_s( buf );
#endif
}

template<typename Ch>
inline void DoTrace( const Ch* fmt, ... )
{
#ifdef ENABLE_DBGSTR
    va_list va_args;
    va_start( va_args, fmt );
    DoTraceV( fmt, va_args );
    va_end( va_args );
#endif
}

#define DBGSTR(fmt, ...) DoTrace(fmt, ##__VA_ARGS__)

#else
#define DBGSTR(...)
#endif

}