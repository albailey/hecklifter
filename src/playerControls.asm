; Player Controls CONSTANTS


REST_DURATION = 20; 1/3 second for a double press to be registered

NORMAL_SPEED  = 2
FAST_SPEED    = 3


MAX_SUB_STATE = 4

UP_MOVEMENT_MASK    = %10000000
DOWN_MOVEMENT_MASK  = %01000000
LEFT_MOVEMENT_MASK  = %00100000
RIGHT_MOVEMENT_MASK = %00010000


GRAVITY_SPEED = 2


; Multiply NORMAL_JUMP and INITIAL_JUMP_VALUE to see how high a jump can be

; This is number of frames a jump lasts (15 means a total of 16 entries needed in the JumpArc tabl
INITIAL_JUMP_DURATION    = $0F

playerJumpArc:
.byt $00, $00, $01, $01, $02, $02, $03, $03, $04, $04, $05, $05, $06, $06, $06, $06

; This is number of frames a knife thrust lasts
KNIFE_DURATION = $0F

; This is the x axis offset for a knife thrust
playerKnifeOffset:
.byt $00, $01, $02, $03, $04, $05, $06, $07, $07, $06, $05, $04, $03, $02, $01, $00

; This is number of frames between gun shots (like a reload/recoil period)
GUN_DURATION = $0F

processPlayerControls:
	; Decrement the state counter unless it is zero
	LDA PLAYER_STATE_COUNTER
	BEQ :+
	DEC PLAYER_STATE_COUNTER
:

	; Reset last move setting
	LDA #$00
	STA LAST_MOVE_SUCCESSFUL

	; Do state specific actions
	LDA PLAYER_STATE
	ASL
        TAX
        LDA playerControlsTable, X
        STA JMP_LOW
        LDA playerControlsTable+1, X
        STA JMP_HIGH
        JMP (JMP_LOW)
	; Never get here
        RTS

; Value in A register is the value for the state
setPlayerState:
 	CMP PLAYER_STATE
	BEQ :+
 	; player state changed
 	STA PLAYER_ANIMATION_STATE
 	STA PLAYER_STATE
	LDA #ANIMATION_RATE
	STA PLAYER_ANIMATION_COUNTER
	rts
:
 	; player state was the same and we moved, so enable animation procedure
	; We do not want to animate unless we actually changed location
	LDA LAST_MOVE_SUCCESSFUL
	BNE :+
	rts
:
	DEC PLAYER_ANIMATION_COUNTER
	BPL :++
	LDA #ANIMATION_RATE
	STA PLAYER_ANIMATION_COUNTER
	INC PLAYER_SUB_STATE
	LDA PLAYER_SUB_STATE
	CMP #MAX_SUB_STATE
	BCC :+
	LDA #$0
	STA PLAYER_SUB_STATE
:
	; 4 entries per state. shift twice and add the substate to get the proper offset
	LDA PLAYER_STATE
	ASL
	ASL
	CLC
	ADC PLAYER_SUB_STATE
	TAX
	LDA playerAnimationTable,X
	STA PLAYER_ANIMATION_STATE
:
	
	
	rts


playerControlsAttacking:
	; No movement allowed while attacking 
	LDA PLAYER_STATE_COUNTER
	BNE :+
	; Attacking timer ran out, revert back to standing
	LDA #PLAYER_STANDING_STATE
	jsr setPlayerState
:

	rts

; This function is the controls when the user is in normal mode
playerControlsNormal:

        ; Check for a LEFT (or double left)
	LDA CURRENT_JOY1_STATUS
	AND #JOY_LEFT_MASK
	BEQ :+  ; left not pressed. branch to checking right

	; --  Process a LEFT --
	jsr handleLeft
	; track multi press combos (like double tap to run)
	jsr detectDoubleLeft
	; Since we handled a left, theres no point in processing a right
	JMP @horizontalDone

        ; Check for a RIGHT (or double right)
:
	LDA CURRENT_JOY1_STATUS
	AND #JOY_RIGHT_MASK
	BEQ :+

	; --  Process a RIGHT --
	jsr handleRight
	jsr detectDoubleRight
	JMP @horizontalDone
:

	; Neither left or right was pressed.  Maybe we are in a rest period which will allow run mode to expire
	jsr checkRest

@horizontalDone:

        ; Check if UP pressed (may not be valid)
	LDA CURRENT_JOY1_STATUS
	AND #JOY_UP_MASK
	BEQ :+

	; --  Process an UP --
	jsr movePlayerUp
	JMP @verticalDone 
:
        ; Check if DOWN pressed (may not be valid)
	LDA CURRENT_JOY1_STATUS
	AND #JOY_DOWN_MASK
	BEQ :+

	; --  Process a Down Press --
	jsr movePlayerDown
	JMP @verticalDone 
:
        ; Neither Up or Down was pressed
        ; Can add extra stuff here later


@verticalDone:

	; Check gravity to see if we fell off an edge
	jsr movePlayerDown ; gravity
	LDA #DOWN_MOVEMENT_MASK
	BIT LAST_MOVE_SUCCESSFUL
	BEQ :+
	; We are falling. Change states
	LDA #PLAYER_FALLING_STATE
	jsr setPlayerState

:
@gravityDone:


	; --- Now the buttons ---
	LDA CURRENT_JOY1_STATUS
	AND #JOY_A_MASK
	BEQ :+
	jsr handleAPress
:
	LDA CURRENT_JOY1_STATUS
	AND #JOY_B_MASK
	BEQ :+
	jsr handleBPress
:
	rts





playerControlsParalyzed:
	; No controls work while paralyzed
	; May add PAUSE ability later
	RTS



goThroughDoor:
	RTS

playerControlsDoor:
	; Check for an UP.  This means go through the door
	LDA CURRENT_JOY1_STATUS
	AND #JOY_UP_MASK
	BEQ :+

	; --  Process an UP --
	jsr goThroughDoor
	rts
:
	JMP playerControlsNormal

	rts


playerControlsLadder:
        ; Check for a LEFT (or double left)
	LDA CURRENT_JOY1_STATUS
	AND #JOY_LEFT_MASK
	BEQ :+  ; left not pressed. branch to checking right

	; --  Process a LEFT --
	jsr handleLeft
	; track multi press combos (like double tap to run)
	jsr detectDoubleLeft
	; Since we handled a left, theres no point in processing a right
	JMP @horizontalDone

        ; Check for a RIGHT (or double right)
:
	LDA CURRENT_JOY1_STATUS
	AND #JOY_RIGHT_MASK
	BEQ :+

	; --  Process a RIGHT --
	jsr handleRight
	jsr detectDoubleRight
	JMP @horizontalDone
:

	; Neither left or right was pressed.  Maybe we are in a rest period which will allow run mode to expire
	jsr checkRest

@horizontalDone:

        ; Check if UP pressed (may not be valid)
	LDA CURRENT_JOY1_STATUS
	AND #JOY_UP_MASK
	BEQ :+

	; --  Process an UP --
	jsr movePlayerUp
	JMP @verticalDone 
:
        ; Check if DOWN pressed (may not be valid)
	LDA CURRENT_JOY1_STATUS
	AND #JOY_DOWN_MASK
	BEQ :+

	; --  Process a Down Press --
	jsr movePlayerDown
	JMP @verticalDone 
:
        ; Neither Up or Down was pressed
        ; Can add extra stuff here later


@verticalDone:



	; --- Now the buttons ---
	LDA CURRENT_JOY1_STATUS
	AND #JOY_A_MASK
	BEQ :+
	jsr handleAPress
:
	LDA CURRENT_JOY1_STATUS
	AND #JOY_B_MASK
	BEQ :+
	jsr handleBPress
	RTS

playerControlsSwinging:
	; TO DO: add support for swinging mode
	RTS

playerControlsDangling:
	; TO DO: add support for dangling from ledges 
	RTS




; ---------------------------------------  A  BUTTON   -------------------------------------------------------------------
; Common controls between the states
handleAPress:
	; TO DO: handle detection of a HOLD button
        jsr jumpPressed
        rts

; ---------------------------------------  B  BUTTON   -------------------------------------------------------------------

handleBPress:
	; TO DO: handle detection of a HOLD button
	jsr doAttack
	rts

; ---------------------------------------  SELECT  BUTTON   -------------------------------------------------------------------

handleSelectPress:
	rts

; ---------------------------------------  START  BUTTON   -------------------------------------------------------------------

handleStartPress:
	rts



; --------------------------- DOUBLE TAP ---------------------------------------------------------------------------------

detectDoubleLeft:
	LDY #JOY_LEFT_MASK
	jsr detectDoublePress
	rts

detectDoubleRight:
	LDY #JOY_RIGHT_MASK
	jsr detectDoublePress
	rts

detectDoublePress:
	; If we could not move, we could not have double pressed successfully
	LDA LAST_MOVE_SUCCESSFUL
	BEQ resetRest

	; check if we JUST pressed the same thing
	TYA
	AND LAST_JOY1_STATUS
	BNE :++
	; last press was not the same thing
	LDA LAST_PRESS
	STY LAST_PRESS  ; store Y to the variable and see if it is equivalent
	CMP LAST_PRESS
	BNE :+
	LDA #FAST_SPEED
	STA PLAYER_SPEED
	JMP :++
:
	LDA #NORMAL_SPEED
	STA PLAYER_SPEED
:
	
	rts

;--------------------------------------  REST code (for timing out running )  --------------------------------------------

checkRest:
	; Nothing pressed
	INC REST_COUNTER
	LDA REST_COUNTER
	CMP #REST_DURATION
	BCC :+

resetRest:
	LDA #$00
	STA REST_COUNTER

	; reset player speed since we rested too long
	LDA #NORMAL_SPEED
	STA PLAYER_SPEED

	; reset last press since we waited too long
	LDA #$00
	STA LAST_PRESS

:
	rts





;--------------------------------------  UP  --------------------------------------------

; Controls for handling player moving UP
movePlayerUp:
	LDX PLAYER_SPEED
	JMP doPlayerUp
	

jumpPlayerUp:
	LDX PLAYER_STATE_COUNTER
	LDA playerJumpArc,X
	TAX
	JMP doPlayerUp


doPlayerUp:
        jsr checkPlayerMoveUp
        ; Now we check start,end,mid
        jsr validateNormalValues

        BEQ :+ ;  if we got a zero, we cannot move left so we are done moving

        LDA PLAYER_TOP_LEFT_Y
	CMP #TOP_OF_SCREEN
        BCC :+
	SEC
	LDA PLAYER_TOP_LEFT_Y
	SBC MOVEMENT_DELTA
	STA PLAYER_TOP_LEFT_Y

	LDA #UP_MOVEMENT_MASK
	EOR LAST_MOVE_SUCCESSFUL
	STA LAST_MOVE_SUCCESSFUL

:
        RTS

; checkPlayerMoveUp
; Amount to move up should be placed in X
; Intersected values are stored in HIT_FLAG0, HIT_FLAG1, HIT_FLAG2
checkPlayerMoveUp: 
	; Amount to move Up is in X
	STX MOVEMENT_DELTA

	LDA #PLAYER_WIDTH ; we check 3 positions horioztally
	STA CLIP_SIZE

        LDA PLAYER_TOP_LEFT_X
	STA X_TO_CHECK

	; Y value needs to have the status region subtracted and the movement amount subtracted.
	
        LDA PLAYER_TOP_LEFT_Y
	SEC
	SBC #PLAYER_OFFSET
	SEC
	SBC MOVEMENT_DELTA
	STA Y_TO_CHECK

	LDA #UP_DIR
	STA TEMP_DIR

	JSR checkMoveVertical

	RTS

;--------------------------------------  DOWN  --------------------------------------------

movePlayerDown:
	LDX #GRAVITY_SPEED
        jsr checkPlayerMoveDown

        ; Now we check start,end,mid
        jsr validateNormalValues

        BEQ :+ ;  if we got a zero, we cannot move left so we are done moving
        LDA PLAYER_TOP_LEFT_Y
	CLC
	ADC #PLAYER_HEIGHT
	CMP #BOTTOM_OF_SCREEN
        BCS :+
	CLC
	LDA PLAYER_TOP_LEFT_Y
	ADC MOVEMENT_DELTA
	STA PLAYER_TOP_LEFT_Y

	LDA #DOWN_MOVEMENT_MASK
	EOR LAST_MOVE_SUCCESSFUL
	STA LAST_MOVE_SUCCESSFUL
:
        RTS

checkPlayerMoveDown:
	; Amount to move down is in X
	STX MOVEMENT_DELTA

	LDA #PLAYER_WIDTH ; we check 3 positions horioztally
	STA CLIP_SIZE

        LDA PLAYER_TOP_LEFT_X
	STA X_TO_CHECK

        LDA PLAYER_TOP_LEFT_Y
	SEC
	SBC #PLAYER_OFFSET
	CLC
	ADC #PLAYER_HEIGHT
	CLC
	ADC MOVEMENT_DELTA
	STA Y_TO_CHECK

	LDA #DOWN_DIR
	STA TEMP_DIR

	JSR checkMoveVertical
	RTS


;--------------------------------------  LEFT  --------------------------------------------
handleLeft:
	jsr moveLeft
	LDA #LEFT_ORIENTATION
	STA PLAYER_ORIENTATION
	rts

moveLeft:
        jsr checkMoveLeft
        ; Now we check start,end,mid
        jsr validateNormalValues
        BEQ :+ ; if we got a zero, we cannot move left so we are done moving

	LDA #LEFT_MOVEMENT_MASK
	EOR LAST_MOVE_SUCCESSFUL
	STA LAST_MOVE_SUCCESSFUL

	JSR scrollLeftIfNeeded ; sets A to zero if it worked
	BNE :+
	; if we got here, we did not scroll, so we can move the player
        LDA PLAYER_TOP_LEFT_X
        SEC
        SBC PLAYER_SPEED
        STA PLAYER_TOP_LEFT_X
:

        rts


checkMoveLeft:
        LDA PLAYER_TOP_LEFT_X
        SEC
        SBC PLAYER_SPEED
        STA TEMP_VAR1
;       DEC TEMP_VAR1

        LDA PLAYER_TOP_LEFT_Y
        SEC
        SBC #PLAYER_OFFSET
        STA TEMP_VAR2

	LDA #LEFT_DIR
	STA TEMP_DIR

        JSR checkMoveHorizontal
	; TO DO:  check HIT0,HIT1,HIT2 and react accordingly
        RTS


;--------------------------------------  RIGHT  -------------------------------------------
handleRight:
	jsr moveRight
	LDA #RIGHT_ORIENTATION
	STA PLAYER_ORIENTATION
	rts


moveRight:
        jsr checkMoveRight
        ; Now we check start,end,mid
        jsr validateNormalValues
        BEQ endMoveRight ; if we got a zero, we cannot move left so we are done moving

	LDA #RIGHT_MOVEMENT_MASK
	EOR LAST_MOVE_SUCCESSFUL
	STA LAST_MOVE_SUCCESSFUL


        LDA PLAYER_TOP_LEFT_X
        CMP #RIGHT_SCROLL_TRIGGER
        BCC :+
        jsr scrollScreenRight
        JMP endMoveRight
:
        LDA PLAYER_TOP_LEFT_X
        CLC
        ADC PLAYER_SPEED
        STA PLAYER_TOP_LEFT_X
endMoveRight:
        rts


checkMoveRight:
        LDA PLAYER_TOP_LEFT_X
        CLC
        ADC #PLAYER_WIDTH
        CLC
        ADC PLAYER_SPEED
        STA TEMP_VAR1
;       INC TEMP_VAR1

        LDA PLAYER_TOP_LEFT_Y
        SEC
        SBC #PLAYER_OFFSET
        STA TEMP_VAR2

	LDA #RIGHT_DIR
	STA TEMP_DIR
        JSR checkMoveHorizontal
        RTS


; Code for dealing with jumping


; ------------------------------------------------------------------------
; If we jump and hit an object above us there are 2 choices.
; 1) We hang until the jump duration expires
; 2) We immediately switch to FALLING mode
; Comment out the next line to allow the hang.
; Uncomment out to immediately switch to falling mode
STOP_JUMP_WHEN_HEAD_HITS  = 1
; ------------------------------------------------------------------------


