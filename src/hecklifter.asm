; -------------------------------------------------------------------------------------------------------
;   COMPILER  DEFINES
; Uncomment the next line to view the line on the screen indicating how much CPU we have used
; -------------------------------------------------------------------------------------------------------
; DEV_MODE		= 1
; -------------------------------------------------------------------------------------------------------
;
; Uncomment the next line to view debug info on the screen
; -------------------------------------------------------------------------------------------------------
  DEBUG_MODE            = 1
; -------------------------------------------------------------------------------------------------------
;
; Uncomment the next line to use alternative functions that have been optimized for speed at the expense of size
; We can turn this on or off based on the amount of space we use in the main bank $C000-$FFFF though I doubt we will
; run out of space
; -------------------------------------------------------------------------------------------------------
; OPTIMIZE_FOR_SPEED	= 1
; -------------------------------------------------------------------------------------------------------
 TOP_STATUS = 1
; -------------------------------------------------------------------------------------------------------


.segment "INES_HEADER"
   ; This is an MMC1 SNROM file for a 256 KB PRG, 0 CHR and Battery backed SRAM and vertical mirroring
  .byt "NES", 26
  .byt 16  ; number of 16 KB program segments
  .byt 0  ; number of 8 KB chr segments
  .byt 19 ; The upper byte is the mapper number, the lower byte is the mapper info ( mirroring, etc)
  .byt 0  ; extended mapper info
  .byt 0,0,0,0,0,0,0,0  ; the rest of the header is empty



.segment "BANKF"

; Note Famitracker uses memory from $0000- $000F, and $0200-$02DC
; Note $A0 to $FF is reserved for the game engine

VBLANK_COUNTER          = $17
CHANGE_DETECTION_FLAG   = $18
STATE_MACHINE		= $19
SUB_STATE_MACHINE_1	= $1A
SUB_STATE_MACHINE_2	= $1B
SUB_STATE_MACHINE_2_HIGH = $1C

FADE_DIRECTION           = $1D
FADE_COUNTER             = $1E
CURRENT_BG_INTENSITY     = $1F



BG_PAL_CURRENT           = $20 ; 16 bytes
BG_PAL_TARGET            = $30 ; 16 bytes

GRAPHICS_UPDATE_ADDR_LOW = $40 
GRAPHICS_UPDATE_ADDR_HIGH= $41
TEXT_ADDR_LOW		 = $42 
TEXT_ADDR_HIGH           = $43 
TEXT_OFFSET              = $44

NMI_COUNTER		 = $45
NUM_ANIMATIONS           = $46
ANIMATION_DURATION       = $47
ANIMATIONDATA_LOW        = $48
ANIMATIONDATA_HIGH       = $49
SPRITEDATA_LOW           = $4A
SPRITEDATA_HIGH          = $4B
CURRENT_BANK             = $4C    
NMI_MODE		= $4D
FPS_VALUE		= $4E
RND_MOD			= $4F

TEMP_VAR0		= $50
TEMP_VAR1		= $51
TEMP_VAR2		= $52
TEMP_VAR3		= $53
TEMP_VAR4		= $54
TEMP_VAR5		= $55
TEMP_VAR6		= $56
TEMP_VAR7		= $57

; for random
RND_TMP			= $58 ; this must be 4 bytes in size
			; $59
			; $5A
			; $5B
RND_SEED0		= $5C
RND_SEED1		= $5D
RND_SEED2		= $5E
RND_SEED3		= $5F



JMP_LOW		 	= $60 ; For using ZP based JMP
JMP_HIGH	 	= $61
IIY_LOW 		= $62	; temp var
IIY_HIGH 		= $63	; temp var
IIY_ALT_LOW             = $64
IIY_ALT_HIGH            = $65
META_LOW                = $66
META_HIGH               = $67
OAM_COLUMN_BIT_MASK     = $68
OAM_TEMP                = $69
COLLISION_TEMP          = $6A
LAST_MOVE_SUCCESSFUL    = $6B
LAST_JOY1_STATUS        = $6C
CURRENT_JOY1_STATUS     = $6D
LAST_PRESS              = $6E
REST_COUNTER            = $6F



; Player variables
PLAYER_STATE             = $70
PLAYER_ANIMATION_STATE   = $71
PLAYER_ANIMATION_COUNTER = $72
PLAYER_SUB_STATE         = $73
PLAYER_ORIENTATION       = $74

PLAYER_TOP_LEFT_X        = $75
PLAYER_TOP_LEFT_Y        = $76
PLAYER_JUMP              = $77
PLAYER_SPEED             = $78
PLAYER_WEAPON            = $79
PLAYER_STATE_COUNTER     = $7A ; duration of a jump, reload of a weapon, etc..
; more room
HELPER                   = $7F


