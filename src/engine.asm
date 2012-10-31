
;-----------------

;  -------------------------------
;  | >Visible portion of screen< |
;  |                             |
;  |                             |
;  |                             |
;  |                             |
;  |left trigger    right trigger|
;  |   {                   }     |
;  *------------------------------


;  * = x,y scroll values (ignore y)
;  left trigger and right trigger are triggered by on scroll character position


;16x16 pixel meta tiles

;12 metatiles per column

;16 columns on the screen. N columns per level  



;--------------------------------------------------------;
; Engine Constants
; These values dictate the behaviour of the engine
; and its scroll characteristics
;--------------------------------------------------------;
;
; LEFT_SCROLL_TRIGGER is the value on the screen where if
; the players X position drops below this (due to moving left)
; that the screen will scroll left, rather than the players
; location on the screen
LEFT_SCROLL_TRIGGER        = 48  ; decimal

; RIGHT_SCROLL_TRIGGER is the same as LEFT_SCROLL_TRIGGER except it applies to the right
RIGHT_SCROLL_TRIGGER       = 212 ; decimal


SCROLL_SPEED = PLAYER_SPEED 

; TO DO: Document these and MOVE TO ENGINE
PAGE_ZERO_PPU_SETTINGS     = %10001000
PAGE_ONE_PPU_SETTINGS      = %10001001
PAGE_EOR_PPU_SETTINGS      = %00000001 ; this will flip only the bottom bit


PLAYER_HALF_HEIGHT	   = 12
PLAYER_HEIGHT		   = 24

PLAYER_HALF_WIDTH	   = 8
PLAYER_WIDTH		   = 15


.ifdef TOP_STATUS
COLUMN_SIZE                = 11 ; decimal
COLUMN_OAM_HEIGHT	   = 6
PLAYER_OFFSET		   = 64
TOP_OF_SCREEN		   = 65
BOTTOM_OF_SCREEN	   = 255
.else
COLUMN_SIZE                = 12 ; decimal
COLUMN_OAM_HEIGHT	   = 6
PLAYER_OFFSET		   = 0
TOP_OF_SCREEN		   = 1
BOTTOM_OF_SCREEN	   = 190
.endif


COLUMN_SIZE_TIMES_TWO      = COLUMN_SIZE + COLUMN_SIZE

; This makes the increment be 16
PPU_OFF_LOADING            = %00000100
; This makes the increment be 1
PPU_OAM_LOADING            = %00000000

ENGINE_LOAD_AHEAD_AMOUNT	= 24
ENGINE_LOAD_BACK_AMOUNT		= 7


.include "engineConstants.asm"



;----------------------------------------------------------;
; Engine ZP Memory
; This block of code is used by the scroll engine
; when converting metatiles into tiles
; that are then copied into PPU
; We use MEMORY $A0 to $FF (need more if COLUMN_SIZE is increased)
;--------------------------------------------------------;
X_TO_CHECK		= $A0   ; This value is used for collision checking
Y_TO_CHECK		= $A1   ; This value is used for collision checking
CLIP_SIZE		= $A2   ; This value is added to X or Y when doing collision checking
MOVEMENT_DELTA		= $A3
BOUND_START             = $A4
BOUND_END		= $A5
BOUND_MID		= $A6
TEMP_DIR		= $A7
; more room
ENGINE_TRIGGER		= $B0
PPU_COLUMN_HIGH         = $B1
PPU_COLUMN_LOW          = $B2
FIRST_COLUMN_RAM        = $B3 ; COLUMN_SIZE_TIMES_TWO
SECOND_COLUMN_RAM       = $CB ; COLUMN_SIZE_TIMES_TWO
OAM_COLUMN_RAM          = $E3 ; size = COLUMN_SIZE used by engine, only COLUMN_OAM_HEIGHT used when copy to PPU
NEXT_FREE_RAM		= $F0 

; COLLISION_MAP_LOW	= $0300 ; Two full pages
; COLLISION_MAP_HIGH	= $0400 ; Two full pages


;----------------------------------------------------------;
; Clipping code
;----------------------------------------------------------;

