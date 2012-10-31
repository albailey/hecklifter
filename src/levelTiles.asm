; tiles used by the levels in bank 6
.segment "BANK6"




; -----------------------------------------------------
; tiles for the levels
; -----------------------------------------------------
level0Tiles: ; Empty so just set it the same as level 1
level1Tiles:
.incbin "levels/editor/Level_1.tiles"
; -----------------------------------------------------

.segment "BANK6_END"






; Metatiles used by the levels in bank 7
.segment "BANK7"


MetaTileSet0:
MetaTileSet1:

.include "levels/editor/Level_1.metatiles"


.segment "BANK7_END"




.segment "BANK8"



; -----------------------------------------------------
;   Level 0 (empty)
Level0Columns: 


; -----------------------------------------------------
;   Level 1

Level1Columns:

Level2Columns:

.include "levels/editor/Level_1.columns"

.segment "BANK8_END"
