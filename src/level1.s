.export _LEVEL1_PALETTE_ADDR
.export _LEVEL1_METATILES_ADDR
.export _LEVEL1_TILES_ADDR
.export _LEVEL1_COLUMNS_ADDR

; Put the data in the proper banks (and update the header constants to match)

.segment "BANK5"

_LEVEL1_TILES_ADDR:
.incbin "level1/Level_1.tiles"

_LEVEL1_PALETTE_ADDR:
.include "level1/Level_1.palette"

_LEVEL1_METATILES_ADDR:
.include "level1/Level_1.metatiles"

_LEVEL1_COLUMNS_ADDR:
.include "level1/Level_1.columns"


.segment "BANKF"

