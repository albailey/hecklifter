.export _TITLE_CHR
.export _TITLE_PAL
.export _TITLE_NAM

.segment "BANK4"

_TITLE_CHR:
.incbin "title_bg_tiles4K.chr"
_TITLE_PAL:
.incbin "title_palette.pal"
_TITLE_NAM:
.incbin "title_uncompressed.nam"

_TITLE_ANIMATION_SPRITES:
.incbin "title_sprites.chr"
_TITLE_ANIMATION_DATA:
.incbin "title.anim"

.segment "BANKF"
