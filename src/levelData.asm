
; This file includes the level table, and the high level values for those levels
; This file must be includes in the FIXED bank
; as well as the game engine code

; -----------------------------------------------------
; Addresses of the Levels
; -----------------------------------------------------
LEVEL_DATA:
.addr Level0
.addr Level1
; -----------------------------------------------------



; -----------------------------------------------------
; Level format
; -----------------------------------------------------
; 1 Byte = TileBank
; 1 Byte = Num CHR Tiles to load into $0000.  Max=$F0
; 2 Bytes = addr of CHR Tiles to load into $0000
; 1 Byte = MetaTileBank
; 2 Bytes = addr of Meta Tile Set 
; 1 Byte = ColumnBank
; 1 Byte = num pages (16 columns to a page)
; 2 Bytes = addr of Columns
; -----------------------------------------------------

; Level 0
Level0:
.byt $06 ; Bank 6 are the tiles
.byt $20
.addr level0Tiles
.byte $07  ; Indicates the bank of the metatiles 
.addr MetaTileSet0  
.byte $08  ; Indicates the bank of the columns 
.byt $08 ; 8 pages total
.addr Level0Columns

Level1:
.byt $06 ; Bank 6 are the tiles
.byt $F0
.addr level1Tiles
.byte $07  ; Indicates the bank of the metatiles 
.addr MetaTileSet1  
.byte $08  ; Indicates the bank of the columns 
.byt $08 ; 8 pages total
.addr Level1Columns


; -----------------------------------------------------
; Address of the palettes used by the levels
levelPalettes:
.addr level0_pal
.addr level1_pal

; -----------------------------------------------------
; Palettes themselves
; -----------------------------------------------------
level0_pal:  ; Empty so just set it the same as level 1
level1_pal:
.include "levels/editor/Level_1.palette"
; -----------------------------------------------------

