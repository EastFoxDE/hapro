%define  SYS_EXIT  1
%define  SYS_READ  3
%define  SYS_WRITE 4
%define  STDIN     0
%define  STDOUT    1
%define  KERNEL    0x80


section .data
  message db `Die BA ist einfach uebergeil`, `!\n\0`
  lenMessage equ $ - message

section .text
  global _start

_start:
  mov eax, SYS_WRITE ; Write syscall
  mov ebx, STDOUT    ; File descriptor
  mov ecx, message   ; Message
  mov edx, lenMessage; Message length
  int KERNEL
