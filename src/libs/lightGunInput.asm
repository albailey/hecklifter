; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File: lightGunInput.asm
;
; Purpose:
;  To provide subroutines for querying lightgun input
;
; Pre-requisites:
;  Memory names must be declared (preferably in zero page)
;  Constants must be defined to turn on the required functionality
;
; What do the subroutines do:
;   jsr checkLightGun1Trigger  populates the A register with 1 if the trigger of lightgun 1 is pressed and 0 if it is not. This routine can be called once per NMI
;   jsr checkLightGun2Trigger  populates the A register with 1 if the trigger of lightgun 2 is pressed and 0 if it is not. This routine can be called once per NMI
;
;   jsr checkLightGun1LightSensor populates the A register with 0 for lightgun 1 if light is not detected and non zero (8) if light is detected. This routine NEEDS to be called during the drawing of the screen. 
;   jsr checkLightGun2LightSensor populates the A register with 0 for lightgun 2 if light is not detected and non zero (8) if light is detected. This routine NEEDS to be called during the drawing of the screen. 
;   
; Usage:
;  To check the trigger of a particular lightgun
;   a) set the constant LIGHTGUN1_ENABLED=1 for lightgun 1, or LIGHTGUN2_ENABLED=1 for lightgun 2
;   b) During NMI check the trigger (if you want to) through the checkLightGun1Trigger and the 0 or 1 in the A register
;   c) After returning from NMI, during the inifinite loop, repeatedly call checkLightGun1LightSensor and check the A register
;




; ********************
;
; checkLightGun1Trigger
;
; ********************
; Populates the A register with 1 if trigger is pressed or zero if it is not
; Bit 4 = Light sensed (1 if true, 0 if not)
; Bit 5 = Trigger (1 if pressed, 0 if not)
;

.IFNDEF LIGHTGUN1_REGISTER
LIGHTGUN1_REGISTER  = $4016
.ENDIF

.IFREF checkLightGun1Trigger 
checkLightGun1Trigger:
	LDA LIGHTGUN1_REGISTER
	AND #%00010000  ; check if trigger pressed
	BEQ :+    ; branch if the value is now zero, meaning trigger not pressed
	LDA #$01
:
	RTS
.ENDIF

.IFREF checkLightGun1LightSensor
; VERY IMPORTANT.   Need to query the lightgun each scanline, and during the render (ie: not vblank)
checkLightGun1LightSensor:
	LDA LIGHTGUN1_REGISTER
	AND #%00001000  ; clear all the bits except the white detection bit
	RTS

.ENDIF



; ********************
;
; checkLightGun2Trigger
;
; ********************
; Populates the A register with 1 if trigger is pressed or zero if it is not
; Bit 4 = Light sensed (1 if true, 0 if not)
; Bit 5 = Trigger (1 if pressed, 0 if not)
;

.IFNDEF LIGHTGUN2_REGISTER
LIGHTGUN2_REGISTER  = $4017
.ENDIF

.IFREF checkLightGun2Trigger
checkLightGun2Trigger:
	LDA LIGHTGUN2_REGISTER
	AND #%00010000  ; check if trigger pressed
	BEQ :+    ; branch if the value is now zero, meaning trigger not pressed
	LDA #$01
:
	RTS
.ENDIF


.IFREF checkLightGun2LightSensor
; VERY IMPORTANT.   Need to query the lightgun each scanline, and during the render (ie: not vblank)
checkLightGun2LightSensor:
	LDA LIGHTGUN2_REGISTER
	AND #%00001000  ; clear all the bits except the white detection bit
	RTS

.ENDIF