; PUBLIC
checkMoveHorizontal:
	; store player state table address in IIY variables for later checking
	LDA PLAYER_STATE
	ASL
	TAX
	LDA p1TransitionTable,X
	STA IIY_LOW
	LDA p1TransitionTable+1,X
	STA IIY_HIGH

	; need to do 3 checks (with varying height)

	LDX #$00
        LDA SCROLL_POSITION
	CLC	
	ADC TEMP_VAR1
	BCC :+
	; If the carry is now set, we overlapped a page
	INX
:
	STX TEMP_VAR3
	STA TEMP_VAR4

	; check start
	LDA TEMP_VAR2
        LSR
        LSR
        LSR
        LSR
	STA TEMP_VAR5
	jsr checkMoveRemainder
	STA BOUND_START

	; check end
	LDA TEMP_VAR2
	CLC
	ADC #PLAYER_HEIGHT
        LSR
        LSR
        LSR
        LSR
	STA TEMP_VAR5
	jsr checkMoveRemainder
	STA BOUND_END

	; check mid
	LDA TEMP_VAR2
	CLC
	ADC #PLAYER_HALF_HEIGHT
        LSR
        LSR
        LSR
        LSR
	STA TEMP_VAR5
	jsr checkMoveRemainder
        STA BOUND_MID

	RTS


; TEMP_VAR3 = page. 4 = X, 5 = Y
; Common for horizontal and vertical
; PRIVATE
checkMoveRemainder:
	
	; convert the X coord into column space and add Y
	; this means masking off the bottom 4 bits
	LDA TEMP_VAR4
	AND #%11110000
	CLC
	ADC TEMP_VAR5
	TAX	

	LDA TEMP_VAR3
	CLC
	ADC CURRENT_PAGE
	AND #%00000001
	BEQ :+
	LDA COLLISION_MAP_HIGH,X
	JMP :++
:
	LDA COLLISION_MAP_LOW,X
:
        RTS
	

validateNormalValues:
; Keep the largest of the 3 values and store it in A
        LDA PLAYER_STATE
        ASL
        TAX
        LDA p1TransitionTable,X
        STA IIY_LOW
        INX
        LDA p1TransitionTable,X
        STA IIY_HIGH

        LDA BOUND_START
        CMP BOUND_MID
        BCS :+        ; take this branch if origin was larger
        LDA BOUND_MID ; if we are here Mid was larger
:
        CMP BOUND_END
        BCS :+        ; take this branch if A was larger
        LDA BOUND_END ; end was larger
:
        ; Now check the state transition table
        ; Multiply the material by 4 to get the row
        ASL
        ASL
        ; Add the direction (up=0,down=1,left=2,right=3)
        CLC
        ADC TEMP_DIR
        TAY
        LDA (IIY_LOW),Y
	jsr validateState
	rts

; Expects: A=player state
; Returns: A  1=success, 0=Fail
validateState:
        CMP #PLAYER_INVALID_STATE
        BEQ :+
	jsr setPlayerState
        LDA #$01
        rts
:
        LDA PLAYER_STATE
        ASL
        ASL
        ; Add the direction (up=0,down=1,left=2,right=3)
        CLC
        ADC TEMP_DIR
        TAX
        LDA invalidTransitionTable,X
	jsr setPlayerState
        LDA #$00
	rts


; A register has the object type
; Return in A:  1 for we can move, 0 for no we cannot
processCollisionType:
        TAX
	BNE :+	
        LDA #$01 ; 1 means YES we can move 
        RTS
:       LDA #$00 ; 0 means No we have struck a non zero object (an obstacle)
        RTS





; PUBLIC
checkMoveVertical:
	; store player state table address in IIY variables for later checking
	LDA PLAYER_STATE
	ASL
	TAX
	LDA p1TransitionTable,X
	STA IIY_LOW
	LDA p1TransitionTable+1,X
	STA IIY_HIGH

	LDA CLIP_SIZE
	LSR
	STA TEMP_VAR1

	; need to do 3 checks (with varying width)
	LDA Y_TO_CHECK
        LSR
        LSR
        LSR
        LSR
	STA TEMP_VAR5

	; left
	LDX #$00
        LDA SCROLL_POSITION
	CLC	
	ADC X_TO_CHECK
	BCC :+
	; If the carry is now set, we overlapped a page
	INX
