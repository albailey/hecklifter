; ********************
; Input reoutines for querying joypads
;
; Written on: July 30, 2007
; ********************


; The default optimization is SPEED
; If you wish to save a small amount of space, at the expense of a few additonal cycles 
; then turn on the following DEFINE
; OPTIMIZE_FOR_SIZE = 1


;  The 8 bits reflect the joypad1 and joypad2 status
; Bit 1 = A Button
; Bit 2 = B Button
; Bit 3 = Select Button
; Bit 4 = Start Button
; Bit 5 = Up Joypad
; Bit 6 = Down JoyPad
; Bit 7 = Left Joypad
; Bit 8 = Right JoyPad
;
; If the constants.asm file is included, one way to determine which buttons are pressed
; Is to do an AND with different MASKs to figure out which bits are set
;JOY_A_MASK              = $01
;JOY_B_MASK              = $02
;JOY_SELECT_MASK         = $04
;JOY_START_MASK          = $08
;JOY_UP_MASK             = $10
;JOY_DOWN_MASK           = $20
;JOY_LEFT_MASK           = $40
;JOY_RIGHT_MASK          = $80
;
; Also, you can determine if a button has changed state (pressed or released) by checking 
; for JOY1 CURRENT_JOY1_STATUS as well as the LAST_JOY1_STATUS 
; for joy2 CURRENT_JOY2_STATUS as well as the LAST_JOY2_STATUS 
;

; Requires 4 bytes (usually in zero page).   
; -  LAST_JOY1_STATUS
; -  CURRENT_JOY1_STATUS
; -  LAST_JOY2_STATUS
; -  CURRENT_JOY2_STATUS
;

; Note: when these subroutines returns: 
; - A register may be changed
; - X register will be zero
; - Zero flag will be set (by the last DEX)
; - Negative flag will be clear (by the last DEX)
; - Carry flag MAY be set (by the last ROR)
;

.IFNDEF JOY_A_MASK              
JOY_A_MASK              = $01
.ENDIF

.IFNDEF JOY_B_MASK              
JOY_B_MASK              = $02
.ENDIF

.IFNDEF JOY_SELECT_MASK              
JOY_SELECT_MASK         = $04
.ENDIF

.IFNDEF JOY_START_MASK              
JOY_START_MASK          = $08
.ENDIF

.IFNDEF JOY_UP_MASK              
JOY_UP_MASK             = $10
.ENDIF

.IFNDEF JOY_DOWN_MASK              
JOY_DOWN_MASK           = $20
.ENDIF

.IFNDEF JOY_LEFT_MASK              
JOY_LEFT_MASK           = $40
.ENDIF

.IFNDEF JOY_RIGHT_MASK              
JOY_RIGHT_MASK          = $80
.ENDIF



; ********************
;
; getJoyPadBothInput
; (untested)
;
; When this subroutine is invoked the following occurs:
;  - The contents of CURRENT_JOY1_STATUS are copied into LAST_JOY1_STATUS
;  - Joy1 is strobed and its values are copied into CURRENT_JOY1_STATUS
;  - The contents of CURRENT_JOY2_STATUS are copied into LAST_JOY2_STATUS
;  - Joy2 is strobed and its values are copied into CURRENT_JOY2_STATUS
; ********************
.IFREF getBothJoyPadInputs

.IFNDEF LAST_JOY1_STATUS
.ERROR "You need to declare the variable LAST_JOY1_STATUS"
.ENDIF

.IFNDEF CURRENT_JOY1_STATUS
.ERROR "You need to declare the variable CURRENT_JOY1_STATUS"
.ENDIF

.IFNDEF LAST_JOY2_STATUS
.ERROR "You need to declare the variable LAST_JOY2_STATUS"
.ENDIF

.IFNDEF CURRENT_JOY2_STATUS
.ERROR "You need to declare the variable CURRENT_JOY2_STATUS"
.ENDIF

