bits 64

global _start                                   ; make our main label visible t>

section .text
_start:
;mov rax, 0xCAFEBABE
;add rsp, 8
;push rax
;push DWORD 12
;push strict dword 24
;POP RAX

mov rax, 0x10
mov rbx, 0x2
;xor edx, edx	;EDX auf 0 setzen, um Fehlermeldung bei MUL und DIV zu vermeiden
mov rdx, 0x0
;cmp rax, rbx
;jg else
;mov rbx, 0x3
div rbx
jmp end
else: mov rbx, 0x2
div rbx
end: nop
nop