; ------------------------------------------------------------------------
; If we jump and hold the A button, we may want to jump longer
; Comment out the next line to disable HELD jump mode.
; Uncomment out  the next line to allow holding the jump button to jump longer
HOLD_TO_JUMP_LONGER = 1
; ------------------------------------------------------------------------





startJump:
rts

jumpPressed:
	; Cannot jump if we are mid jump or mid attack
	LDA PLAYER_STATE_COUNTER
	BNE :+

        LDA #PLAYER_JUMPING_STATE
	jsr setPlayerState
	LDA #INITIAL_JUMP_DURATION
	STA PLAYER_STATE_COUNTER
:
        rts

playerControlsJumping:
	LDA CURRENT_JOY1_STATUS
	AND #JOY_LEFT_MASK
	BEQ :+

	; --  Process a LEFT --
	jsr handleLeft
	JMP :++
:
	LDA CURRENT_JOY1_STATUS
	AND #JOY_RIGHT_MASK
	BEQ :+

	; --  Process a Right --
	jsr handleRight

:
	; Jumping involves a jump arc
	jsr jumpPlayerUp

.IFDEF  STOP_JUMP_WHEN_HEAD_HITS
	LDA #UP_MOVEMENT_MASK
	BIT LAST_MOVE_SUCCESSFUL
	BEQ :+ ; failed to move up.
