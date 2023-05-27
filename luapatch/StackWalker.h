#pragma once

#include <stdint.h>

enum {
	STACKSIZE = 256,
};

// BH的栈回溯可以看看...
// https://github.com/DarthTon/Blackbone/blob/a672509b5458efeb68f65436259b96fa8cd4dcfc/src/BlackBone/LocalHook/TraceHook.cpp#L224
int
__stdcall
StackTrace(uint64_t* pcstack, uintptr_t ip, uintptr_t sp, int limit, int aframes);