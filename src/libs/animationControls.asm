; File: animationControls.asm
;
;  This file contains routines that are used in setting up and processing animations.
;  An example of this would be to animate a title screen
;


; -------------------------------------------------------------------------------------------------------------------------------
; initializeAnimations 
; -------------------------------------------------------------------------------------------------------------------------------
;
; -------------------------------------------------------------------------------------------------------------------------------
; Sample usage:
; LDX #<animationDataAddress
; LDY #>animationDataAddress
; JSR initializeAnimations
; -------------------------------------------------------------------------------------------------------------------------------

;  Require 9 ZP variables.  
;  NMI_COUNTER
;  NUM_ANIMATIONS
;  ANIMATION_DURATION
;  TEMP_VAR1 and TEMP_VAR2 (consecutive bytes)
;  ANIMATIONDATA_LOW and ANIMATIONDATA_HIGH (consecutive bytes)
;  SPRITEDATA_LOW and SPRITEDATA_HIGH (consecutive bytes)

; Requires a special constant
; SPRITE_BANK = $0300



.IFNDEF NMI_COUNTER
.ERROR  "Need to declare ZP variable called NMI_COUNTER"
.ENDIF

.IFNDEF NUM_ANIMATIONS
.ERROR "Need to declare ZP variable called NUM_ANIMATIONS"
.ENDIF

.IFNDEF ANIMATION_DURATION
.ERROR "Need to declare ZP variable called ANIMATION_DURATION"
.ENDIF


.IFNDEF TEMP_VAR1
.ERROR "Need to declare ZP variable called TEMP_VAR1"
.ENDIF

.IFNDEF TEMP_VAR2
.ERROR "Need to declare ZP variable called TEMP_VAR2"
.ENDIF

.IFNDEF ANIMATIONDATA_LOW
.ERROR "Need to declare ZP variable called ANIMATIONDATA_LOW"
.ENDIF

.IFNDEF ANIMATIONDATA_HIGH
.ERROR "Need to declare ZP variable called ANIMATIONDATA_HIGH"
.ENDIF

.IFNDEF SPRITEDATA_LOW
.ERROR "Need to declare ZP variable called SPRITEDATA_LOW"
.ENDIF

.IFNDEF SPRITEDATA_HIGH
.ERROR "Need to declare ZP variable called SPRITEDATA_HIGH"
.ENDIF

.IFNDEF SPRITE_BANK
.ERROR "Need to define a constant called SPRITE_BANK.  Example SPRITE_BANK = $0300"
.ENDIF


initializeAnimations:
	; Step 1: put the src address into zero page so we can start reading the stuff
	STX TEMP_VAR1 ; X had the low byte of the src address
	STY TEMP_VAR2 ; Y had the high byte of the src address

	LDA #$00
	STA NMI_COUNTER

	; Now query the first two bytes to num animations and their duration
	LDY #$00
	LDA (TEMP_VAR1),Y
	STA NUM_ANIMATIONS
	INY
	LDA (TEMP_VAR1),Y
	STA ANIMATION_DURATION

	INC TEMP_VAR1  ; Move forward 2 bytes to where the animation sequences start
	BNE :+
	INC TEMP_VAR2 
:
	INC TEMP_VAR1 
	BNE :+
	INC TEMP_VAR2
:

	; Now need to store the starting address of where the animations are
	; and where the sprite data is stored
	LDA TEMP_VAR1
	STA ANIMATIONDATA_LOW
	STA SPRITEDATA_LOW
	LDA TEMP_VAR2
	STA ANIMATIONDATA_HIGH
	STA SPRITEDATA_HIGH

	CLC
	INC SPRITEDATA_LOW
	BCC :+
	INC SPRITEDATA_HIGH
:
	LDX NUM_ANIMATIONS
	BEQ @endInitAnimations

@nextAnimationStep:
	CLC
	LDA ANIMATION_DURATION
	ADC SPRITEDATA_LOW
	STA SPRITEDATA_LOW
	BCC @skipNextHighInc
	INC SPRITEDATA_HIGH

@skipNextHighInc:
	DEX
        BNE @nextAnimationStep	
	
@endInitAnimations:
	rts

; -------------------------------------------------------------------------------------------------------------------------------

processNextAnimation:
	LDA NUM_ANIMATIONS
	BEQ @doneNextAnimation
	; If we are here it means there are some animations

	LDA ANIMATIONDATA_LOW
	STA IIY_LOW
	LDA ANIMATIONDATA_HIGH
	STA IIY_HIGH

	LDX #$00
:      
	TXA ; Store X on the stack for now
	PHA
	ASL A
	ASL A
	TAX

	LDY NMI_COUNTER
	lda ( IIY_LOW ),y  
	BEQ @skipSprite
	SEC
	SBC #$01
	ASL A
	ASL A

	TAY

	LDA (SPRITEDATA_LOW),Y
	STA SPRITE_BANK,X

	INY
	LDA (SPRITEDATA_LOW),Y
	STA SPRITE_BANK+1,X

	INY
	LDA (SPRITEDATA_LOW),Y
	STA SPRITE_BANK+2,X

	INY
	LDA (SPRITEDATA_LOW),Y
	STA SPRITE_BANK+3,X

@skipSprite:
	CLC
	LDA ANIMATION_DURATION 
	ADC IIY_LOW
	STA IIY_LOW
	BCC @skipOver
	INC IIY_HIGH
@skipOver:
	PLA
	TAX

	INX
	CPX NUM_ANIMATIONS
	BNE :-


	CLC
	INC NMI_COUNTER
	LDA NMI_COUNTER
	CMP ANIMATION_DURATION
	BCC :+
	LDA #$00
	STA NMI_COUNTER
:
	
@doneNextAnimation:
	rts

