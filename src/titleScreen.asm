#define TITLE_SCREEN_TILE_BANK 4
#define TITLE_SCREEN_NUM_TILES 255


TITLE_CHR:
.incbin "graphics/title/title_bg_tiles4K.chr"
TITLE_PAL:
.incbin "graphics/title/title_palette.pal"
TITLE_NAM:
.incbin "graphics/title/title_uncompressed.nam"
TITLE_SPRITES_NUMBER:
.byte $06
TITLE_ANIMATION_SPRITES:
.incbin "graphics/title/title_sprites.chr"
TITLE_ANIMATION_DATA:
.incbin "graphics/title/title.anim"