:
	STX TEMP_VAR3
	STA TEMP_VAR4

	jsr checkMoveRemainder
	STA BOUND_START

	; right
	LDX #$00
        LDA SCROLL_POSITION
	CLC	
	ADC X_TO_CHECK
	BCC :+
	; If the carry is now set, we overlapped a page
	INX
	CLC
:
	ADC CLIP_SIZE
	BCC :+
	; If the carry is now set, we overlapped a page
	INX
:
	STX TEMP_VAR3
	STA TEMP_VAR4
	jsr checkMoveRemainder
	STA BOUND_END

	; mid
	LDX #$00
        LDA SCROLL_POSITION
	CLC	
	ADC X_TO_CHECK
	BCC :+
	INX
	CLC
:
	ADC TEMP_VAR1
	BCC :+
	; If the carry is now set, we overlapped a page
	INX
:
	STX TEMP_VAR3
	STA TEMP_VAR4
	jsr checkMoveRemainder
	STA BOUND_MID


	RTS

	
;----------------------------------------------------------;
; Scrolling code
;----------------------------------------------------------;

; PUBLIC
scrollLeftIfNeeded:
	; If we do not scroll, the A is set to zero
        LDA PLAYER_TOP_LEFT_X
        CMP #LEFT_SCROLL_TRIGGER
        BCS :+
        jsr scrollScreenLeft ; Scrolls the screen, triggers column loading, etc..
	; scrollScreenLeft sets A to non zero if it actually scrolled
	RTS
:
	; if we are here, we did not scroll. Let A to zero to indicate failure
	LDA #$00
	RTS


; PRIVATE
scrollScreenLeft:
        LDA SCROLL_POSITION
	CMP SCROLL_SPEED
	BCS :+
        ; If we are here, scroll value is zero
        LDA CURRENT_PAGE
        BEQ  didNotScrollLeft

        DEC CURRENT_PAGE
        LDA CURRENT_PAGE_PPU_SETTINGS
        EOR #PAGE_EOR_PPU_SETTINGS
        STA CURRENT_PAGE_PPU_SETTINGS
:
        ; decrement scroll position (wraps)
        LDA SCROLL_POSITION
	SEC
	SBC SCROLL_SPEED
	STA SCROLL_POSITION
        ; div by 16 to get the column
        LDA SCROLL_POSITION
        LSR
        LSR
        LSR
        LSR
        CMP CURRENT_SCREEN_COLUMN
        BEQ :+ ; branch if the value is the same as before
        ; If we are here, its a different column
        STA CURRENT_SCREEN_COLUMN
        jsr doLeftLoad
	; This means we DID scroll
:
	LDA #$01
	RTS
didNotScrollLeft:
	; This means we did not scroll
	LDA #$00
	RTS




scrollScreenRight:
	LDA SCROLL_POSITION
	CLC
	ADC SCROLL_SPEED
	BCC :+

        ; if we are here, scroll wrapped to zero
        ; Here's the weirdness.  If there are 8 pages, then when the current_page is set to 6 and the scroll is at max, we can no longer move right
        LDX CURRENT_PAGE
        INX
        INX
        CPX MAX_PAGE
        BCS endScreenScrollRight ; carry set if cur page >= max

        INC CURRENT_PAGE
        LDA CURRENT_PAGE_PPU_SETTINGS
        EOR #PAGE_EOR_PPU_SETTINGS
        STA CURRENT_PAGE_PPU_SETTINGS
:
	LDA SCROLL_POSITION
	CLC
	ADC SCROLL_SPEED
	STA SCROLL_POSITION

        ; div by 16 to get the column
        LDA SCROLL_POSITION
        LSR
        LSR
        LSR
        LSR
        CMP CURRENT_SCREEN_COLUMN
        BEQ :+ ; branch if the value is the same as before
        ; If we are here, its a different column
        STA CURRENT_SCREEN_COLUMN
        jsr doRightLoad

