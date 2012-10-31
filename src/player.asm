
.include "engineConstants.asm"
.include "playerControls.asm"


;--------------------------------------------------------;
; Constants
;--------------------------------------------------------;

COLLISION_MAP_LOW          = $0400
COLLISION_MAP_HIGH         = $0500


;Level 1 starting position for character
INITIAL_PLAYER_LEFT_X      = 148 ; decimal
INITIAL_PLAYER_LEFT_Y      = 142 ; decimal
FIRST_PLAYER_SPRITE_INDEX  = 4   ; decimal
PLAYER_ATTRIBUTES          = %00000001

; This needs to be replaced with player sprites
PLAYER_CHR_INDEX           = $FF

; Additional address offset based on orientations.
RIGHT_ORIENTATION = 0
LEFT_ORIENTATION = 2

SPRITES_WIDE_VAR         = TEMP_VAR0
TMP_SPRITES_WIDE_VAR     = TEMP_VAR1
SPRITES_HIGH_VAR         = TEMP_VAR2
CURRENT_PLAYER_ROW_INDEX = TEMP_VAR3

TEMP_PLAYER_X            = TEMP_VAR4
TEMP_PLAYER_Y            = TEMP_VAR5
TEMP_PLAYER_X_ALT        = TEMP_VAR6

; Constants pertaining to the number of player sprites in the tile page, and where to load them
NUM_PLAYER_TILES   = 48   ; decimal
PLAYER_TILE_OFFSET = $20


loadPlayerSpritesIntoTileBanks:
        LDA #<PLAYER_TILES
        STA IIY_LOW
        LDA #>PLAYER_TILES
        STA IIY_HIGH
        LDA #$10 ; sprite table
        LDX #PLAYER_TILE_OFFSET  ; Store at 10xx 
        LDY #NUM_PLAYER_TILES    ; num sprites to load 
        jsr LoadCHRSubset
	rts

initializePlayerSprites:
	jsr postUpdatePlayerState
        rts

updatePlayerSprites:
	jsr postUpdatePlayerState
        rts


;  fixed player sprite start index
; There is a max number of sprites.  Mode may be less
; So we need to set the Y value offscreen for the remainder 


; Y, Tile, Attrib, X
postUpdatePlayerState:

	LDA PLAYER_ANIMATION_STATE
	ASL ; mul by 2 to get proper address offset
	TAX
	LDA playerSpriteTable,X
	STA IIY_LOW
	INX
	LDA playerSpriteTable, X
	STA IIY_HIGH

	LDY #$00
	;first byte is num bytes wide
	LDA (IIY_LOW),Y
	STA SPRITES_WIDE_VAR 
	STA TMP_SPRITES_WIDE_VAR 
	INY
	;second byte is num bytes high
	LDA (IIY_LOW),Y
	STA SPRITES_HIGH_VAR 
	INY

	LDA PLAYER_ORIENTATION
	BNE drawOrientationLeft
	JMP drawOrientationRight

drawOrientationLeft:
	; TO DO: handle when we have a reduction in num sprites

	LDA PLAYER_TOP_LEFT_Y
	STA TEMP_PLAYER_Y

	LDX TMP_SPRITES_WIDE_VAR 
	DEX
	TXA
	ASL
	ASL
	ASL
	CLC
	ADC PLAYER_TOP_LEFT_X
	STA TEMP_PLAYER_X_ALT
	STA TEMP_PLAYER_X
	
	LDX #FIRST_PLAYER_SPRITE_INDEX

:
	LDA (IIY_LOW),Y
	CLC
        ADC TEMP_PLAYER_Y
	STA SPRITE_BANK,X
	INX
	INY

	LDA (IIY_LOW),Y
	STA SPRITE_BANK,X
	INX
	INY

	; Flip the attribute
	LDA (IIY_LOW),Y
	EOR #%1000000
	
	STA SPRITE_BANK,X
	INX
	INY

	LDA (IIY_LOW),Y
	CLC
        ADC TEMP_PLAYER_X
	STA SPRITE_BANK,X
	INX
	INY

	SEC
	LDA TEMP_PLAYER_X
	SBC #8
	STA TEMP_PLAYER_X

	DEC TMP_SPRITES_WIDE_VAR
	BNE :-
	LDA TEMP_PLAYER_X_ALT
	STA TEMP_PLAYER_X
	CLC
	LDA #8
	ADC TEMP_PLAYER_Y
	STA TEMP_PLAYER_Y
	LDA SPRITES_WIDE_VAR
	STA TMP_SPRITES_WIDE_VAR
	DEC SPRITES_HIGH_VAR
	BNE :-
	RTS

