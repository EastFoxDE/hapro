bits 64

global _start                                   ; make our main label visible t>


section .text
_start:
mov rax, 0x7
mov rbx, 0x0A
xor edx, edx	;EDX auf 0 setzen, um Fehlermeldung bei MUL und DIV zu vermeiden
cmp rax, rbx
jg else
mov rbx, 0x3
mul rbx
jmp end
else: mov rbx, 0x2
div rbx
end: nop
nop
