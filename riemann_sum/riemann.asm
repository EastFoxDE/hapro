; This is a assembly implementation from riemann.c which calculates pi using SSE2
bits 64

global _start					; make our main label visible to the linker

section .data                   ; these are our variables
    interval dd 4
    one_as_float dd 1.0
    stepping dd 0.0
    x dd 0.0
    sum dd 0.0

section .text
_start:

	;interval angeben
	mov eax, [interval]
    cvtsi2ss xmm1, eax

    ;Stepping berechnen
    movss xmm0, [one_as_float]
    divss xmm0, xmm1
    movss [stepping], xmm0

    ;x initialisieren
    mov eax, 2
    cvtsi2ss xmm1, eax
    divss xmm0, xmm1
    movss [x], xmm0

    ;Zähler initialisieren
    mov rcx, 1

    ;Berechnung
	loop1:
        ;For-BEGIN
		cmp rcx, [interval]
        jge end1

        ;For-BODY           ; Äquivalent zu:
                            ;   sum += 4/(1+x*x);
                            ;   x += stepping;
        movss xmm1, [x]
        mulss xmm1, xmm1    ; x*x
        mov eax, 1
        cvtsi2ss xmm2, eax
        addss xmm1, xmm2    ; 1+x*x
        mov eax, 4
        cvtsi2ss xmm0, eax  ; 4
        divss xmm0, xmm1    ; 4/(1+x*x) --> in xmm0 steht nun unsere zwischensumme
        movss xmm2, [sum]
        addss xmm0, xmm2
        movss [sum], xmm0     ;summe wird um zwischensumme ergänzt
        movss xmm0, [x]
        movss xmm1, [stepping]
        addss xmm0, xmm1
        movss [x], xmm0       ; x um stepping inkrementieren

        ;For-END
        inc rcx
        jmp loop1



		;mov ebx, 0x40C00000 ; Eingabe X-Wert als Float
		;movaps xmm2, xmm0
		;mov rbx, 0
		;loop2:
		;	shufps xmm0, xmm0, 0x90
		;	mulss xmm0, xmm2 ;4x Multiplizieren
		;	mulss xmm0, xmm2
		;	inc rbx
		;	cmp rbx, 4
		;	jl loop2

		;end2:
		;Summanden berechnen
		;divps xmm0, xmm1
		;haddps xmm0, xmm0
		;haddps xmm0, xmm0
		;addss xmm2, xmm0 	;urspruenglichen x-Wert noch addieren
							;Endergebnis in ~xmm2[0]~

    end1:
    xor rax, rax
    xor rax, rax
    xor rax, rax
    xor rax, rax
	ret							; can be ommitted