drawOrientationRight:

	; TO DO: handle when we have a reduction in num sprites
	LDX #FIRST_PLAYER_SPRITE_INDEX

	LDA PLAYER_TOP_LEFT_Y
	STA TEMP_PLAYER_Y

	LDA PLAYER_TOP_LEFT_X
	STA TEMP_PLAYER_X

:
	LDA (IIY_LOW),Y
	CLC
        ADC TEMP_PLAYER_Y
	STA SPRITE_BANK,X
	INX
	INY

	LDA (IIY_LOW),Y
	STA SPRITE_BANK,X
	INX
	INY

	LDA (IIY_LOW),Y
	STA SPRITE_BANK,X
	INX
	INY

	LDA (IIY_LOW),Y
	CLC
        ADC TEMP_PLAYER_X
	STA SPRITE_BANK,X
	INX
	INY

	CLC
	LDA #8
	ADC TEMP_PLAYER_X
	STA TEMP_PLAYER_X

	DEC TMP_SPRITES_WIDE_VAR
	BNE :-
	LDA PLAYER_TOP_LEFT_X
	STA TEMP_PLAYER_X
	CLC
	LDA #8
	ADC TEMP_PLAYER_Y
	STA TEMP_PLAYER_Y
	LDA SPRITES_WIDE_VAR
	STA TMP_SPRITES_WIDE_VAR
	DEC SPRITES_HIGH_VAR
	BNE :-
	RTS


	rts
	





;  IMPORTANT!!!
;  The priority system chooses the highest object type for the start,mid,end calculations
;  So for example, it is important that a SOLID  is a higher value than AIR.  

; AIR_OBJECT_TYPE   (index 0)
; COVER_OBJECT_TYPE
; PUSH_OBJECT_TYPE
; WATER_OBJECT_TYPE
; DOOR_OBJECT_TYPE
; STAIRS_OBJECT_TYPE
; CARRIER_OBJECT_TYPE
; TRIGGER_OBJECT_TYPE
; PLATFORM_OBJECT_TYPE
; SOLID_OBJECT_TYPE
; SLIPPY_OBJECT_TYPE
; CLING_OBJECT_TYPE
; PAIN_OBJECT_TYPE




beastieValidationTable:
; One value per object type (in order)
; In this example, this beastie cannot travel through platform, cling solid, or pain
.byt $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00


; IMPORTANT !!!
; If we add a new player state, we must add a new address to several tables
; playerSpriteTable   ; Otherwise the graphics get mangled
; playerControlsTable ; Otherwise controls break
; invalidTransitionTable ; Otherwise we break when we hit something in that state

;  PLAYER STATES (defined in engineConstants.asm)
;PLAYER_STANDING_STATE = 0
;PLAYER_WALKING_STATE = 1
;PLAYER_CLIMBING_STATE = 2
;PLAYER_JUMPING_STATE = 3
;PLAYER_FALLING_STATE = 4
;PLAYER_COVERED_STATE = 5
;PLAYER_DOOR_STATE = 6
;PLAYER_HURT_STATE     = 7
;PLAYER_CLING_STATE    = 8
;PLAYER_SLIPPING_STATE = 9
;PLAYER_TRIGGER_STATE  = $A
;PLAYER_CARRIED_STATE  = $B
;PLAYER_SWIMMING_STATE = $C
;PLAYER_PUSHED_STATE   = $D
;PLAYER_ATTACKING_STATE   = $E

PLAYER_STEP_1          = $F
PLAYER_JUMP_STEP_1     = $10

