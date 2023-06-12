
; -----------------------------------------------

cseg at 0h
ajmp init
cseg at 100h

; P0: Bit 0-3 digits
; P1: Bit 0-7 segments
; P2: Bit 0-7 Key input
; ------------------------------------------------
; Interrupt für TIMER0: Einsprung bei 0Bh
;-------------------------------------------------
ORG 0Bh
;call zeigen
reti
;-------------------------------------------------------
;init: TIMER wird initialisiert
; für 40 ms benötigt man einen 16 bit Timer
; das dauert zu lange in der Simulation! 
; Daher hier eine kurze Variante!
; Es wird nur von C0h auf FFh hochgezählt und 
; dann der Timer wird auf C0h gesetzt
; (für Hardware müsste das ersetzt werden!)
;-------------------------------------------------------
ORG 20h
;tommy
init:
mov IE, #10010010b
mov tmod, #00000010b
mov tl0, #0c0h  ; Timer-Initionalsierung 
mov th0, #0c0h
mov P0,#00h
mov P1,#0FFh
mov P2,#0FFh
mov P3,#00h

; R4 - R7 : Digits
mov R4, #0h
mov R5, #0h
mov R6, #0h
mov R7, #0h

call zeigen

hauptloop:
call checkkeypad
call display
ajmp hauptloop

checkkeypad:
mov P2, #0FFh
; 3. bit setzen
mov A, P2
ORL A, #0Fh
ANL A, #11110111b
MOV P2, A
MOV A, P2

cjne A, #11100111b, gedrueckt_else_succ_fail_check
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	call clear_display
	AJMP gedrueckt_nachif
	
gedrueckt_else_succ_fail_check:
; succ oder fail ignorieren
mov A, P3
ANL A, #01000000b
cjne A, #0h, gedrueckt_nachif

MOV A, P2
; enter
cjne A, #10110111b, gedrueckt_else1
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	call check_password
	AJMP gedrueckt_nachif
gedrueckt_else1:
; continue with if lel
; 0 press
cjne A, #11010111b, gedrueckt_else2
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #00h
	AJMP gedrueckt_nachif
gedrueckt_else2:
; Check 1er reihe
mov A, P2
ORL A, #0Fh
ANL A, #11111110b
MOV P2, A
MOV A, P2
; 1 press
cjne A, #11101110b, gedrueckt_else3
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #01h
	AJMP gedrueckt_nachif
gedrueckt_else3:
; 2 press
cjne A, #11011110b, gedrueckt_else4
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #02h
	AJMP gedrueckt_nachif
gedrueckt_else4:
; 3 press
cjne A, #10111110b, gedrueckt_else5
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #03h
	AJMP gedrueckt_nachif
;---------------------
gedrueckt_nachif:
; happy
call zeigen
ret
;-----------------------
gedrueckt_else5:
; Check 4er reihe
mov A, P2
ORL A, #0FFh
ANL A, #11111101b
MOV P2, A
MOV A, P2
; 4 press
cjne A, #11101101b, gedrueckt_else6
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #04h
	AJMP gedrueckt_nachif
gedrueckt_else6:
; 5 press
cjne A, #11011101b, gedrueckt_else7
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #05h
	AJMP gedrueckt_nachif
gedrueckt_else7:
; 6 press
cjne A, #10111101b, gedrueckt_else8
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #06h
	AJMP gedrueckt_nachif
gedrueckt_else8:
; Check 7er Reihe
mov A, P2
ORL A, #0Fh
ANL A, #11111011b
MOV P2, A
MOV A, P2
; 7 press
cjne A, #11101011b, gedrueckt_else9
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #07h
	AJMP gedrueckt_nachif
gedrueckt_else9:
; 8 press
cjne A, #11011011b, gedrueckt_else10
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #08h
	AJMP gedrueckt_nachif
gedrueckt_else10:
; 9 press
cjne A, #10111011b, gedrueckt_else_default
	mov A, P3
	ANL A, #10000000b
	cjne A, #0h, gedrueckt_nachif
	;shift digits
	call shift_display_digits
	mov R4, #09h
	AJMP gedrueckt_nachif

gedrueckt_else_default:
; nicht gedrückt flag setzen
mov A, P3
ANL A, #01111111b
mov P3, A
AJMP gedrueckt_nachif

shift_display_digits:
mov B, R6
mov R7, B
mov B, R5
mov R6, B
mov B, R4
mov R5, B
; gedrückt flag setzen
mov A, P3
ORL A, #10000000b
mov P3,A
ret

clear_display:
mov A, P3
ANL A, #10111111b
mov P3, A
mov R4, #0h
mov R5, #0h
mov R6, #0h
mov R7, #0h
ret

check_password:

mov A, P3
ORL A, #01000000b
mov P3, A
; password 4269
mov A, R4
CJNE A, #09h, fail
mov A, R5
CJNE A, #06h, fail
mov A, R6
CJNE A, #02h, fail
mov A, R7
CJNE A, #04h, fail

; succ
mov R7, #05h
mov R6, #0Dh
mov R5, #0Eh
mov R4, #0Eh
ret

fail:
mov R7, #0Ah
mov R6, #0Bh
mov R5, #01h
mov R4, #0Ch
ret

; F #0Ah
; A #0Bh
; I #01h
; L #0Ch
;
; S #05h
; U #0Dh
; C #0Eh
zeigen:
; 1. digit
mov DPTR, #displayDB
mov a, r7
;mov b, #0ah
;div ab
;xch a, b
movc a,@a+dptr
mov r3, a

; 2. digit
mov DPTR, #displayDB
mov a, r6
;mov b, #0ah
;div ab
;xch a, b
movc a,@a+dptr
mov r2, a

; 3. digit
mov DPTR, #displayDB
mov a, r5
;mov b, #0ah
;div ab
;xch a, b
movc a,@a+dptr
mov r1, a

; 4. digit
mov DPTR, #displayDB
mov a, r4
;mov b, #0ah
;div ab
;xch a, b
movc a,@a+dptr
mov r0, a

call display
ret

;-----------------------------------------------
;   DISPLAY: steuert die 4x7 Segmentanzeige
;-----------------------------------------------
display:
mov P1, R0
clr P0.0
setb P0.0

mov P1, R1
clr P0.1
setb P0.1

mov P1, R2
clr P0.2
setb P0.2

mov P1, R3
clr P0.3
setb P0.3

ret

; F #0Ah
; A #0Bh
; I #01h
; L #0Ch
;
; S #05h
; U #0Dh
; C #0Eh
;-------------------------------------------------
; TABLE: Datenbank der 7-Segment-Darstellung
;-------------------------------------------------
org 300h
displayDB:
db 11000000b
db 11111001b, 10100100b, 10110000b
db 10011001b, 10010010b, 10000010b
db 11111000b, 10000000b, 10010000b
db 10001110b, 10001000b, 11000111b
db 11000001b, 11000110b

end