:
endScreenScrollRight:
rts



;----------------------------------------------------------;
; On Demand Column loading code
;----------------------------------------------------------;

; We know the current page, and the current scroll column
; We load one page less going left, and one page more going right
doLeftLoad:
	; NEW col to load = (page*16)+cur-8
	LDA CURRENT_PAGE
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC CURRENT_SCREEN_COLUMN
	CMP #ENGINE_LOAD_BACK_AMOUNT
	BCC :+ ; cannot load left
	SEC
	SBC #ENGINE_LOAD_BACK_AMOUNT
	STA COLUMN_TO_LOAD
	AND #%00011111
	STA COLUMN_TO_STORE

	jsr loadLevelColumnIntoRAM

	; By setting 1 to engine trigger, NMI will update PPU over 3 frames
	LDA #$01
	STA ENGINE_TRIGGER

:
	RTS



doRightLoad:
	; NEW col to load = (page*16)+cur+24
	LDA CURRENT_PAGE
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC CURRENT_SCREEN_COLUMN
	CLC
	ADC #ENGINE_LOAD_AHEAD_AMOUNT
	BVS :+ ; Handles the case where we go past 256
	CMP MAX_COLUMNS
	BCS :+
	STA COLUMN_TO_LOAD
	AND #%00011111
	STA COLUMN_TO_STORE

	jsr loadLevelColumnIntoRAM

	; By setting 1 to engine trigger, NMI will update PPU over 3 frames
	LDA #$01
	STA ENGINE_TRIGGER

:
	RTS


;----------------------------------------------------------;
; Level loading code
;----------------------------------------------------------;

setupLevel:
	; First of all we turn OFF display since this might take a while
	LDA #$00
	STA $2000
	STA $2001

	; uncompress level into extended RAM
	jsr loadLevelIntoRAM
	
	; TO DO: add starting location for player


	; setup the two screens of the nametable (32 columns = 64 tiles wide total)
	; These metatiles are stored in RAM
	LDX #$00
	STX COLUMN_TO_LOAD
	STX COLUMN_TO_STORE
:
	jsr loadLevelColumnIntoRAM
	jsr loadRAMColumnIntoPPU
	LDX COLUMN_TO_LOAD
	INX
	STX COLUMN_TO_LOAD
	STX COLUMN_TO_STORE
	CPX #$20
	BNE :-

	; setup palette
	jsr setupLevelPalette

        rts



; TO DO:  Needs to be rewritten to handle the palette for the level
setupLevelPalette:
        LDA LEVEL
	ASL
        TAX
        LDA levelPalettes,X
        STA IIY_LOW
        LDA levelPalettes+1,X
        STA IIY_HIGH
        jsr updateBGAndSpritePalette
rts

	
	
loadRAMColumnIntoPPU:
	jsr loadFirstRAMColumnIntoPPU
	jsr loadSecondRAMColumnIntoPPU
	jsr loadOAMRAMColumnIntoPPU
	rts

updateBackgroundTileLocations:
	LDA ENGINE_TRIGGER
	BEQ :+
	LDA ENGINE_TRIGGER
	CMP #1
	BEQ loadFirstRAMColumnIntoPPU
	CMP #2
	BEQ loadSecondRAMColumnIntoPPU
	CMP #3
	BEQ loadOAMRAMColumnIntoPPU
:
	rts


loadFirstRAMColumnIntoPPU:

	LDA #PPU_OFF_LOADING
	STA $2000

	LDA $2002

	LDA PPU_COLUMN_HIGH
	STA $2006
	LDA PPU_COLUMN_LOW
	STA $2006
	
	LDX #$00
:
	; TO DO: Determine if it is smarter to unroll this loop. Note: doing so may exceed updateBackgroundTileLocations branch range
	LDA FIRST_COLUMN_RAM,X
	STA $2007
	INX
	CPX #COLUMN_SIZE_TIMES_TWO	   
	BNE :-

	LDA #$02	
	STA ENGINE_TRIGGER

	rts

