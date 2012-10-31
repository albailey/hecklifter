
; Assume that a variable called TEMP_VAR1 is on Zero Page
; Fast Multiply by 10
; Mult10 was referenced on www.6502.org and is credited to
; Leo Nechaev (leo@ogpi.orsk.ru), 28 October 2000.
; 
; Description:
; Takes the value located in the accumulator and multiplies it by 10, the result is also in the accumulator
; It does this because of the mathematical fact than N*10 = N*8 + N*2 which are simple and fast to perform
;
; Requirments:
;   requires a Variable called TEMP_VAR1 be declared on zero page
;

.IFREF MULT10



.IFNDEF TEMP_VAR1
.ERROR "MULT10 requires TEMP_VAR1 to be declared to hold the result"
.ENDIF

MULT10:
        ASL            ; multiply Accumulator by 2 (A=N*2)
        STA TEMP_VAR1  ; store accumulator in TEMP_VAR1 (N*2)
        ASL            ; multiply Accumulator by 2 (A=N*4)
        ASL            ; again multiply by 2 (A=N*8)
        CLC	       ; clear carry. 
        ADC TEMP_VAR1  ; A = N*8 + N*2
        RTS
.ENDIF