getBothJoyPadInputs:
        LDA CURRENT_JOY1_STATUS
        STA LAST_JOY1_STATUS
        LDA CURRENT_JOY2_STATUS
        STA LAST_JOY2_STATUS

        ; strobe joypad
        LDX #$09 ; bit zero is 1
        stx $4016 ; $4016 is JOY1
        stx $4017 ; $4017 is JOY1
        DEX
        stx $4016 ; bit 0 is zero. $4016 is JOY1
        stx $4017 ; bit 0 is zero. $4017 is JOY2
        ; Now we read 8 times from Joy1 and Joy2
:       
	; First Joy1
	LDA $4016 ; $4016 is JOY1
        LSR A
        ROR CURRENT_JOY1_STATUS
	; Next Joy2
	LDA $4017 ; $4017 is JOY2
        LSR A
        ROR CURRENT_JOY2_STATUS
        DEX
        BNE :-
        rts

.ENDIF


; ********************
;
; getJoyPad1Input
;
; ********************
;
; When this subroutine is invoked the following occurs:
;  - The contents of CURRENT_JOY1_STATUS are copied into LAST_JOY1_STATUS
;  - Joy1 is strobed and its values are copied into CURRENT_JOY1_STATUS
;  The 8 bits reflect the joypad1 status
;
; Also, you can determine if a button has changed state (pressed or released) by checking the
; CURRENT_JOY1_STATUS as well as the LAST_JOY1_STATUS
;
; Requires 2 ZeroPage variables.   
; -  LAST_JOY1_STATUS
; -  CURRENT_JOY1_STATUS
;


.IFREF getJoyPad1Input

.IFNDEF LAST_JOY1_STATUS
.ERROR "You need to declare the variable LAST_JOY1_STATUS"
.ENDIF

.IFNDEF CURRENT_JOY1_STATUS
.ERROR "You need to declare the variable CURRENT_JOY1_STATUS"
.ENDIF

getJoyPad1Input:

.IFDEF OPTIMIZE_FOR_SIZE
; ----------------------------------------------------------------------------------------------
; This way uses a COUNTER and is not optimized for SIZE instead of SPEED 
; This is actually 39 bytes smaller than the one compiled for speed.
; Coincidentally it is also 39 CPU cycles slower 
; ----------------------------------------------------------------------------------------------
        LDA CURRENT_JOY1_STATUS
        STA LAST_JOY1_STATUS

        ; strobe joypad
        LDX #$09 ; bit zero is 1
        stx $4016 ; $4016 is JOY1
        DEX
        stx $4016 ; bit 0 is zero. $4016 is JOY1
        ; Now we read 8 times from Joy1
:       LDA $4016 ; $4016 is JOY1;   4 cycles
        LSR A     ; 2 cycles
        ROR CURRENT_JOY1_STATUS  ; 5 cycles
        DEX ;  2 cycles
        BNE :- ; 7x3 + 2 cycles
        rts
.ELSE
; ----------------------------------------------------------------------------------------------
; This way is optimized for SPEED instead of SIZE
; By unrolling the loop we eliminate the DEX and BNE
; Saves: 39 CPU cycles which is 117 PPU cycles (there are 341 PPU cycles per scanline)
; ----------------------------------------------------------------------------------------------

        LDA CURRENT_JOY1_STATUS
        STA LAST_JOY1_STATUS

        ; strobe joypad
        LDX #$01 ; bit zero is 1
        stx $4016 ; $4016 is JOY1
        DEX
        stx $4016 ; bit 0 is zero. $4016 is JOY1

        ; Now we read 8 times from Joy1
        LDA $4016 ; $4016 is JOY1
        LSR A
        ROR CURRENT_JOY1_STATUS
        LDA $4016 ; $4016 is JOY1
        LSR A
        ROR CURRENT_JOY1_STATUS
        LDA $4016 ; $4016 is JOY1
        LSR A
        ROR CURRENT_JOY1_STATUS
        LDA $4016 ; $4016 is JOY1
        LSR A
        ROR CURRENT_JOY1_STATUS
        LDA $4016 ; $4016 is JOY1
        LSR A
        ROR CURRENT_JOY1_STATUS
        LDA $4016 ; $4016 is JOY1
        LSR A
        ROR CURRENT_JOY1_STATUS
        LDA $4016 ; $4016 is JOY1
        LSR A
        ROR CURRENT_JOY1_STATUS
        LDA $4016 ; $4016 is JOY1
        LSR A
        ROR CURRENT_JOY1_STATUS
        rts
