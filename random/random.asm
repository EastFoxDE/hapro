SECTION .data                   ; Section containing initialised data

    file db "/dev/urandom",0
    txt db " random bytes generated", 0x0A, 0x0A
    txt_len EQU $ - txt
    index dd 0

SECTION .bss                    ; Section containing uninitialised data
    decstr resb 40              ; 40 Bytes for an ASCII string
    decstr_len resd 1
    filedescriptor resd 1
    numbers resb 256

SECTION .text                   ; Section containing code
global  _start                  ; Linker needs this to find the entry point!
_start:

    ; http://www.lxhp.in-berlin.de/lhpsysc1.html#open
    mov eax, 5                  ; SYSCALL open
    mov ebx, file               ; File descriptor
    mov ecx, 0                  ; Access: read only
    mov edx, 0x00004            ; Mode: read by others
    int 0x80                    ; Call Linux kernel
    mov [filedescriptor], eax   ; Store the resulting fd

    ; http://www.lxhp.in-berlin.de/lhpsysc1.html#read
    mov eax, 3                  ; SYSCALL read
    mov ebx, [filedescriptor]   ; File descriptor
    mov ecx, numbers            ; Pointer to input buffer
    mov edx, 256                ; Max. count of bytes to read
    int 0x80                    ; Call Linux kernel
    mov [index], eax            ; Store the count of bytes received

    ; http://www.lxhp.in-berlin.de/lhpsysc1.html#close
    mov eax, 6                  ; SYSCALL close
    mov ebx, [filedescriptor]   ; File descriptor
    int 0x80                    ; Call Linux kernel

    ; Print index
    mov eax, [index]            ; Argument: Integer to convert
    mov edi, decstr             ; Argument: Address of the target string
    call int2str                ; Get the digits of EAX and store it as ASCII & LF & NUL
    sub edi, decstr             ; EDI (pointer to the terminating NULL) - pointer to decstr = length of the string
    dec edi                     ; Shorten the string by the LF
    mov [decstr_len], edi       ; Store the resulting length of the string

    ; http://www.lxhp.in-berlin.de/lhpsysc1.html#write
    mov eax, 4                  ; SYSCALL write
    mov ebx, 1                  ; File descriptor: STDOUT
    mov ecx, decstr             ; Pointer to output buffer
    mov edx, [decstr_len]       ; count of bytes to send
    int 0x80

    ; http://www.lxhp.in-berlin.de/lhpsysc1.html#write
    mov eax, 4                  ; SYSCALL write
    mov ebx, 1                  ; File descriptor: STDOUT
    mov ecx, txt                ; Pointer to output buffer
    mov edx, txt_len            ; count of bytes to send
    int 0x80

    ; Print the numbers
    mov esi, numbers            ; Start address for lodsb
L1:                             ; Loop to print <index> numbers
    xor eax, eax                ; Argument: Integer to convert
    lodsb
    mov edi, decstr             ; Argument: Address of the target string
    call int2str                ; Get the digits of EAX and store it as ASCII & LF & NUL
    sub edi, decstr             ; EDI (pointer to the terminating NULL) - pointer to decstr = length of the string
    mov [decstr_len], edi       ; Store the resulting length of the string

    ; http://www.lxhp.in-berlin.de/lhpsysc1.html#write
    mov eax, 4                  ; SYSCALL write
    mov ebx, 1                  ; File descriptor: STDOUT
    mov ecx, decstr             ; Pointer to output buffer
    mov edx, [decstr_len]       ; count of bytes to send
    int 0x80

    sub dword [index], 1
    jnz L1                      ; Do it again

    ; http://www.lxhp.in-berlin.de/lhpsysc1.html#exit
    mov eax, 1                  ; SYSCALL exit
    mov ebx, 0                  ; Exit Code
    int 80h                     ; Call Linux kernel

int2str:    ; Converts an positive integer in EAX to a string pointed to by EDI
    xor ecx, ecx
    mov ebx, 10
    .LL1:                       ; First loop: Collect the remainders
    xor edx, edx                ; Clear EDX for div
    div ebx                     ; EDX:EAX/EBX -> EAX Remainder EDX
    push dx                     ; Save remainder
    inc ecx                     ; Increment push counter
    test eax, eax               ; Anything left to divide?
    jnz .LL1                    ; Yes: loop once more

    .LL2:                       ; Second loop: Retrieve the remainders
    pop dx                      ; In DL is the value
    or dl, '0'                  ; To ASCII
    mov [edi], dl               ; Save it to the string
    inc edi                     ; Increment the pointer to the string
    loop .LL2                   ; Loop ECX times

    mov word [edi], 0x0A        ; Last characters: LF, NUL
    inc edi
    ret                         ; RET: EDI points to the terminating NULL