; The sprites table is tied to ANIMATION_STATE
playerSpriteTable:
.addr playerStanding ; standing
.addr playerStanding ; walking
.addr playerJumping  ; climbing
.addr playerJumping  ; jumping
.addr playerJumping  ; falling
.addr playerJumping  ; Covered
.addr playerJumping  ; Door
.addr playerJumping  ; Hurt
.addr playerJumping  ; Cling
.addr playerJumping  ; Slipping
.addr playerJumping  ; Trigger
.addr playerJumping  ; Carried
.addr playerJumping  ; Swimming
.addr playerJumping  ; Pushed
.addr playerAttacking  ; Pushed
.addr playerStandingStep ; animation step
.addr playerJumpingStep ; animation step



; 4 entries per state
playerAnimationTable:
.byt PLAYER_STANDING_STATE, PLAYER_STEP_1, PLAYER_STANDING_STATE, PLAYER_STEP_1
.byt PLAYER_WALKING_STATE,  PLAYER_STEP_1,  PLAYER_WALKING_STATE,  PLAYER_STEP_1
.byt PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE
.byt PLAYER_JUMPING_STATE, PLAYER_JUMP_STEP_1, PLAYER_JUMPING_STATE, PLAYER_JUMP_STEP_1
.byt PLAYER_FALLING_STATE, PLAYER_FALLING_STATE, PLAYER_FALLING_STATE, PLAYER_FALLING_STATE
.byt PLAYER_COVERED_STATE, PLAYER_COVERED_STATE, PLAYER_COVERED_STATE, PLAYER_COVERED_STATE
.byt PLAYER_DOOR_STATE, PLAYER_DOOR_STATE, PLAYER_DOOR_STATE, PLAYER_DOOR_STATE
.byt PLAYER_HURT_STATE, PLAYER_HURT_STATE, PLAYER_HURT_STATE, PLAYER_HURT_STATE
.byt PLAYER_CLING_STATE, PLAYER_CLING_STATE, PLAYER_CLING_STATE, PLAYER_CLING_STATE
.byt PLAYER_SLIPPING_STATE, PLAYER_SLIPPING_STATE, PLAYER_SLIPPING_STATE, PLAYER_SLIPPING_STATE
.byt PLAYER_TRIGGER_STATE, PLAYER_TRIGGER_STATE, PLAYER_TRIGGER_STATE, PLAYER_TRIGGER_STATE
.byt PLAYER_CARRIED_STATE, PLAYER_CARRIED_STATE, PLAYER_CARRIED_STATE, PLAYER_CARRIED_STATE
.byt PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE
.byt PLAYER_PUSHED_STATE, PLAYER_PUSHED_STATE, PLAYER_PUSHED_STATE, PLAYER_PUSHED_STATE
.byt PLAYER_ATTACKING_STATE, PLAYER_ATTACKING_STATE, PLAYER_ATTACKING_STATE, PLAYER_ATTACKING_STATE


; The controls table should be the same order as the player state table
playerControlsTable:
        .addr playerControlsNormal ; standing
        .addr playerControlsNormal ; walking
        .addr playerControlsLadder ; climbing
        .addr playerControlsJumping ; jumping
        .addr playerControlsDropping ; falling
        .addr playerControlsNormal ; covered
        .addr playerControlsDoor   ; door
        .addr playerControlsNormal ; hurt
        .addr playerControlsNormal ; cling
        .addr playerControlsNormal ; slipping
        .addr playerControlsNormal ; trigger
        .addr playerControlsNormal ; carried
        .addr playerControlsNormal ; swimming
        .addr playerControlsNormal ; pushed
        .addr playerControlsAttacking ; attacking

