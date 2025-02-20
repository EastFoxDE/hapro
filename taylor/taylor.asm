; This line is a comment.

bits 64

;%include "win32n.inc"

	;extern ExitProcess
	;extern GetTickCount
	;extern sprintf 

global _start					; make our main label visible to the linker

section .data

	fak dd 362880.0, -5040.0, 120.0, -6.0
	func dd 0,0,0,0

section .text
_start:
	;call GetTickCount
	push rax

	;Zeitmessung, 10mio. Schleifen
	mov rdx, 10000000
	fakLoop:

		;Fakultaet aus Speicher laden
		movaps xmm1, [fak]

		; X-Werte berechnen
		mov ebx, 0x40C00000 ; Eingabe X-Wert als Float
		mov DWORD [func], ebx
		movaps xmm0, [func]
		movaps xmm2, xmm0
		mov rbx, 0
		loop2:
			shufps xmm0, xmm0, 0x90
			mulss xmm0, xmm2 ;4x Multiplizieren
			mulss xmm0, xmm2
			inc rbx
			cmp rbx, 4
			jl loop2

		end2:
		;Summanden berechnen
		divps xmm0, xmm1
		haddps xmm0, xmm0
		haddps xmm0, xmm0
		addss xmm2, xmm0 	;urspruenglichen x-Wert noch addieren
							;Endergebnis in ~xmm2[0]~

	loop fakLoop
	;call GetTickCount
	mov rbx, rax
	pop rax
	sub rbx, rax

	;sub rsp, 40
	;mov ecx, eax          		; Parameter 1: uExitCode
	;call ExitProcess
	;add rsp, 40

	ret							; can be ommitted


	;Fakultaet berechnen, beginne bei 3!
		; mov ecx, 3
		; loopFak:
			; cmp rcx, 9 ; Maximale Fak., die zu berechnen ist
			; jg endFak
			; mov eax, 1
			; mov ebx, 1

			; loop1:
				; cmp ebx, ecx
				; je end1
				; inc ebx
				; mul ebx
				; jmp loop1

			; end1: ;speicher fak-ergebnis
				; ;Speicher berechnen
				; mov rbx, rcx
				; dec rbx
				; mov QWORD [fak + 4*rbx], rax
				; inc rcx
				; inc rcx
				; jmp loopFak
		; endFak:
