.IFNDEF ENGINE_CONSTANTS
ENGINE_CONSTANTS = 1

; PLAYER STATES
PLAYER_STANDING_STATE = 0
PLAYER_WALKING_STATE = 1
PLAYER_CLIMBING_STATE = 2
PLAYER_JUMPING_STATE = 3
PLAYER_FALLING_STATE = 4
PLAYER_COVERED_STATE = 5
PLAYER_DOOR_STATE = 6
PLAYER_HURT_STATE     = 7
PLAYER_CLING_STATE    = 8
PLAYER_SLIPPING_STATE = 9
PLAYER_TRIGGER_STATE  = $A
PLAYER_CARRIED_STATE  = $B
PLAYER_SWIMMING_STATE = $C
PLAYER_PUSHED_STATE   = $D
PLAYER_ATTACKING_STATE  = $E

; ROOM FOR MORE.  32 theoretical max

PLAYER_INVALID_STATE = $FF

ANIMATION_RATE  = 5


;  OBJECT TYPES
; These are used by the level editor
; ORDER IS IMPORTANT.  If more than one object type is encountered (start, mid, end) then the HIGHEST value is used
; This is why PAIN is last.  We want to make sure if we hit a solid object or a pointy one, we notice the pointy one.

AIR_OBJECT_TYPE      = 0
COVER_OBJECT_TYPE    = 1  ; COVER is essentially the same as air, it doesn't obstruct
PUSH_OBJECT_TYPE     = 2  ; A special object type that pushes the character. Directional. Can be a conveyor belt, wind, etc..
WATER_OBJECT_TYPE    = 3  ; Allows swimming
DOOR_OBJECT_TYPE     = 4  ; Almost the same as air.  Except pressing UP near it allows you to go through it
STAIRS_OBJECT_TYPE   = 5  ; A special object type that allows up/down travel without gravity
CARRIER_OBJECT_TYPE  = 6  ; A special object type that moves and can bring the character with them (vine, floating disc)
TRIGGER_OBJECT_TYPE  = 7  ; An object type that triggers an action on the player (like a jump)
PLATFORM_OBJECT_TYPE = 8  ; Like a solid object, except you can jump or pass through it in one or more directions.
SOLID_OBJECT_TYPE    = 9 ; Cannot go through it
SLIPPY_OBJECT_TYPE   = $A  ; A surface that does not allow changes in direction.  Affects acceleration
CLING_OBJECT_TYPE    = $B  ; Cannot go through it, but can grab it
PAIN_OBJECT_TYPE     = $C  ; Hit this, and feel pain.  Like a solid, but higher priority due to the consequences


; PLAYER CONTROL DIRECTIONS.

UP_DIR 		= 0
DOWN_DIR	= 1
LEFT_DIR	= 2
RIGHT_DIR	= 3


.ENDIF