; Level variables
TMP_NUM_COLUMNS         = $80
COLUMN_TO_LOAD          = $81
COLUMN_TO_STORE         = $82
TMP_NUM_TILES           = $83
TMP_NUM_TILES_REMAINDER = $84
LEVEL                    = $85
LEVEL_OFFSET             = $86
SCROLL_POSITION            = $87 ; value 0 to 255
CURRENT_SCREEN_COLUMN      = $88 ; column index of the left edge of the screen (0 to 31)
CURRENT_MAP_COLUMN         = $89 ; column index of the MAP for the left edge of the screen (0 to N where N is size of the map)
CURRENT_PAGE               = $8A
MAX_PAGE                   = $8B
MAX_COLUMNS                = $8C
CURRENT_PAGE_PPU_SETTINGS  = $8D
TILE_BANK		   = $8E
METATILE_BANK		   = $8F

; Required for regionDetection.asm
REGION_CHECK_LOW	= $90  ; These can be assigned to a TEMP value like the ones above
REGION_CHECK_HIGH	= $91  ; These can be assigned to a TEMP value like the ones above
nextvarmarker            = $93 


; $0100 is the stack
; $0200  is used for music
; $0300 is the sprite page

SPRITE_BANK = $0300


;=---------------------------------------------------------------
; My constants
;=---------------------------------------------------------------
CUT_SCENE_DURATION	= $FD ;  - Note Cut Scene Duration (low byte) should be >= Fade Step Duration * 4
CUT_SCENE_DURATION_HIGH = $01

SCREEN_TEXT_START_HIGH	= $22 
SCREEN_TEXT_START_LOW	= $A6

SPRITE_PAGE		= $03

; Next 2 are flags for the
STATE_CHANGED		= $01
STATE_UNCHANGED		= $00

CUT_SCENE_STATE		= $00
TITLE_SCREEN_STATE	= $01
WEAPON_SELECT_STATE	= $02
GAME_ENGINE_STATE	= $03


COLOUR_BLACK            = $0F

BG_INTENSITY_0          = $00
BG_INTENSITY_1          = $0F
BG_INTENSITY_2          = $1F
BG_INTENSITY_3          = $2F
BG_INTENSITY_4          = $3F

FADE_NONE               = $00
FADE_UP                 = $01
FADE_DOWN               = $02

FADE_STEP_DURATION      = $18 ; frames for each step of fade (5 steps)




;=---------------------------------------------------------------


