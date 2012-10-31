; Requires 2 Zero Page temp variables:
; REGION_CHECK_LOW (temp)
; REGION_CHECK_HIGH (temp)
; 
; Constant:
PAL_CUTOFF_VALUE        = $24 ; Used by REGION_CHECK

; The value of A is 1 for NTSC and 0 if PAL
regionDetect:

        ; lets determine NTSC or PAL
        ; According to Blargg and dvdmuth, if I write to APU and poll 4015
        ; I can keep a counter and determine if I am on NTSC or PAL
        lda #$40
        sta $4017 ; disable APU frame IRQ. this resets frame counter
        ; play a sound and keep polling 4015
        LDA #$00
        STA $4000
        STA $4001
        STA $4002
        ; LDA #%00011000 ; if uncommented this will reduce the sound length to 1
        STA $4003
TEST_REGION:
        INC REGION_CHECK_LOW
        BNE :+
        INC REGION_CHECK_HIGH
:
        LDA $4015
        AND #$01
        BNE TEST_REGION

        ; Based on the loops up above,
        ; In FCEU, the REGION_CHECK_HIGH value is 22(hex) NTSC and 26(hex) PAL
        ; So I will split the difference and say anything over 24 is PAL
        LDA REGION_CHECK_HIGH
        CMP #PAL_CUTOFF_VALUE
        BCC NTSC_MODE
	LDA #$00
	rts ; returning 0 in A to indicate PAL mode
NTSC_MODE:
	LDA #$01
	rts ; returning 1 in A to indicate NTSC mode


