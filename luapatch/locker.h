#pragma once

#include <phnt_windows.h>
#include <phnt.h>
class CLock
{
public:
	CLock()
	{
		InitializeCriticalSection(&m_cs);
	}

	~CLock()
	{
		DeleteCriticalSection(&m_cs);
	}

	void Lock()
	{
		EnterCriticalSection(&m_cs);
	}

	void Unlock()
	{
		LeaveCriticalSection(&m_cs);
	}

private:
	CRITICAL_SECTION m_cs;
};

class AutoLock
{
public:
	AutoLock()
	{
		m_lock.Lock();
	}
	~AutoLock()
	{
		m_lock.Unlock();
	}

private:
	static CLock m_lock; //声明，全局中初始化

private:
	AutoLock(const AutoLock &lock);
	AutoLock &operator=(const AutoLock &lock);
};


