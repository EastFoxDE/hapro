%define  SYS_EXIT  1
%define  SYS_READ  3
%define  SYS_WRITE 4
%define  STDIN     0
%define  STDOUT    1
%define  KERNEL    0x80

; This is a assembly implementation from riemann.c which calculates pi using SSE2
bits 64

;extern GetTickCount

global _start					; make our main label visible to the linker
;global Start					; make our main label visible to the linker

extern printf

section .data                   ; these are our variables
    interval dd 32 ; 524288;
    one_as_float dd 1.0
    stepping dd 0.0
    x dd 0.0
    sum dd 0.0

section .bss
    float_str resb 32

section .text

_start:
;Start:

	;interval angeben
	mov ebx, [interval]
	;mov ebx, eax			;zähler behalten für cmp
    cvtsi2ss xmm1, ebx

    ;Stepping berechnen
    movss xmm0, [one_as_float]
    divss xmm0, xmm1
    movss [stepping], xmm0

    ;x initialisieren
    mov rax, 2
    cvtsi2ss xmm1, eax
    divss xmm0, xmm1
    movss [x], xmm0

	;Startzeit
	;Call GetTickCount
	;push rax
	
    ;Zähler initialisieren
	mov rcx, 0
	
    ;Berechnung
	loop1:
        ;For-BEGIN
		cmp ecx, ebx
        jge end1

        ;For-BODY           	; Äquivalent zu:
								;   sum += 4/(1+x*x);
								;   x += stepping;
        
		movss xmm1, [x]			; move first x into xmm1
		push rcx
		mov rcx, 0
		loop2:
			cmp rcx, 3
			jge calc
			shufps xmm1, xmm1, 0x90	; shift x one to the left
			call calcx			; next f(x) now lays in xmm0
			movss xmm1, xmm0
			inc rcx
			jmp loop2
		
		calc: 
		call calcx
		pop rcx
		mulps xmm1, xmm1    	; x*x
        mov eax, 1
        cvtsi2ss xmm2, eax
		shufps xmm2, xmm2, 0x0	; push '1' into all four segments of xmm2
		
        addps xmm1, xmm2    	; 1+x*x
        mov eax, 4
        cvtsi2ss xmm0, eax  	; 4
		shufps xmm0, xmm0, 0x0	; push '4' into all four segments of xmm0
		
        divps xmm0, xmm1    	; 4/(1+x*x) --> in xmm0 steht nun unsere zwischensumme
		haddps xmm0, xmm0
		haddps xmm0, xmm0		; Horizontal addieren, um nicht zwischensumme zu oft zu addieren
		movss xmm2, [sum]
        addss xmm0, xmm2
        movss [sum], xmm0     	;summe wird um zwischensumme ergänzt

        ;For-END
        add rcx, 4				; statt inc rcx -> add 4, weil 4 Ops gleichzeitig
        jmp loop1

	calcx:
		movss xmm0, [x]
        movss xmm4, [stepping]
        addss xmm0, xmm4		; calculate new x for next f(x)
		movss [x], xmm0
		ret

    end1:
	movss xmm0, [sum]
	cvtsi2ss xmm1, ebx
	divss xmm0, xmm1		; Sum/interval
	
	;call GetTickCount
	;mov rbx, rax
	;pop rax
	;sub rbx, rax

	;ret						; can be ommitted

    ; Exit the program
    mov eax, 60             ; sys_exit syscall number for x86_64
    xor edi, edi            ; Exit code 0
    syscall                 ; Invoke system call