.ENDIF
.ENDIF


; ********************
;
; getJoyPad2Input
;
; ********************
;
; When this subroutine is invoked the following occurs:
;  - The contents of CURRENT_JOY2_STATUS are copied into LAST_JOY2_STATUS
;  - Joy1 is strobed and its values are copied into CURRENT_JOY2_STATUS
;  The 8 bits reflect the joypad1 status
;
; Also, you can determine if a button has changed state (pressed or released) by checking the
; CURRENT_JOY2_STATUS as well as the LAST_JOY2_STATUS
;
; Requires 2 ZeroPage variables.   
; -  LAST_JOY2_STATUS
; -  CURRENT_JOY2_STATUS
;


.IFREF getJoyPad2Input

.IFNDEF LAST_JOY2_STATUS
.ERROR "You need to declare the variable LAST_JOY2_STATUS"
.ENDIF

.IFNDEF CURRENT_JOY2_STATUS
.ERROR "You need to declare the variable CURRENT_JOY2_STATUS"
.ENDIF

getJoyPad2Input:

.IFDEF OPTIMIZE_FOR_SIZE
; ----------------------------------------------------------------------------------------------
; This way uses a COUNTER and is not optimized for SIZE instead of SPEED 
; This is actually 39 bytes smaller than the one compiled for speed.
; Coincidentally it is also 39 CPU cycles slower 
; ----------------------------------------------------------------------------------------------
        LDA CURRENT_JOY2_STATUS
        STA LAST_JOY2_STATUS

        ; strobe joypad
        LDX #$09 ; bit zero is 1
        stx $4017 ; $4017 is JOY2
        DEX
        stx $4017 ; bit 0 is zero. $4017 is JOY2
        ; Now we read 8 times from Joy1
:       LDA $4017 ; $4017 is JOY2;   4 cycles
        LSR A     ; 2 cycles
        ROR CURRENT_JOY2_STATUS  ; 5 cycles
        DEX ;  2 cycles
        BNE :- ; 7x3 + 2 cycles
        rts
.ELSE
; ----------------------------------------------------------------------------------------------
; This way is optimized for SPEED instead of SIZE
; By unrolling the loop we eliminate the DEX and BNE
; Saves: 39 CPU cycles which is 117 PPU cycles (there are 341 PPU cycles per scanline)
; ----------------------------------------------------------------------------------------------

        LDA CURRENT_JOY2_STATUS
        STA LAST_JOY2_STATUS

        ; strobe joypad
        LDX #$01 ; bit zero is 1
        stx $4017 ; $4017 is JOY2
        DEX
        stx $4017 ; bit 0 is zero. $4017 is JOY2

        ; Now we read 8 times from Joy1
        LDA $4017 ; $4017 is JOY2
        LSR A
        ROR CURRENT_JOY2_STATUS
        LDA $4017 ; $4017 is JOY2
        LSR A
        ROR CURRENT_JOY2_STATUS
        LDA $4017 ; $4017 is JOY2
        LSR A
        ROR CURRENT_JOY2_STATUS
        LDA $4017 ; $4017 is JOY2
        LSR A
        ROR CURRENT_JOY2_STATUS
        LDA $4017 ; $4017 is JOY2
        LSR A
        ROR CURRENT_JOY2_STATUS
        LDA $4017 ; $4017 is JOY2
        LSR A
        ROR CURRENT_JOY2_STATUS
        LDA $4017 ; $4017 is JOY2
        LSR A
        ROR CURRENT_JOY2_STATUS
        LDA $4017 ; $4017 is JOY2
        LSR A
        ROR CURRENT_JOY2_STATUS
        rts
.ENDIF
.ENDIF




