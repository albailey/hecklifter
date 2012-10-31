.export _getNumCutScenes
.export _getCutSceneBank
.export _getCutSceneNumTiles
.export _getCutSceneCHRAddr
.export _getCutScenePaletteAddr
.export _getCutSceneNTAddr
.export _getCutSceneTextAddr
.export _getAlphabetCHRAddr

; getNumCutScenes()
_getNumCutScenes:  
   LDA #CUT_SCENE_NUM_SCENES
   RTS

; getCutSceneBank(unsigned char)
_getCutSceneBank:  
	; each entity is 8 bytes    
	ASL
	ASL
	ASL
	TAX
	LDA CUT_SCENE_DATA_TABLE,X
	RTS

; getCutSceneNumTiles(unsigned char)
_getCutSceneNumTiles:  
	; each entity is 8 bytes    
	ASL
	ASL
	ASL
	TAX
	LDA CUT_SCENE_DATA_TABLE+1,X
	RTS

; getCutSceneCHRAddr(unsigned char)
_getCutSceneCHRAddr:  
	; each entity is 8 bytes    
	ASL
	ASL
	ASL
	TAY
	LDA CUT_SCENE_DATA_TABLE+2,Y
	LDX CUT_SCENE_DATA_TABLE+3,Y
	RTS

; getCutScenePaletteAddr(unsigned char)
_getCutScenePaletteAddr:  
	; each entity is 8 bytes    
	ASL
	ASL
	ASL
	TAY
	LDA CUT_SCENE_DATA_TABLE+4,Y
	LDX CUT_SCENE_DATA_TABLE+5,Y
	RTS

; getCutSceneNTAddr(unsigned char)
_getCutSceneNTAddr:  
	; each entity is 8 bytes    
	ASL
	ASL
	ASL
	TAY
	LDA CUT_SCENE_DATA_TABLE+6,Y
	LDX CUT_SCENE_DATA_TABLE+7,Y
	RTS

; getCutSceneTextAddr(unsigned char)
_getCutSceneTextAddr:  
	; each entity is 2 bytes    
	ASL
	TAY
	LDA CUT_SCENE_TEXT,Y
	LDX CUT_SCENE_TEXT+1,Y
	RTS

_getAlphabetCHRAddr:  
	LDA #<ALPHABET_FONT_CHR
	LDX #>ALPHABET_FONT_CHR
	RTS

; Text Chars
ALPHABET_FONT_CHR:  ; 32 characters = 512 bytes
.incbin "graphics/chars/alphabet.font.chr"


.include "cutSceneData.s"