loadSecondRAMColumnIntoPPU:

	LDA #PPU_OFF_LOADING
	STA $2000

	LDA $2002

	LDA PPU_COLUMN_HIGH
	STA $2006
	LDX PPU_COLUMN_LOW
	INX
	STX $2006
	
	LDX #$00
:
	; TO DO: Determine if it is smarter to unroll this loop. Note: doing so may exceed updateBackgroundTileLocations branch range
	LDA SECOND_COLUMN_RAM,X
	STA $2007
	INX
	CPX #COLUMN_SIZE_TIMES_TWO	   
	BNE :-

	LDA #$03	
	STA ENGINE_TRIGGER

	rts

loadOAMRAMColumnIntoPPU:


	LDA #PPU_OAM_LOADING
	STA $2000

        ; 0x23C0 or 0x27C0 is where OAM starts
        ; For a top status bar, skip 16 bytes

        ; Need to load IN the old value, change 4 bits, and set it back
        LDX PPU_COLUMN_HIGH
.ifdef TOP_STATUS
        INX
        INX
.else
        INX
        INX
        INX
.endif
	TXA
        STA $2006

	; Up to 16 columns, but only 8 OAM columns so divide by 2

	LDA COLUMN_TO_STORE
	AND #%00001111
	LSR

	CLC
.ifdef TOP_STATUS
	ADC #$D0
.else
	ADC #$C0
.endif
        STA $2006
	PHA ; first second $2006
	TXA
	PHA ; push first $2006


	LDA $2007 ; junk read
	; read COLUMN_OAM_HEIGHT times to read the old OAM (max of 8)
	
	LDX #$00
:
	LDA $2007 
	AND OAM_COLUMN_BIT_MASK ; AND against %11001100 or %00110011
	ORA OAM_COLUMN_RAM,X
	STA OAM_COLUMN_RAM,X
	; move PPU address ahead 7 to next row
	LDA $2007 
	LDA $2007 
	LDA $2007 
	LDA $2007 
	LDA $2007 
	LDA $2007 
	LDA $2007 
	INX
	CPX #COLUMN_OAM_HEIGHT
	BNE :-

	PLA ; pull first $2006
	STA $2006
	PLA ; pull second $2006
	STA $2006

	LDX #$00
:
	LDA OAM_COLUMN_RAM,X
	STA $2007 
	; move PPU address ahead 7 to next row
	LDA $2007 
	LDA $2007 
	LDA $2007 
	LDA $2007 
	LDA $2007 
	LDA $2007 
	LDA $2007 
	INX
	CPX #COLUMN_OAM_HEIGHT
	BNE :-

        LDA #$00
        STA ENGINE_TRIGGER

        rts


blankTiles:
	LDA #$F0
	STA TMP_NUM_TILES_REMAINDER
	LDX #$10
	LDA #$00
	LDY #$00 
:	
	STA $2007
	DEX
	BNE :-
	DEC TMP_NUM_TILES_REMAINDER
	BEQ :+
	LDX #$10
	BNE :-
:
	
	rts
	
; Expects 2007 to be properly setup
; Expects TMP_NUM_TILES to have the number of 16 byte tiles already
loadTiles:
	LDA TMP_NUM_TILES
	LDX #$10
	LDY #$00 
:	
	DEX
	BNE :+
	DEC TMP_NUM_TILES
	BEQ :++
	LDX #$10
:
        LDA (IIY_LOW),y
	STA $2007
	INY
	BNE :--
	INC IIY_HIGH
	BNE :--
:
	
	rts
	

loadTilesOld:

	; 16 bytes per tile, so store counter and remainder
	; N / 16 = pages
	; N % 16 = remainder
	LDA TMP_NUM_TILES
	AND #%00001111
	ASL
	ASL
	ASL
	ASL
	STA TMP_NUM_TILES_REMAINDER

	CLC
	LDA TMP_NUM_TILES
	LSR
	LSR
	LSR
	LSR
	; Number of mega loops
	BEQ skipLoopPages
	TAX ; non zero
	LDY #$00 
:	
        LDA (IIY_LOW),y
	STA $2007
	INY
	BNE :-
	INC IIY_HIGH
	DEX
	BNE :-
	
