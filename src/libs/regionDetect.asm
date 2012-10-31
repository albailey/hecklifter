; Does an NTSC region check
; Constants:
; In FCEU the high byte value on NTSC is 29 and is 2E on PAL so I split the difference at 2C
PAL_CUTOFF_VALUE = $2C

.IFREF determine_NTSC_PAL_Mode
determine_NTSC_PAL_Mode:
        ; lets determine NTSC or PAL
        ; According to Blargg and dvdmuth, if I write to APU and poll 4015
        ; I can keep a counter and determine if I am on NTSC or PAL
        LDA #$40
        STA $4017 ; disable APU frame IRQ. this resets frame counter
        ; play a sound and keep polling 4015
        LDA #$00
        STA $4000
        STA $4001
        STA $4002
        ; LDA #%00011000 ; if uncommented this will reduce the sound length to 1
        STA $4003

	; USE X and Y for the variables
	LDX #$00
	LDY #$00
:
        INX 
        BNE :+
        INY 
:
        LDA $4015
        AND #$01
        BNE :--

	STX TEMP_VAR1
	STY TEMP_VAR2

	LDX #$00 ; discard low counter and replace its value with 0 for NTSC
        CPY #PAL_CUTOFF_VALUE
        BCC :+
	INX ; If we are here we are PAL, so lets make the value 1
:
	; The X register when returning from this method has 0 for NTSC or 1 for PAL
        rts
.ENDIF

