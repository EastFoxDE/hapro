; This is a assembly implementation from riemann.c which calculates pi using SSE2
bits 64

extern GetTickCount

global Start					; make our main label visible to the linker

section .data                   ; these are our variables
    interval dd 524288
    one_as_float dd 1.0
    stepping dd 0.0
    x dd 0.0
    sum dd 0.0

section .text
Start:

	;Startzeit
	Call GetTickCount
	push rax
	
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
        mov rax, 1
        cvtsi2ss xmm0, eax
		shufps xmm0, xmm0, 0x0	; push '1' into all four segments of xmm2
		
        addps xmm1, xmm0    	; 1+x*x
        mov rax, 4
        cvtsi2ss xmm0, eax  	; 4
		shufps xmm0, xmm0, 0x0	; push '4' into all four segments of xmm0
		
        divps xmm0, xmm1    	; 4/(1+x*x) --> in xmm0 steht nun unsere zwischensumme
		haddps xmm0, xmm0
		haddps xmm0, xmm0		; Horizontal addieren, um nicht zwischensumme zu oft zu addieren
		movss xmm1, [sum]
        addss xmm0, xmm1
        movss [sum], xmm0     	;summe wird um zwischensumme ergänzt

        ;For-END
        add rcx, 4				; statt inc rcx -> add 4, weil 4 Ops gleichzeitig
        jmp loop1

	calcx:
		movss xmm0, [x]
        movss xmm2, [stepping]
        addss xmm0, xmm2		; calculate new x for next f(x)
		movss [x], xmm0
		ret

    end1:
	movss xmm0, [sum]
	cvtsi2ss xmm1, ebx
	divss xmm0, xmm1		; Sum/interval
	
	call GetTickCount
	mov rbx, rax
	pop rax
	sub rbx, rax
	
	ret						; can be ommitted
	

	;Schleife, um Ticks zu erhoehen
	; mov edx, 10000
	; begin:
	; mov rax, 524288
	; mov [interval], rax
	; mov ebx, 0
	; cvtsi2ss xmm1, ebx
	; movss [stepping], xmm1
	; mov ebx, 0
	; cvtsi2ss xmm1, ebx
	; movss [x], xmm1
	; mov ebx, 0
	; cvtsi2ss xmm1, ebx
	; movss [sum], xmm1
	
	; ...
	
	; dec edx
	; cmp edx, 0
	; jge begin