; The invalidTransitionTable should be the same order as the player state table (4 bytes per row. Up, Down, Left, Right)
; Need to deal with what to do when we encounter an INVALID state, in terms of which state to change to
; Usually we just stay in the same state
; Example: if we are in player state 2 (row 2 = climbing) and encounter an invalid state, we stay in that state
; Special case: look at jumping.  if we are jumping (up) and hit an obstruction, we switch to falling mode
invalidTransitionTable:
.byt PLAYER_STANDING_STATE, PLAYER_STANDING_STATE, PLAYER_STANDING_STATE, PLAYER_STANDING_STATE ; standing
.byt PLAYER_WALKING_STATE,  PLAYER_WALKING_STATE,  PLAYER_WALKING_STATE,  PLAYER_WALKING_STATE ; walking 
.byt PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE ; climbing
.byt PLAYER_FALLING_STATE,  PLAYER_FALLING_STATE,  PLAYER_JUMPING_STATE,  PLAYER_JUMPING_STATE  ; jumping
.byt PLAYER_FALLING_STATE,  PLAYER_STANDING_STATE, PLAYER_FALLING_STATE,  PLAYER_FALLING_STATE  ; falling
.byt PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE  ; covered 
.byt PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE     ; door
.byt PLAYER_HURT_STATE,     PLAYER_HURT_STATE,     PLAYER_HURT_STATE,     PLAYER_HURT_STATE     ; hurt
.byt PLAYER_CLING_STATE,    PLAYER_CLING_STATE,    PLAYER_CLING_STATE,    PLAYER_CLING_STATE    ; cling
.byt PLAYER_SLIPPING_STATE, PLAYER_SLIPPING_STATE, PLAYER_SLIPPING_STATE, PLAYER_SLIPPING_STATE ; slipping
.byt PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE  ; trigger
.byt PLAYER_CARRIED_STATE,  PLAYER_CARRIED_STATE,  PLAYER_CARRIED_STATE,  PLAYER_CARRIED_STATE  ; carried
.byt PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE ; swimming
.byt PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE   ; pushed
.byt PLAYER_ATTACKING_STATE, PLAYER_ATTACKING_STATE, PLAYER_ATTACKING_STATE, PLAYER_ATTACKING_STATE ; attacking


; The p1TransitionTable should be the same order as the player state table
; This table is for PLAYER states (and has one row per object state)
p1TransitionTable:
.addr standingStateTable
.addr walkingStateTable
.addr climbingStateTable
.addr jumpingStateTable
.addr fallingStateTable
.addr coveredStateTable
.addr doorStateTable
.addr hurtStateTable
.addr clingStateTable
.addr slippingStateTable
.addr triggerStateTable
.addr carriedStateTable
.addr swimmingStateTable
.addr pushedStateTable
.addr attackingStateTable

; The following are used by some of the above tables

; Need to specify what transitions are valid in each state
; Each row has 4 bytes (up, down, left, right). Each row corresponds in order to all the mapStates


; Standing 
; Walking is the same logic.
; Climbing is the same logic
; Covered is the same logic
; Door is the same logic
; Guessing the rest are the same logic
standingStateTable:
walkingStateTable:
climbingStateTable:
coveredStateTable:
doorStateTable:
hurtStateTable:
clingStateTable:
slippingStateTable:
triggerStateTable:
carriedStateTable:
swimmingStateTable:
pushedStateTable:
.byt PLAYER_INVALID_STATE,  PLAYER_FALLING_STATE,  PLAYER_WALKING_STATE,  PLAYER_WALKING_STATE       ; AIR
.byt PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE       ; COVER
.byt PLAYER_INVALID_STATE,  PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE        ; PUSH 
.byt PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE      ; WATER
.byt PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE          ; DOOR
.byt PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE      ; STAIRS
.byt PLAYER_INVALID_STATE,  PLAYER_CARRIED_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       ; CARRIER
.byt PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE       ; TRIGGER
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       ; PLATFORM
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       ; SOLID
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_SLIPPING_STATE, PLAYER_SLIPPING_STATE      ; SLIPPY
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_CLING_STATE,    PLAYER_CLING_STATE         ; CLING
.byt PLAYER_HURT_STATE,     PLAYER_HURT_STATE,     PLAYER_HURT_STATE,     PLAYER_HURT_STATE          ; PAIN

