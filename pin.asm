; Variables for keypad
keypad_1 equ 0x7f
mov keypad_1, #11101110b
keypad_2 equ 0x7E
mov keypad_2, #11011110b
keypad_3 equ 0x7D
mov keypad_3, #10111110b
keypad_4 equ 0x7C
mov keypad_4, #11101101b
keypad_5 equ 0x7B
mov keypad_5, #11011101b
keypad_6 equ 0x7A
mov keypad_6, #10111101b
keypad_7 equ 0x79
mov keypad_7, #11101011b
keypad_8 equ 0x78
mov keypad_8, #11011011b
keypad_9 equ 0x77
mov keypad_9, #10111011b
keypad_0 equ 0x76
mov keypad_0, #11010111b
keypad_enter equ 0x75
mov keypad_enter, #10110111b
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
mov A, P2
cjne A, #0FFh, gedrueckt
ret

gedrueckt:
mov A, P2
cjne A, keypad_enter, gedrueckt_else1
	; TODO: Passwort check routine
	AJMP gedrueckt_nachif
gedrueckt_else1:
;shift digits
mov B, R6
mov R7, B
mov B, R5
mov R6, B
mov B, R4
mov R5, B
; continue with if lel
cjne A, keypad_1, gedrueckt_else2
	mov R4, #01h
	AJMP gedrueckt_nachif
gedrueckt_else2:
cjne A, keypad_2, gedrueckt_else3
	mov R4, #02h
	AJMP gedrueckt_nachif
gedrueckt_else3:
cjne A, keypad_3, gedrueckt_else4
	mov R4, #03h
	AJMP gedrueckt_nachif
gedrueckt_else4:
cjne A, keypad_4, gedrueckt_else5
	mov R4, #04h
	AJMP gedrueckt_nachif
gedrueckt_else5:
cjne A, keypad_5, gedrueckt_else6
	mov R4, #05h
	AJMP gedrueckt_nachif
gedrueckt_else6:
cjne A, keypad_6, gedrueckt_else7
	mov R4, #06h
	AJMP gedrueckt_nachif
gedrueckt_else7:
cjne A, keypad_7, gedrueckt_else8
	mov R4, #07h
	AJMP gedrueckt_nachif
gedrueckt_else8:
cjne A, keypad_8, gedrueckt_else9
	mov R4, #08h
	AJMP gedrueckt_nachif
gedrueckt_else9:
cjne A, keypad_9, gedrueckt_else0
	mov R4, #09h
	AJMP gedrueckt_nachif
gedrueckt_else0:
	mov R4, #00h
	AJMP gedrueckt_nachif
gedrueckt_nachif:
; happy
mov P2, #0FFh
call zeigen
ret



zeigen:
; 1. digit
mov DPTR, #displayDB
mov a, r7
mov b, #0ah
div ab
xch a, b
movc a,@a+dptr
mov r3, a

; 2. digit
mov DPTR, #displayDB
mov a, r6
mov b, #0ah
div ab
xch a, b
movc a,@a+dptr
mov r2, a

; 3. digit
mov DPTR, #displayDB
mov a, r5
mov b, #0ah
div ab
xch a, b
movc a,@a+dptr
mov r1, a

; 4. digit
mov DPTR, #displayDB
mov a, r4
mov b, #0ah
div ab
xch a, b
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


;-------------------------------------------------
; TABLE: Datenbank der 7-Segment-Darstellung
;-------------------------------------------------
org 300h
displayDB:
db 11000000b
db 11111001b, 10100100b, 10110000b
db 10011001b, 10010010b, 10000010b
db 11111000b, 10000000b, 10010000b


end