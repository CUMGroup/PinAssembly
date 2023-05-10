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
mov P2,#00h

; R4 - R7 : Digits
mov R4, #0h
mov R5, #0h
mov R6, #0h
mov R7, #0h

call zeigen

hauptloop:
call display
ajmp hauptloop


zeigen:
; 1. digit
mov DPTR, #table
mov a, r7
mov b, #0ah
div ab
xch a, b
movc a,@a+dptr
mov r3, a

; 2. digit
mov DPTR, #table
mov a, r6
mov b, #0ah
div ab
xch a, b
movc a,@a+dptr
mov r2, a

; 3. digit
mov DPTR, #table
mov a, r5
mov b, #0ah
div ab
xch a, b
movc a,@a+dptr
mov r1, a

; 4. digit
mov DPTR, #table
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
table:
db 11000000b
db 11111001b, 10100100b, 10110000b
db 10011001b, 10010010b, 10000010b
db 11111000b, 10000000b, 10010000b

end