; Jumping is different since we can go UP through things like air
; We can go UP through Carrier and Platform (but not solid) and cling to CLING types
jumpingStateTable:
.byt PLAYER_JUMPING_STATE,  PLAYER_FALLING_STATE,  PLAYER_JUMPING_STATE, PLAYER_JUMPING_STATE        ; AIR
.byt PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE       ; COVER
.byt PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE        ; PUSH 
.byt PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE      ; WATER
.byt PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE          ; DOOR
.byt PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE      ; STAIRS
.byt PLAYER_JUMPING_STATE,  PLAYER_CARRIED_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       ; CARRIER
.byt PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE       ; TRIGGER
.byt PLAYER_JUMPING_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       ; PLATFORM
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       ; SOLID
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_SLIPPING_STATE, PLAYER_SLIPPING_STATE      ; SLIPPY
.byt PLAYER_CLING_STATE,    PLAYER_INVALID_STATE,  PLAYER_CLING_STATE,    PLAYER_CLING_STATE         ; CLING
.byt PLAYER_HURT_STATE,     PLAYER_HURT_STATE,     PLAYER_HURT_STATE,     PLAYER_HURT_STATE          ; PAIN


; Falling is special since we can't really go UP
fallingStateTable:
.byt PLAYER_INVALID_STATE,  PLAYER_FALLING_STATE,  PLAYER_FALLING_STATE,  PLAYER_FALLING_STATE       ; AIR
.byt PLAYER_INVALID_STATE,  PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE,  PLAYER_COVERED_STATE       ; COVER
.byt PLAYER_INVALID_STATE,  PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE,   PLAYER_PUSHED_STATE        ; PUSH 
.byt PLAYER_INVALID_STATE,  PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE, PLAYER_SWIMMING_STATE      ; WATER
.byt PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE,     PLAYER_DOOR_STATE          ; DOOR
.byt PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE, PLAYER_CLIMBING_STATE      ; STAIRS
.byt PLAYER_INVALID_STATE,  PLAYER_CARRIED_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       ; CARRIER
.byt PLAYER_INVALID_STATE,  PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE,  PLAYER_TRIGGER_STATE       ; TRIGGER
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       ; PLATFORM
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       ; SOLID
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_SLIPPING_STATE, PLAYER_SLIPPING_STATE      ; SLIPPY
.byt PLAYER_CLING_STATE,    PLAYER_INVALID_STATE,  PLAYER_CLING_STATE,    PLAYER_CLING_STATE         ; CLING
.byt PLAYER_HURT_STATE,     PLAYER_HURT_STATE,     PLAYER_HURT_STATE,     PLAYER_HURT_STATE          ; PAIN

; We do not support any movement while attacking
attackingStateTable:
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       
.byt PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE,  PLAYER_INVALID_STATE       





;--------------------------------------------------------;
;----------------------PLAYER SPRITE TABLES -------------
;--------------------------------------------------------;
;  Need to add sprites and layout info for player states
; Y-Delta, Tile. Attrib, X-Delta 

; This is ordered 0 to FF.
; If we are less than the value, we use that address.
; Last value must be $0 meaning done.
playerStanding:
.byt  2, 3 ; 2x3 sprites
.byt  $0, $21, $40, $0
.byt  $0, $20, $40, $0
.byt  $0, $31, $40, $0
.byt  $0, $30, $40, $0
.byt  $0, $41, $40, $0
.byt  $0, $40, $40, $0

playerStandingStep:
.byt  2, 3 ; 2x3 sprites
.byt  $0, $21, $40, $0
.byt  $0, $20, $40, $0
.byt  $0, $31, $40, $0
.byt  $0, $30, $40, $0
.byt  $2, $41, $40, $0
.byt  $2, $40, $40, $0

playerJumping:
.byt  2, 3     ; 2x3 sprites
.byt  $0, $21, $40, $0
.byt  $0, $20, $40, $0
.byt  $0, $31, $40, $0
.byt  $0, $30, $40, $0
.byt  $0, $41, $40, $0
.byt  $0, $40, $40, $0

playerJumpingStep:
.byt  2, 3     ; 2x3 sprites
.byt  $0, $21, $40, $0
.byt  $0, $20, $40, $0
.byt  $0, $31, $40, $0
.byt  $0, $30, $40, $0
.byt  $2, $41, $40, $0
.byt  $2, $40, $40, $0

playerAttacking:
.byt  2, 3     ; 2x3 sprites
.byt  $0, $21, $40, $0
.byt  $0, $20, $40, $2
.byt  $0, $31, $40, $0
.byt  $0, $30, $40, $2
.byt  $0, $41, $40, $0
.byt  $0, $40, $40, $2




PLAYER_TILES:
.incbin "player/player.chr"