;--------------------------------------------------------;
;              RESET                                     ;
; The reset needs to do the following(in this order):    ;
;                                                        ;
; - Disable interrupts (not needed on a real NES  )      ;
;                                                        ;
; - Clear the decimal flag (not needed on a real NES)    ;
;                                                        ;
; - Disable APU frame IRQs (not really needed unless     ;
;   using a mapper that generates IRQs                   ;
;                                                        ;
; - Disable PPU NMIs($2000) and rendering($2001)         ;
;                                                        ;
; - Clear out RAM and reset the stack memory             ;
;                                                        ;
; - Initialize game variables, etc..                     ;
;                                                        ;
; - Initialize the mapper (if one is being used)         ;
;                                                        ;
; - Wait 2 VBlanks for the PPU to get sane               ;
;                                                        ;
; - Initialize graphics                                  ;
;    - load in the palette                               ;
;    - init sprites                                      ;
;    - load in the name tables                           ;
;    - setup scrolling                                   ;
;                                                        ;
; - Initialize Sound                                     ;
;                                                        ;
; - Setup the PPU registers                              ;
;                                                        ;
;--------------------------------------------------------;

resetHandler:

	; Step 1: I dont have IRQs and dont have Decimal Mode, so turn them off
        sei ; disable IRQ interrupts (since I never use them)
        cld ; clear decimal flag (not really needed)

	lda #$40
	sta $4017 ; disable APU frame IRQ

	lda #$00
	sta $4010 ; disable DMC IRQs

	; Step 2: Disable PPU NMIs and rendering
	;lda #$00 ; I already assigned $00 to A up above
	sta $2000
	sta $2001

        ; Step 3: Clear the RAM and Reset the stack.
        ;   There are 7 memory pages of 256 bytes. ($0000 to $07FF)
	; PRG RAM is located from $6000 to $7FFF so may also be cleared
	; unless it is intended to survive a reset (like a high score)
        ; We can make use of an x register and loop until it loops around to 0
	; Note: my program only uses pages: 0,1,2,3 but I do the rest anyways
        lda #$00
        ldx #$00
:	sta $0000,x ; CA65 will compile $0000,X as $00,X which is more efficient
        sta $0100,x
        sta $0200,x
        sta $0300,x
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
	; omitting the code that would clear 6000 to 7FFF 
	; sta $6000,x
	; sta $6100,x
	; etc...
	; sta $7F00,x
        inx
        bne :- ; X will loop around to zero after 256 entries. branch if  X != 0

        ; Reset the stack pointer
        ldx #$FF
        txs



        ; Step 4: Initialize Game variables
	; all the zero page variables were set to #$00 up above.
	; If any variable needs to be set to NON zero at startup, its done here

	LDA #<doNothingGraphicsUpdate
	STA GRAPHICS_UPDATE_ADDR_LOW
	LDA #>doNothingGraphicsUpdate
	STA GRAPHICS_UPDATE_ADDR_HIGH

	; setup some arbitrary numbers for the RND SEED
	; these will be incremented/decremented elsewhere
	LDA #$A3
	STA RND_SEED0
	LDA #$07
	STA RND_SEED1
	LDA #$C1
	STA RND_SEED2
	LDA #$25
	STA RND_SEED3

	; Step 5: Initialize Mapper
	; MMC1
	LDX #%00011110 ; 4K CHR blocks. Swap PRG at $8000. Vertical mirroring (for horizontal scrolling)
	jsr initMMC1Mapper
	; After calling initMMC1Mapper
	; CHR0000 will be CHR bank 0
	; CHR1000 will be CHR bank 1
	; PRG $8000 will be bank 0
	LDA #$00
  	STA CURRENT_BANK



        ; Step 6: init sprite information
	;
	; Clear all sprite info
	;64 sprites. 4 bytes each. 256 bytes total (1 page)
	; Byte 0 - Y position of top of sprite
	; Byte 1 - Tile Index Number (for 8x8 sprites)
	;     - For 8x16 sprites
	;        bits 7..1 tile number of top of spite (0 to 254)
	;	 bit 0: bank $0000 or $1000 of tiles.
	; Byte 2 - Attributes
	;          bit7-flip sprite vertically
	;          bit6-flip sprite horizontally
	;          bit5-priority. (0:in front of background. 1:behind background
	;          bit4-unimplemented
	;          bit4,3,2-unimplemented
	;          bit1,0-palette (4 to 7) of sprite
	; Byte 3 - X position of left side of sprite (F9-FF do NOT wrap to left)

	; we will just set F0 as the y Position and 00 for all other attributes
        JSR resetSprites

	; Step 7:  *** WAIT 2 VBLANKS ***
:	lda $2002 ; (anonymous label)
        bpl :- ; (branch if positive)
:	lda $2002 ;
        bpl  :-

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;                                              ;
	; At this point the PPU should be nicely setup ;
	;                                              ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; set OAMADDR ($2003) to zero since OAM_DMA ($4014) will be used
	lda #$00
	sta $2003

	; Sprite table is initialized. Bring it in using SPRDMA
	lda #SPRITE_PAGE
	sta $4014


        ; Initialise FPS Value
	LDA #60 ; decimal
	STA FPS_VALUE
	jsr determine_NTSC_PAL_Mode
	; Value in X is (0 for PAL. 1 for NTSC)
	TXA
	; If X is 1, it is NTSC which is already populated
	BNE :+
	LDA #50
	STA FPS_VALUE
:


	jsr initCutSceneNMI ; Even though we are not in the NMI, this sets the state machine

	; indicate the infinite loop should process the state change (ie: init the cut scene)
	LDA #STATE_CHANGED
	STA CHANGE_DETECTION_FLAG


	; initialize scrolling variable
	; reset scroll amount
	lda $2002 ; reset address latch. Do I need to do this

	lda #$00
	STA $2005
	STA $2005


        ; Initialize For Sound (see explanation in NES 101)
	lda #$0F ; bits 0,1,2,3 for Rect1,Rect2, Tri, Noise enabling
        sta $4015


	; Wait for another vblank and turn back on graphics
:	lda $2002 ;
        bpl :- ;

        ; Now wire in the PPU registers based on the graphics setup above
        ; Background is at $0000
        ; Sprites are in $0000
        ; base name table at $2000
	lda #$00
	STA $2005
	STA $2005
        lda #%10000000
        sta $2000
        lda #%00011110
        sta $2001

	; testing this....

	LDA #$01
	STA NMI_MODE
	; At the end of NMI, NMI_MODE is set to zero.
infiniteLoop:
:	lda NMI_MODE
        BNE :- 

	LDA #$01
	STA NMI_MODE
	jsr processStateMachineNonNMI;


.IFDEF DEV_MODE
	; Show a line on the screen to see visually how much time we still have left.
	jsr showCPUUsageBar
.ENDIF

	jmp infiniteLoop
	rts ; never gets here



nmiHandler:
	; start of NMI
	;------------------------------------------------------
        ; NMIs can be called anywhere at any time, so lets protect A,X,Y by putting them on the stack
        PHA ; 3 cycles
        TXA ; 2 cycles
        PHA ; 3 cycles
        TYA ; 2 cycles
        PHA ; 3 cycles  so 13 CPU cycle setup cost to protect A,X,Y (and another 16 to restore things back at the end of the RTI)
	;------------------------------------------------------

        LDA $2002 ; reset address latch
	; Do stuff that DOES affect the graphics.  Not much time here....

	jsr  updateGraphics

        ; sprite DMA   this chews up quite a few cycles....

        lda #SPRITE_PAGE
        sta $4014

	; *****   Do stuff that does NOT affect the graphics *****

	; From this point forward we assume we are drawing the screen so no further screen updates are permitted
	; Get Joy 1 input 
	jsr getJoyPad1Input

	jsr processStateMachineNMI

	INC VBLANK_COUNTER
	

	; end of NMI
	;------------------------------------------------------
	; All done. Restore from NMI (A,X,Y. This costs 16 cycles since PLA cost 4 while PHA only cost 3)
	PLA ; 4 cycles
	TAY ; 2 cycles
	PLA ; 4 cycles 
	TAX ; 2 cycles
	PLA ; 4 cycles 
	;------------------------------------------------------

	; Clear a flag indicating NMI has completed..
	LDA #$00
	STA NMI_MODE

	rti


updateGraphics:
	JMP (GRAPHICS_UPDATE_ADDR_LOW)
	; We will never get to the following RTS
	rts


updateStateMachine:
	; determine the next state, etc...
	rts

resetSprites:
	; we will just set F0 as the y Position and 00 for all other attributes
	ldx #$00
:	lda #$F0
	sta $0300,x ; y pos
	lda #$00
	inx
	sta $0300,x ; tile index
	inx
	sta $0300,x ; attributes
	inx
	sta $0300,x ; x position
	inx
	bne :-
	RTS



; Note: the addresses of the stateMachineTable MUST correspond to the different states in be in the same order

stateMachineTable:
	.addr processCutSceneNMI 	; CUT_SCENE_STATE	= $00
	.addr processTitleScreenNMI	; TITLE_SCREEN_STATE	= $01
	.addr processWeaponSelectNMI	; WEAPON_SELECT_STATE   = $02	
	.addr processGameEngineNMI	; GAME_ENGINE_STATE     = $03	

processStateMachineNMI:
	LDA STATE_MACHINE
	ASL
	TAX
	LDA stateMachineTable, X
	STA JMP_LOW
	INX
	LDA stateMachineTable, X
	STA JMP_HIGH
	JMP (JMP_LOW)
	RTS		

stateMachineNonNMITable:
	.addr processCutSceneNonNMI	; CUT_SCENE_STATE	= $00
	.addr processTitleScreenNonNMI	; TITLE_SCREEN_STATE	= $01
	.addr processWeaponSelectNonNMI ; WEAPON_SELECT_STATE   = $02	
	.addr processGameEngineNonNMI   ; GAME_ENGINE_STATE     = $03	

processStateMachineNonNMI:
	LDA STATE_MACHINE
	ASL
	TAX
	LDA stateMachineNonNMITable, X
	STA JMP_LOW
	INX
	LDA stateMachineNonNMITable, X
	STA JMP_HIGH
	JMP (JMP_LOW)
	RTS		



incRand:
	INC RND_SEED0
	DEC RND_SEED1
	INC RND_SEED2
	BNE:+
	DEC RND_SEED3
:
	rts


	; A CHR bank is 4K
	; We either store it to $0000 or $1000
	; 16 pages (4K total)

	; The address to load from has been populated into IIY_LOW and IIY_HIGH already
	; Address IIY_LOW and IIY_HIGH are used for indirect indexed Y accesses
	; Y is either $10 or $00
updateCHRBank:
	LDA $2002 ; reset latch
	TYA ; start writing to PPU address YY00  where YY is $00 or $10
	STA $2006
	LDA #$00
	STA $2006

	LDX #16 ; 16 pages of data (decimal)
	LDY #$00

	LDA TEMP_VAR1
	; zero means load 256 tiles which is 16 bytes per tile or 16 pages total
	BEQ beginLoading

	; we need to mult the num tiles (in temp_var1 by 16, which means there will be overflow into temp_var2)
	LDX #$00
	STX TEMP_VAR2
	CLC
	ASL TEMP_VAR1
	ROL TEMP_VAR2
	ASL TEMP_VAR1
	ROL TEMP_VAR2
	ASL TEMP_VAR1
	ROL TEMP_VAR2
	ASL TEMP_VAR1
	ROL TEMP_VAR2
	; Subtract (256-TEMP_VAR1) from IIY_LOW since we will be setting Y to a value other than zero (to allow for pages)
	SEC
	LDA #$00
	SBC TEMP_VAR1
	STA TEMP_VAR1
	SEC
	LDA IIY_LOW
	SBC TEMP_VAR1
	STA IIY_LOW
	STA TEMP_VAR3
	BCS skipUpper
	DEC IIY_HIGH
	DEC TEMP_VAR4
skipUpper:
	LDY TEMP_VAR1
	LDX TEMP_VAR2
	INX

beginLoading:

:       lda (IIY_LOW),y
        sta $2007
        iny
        bne :-
        inc IIY_HIGH ; Y just went to 256. Increment the high byte
        dex ; decrement the x counter (loading another page if X is not 0)
        bne :-
	rts

LoadAlphabetChr:
	LDA $2002 ; reset 2006 flipflop
        LDA #$0E ; Load to $F00 (last 26 tiles)
        STA $2006
        LDA #$00
        STA $2006

       	LDA CURRENT_BANK
	PHA
        LDA #$00             ; Alphabet CHR is in Bank 0
	JSR setMMC1PRGBank

        LDA #>ALPHABET_FONT_CHR
        STA IIY_HIGH
        LDA #<ALPHABET_FONT_CHR
        STA IIY_LOW

        LDY #$00

:       LDA (IIY_LOW),Y
        STA $2007
        INY
        BNE :-
        
        INC IIY_HIGH ; Y just went to 256. Increment the high byte
; second 256 bytes
:       LDA (IIY_LOW),Y
        STA $2007
        INY
        BNE :-


        PLA
        JSR setMMC1PRGBank ; Reset MMC Bank
        RTS




; Uses IIY_LOW and IIY_HIGH
updateBGPalette:
	; (loads 16 into $3F00)
	lda $2002 ; reset 2006 flipflop
        lda #$3F
        STA $2006
        LDA #$00
        STA $2006

	LDX #16 ; 16 bytes
	ldy #$00
:       lda (IIY_LOW),y
        sta $2007
        dex ; decrement the x counter (loading another page if X is not 0)
        beq :+
        iny
        bne :-
:
        LDA $2002              ; Reset Scroll
        LDA #$00
        STA $2005
        STA $2005
        STA $2006
        STA $2006     
	rts

; Uses IIY_LOW and IIY_HIGH
updateBGAndSpritePalette:
	; (loads 32 into $3F00)
	lda $2002 ; reset 2006 flipflop
        lda #$3F
        STA $2006
        LDA #$00
        STA $2006

	LDX #32 ; 16 bytes
	ldy #$00
:       lda (IIY_LOW),y
        sta $2007
        dex ; decrement the x counter (loading another page if X is not 0)
        beq :+
        iny
        bne :-
:
        LDA $2002              ; Reset Scroll
        LDA #$00
        STA $2005
        STA $2005
        STA $2006
        STA $2006     
	rts



updateTargetPalette:
	; (loads 16 into BG_PAL_TARGET)
	LDX #$10 ; 16 bytes
	LDY #$00
:       lda (IIY_LOW),y
        sta BG_PAL_TARGET,y
        dex ; decrement the x counter (loading another page if X is not 0)
        beq :+
        iny
        bne :-
:
	rts


updateCurrentBGPalette:
; Parameter X = 1 of 5 intensity values to scale BG_PAL_TARGET by to update BG_PAL_CURRENT
;           BG_INTENSITY_0 = black, BG_INTENSITY_4 = target palette
        LDA CURRENT_BG_INTENSITY
	CMP #BG_INTENSITY_0
	BEQ intensity_0

        LDY #$00
updateCurrentBGPaletteLoop:
        LDA BG_PAL_TARGET,Y
        AND CURRENT_BG_INTENSITY;#$0F;TEMP_VAR1
        CMP #$0D ; Bad Black
        BNE :+
        LDA #COLOUR_BLACK
:
        STA BG_PAL_CURRENT,Y
        INY
        CPY #$10
        BNE updateCurrentBGPaletteLoop
        JMP updateCurrentBGPaletteComplete

intensity_0:
        LDA #COLOUR_BLACK
        LDY #$00
:
        STA BG_PAL_CURRENT,Y
        INY
        CPY #$10
        BNE :-

updateCurrentBGPaletteComplete:
        RTS




updateSpritePalette:
	; (loads 16 into $3F10)
	lda $2002 ; reset 2006 flipflop
        lda #$3F
        STA $2006
        LDA #$10
        STA $2006

	LDX #16 ; 16 bytes
	ldy #$00
:       lda (IIY_LOW),y
        sta $2007
        dex ; decrement the x counter (loading another page if X is not 0)
        beq :+
        iny
        bne :-
        inc IIY_HIGH ; Y just went to 256. Increment the high byte
        bne :-
:
	rts



; A is high address of dest nametable
; X is low address of src data for nametable
; Y is high address of src data for nametable
; LDA #$20
; ldX #<NAMETABLE
; ldY #>NAMETABLE
updateUncompressedNametable:
	; Nametable (at the moment) is 1K stored at $A020 (ie: in each of the banks)
	PHA
	LDA $2002 ; reset latch
	PLA
	STA $2006
	LDA #$00 ; start writing to PPU address AA00 (ie: 2000)
	STA $2006
	; Address IIY_LOW and IIY_HIGH are used for indirect indexed Y accesses
	TXA
	sta IIY_LOW ; store the low byte of the nametable address to $10
	TYA
	sta IIY_HIGH ; store high byte of the nametable address to $11

	ldx #4 ; 4 pages of data (decimal)
	ldy #$00
:       lda (IIY_LOW),y  
        sta $2007
        iny
        bne :-
        inc IIY_HIGH ; Y just went to 256. Increment the high byte
        dex ; decrement the x counter (loading another page if X is not 0)
        bne :-
	rts

; A is high address of dest nametable
; X is low address of src data for nametable
; Y is high address of src data for nametable
; LDA #$20
; ldX #<NAMETABLE
; ldY #>NAMETABLE
updateCompressedNametable:
	; Nametable (at the moment) is 1K stored at $A020 (ie: in each of the banks)
	PHA
	LDA $2002 ; reset latch
	PLA
	STA $2006
	LDA #$00 ; start writing to PPU address AA00 (ie: 2000)
	STA $2006

	; address is YYXX
	; skip over the first byte since I know its compressed
 	INX
 	BNE :+
 	INY
:	JSR uncompressRLENameTableSetup
	rts


; Separate files with the guts of each state

.include "cutScenes.asm"
.include "titleScreen.asm"
.include "weaponSelect.asm"
.include "gameEngineState.asm"




doNothingGraphicsUpdate:
	rts


prepareCutSceneText:
	LDA #<updateCutSceneText
	STA GRAPHICS_UPDATE_ADDR_LOW 
	LDA #>updateCutSceneText
	STA GRAPHICS_UPDATE_ADDR_HIGH

	LDA SUB_STATE_MACHINE_1
	AND #$0F ; I dont support more than 16 scenes
	; multiply by 2. I know there are less than 16 scenes, so I only have to CLC once
	CLC
	ASL
	TAX
	LDA CUT_SCENE_TEXT,X ; address of the text
	STA TEXT_ADDR_LOW
	INX
	LDA CUT_SCENE_TEXT,X 
	STA TEXT_ADDR_HIGH
	LDA #$00
	STA TEXT_OFFSET
rts



; ' = $27 =Char $1D in character set
; . = $2E =Char $1B in character set
; , = $2C =Char $1C in character set
; ? = $3F =Char $1E in character set
updateCutSceneText:
	LDY TEXT_OFFSET

	LDA (TEXT_ADDR_LOW),Y
	BEQ textFinish
	; Its a character
	; check if its a space (32)
	CMP #32
	BEQ renderSpace
        CMP #$40
        BCS renderLetters
        CMP #$27
        BNE :+
        LDA #($1D+$DF)
        JMP renderCharacter
:
        CMP #$2E
        BNE :+
        LDA #($1B+$DF)
        JMP renderCharacter
:
        CMP #$2C
        BNE :+
        LDA #($1C+$DF)
        JMP renderCharacter
:
        CMP #$3F
        BNE :+
        LDA #($1E+$DF)
        JMP renderCharacter
:
        JMP moveOver

renderSpace:
        LDA #$FF
renderCharacter:
	TAY
	LDA $2002 ; reset latch
	LDA #SCREEN_TEXT_START_HIGH
	STA $2006
	LDA TEXT_OFFSET ; start writing to PPU address AA00 (ie: 2000)
	CLC
	ADC #SCREEN_TEXT_START_LOW
	STA $2006
	TYA
	STA $2007
	JMP moveOver

renderLetters:
	CLC	
	; Subtract 40 from the character (41 is Ascii A is the first character) and add to E5 which is the CHR offset
	; A5
	ADC #$9F
	; If its greater than 26 we'll know since the carry will get set	
	BCS textFinish
	; The value will now be added into the nametable
	TAY
	LDA $2002 ; reset latch
	LDA #SCREEN_TEXT_START_HIGH
	STA $2006
	LDA TEXT_OFFSET ; start writing to PPU address AA00 (ie: 2000)
	CLC
	ADC #SCREEN_TEXT_START_LOW
	STA $2006
	TYA
	STA $2007
moveOver:
	INC TEXT_OFFSET

textFinish:

	JMP loadInBGPaletteFromZP
	rts

loadInBGPaletteFromZP:
        LDA #>BG_PAL_CURRENT
        STA IIY_HIGH
        LDA #<BG_PAL_CURRENT
        STA IIY_LOW
        JSR updateBGPalette
	rts


; The following are JUMP tables for use with Indirect Indexed JMP commands.
; Basically this allows us to use a simple variable GRAPHICS_UPDATE_ROUTINE_INDEX 
; and we can create multiple routines for different stages of a graphics update

;  Cut Scene playback controls
; Num entries
CUT_SCENE_NUM_SCENES:
.byt $0C ; 12 cutscenes in the opening sequence

; Table: BANK, NUM_TILES(not supported), CHR address, PAL address, nametable address
CUT_SCENE_DATA_TABLE:
.byt $00, $D9
.addr SCENE_1_CHR
.addr SCENE_1_PAL
.addr SCENE_1_NAM

.byt $00, $60  ; 
.addr SCENE_2_CHR
.addr SCENE_2_PAL
.addr SCENE_2_NAM

.byt $00, $00
.addr SCENE_3_CHR
.addr SCENE_3_PAL
.addr SCENE_3_NAM

.byt $01, $00
.addr SCENE_4_CHR
.addr SCENE_4_PAL
.addr SCENE_4_NAM

.byt $01, $00
.addr SCENE_5_CHR
.addr SCENE_5_PAL
.addr SCENE_5_NAM

.byt $01, $00
.addr SCENE_6_CHR
.addr SCENE_6_PAL
.addr SCENE_6_NAM

.byt $02, $00
.addr SCENE_7_CHR
.addr SCENE_7_PAL
.addr SCENE_7_NAM

.byt $02, $00
.addr SCENE_8_CHR
.addr SCENE_8_PAL
.addr SCENE_8_NAM

.byt $02, $00
.addr SCENE_9_CHR
.addr SCENE_9_PAL
.addr SCENE_9_NAM

.byt $03, $00
.addr SCENE_10_CHR
.addr SCENE_10_PAL
.addr SCENE_10_NAM

.byt $03, $00
.addr SCENE_11_CHR
.addr SCENE_11_PAL
.addr SCENE_11_NAM

.byt $03, $00
.addr SCENE_12_CHR
.addr SCENE_12_PAL
.addr SCENE_12_NAM


; Remember.  Only support UPPER CASE.
; The values are ASCII, so we need to subtract 41 and since the alphabet is at the end , add E5
CUT_SCENE_TEXT:
.addr SCENE_1_TEXT
.addr SCENE_2_TEXT
.addr SCENE_3_TEXT
.addr SCENE_4_TEXT
.addr SCENE_5_TEXT
.addr SCENE_6_TEXT
.addr SCENE_7_TEXT
.addr SCENE_8_TEXT
.addr SCENE_9_TEXT
.addr SCENE_10_TEXT
.addr SCENE_11_TEXT
.addr SCENE_12_TEXT

SCENE_1_TEXT:
.asciiz "WHAT'S YOUR PLEASURE?"
SCENE_2_TEXT:
.asciiz "THE BOX...           "
SCENE_3_TEXT:
.asciiz "TAKE IT, IT'S YOURS.                                              IT ALWAYS WAS..."
SCENE_4_TEXT:
.asciiz "                                                                                  "
SCENE_5_TEXT:
.asciiz ""
SCENE_6_TEXT:
.asciiz ""
SCENE_7_TEXT:
.asciiz ""
SCENE_8_TEXT:
.asciiz ""
SCENE_9_TEXT:
.asciiz ""
SCENE_10_TEXT:
.asciiz ""
SCENE_11_TEXT:
.asciiz ""
SCENE_12_TEXT:
.asciiz ""


; Master include for all the libs
.include "includes.asm"


.include "engine.asm"

; Data for Player Sprites and modes
.include "player.asm"

; Data for levels
.include "levelData.asm"

; I put this here to let me know how much space I have left.
irqHandler:
	  rti




.segment "VECTORS"

  .addr nmiHandler, resetHandler, irqHandler




.segment "BANK0"
.byt $30

; Scene 1.  181 tiles
SCENE_1_CHR:
.incbin "graphics/cutScenes/scene1/scene1.bg4K.chr"
SCENE_1_PAL:
.incbin "graphics/cutScenes/scene1/scene1.bg.pal"
SCENE_1_NAM:
.incbin "graphics/cutScenes/scene1/scene1.rle.nam"

; Scene 2.  127 tiles
SCENE_2_CHR:
.incbin "graphics/cutScenes/scene2/scene2.bg4K.chr"
SCENE_2_PAL:
.incbin "graphics/cutScenes/scene2/scene2.bg.pal"
SCENE_2_NAM:
.incbin "graphics/cutScenes/scene2/scene2.rle.nam"

; Scene 3.  131 tiles
SCENE_3_CHR:
.incbin "graphics/cutScenes/scene3/scene3.bg4K.chr"
SCENE_3_PAL:
.incbin "graphics/cutScenes/scene3/scene3.bg.pal"
SCENE_3_NAM:
.incbin "graphics/cutScenes/scene3/scene3.rle.nam"

; Text Chars
ALPHABET_FONT_CHR:  ; 32 characters = 512 bytes
.incbin "graphics/chars/alphabet.font.chr"

.segment "BANK0_END"


.segment "BANK1"
.byt $31

SCENE_4_CHR:
.incbin "graphics/cutScenes/scene4/scene4.bg4K.chr"
SCENE_4_PAL:
.incbin "graphics/cutScenes/scene4/scene4.bg.pal"
SCENE_4_NAM:
.incbin "graphics/cutScenes/scene4/scene4.rle.nam"

SCENE_5_CHR:
.incbin "graphics/cutScenes/scene5/scene5.bg4K.chr"
SCENE_5_PAL:
.incbin "graphics/cutScenes/scene5/scene5.bg.pal"
SCENE_5_NAM:
.incbin "graphics/cutScenes/scene5/scene5.rle.nam"

SCENE_6_CHR:
.incbin "graphics/cutScenes/scene6/scene6.bg4K.chr"
SCENE_6_PAL:
.incbin "graphics/cutScenes/scene6/scene6.bg.pal"
SCENE_6_NAM:
.incbin "graphics/cutScenes/scene6/scene6.rle.nam"


.segment "BANK1_END"


.segment "BANK2"
.byt $32

SCENE_7_CHR:
.incbin "graphics/cutScenes/scene7/scene7.bg4K.chr"
SCENE_7_PAL:
.incbin "graphics/cutScenes/scene7/scene7.bg.pal"
SCENE_7_NAM:
.incbin "graphics/cutScenes/scene7/scene7.rle.nam"

SCENE_8_CHR:
.incbin "graphics/cutScenes/scene8/scene8.bg4K.chr"
SCENE_8_PAL:
.incbin "graphics/cutScenes/scene8/scene8.bg.pal"
SCENE_8_NAM:
.incbin "graphics/cutScenes/scene8/scene8.rle.nam"

SCENE_9_CHR:
.incbin "graphics/cutScenes/scene9/scene9.bg4K.chr"
SCENE_9_PAL:
.incbin "graphics/cutScenes/scene9/scene9.bg.pal"
SCENE_9_NAM:
.incbin "graphics/cutScenes/scene9/scene9.rle.nam"

.segment "BANK2_END"


.segment "BANK3"

SCENE_10_CHR:
.incbin "graphics/cutScenes/scene10/scene10.bg4K.chr"
SCENE_10_PAL:
.incbin "graphics/cutScenes/scene10/scene10.bg.pal"
SCENE_10_NAM:
.incbin "graphics/cutScenes/scene10/scene10.rle.nam"

SCENE_11_CHR:
.incbin "graphics/cutScenes/scene11/scene11.bg4K.chr"
SCENE_11_PAL:
.incbin "graphics/cutScenes/scene11/scene11.bg.pal"
SCENE_11_NAM:
.incbin "graphics/cutScenes/scene11/scene11.rle.nam"

SCENE_12_CHR:
.incbin "graphics/cutScenes/scene12/scene12.bg4K.chr"
SCENE_12_PAL:
.incbin "graphics/cutScenes/scene12/scene12.bg.pal"
SCENE_12_NAM:
.incbin "graphics/cutScenes/scene12/scene12.rle.nam"

.segment "BANK3_END"


.segment "BANK4"

TITLE_CHR:
.incbin "graphics/title/title_bg_tiles4K.chr"
TITLE_PAL:
.incbin "graphics/title/title_palette.pal"
TITLE_NAM:
.incbin "graphics/title/title_uncompressed.nam"
TITLE_SPRITES_NUMBER:
.byte $06
TITLE_ANIMATION_SPRITES:
.incbin "graphics/title/title_sprites.chr"
TITLE_ANIMATION_DATA:
.incbin "graphics/title/title.anim"

.segment "BANK4_END"




; Game Engine Sprites is in Bank 5
.segment "BANK5"

STATUS_BAR_NAMETABLE:
.ifdef TOP_STATUS
.include "status/statusBarTop.nam"
.else
.include "status/statusBarBottom.nam"
.endif


STATUS_BAR_TILES:
.incbin "status/statusBar_last16.chr"

NUMBER_TILES:
.incbin "graphics/10_numbers.chr"
.include "status/statusBar.asm"


.segment "BANK5_END"


; Bank 6,7,8 are defined in levelTiles.asm
.include "levelTiles.asm"



.segment "BANK9"
.segment "BANK9_END"

.segment "BANKA"
.segment "BANKA_END"

.segment "BANKB"
.segment "BANKB_END"

.segment "BANKC"
.segment "BANKC_END"

.segment "BANKD"
.segment "BANKD_END"


; Music Bank
.segment "BANKE"
; famitracker music driver
.incbin "src/libs/famitracker/driver.bin"

; all music
.incbin "music/all_music_ft027.bin"
.incbin "music/all_music_samplesft027.bin"


.segment "BANKE_END"

