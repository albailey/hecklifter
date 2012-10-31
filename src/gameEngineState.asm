; This file contains everything pertaining to TITLE screens
; It does not compile or stand on its own.  Basically it is just where the code from game.asm has been cut out

LEVEL_1  =  $01
LEVEL_2  =  $02

PPUMASK_VAL = %00011110 ; turn off left and right 8 pixels

GAME_ENGINE_BANK = $05

GAME_ENGINE_MUSIC_BANK = $0E


initGameEngineNMI:

	; TESTING!!!!   would normally be level 1
        LDA #LEVEL_1
        STA LEVEL

        ; Do not update any graphics during this part of NMI
        LDA #<doNothingGraphicsUpdate
        STA GRAPHICS_UPDATE_ADDR_LOW
        LDA #>doNothingGraphicsUpdate
        STA GRAPHICS_UPDATE_ADDR_HIGH

        ; Switch to game engine mode
        LDA #GAME_ENGINE_STATE
        STA STATE_MACHINE

        ; Notify about the change
        LDA #STATE_CHANGED
        STA CHANGE_DETECTION_FLAG

        LDA CURRENT_BANK
        PHA
        ; Initialize music driver 
        LDA #GAME_ENGINE_MUSIC_BANK
        JSR setMMC1PRGBank

        LDX #$00 ; NTSC default
        LDA FPS_VALUE
        CMP #60 ; NTSC
        BEQ :+
        INX ; PAL - set X = 1
:
        LDA #$01 ; song 1
        JSR $8000 ; music init

        ; reset bank back to current bank
        PLA
        JSR setMMC1PRGBank
rts




processGameEngineNMI:
       ; Update the offscreen background tiles that can only be done during VBLANK period
        LDA CURRENT_BANK
        PHA
        LDA #GAME_ENGINE_BANK  
        jsr setMMC1PRGBank
        JSR updateBackgroundTileLocations 
	PLA 
        jsr setMMC1PRGBank

       LDA $2002 ; reset address latch

.ifdef TOP_STATUS
        ; Reset Scroll for Status Bar
        LDA #$00
        STA $2005
        STA $2005
        LDA #STATUS_REGION_PPU_SETTINGS
        STA $2000
.else
        ; Set Scroll data for the screen
        LDA SCROLL_POSITION
        STA $2005 ; first write is X scrolling
        LDA #$00
        STA $2005 ; second write is Y scrolling

        ; Now set the scrolling and page back for the rest
        LDA CURRENT_PAGE_PPU_SETTINGS
        STA $2000
        JSR doGameEngineNMIWork
.endif


        ; Wait for Scanline #0 to reset the Sprite #0 hit flag
:       BIT $2002
        BVS :-

        ; Wait for the first intersected pixel of sprite #0 to be rendered
:       BIT $2002
        BVC :-


.ifdef TOP_STATUS
        ; Draw the screen
        LDA SCROLL_POSITION
        STA $2005 ; first write is X scrolling
        LDA #$00
        STA $2005 ; second write is Y scrolling

        ; Now set the scrolling and page back for the rest
        LDA CURRENT_PAGE_PPU_SETTINGS
        STA $2000
        JSR doGameEngineNMIWork
.else
        ; Reset Scroll for Status Bar
        LDA #$00
        STA $2005
        STA $2005
        LDA #STATUS_REGION_PPU_SETTINGS
        STA $2000
.endif



rts

doGameEngineNMIWork:

        LDA CURRENT_BANK
        PHA

        ; Here is our sequence
        ; update audio
        ; update game state machine (sprites/game/scrolling, etc..) based on input
        JSR updateGameEngineAudio

        LDA #GAME_ENGINE_BANK  
        jsr setMMC1PRGBank

        JSR processPlayerControls
        JSR updatePlayerSprites

	; These next 2 have not been implemented yet
        ;JSR updateEnemyActions
        ;JSR updateEnemySprites


        PLA
        JSR setMMC1PRGBank

        RTS

updateGameEngineAudio:
        ; Play music
        LDA CURRENT_BANK
        PHA

        ; Update Game Engine Audio
        LDA #GAME_ENGINE_MUSIC_BANK
        JSR setMMC1PRGBank
        JSR $8003

        ; Restore whatever bank we were in
        PLA
        JSR setMMC1PRGBank
        RTS

processGameEngineNonNMI:

        LDA CHANGE_DETECTION_FLAG
        BEQ :+
        jsr loadGameEngineNonNMI 

        LDA #STATE_UNCHANGED
        STA CHANGE_DETECTION_FLAG
:

        ; To Do: Add controls interaction, etc..

rts

loadGameEngineNonNMI:
        LDA #$00
        STA $2000
        STA $2001
        LDA $2002 ; reset latch

        ; graphics are off

	; setup the initial level variables
        jsr prepareLevel

        ; Wait for vblank before turning back on graphics
:       lda $2002 ;
        bpl  :-

	; Now wire in the PPU registers based on the graphics setup above
	LDA #$00
	STA $2005
	STA $2005
	STA $2006
	STA $2006
	LDA CURRENT_PAGE_PPU_SETTINGS
	STA $2000
	LDA #PPUMASK_VAL
	STA $2001
	
rts



prepareLevel:
        ; Store the current bank
        LDA CURRENT_BANK
	PHA

        ; Switch to the game engine bank
        LDA #GAME_ENGINE_BANK  
        jsr setMMC1PRGBank

        ; Initialite the starting player values for the level

	LDA #PLAYER_STANDING_STATE
	STA PLAYER_STATE
	STA PLAYER_ANIMATION_STATE

	LDA #RIGHT_ORIENTATION
	STA PLAYER_ORIENTATION

	LDA #$00
	STA PLAYER_JUMP

	LDA #NORMAL_SPEED
	STA PLAYER_SPEED

	LDA #KNIFE_WEAPON
	STA PLAYER_WEAPON

	LDA #INITIAL_PLAYER_LEFT_X
	STA PLAYER_TOP_LEFT_X

	LDA #INITIAL_PLAYER_LEFT_Y
	STA PLAYER_TOP_LEFT_Y

        ; setup the sprite zero for the status bar
        jsr initStatusBarSpriteZero
        JSR setupStatusBar

        ; setup the level
	jsr setupLevel

        ; setup the player
        JSR loadPlayerSpritesIntoTileBanks
        JSR initializePlayerSprites

	; Set everything back to normal in case setupLevel messed with PPU
	LDA $2002 ; reset address latch. Do I need to do this
	LDA #$00
	STA SCROLL_POSITION ; initialize it to zero
	LDA #PAGE_ZERO_PPU_SETTINGS
	STA CURRENT_PAGE_PPU_SETTINGS


	; Restore back to the bank we were using before calling this function
        PLA
        JSR setMMC1PRGBank
rts






