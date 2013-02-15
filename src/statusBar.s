.export _STATUS_BAR_CHR_ADDR
.export _STATUS_BAR_SPRITES_ADDR
.export _STATUS_BAR_NAMETABLE_ADDR

.segment "BANK4"


_STATUS_BAR_CHR_ADDR:
.incbin "statusBar_last16.chr"

_STATUS_BAR_SPRITES_ADDR:
.incbin "40_numbers.chr"

_STATUS_BAR_NAMETABLE_ADDR:
.include "statusBarTop.nam"



.segment "BANKF"