skipLoopPages:
	LDX TMP_NUM_TILES_REMAINDER
	BEQ skipRemainder
:	
        LDA (IIY_LOW),y
	STA $2007
	INY
	DEX
	BNE :-

skipRemainder:
	RTS






; Uncompresses a level into extended RAM
; These levels are then used when loading metatiles
; $6000-$7FFF
loadLevelIntoRAM:
	; Level table of addresses, so get the proper address for the current level

	LDA LEVEL
	ASL
	TAX
 	LDA LEVEL_DATA,X
	STA IIY_LOW
 	LDA LEVEL_DATA+1,X
	STA IIY_HIGH

        ldy #$00
        lda (IIY_LOW),y  ; tile bank
	STA TILE_BANK
        JSR setMMC1PRGBank

	INY
	; second byte is the number of tiles in the 
        LDA (IIY_LOW),y
	STA TMP_NUM_TILES

	; next two bytes are the address of the tiles in the bank
	INY
        LDA (IIY_LOW),y
	TAX ; temporarily put in X
	INY
        LDA (IIY_LOW),y
	STX IIY_LOW ; get it back out of X
        STA IIY_HIGH

	; Load in the tiles (address of tile data in IIY)

	; BG tiles in $0000
	LDY #$00
	STY $2006
	STY $2006
	jsr blankTiles

	LDY #$00
	STY $2006
	STY $2006
	jsr loadTiles


	LDA LEVEL
	ASL
	TAX
 	LDA LEVEL_DATA,X
	STA IIY_LOW
 	LDA LEVEL_DATA+1,X
	STA IIY_HIGH


        ; Next value to load is the bank of the metatiles at level index 4
        ldy #$04
        lda (IIY_LOW),y
	STA METATILE_BANK
	INY
        lda (IIY_LOW),y
	STA META_LOW
	INY
        lda (IIY_LOW),y
	STA META_HIGH

	INY
        lda (IIY_LOW),y ; column bank
        JSR setMMC1PRGBank

	INY
        lda (IIY_LOW),y 
	STA MAX_PAGE
	ASL
	ASL
	ASL
	ASL
	STA MAX_COLUMNS
	STA TMP_NUM_COLUMNS

	INY
        lda (IIY_LOW),y
	TAX
	INY
        lda (IIY_LOW),y
	STX IIY_LOW
	STA IIY_HIGH


; Load the columns into high RAM. I only do this with the hopes of supporting decompression someday
; Hog 16 bytes per column (makes math easier)
	LDA #$00
	STA IIY_ALT_LOW
	LDA #$60
	STA IIY_ALT_HIGH  ; start writing at $6000

	LDX #$10
        ldy #$00
@startLoop:      
	; TO DO: support RLE decompression 
	lda (IIY_LOW),y
        sta (IIY_ALT_LOW),y
	DEX
	BNE :+
	LDX #$10
	DEC TMP_NUM_COLUMNS
	BEQ @endLoader ; this is the only way out of this loop
:
	INY
	BNE @startLoop
	INC IIY_HIGH
	INC IIY_ALT_HIGH
	JMP @startLoop ; 3 cycles. Same as using a branch
@endLoader:

rts


loadLevelColumnIntoRAM:
	; first determine where the RAM will be extracted to in PPU
	; this is based on the COLUMN_TO_STORE value which must be between 0 and 32 (inclusive)
	; column 0..15 in page 2000, 16..31 in 2400
	; algorithm. if val >=16 use 2400 else 2000
	; take (column % 16) * 2 amd add to either $2000 or $2400
	; Make sure we increment by 32

	; store first 2 bytes as the PPU (high,low)
	LDA #$20
	STA PPU_COLUMN_HIGH
	LDA COLUMN_TO_STORE
	AND #%00010000
	BEQ :+
	LDA #$24
	STA PPU_COLUMN_HIGH
:

.ifdef TOP_STATUS
	; Use $2100 or $2500 (ie: offset by 256 or 8 columns)
	INC PPU_COLUMN_HIGH