.ENDIF
	; This gives the impression of hanging in air when we hit something
	LDA PLAYER_STATE_COUNTER
	BNE :++

:
	LDA #PLAYER_FALLING_STATE
	jsr setPlayerState
:

.IFDEF ATTACK_WHILE_JUMPING
	; Attacking is considered a valid act while jumping
	LDA CURRENT_JOY1_STATUS
	AND #JOY_B_MASK
	BEQ :+
	jsr handleBPress
:
.ENDIF

	rts


playerControlsDropping:
	LDA CURRENT_JOY1_STATUS
	AND #JOY_LEFT_MASK
	BEQ :+

	; --  Process a LEFT --
	jsr handleLeft
	JMP :++
:
	LDA CURRENT_JOY1_STATUS
	AND #JOY_RIGHT_MASK
	BEQ :+

	; --  Process a Right --
	jsr handleRight

:
	jsr movePlayerDown ; Gravity

	LDA #DOWN_MOVEMENT_MASK
	BIT LAST_MOVE_SUCCESSFUL
	BNE :+ ; still moving down
	; Last move failed, so we must have hit a solid.  No longer dropping
	LDA #PLAYER_STANDING_STATE
	STA PLAYER_STATE
:

.IFDEF ATTACK_WHILE_FALLING
	LDA CURRENT_JOY1_STATUS
	AND #JOY_B_MASK
	BEQ :+
	jsr handleBPress
:
.ENDIF

	rts




;--------------------------------------  WEAPONS  -------------------------------------------

; WEAPONS AND ATTACK CODE

BARE_HANDED_WEAPON	 = 0
KNIFE_WEAPON		 = 1
GUN_WEAPON 		 = 2

playerWeaponsTable:
	.addr bareHandedWeaponAttack
	.addr knifeWeaponAttack
	.addr gunWeaponAttack

bareHandedWeaponAttack:
	rts

knifeWeaponAttack:
	LDA #KNIFE_DURATION
	STA PLAYER_STATE_COUNTER

	rts
gunWeaponAttack:
	LDA #GUN_DURATION
	STA PLAYER_STATE_COUNTER
	rts

doAttack:
	; We do not support doing an attack if we are mid action for something else (like jump or another attack)
	LDA PLAYER_STATE_COUNTER
	BNE :+

	LDA #PLAYER_ATTACKING_STATE
	jsr setPlayerState

	; Attack is different based on the equipped weapon
	LDA PLAYER_WEAPON
	ASL
        TAX
        LDA playerWeaponsTable, X
        STA JMP_LOW
        LDA playerWeaponsTable+1, X
        STA JMP_HIGH
        JMP (JMP_LOW)
:
        RTS
	
