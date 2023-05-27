BITS 32
ORG 0

ctx: DB 0x00,0x00,0x00,0x00
orgin_call: jmp 0x12345678
pre_hook: jmp 0x12345678

pushfd
pushad
lea eax, [esp]
push eax

call L1
L1:pop eax

lea eax, [eax - L1 + ctx]
push eax
call pre_hook
popad
popfd
jmp orgin_call
nop
nop