.endif



	LDA COLUMN_TO_STORE
	AND #%00001111
	ASL
	STA PPU_COLUMN_LOW
	

	; since the columns start at $6000
	; and each 16 columns is a page (16 bytes each column)
	; I can determine the address like this
	; high = 60 + (column /16)
	; low = (column % 16) * 16
	LDA COLUMN_TO_LOAD
	AND #%00001111
	ASL
	ASL
	ASL
	ASL
	STA IIY_LOW
	LDA COLUMN_TO_LOAD
	AND #%11110000
	LSR
	LSR
	LSR
	LSR
	CLC
	ADC #$60
	STA IIY_HIGH
	

        ; The metatiles are in the metatile bank
	LDA METATILE_BANK
        JSR setMMC1PRGBank

	LDY #$00
	LDX #$00
:

		
	LDA (IIY_LOW),Y
	; this gives a metatile index
        ; this algorithm only supports 32 meta tiles

	; Grab the parts of the meta tile
	;Store Y
	STY TEMP_VAR1
	; Mult A by 8
	ASL
	ASL
	ASL
	; xfer A into Y
	TAY
	LDA (META_LOW),Y 
	STA FIRST_COLUMN_RAM,X
	INY
	LDA (META_LOW),Y 
	STA FIRST_COLUMN_RAM+1,X
	INY
	LDA (META_LOW),Y 
	STA SECOND_COLUMN_RAM,X
	INY
	LDA (META_LOW),Y 
	STA SECOND_COLUMN_RAM+1,X
	INY
	LDA (META_LOW),Y 
	AND #%00000011 
	; defer since OAM is smaller than tiles
	STA OAM_TEMP

	; Next byte is the tile type for collision code
	; defer since collision type is smaller than tiles
	INY
	LDA (META_LOW),Y 
	STA COLLISION_TEMP

	INX
	INX

	LDA COLUMN_TO_STORE
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC TEMP_VAR1 ; Add the y value
	TAY

	LDA COLUMN_TO_STORE
	AND #%00010000
	BEQ storeLowPage

	LDA COLLISION_TEMP
	STA COLLISION_MAP_HIGH,Y
	JMP doneLow
storeLowPage:
	LDA COLLISION_TEMP
	STA COLLISION_MAP_LOW,Y
doneLow:

	; restore Y
	LDY TEMP_VAR1
	LDA OAM_TEMP
	STA OAM_COLUMN_RAM,Y

	
	INY
	CPY #COLUMN_SIZE
	BNE :-

	; this is where OAM values can be aggregated, masked, etc... so that the PPU update stage can run faster
	; There are about COLUMN_SIZE OAM entries, but only COLUMN_SIZE/2 updates for OAM
	; If COLUMN_TO_LOAD is even, we update D0,D1  and D4,D5 for OAM.  If COLUMN_TO_LOAD is odd: we update D2,D3 and D6,D7
	; value = (topleft << 0) | (topright << 2) | (bottomleft << 4) | (bottomright << 6)
	LDA COLUMN_TO_STORE
	AND #$01
	BEQ aggregateEvenColumnOAM
	BNE aggregateOddColumnOAM
	RTS

aggregateEvenColumnOAM:

	LDA #%11001100
	STA OAM_COLUMN_BIT_MASK 

	LDX #$00
	LDY #$00
:
	LDA OAM_COLUMN_RAM+1,X  
	ASL
	ASL
	ASL
	ASL
	ORA OAM_COLUMN_RAM,X ; this should not set the carry either
	STA OAM_COLUMN_RAM,Y
	INX
	INX
	INY
	CPY #COLUMN_OAM_HEIGHT
	BNE :-
	RTS

aggregateOddColumnOAM:

	LDA #%00110011
	STA OAM_COLUMN_BIT_MASK 

	LDX #$00
	LDY #$00
:
	LDA OAM_COLUMN_RAM+1,X 
	ASL
	ASL
	ASL
	ASL	
	ORA OAM_COLUMN_RAM,X ; this should not set the carry either
	ASL
	ASL
	STA OAM_COLUMN_RAM,Y
	INX
	INX
	INY
	CPY #COLUMN_OAM_HEIGHT
	BNE :-
	RTS



