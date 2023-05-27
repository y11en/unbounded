.CODE

; Saves all general purpose registers to the stack
PUSHAQ MACRO
    push    rax
    push    rcx
    push    rdx
    push    rbx
    push    -1      ; dummy for rsp
    push    rbp
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    push    r12
    push    r13
    push    r14
    push    r15
ENDM

; Loads all general purpose registers from the stack
POPAQ MACRO
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rbp
    add     rsp, 8    ; dummy for rsp
    pop     rbx
    pop     rdx
    pop     rcx
    pop     rax
ENDM

PUSHXMM MACRO
	; save volatile XMM registers
	sub rsp, 60h           
	movaps xmmword ptr [rsp +  0h], xmm0
	movaps xmmword ptr [rsp + 10h], xmm1
	movaps xmmword ptr [rsp + 20h], xmm2
	movaps xmmword ptr [rsp + 30h], xmm3
	movaps xmmword ptr [rsp + 40h], xmm4
	movaps xmmword ptr [rsp + 50h], xmm5
ENDM

POPXMM MACRO
    ; restore XMM registers
    movaps xmm0, xmmword ptr [rsp +  0h]
    movaps xmm1, xmmword ptr [rsp + 10h]
    movaps xmm2, xmmword ptr [rsp + 20h]
    movaps xmm3, xmmword ptr [rsp + 30h]
    movaps xmm4, xmmword ptr [rsp + 40h]
    movaps xmm5, xmmword ptr [rsp + 50h]
    add rsp, 60h
ENDM




; CTX
; trampline
; PRE_HOOK
; HOOK
; POST_HOOK

HOOK_STUB PROC	public

start:

ctx db 00h,00h,00h,00h,00h,00h,00h,00h

_trampline: 
db 0ffh,25h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h,00h,00h   ;// trampline orgin_func

_pre_hook: 
db 0ffh,25h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h,00h,00h   ;// PRE_HOOK

_post_hook: 
db 0ffh,25h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h,00h,00h   ;// POST_HOOK

_lua_callback:
db 0ffh,25h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h,00h,00h   ;// LUA CB

PRE_CALL:
	nop
	pushfq
	PUSHAQ
    PUSHXMM

    lea rcx, [ctx]
    lea rdx, [rsp]

    sub     rsp, 20h
    call    _pre_hook
    add     rsp, 20h	
    
	POPXMM
    POPAQ
	popfq
    nop

    jmp _trampline

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop


HOOK_STUB ENDP



PURGE PUSHAQ
PURGE POPAQ
END