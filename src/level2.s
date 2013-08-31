.export _LEVEL2_PALETTE_ADDR
.export _LEVEL2_METATILES_ADDR
.export _LEVEL2_TILES_ADDR
.export _LEVEL2_COLUMNS_ADDR

; Put the data in the proper banks (and update the header constants to match)

.segment "BANK5"

_LEVEL2_TILES_ADDR:
.incbin "level2/Level_2.tiles"

_LEVEL2_PALETTE_ADDR:
.include "level2/Level_2.palette"

_LEVEL2_METATILES_ADDR:
.include "level2/Level_2.metatiles"

_LEVEL2_COLUMNS_ADDR:
.include "level2/Level_2.columns"


.segment "BANKF"

