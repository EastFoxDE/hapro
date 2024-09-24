; This line is a comment.
%define  SYS_EXIT  1
%define  SYS_READ  3
%define  SYS_WRITE 4
%define  STDIN     0
%define  STDOUT    1
%define  KERNEL    0x80

bits 64

section .data
  eq0 db `Null\n\0`
  len_eq0 equ $ - eq0

  eq1 db `Eins\n\1`
  len_eq1 equ $ - eq1

  eqDef db `Viel\n\0`
  len_eqDef equ $ - eqDef

section .text
  global _start

_start:
;mov eax, 0xCAFEBABE
;mov ax, 0xDEAD

mov r8d, 0x0
current:
mov ecx, r8d
cmp ecx, 0
je sc_0
cmp ecx, 1
je sc_1
jmp sc_def
sc_0:
  mov ecx, eq0   ; Message
  mov edx, len_eq0; Message length
  mov r8d, 1
  jmp sc_end
sc_1:
  mov ecx, eq1   ; Message
  mov edx, len_eq1; Message length
  mov r8d, 5
  jmp sc_end
sc_def:
  mov ecx, eqDef   ; Message
  mov edx, len_eqDef; Message length
  mov r8d, 0
sc_end:
  mov eax, SYS_WRITE ; Write syscall
  mov ebx, STDOUT    ; File descriptor
  int KERNEL
jmp current
ret

ue2_2_1:
mov ebx, eax
shr ebx, 4
not ebx,
and ebx, 0xF
and eax, 0xFFFFFFF0
or eax, ebx

ue2_2_2:
mov ebx, eax
shr ebx, 4
not ebx
and ebx, 0xF
mov ecx, 0
 loop1:
  cmp bl, 0
  je loop1_end
  shr bl, 1
  rcl cl, 1
  jmp loop1
 loop1_end:
and al, 0xF0
or eax, ecx

ue2_2_3:
mov ax, 0xA123
mov bl, 0x7
mul bl ; OVERFLOW!

ue_2_2_4:
mov eax, 63
shl eax, 1

ue_2_2_5:
; Check if cpu has sse2 feature
mov eax, 0x1
cpuid
shr edx, 26
and edx, 0x1
mov eax, edx

ende:
ret
