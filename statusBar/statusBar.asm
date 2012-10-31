;--------------------------------------------------------;
; Status Bar Constants
;--------------------------------------------------------;



STATUS_REGION_PPU_SETTINGS = %10001000

SPRITE_ZERO_CHR_INDEX      = $FF
SPRITE_ZERO_ATTRIBUTES     = %00000000

; If the status area is 8 rows in height, place sprite zero on the first line of the 8th row somewhere on the left side of the screen
.ifdef TOP_STATUS
; When using the top, to keep OAM lined up, 8 for status and only 22 for remainder (11 meta per columns)
SPRITE_ZERO_Y_POS          = 54
SPRITE_ZERO_X_POS          = 20
STATUS_BAR_SIZE_IN_BYTES   = $FF ; 8 lines

.else
; When using the bottom, to keep OAM lined up, region is 24 rows (12 meta per column) and only 6 for status
SPRITE_ZERO_Y_POS          = 192
SPRITE_ZERO_X_POS          = 20
STATUS_BAR_SIZE_IN_BYTES   = $C0 ; 6 lines
.endif


.IFREF initStatusBarSpriteZero
initStatusBarSpriteZero:
 ; Sprite 0 is special. I am using it to create a status bar
 LDA #SPRITE_ZERO_Y_POS
 STA SPRITE_BANK
 LDA #SPRITE_ZERO_CHR_INDEX
 STA SPRITE_BANK+1
 LDA #SPRITE_ZERO_ATTRIBUTES
 STA SPRITE_BANK+2
 LDA #SPRITE_ZERO_X_POS
 STA SPRITE_BANK+3
rts
.ENDIF




setupStatusBar:
	; Overwrite the last 16 tiles of BG Tile Bank $0000 with 16 status tiles
 	LDA #<STATUS_BAR_TILES
	STA IIY_LOW
 	LDA #>STATUS_BAR_TILES
	STA IIY_HIGH
	LDA #$00
	LDX #$F0
	LDY #$10
	jsr LoadCHRSubset

	; Overwrite the last 1 tile of Sprite Tile Bank $0000 with 1 tile to use for SPR 0 Hits
 	LDA #<STATUS_BAR_TILES
	STA IIY_LOW
 	LDA #>STATUS_BAR_TILES
	STA IIY_HIGH
	LDA #$10
	LDX #$FF
	LDY #$01
	jsr LoadCHRSubset


	


        LDA $2002 ; reset latch

	; A is high address of dest nametable
	; X is low address of src data for status bar
	; Y is high address of src data for status bar
 	LDA #$20
        STA $2006
        LDA #$00 ; start writing to 2000
        STA $2006

 	LDA #<STATUS_BAR_NAMETABLE
	STA IIY_LOW
 	LDA #>STATUS_BAR_NAMETABLE
	STA IIY_HIGH

	; 256 bytes total ( 8 rows)
	LDX #$04
        ldy #$00
:       lda (IIY_LOW),y
        sta $2007
        iny
	BNE :-
        ldy #$00
	INC IIY_HIGH
	DEX
	BNE :-

 	LDA #$24
        STA $2006
        LDA #$00 ; start writing to nametable 2400
        STA $2006

 	LDA #<STATUS_BAR_NAMETABLE
	STA IIY_LOW
 	LDA #>STATUS_BAR_NAMETABLE
	STA IIY_HIGH

	; 256 bytes total ( 8 rows)
	LDX #$04
        ldy #$00
:       lda (IIY_LOW),y
        sta $2007
        iny
	BNE :-
        ldy #$00
	INC IIY_HIGH
	DEX
	BNE :-

        rts


