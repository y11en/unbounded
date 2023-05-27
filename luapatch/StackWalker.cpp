#include "stackwalker.h"
#include <phnt_windows.h>
#include <phnt.h>
#include <stdint.h>

#ifdef _WIN64

/* http://www.nynaeve.net/Code/StackWalk64.cpp */
#define	UNW_FLAG_NHANDLER 0x0

int
__stdcall
StackTrace(uint64_t* pcstack, uintptr_t ip, uintptr_t sp,
	int limit, int aframes)
{
	CONTEXT Context;
	KNONVOLATILE_CONTEXT_POINTERS NvContext;
	UNWIND_HISTORY_TABLE UnwindHistoryTable;
	PRUNTIME_FUNCTION RuntimeFunction;
	PVOID HandlerData;
	ULONG64 EstablisherFrame;
	ULONG64 ImageBase;
	int depth = 0;

	__try {
		RtlCaptureContext(&Context);
	}
	__except (EXCEPTION_EXECUTE_HANDLER) {
		return (0);
	}

	if (sp)
	{
		Context.Rsp = sp;
	}
	if (ip)
	{
		Context.Rip = ip;
	}

	RtlZeroMemory(&UnwindHistoryTable, sizeof(UNWIND_HISTORY_TABLE));

	/*
	 * This unwind loop intentionally skips the first call frame,
	 * as it shall correspond to the call to StackTrace64,
	 * which we aren't interested in.
	 */
	while (depth < limit) {
		/* Try to look up unwind metadata for the current function. */
		RuntimeFunction = RtlLookupFunctionEntry(Context.Rip,
			&ImageBase, &UnwindHistoryTable);
		RtlZeroMemory(&NvContext,
			sizeof(KNONVOLATILE_CONTEXT_POINTERS));

		if (!RuntimeFunction) {
			/*
			 * If we don't have a RUNTIME_FUNCTION, then
			 * we've encountered a leaf function.
			 * Adjust the stack approprately.
			 */
			__try {
				Context.Rip =
					(ULONG64)(*(PULONG64)Context.Rsp);
			}
			__except (EXCEPTION_EXECUTE_HANDLER) {
				return (depth);
			}
			Context.Rsp += 8;
		}
		else {
			/* call RtlVirtualUnwind to execute the unwind for us */
			__try {
				RtlVirtualUnwind(UNW_FLAG_NHANDLER, ImageBase,
					Context.Rip, RuntimeFunction, &Context,
					&HandlerData, &EstablisherFrame,
					&NvContext);
			}
			__except (EXCEPTION_EXECUTE_HANDLER) {
				return (depth);
			}
		}

		/*
		 * If we reach an RIP of zero, this means that we've walked
		 * off the end of the call stack and are done.
		 */
		if (!Context.Rip)
			break;
		if (aframes > 0) {
			aframes--;
			if ((aframes == 0) && (ip != 0)) {
				pcstack[depth++] = ip;
			}
		}
		else {
			pcstack[depth++] = Context.Rip;
		}
	}

	return (depth);
}
#else
struct frame {
	struct frame* f_frame;
	uintptr_t f_retaddr;
};

int 
__stdcall
StackTrace(uint64_t* pcstack, uintptr_t ip, uintptr_t ebp, int limit, int aframes)
{
	CONTEXT Context;
	struct frame* frames;
	uintptr_t callpc;
	int depth = 0;

	if (ebp)
	{
		frames = (struct frame*)ebp;
	}
	else
	{
		RtlCaptureContext(&Context);
		frames = (struct frame*)Context.Ebp;
	}
	while (frames && depth < limit) {
		__try {
			callpc = frames->f_retaddr;
		}
		__except (EXCEPTION_EXECUTE_HANDLER) {
			break;
		}

		if (aframes > 0) {
			aframes--;
			if ((aframes == 0) && (ip != 0)) {
				pcstack[depth++] = ip;
			}
		}
		else {
			pcstack[depth++] = callpc;
		}
		frames = frames->f_frame;
	}

	return (depth);
}
#endif

/*
 * CaptureStackBackTrace, will not work, beacause the
 * injected trampoline code is not within loaded module range.
 * http://win32easy.blogspot.com/2011/03/rtlcapturestackbacktrace-in-managed.html
 */
