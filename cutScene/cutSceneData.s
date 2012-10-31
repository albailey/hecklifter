;  HECKLIFTER CUT SCENE DATA
.segment "BANKF"

; 11 scenes at the start
CUT_SCENE_NUM_SCENES = 11

; Table: BANK, NUM_TILES(not supported), CHR address, PAL address, nametable address
CUT_SCENE_DATA_TABLE:
.byt $01, $D9
.addr SCENE_1_CHR
.addr SCENE_1_PAL
.addr SCENE_1_NAM

.byt $01, $60  ;
.addr SCENE_2_CHR
.addr SCENE_2_PAL
.addr SCENE_2_NAM

.byt $01, $00
.addr SCENE_3_CHR
.addr SCENE_3_PAL
.addr SCENE_3_NAM

.byt $02, $00
.addr SCENE_4_CHR
.addr SCENE_4_PAL
.addr SCENE_4_NAM

.byt $02, $00
.addr SCENE_5_CHR
.addr SCENE_5_PAL
.addr SCENE_5_NAM

.byt $02, $00
.addr SCENE_6_CHR
.addr SCENE_6_PAL
.addr SCENE_6_NAM

.byt $03, $00
.addr SCENE_7_CHR
.addr SCENE_7_PAL
.addr SCENE_7_NAM

.byt $03, $00
.addr SCENE_8_CHR
.addr SCENE_8_PAL
.addr SCENE_8_NAM

.byt $03, $00
.addr SCENE_9_CHR
.addr SCENE_9_PAL
.addr SCENE_9_NAM

.byt $04, $00
.addr SCENE_10_CHR
.addr SCENE_10_PAL
.addr SCENE_10_NAM

.byt $04, $00
.addr SCENE_11_CHR
.addr SCENE_11_PAL
.addr SCENE_11_NAM

; Remember.  Only support UPPER CASE.
; The values are ASCII, so we need to subtract 41 and since the alphabet is at the end , add E5
CUT_SCENE_TEXT:
.addr SCENE_1_TEXT
.addr SCENE_2_TEXT
.addr SCENE_3_TEXT
.addr SCENE_4_TEXT
.addr SCENE_5_TEXT
.addr SCENE_6_TEXT
.addr SCENE_7_TEXT
.addr SCENE_8_TEXT
.addr SCENE_9_TEXT
.addr SCENE_10_TEXT
.addr SCENE_11_TEXT



SCENE_1_TEXT:
.asciiz "WHAT'S YOUR PLEASURE?"
SCENE_2_TEXT:
.asciiz "THE BOX..."
SCENE_3_TEXT:
.asciiz "TAKE IT,     IT'S YOURS.                                          IT ALWAYS WAS... "
SCENE_4_TEXT:
.asciiz ""
SCENE_5_TEXT:
.asciiz ""
SCENE_6_TEXT:
.asciiz ""
SCENE_7_TEXT:
.asciiz ""
SCENE_8_TEXT:
.asciiz ""
SCENE_9_TEXT:
.asciiz ""
SCENE_10_TEXT:
.asciiz ""
SCENE_11_TEXT:
.asciiz ""


.segment "BANK1"
; Scene 1.  181 tiles
SCENE_1_CHR:
.incbin "graphics/cutScenes/scene1/scene1.bg4K.chr"
SCENE_1_PAL:
.incbin "graphics/cutScenes/scene1/scene1.bg.pal"
SCENE_1_NAM:
.incbin "graphics/cutScenes/scene1/scene1.rle.nam"

; Scene 2.  127 tiles
SCENE_2_CHR:
.incbin "graphics/cutScenes/scene2/scene2.bg4K.chr"
SCENE_2_PAL:
.incbin "graphics/cutScenes/scene2/scene2.bg.pal"
SCENE_2_NAM:
.incbin "graphics/cutScenes/scene2/scene2.rle.nam"

; Scene 3.  131 tiles
SCENE_3_CHR:
.incbin "graphics/cutScenes/scene3/scene3.bg4K.chr"
SCENE_3_PAL:
.incbin "graphics/cutScenes/scene3/scene3.bg.pal"
SCENE_3_NAM:
.incbin "graphics/cutScenes/scene3/scene3.rle.nam"

; Text Chars
;ALPHABET_FONT_CHR:  ; 32 characters = 512 bytes
;.incbin "graphics/chars/alphabet.font.chr"



.segment "BANK2"

SCENE_4_CHR:
.incbin "graphics/cutScenes/scene4/scene4.bg4K.chr"
SCENE_4_PAL:
.incbin "graphics/cutScenes/scene4/scene4.bg.pal"
SCENE_4_NAM:
.incbin "graphics/cutScenes/scene4/scene4.rle.nam"

SCENE_5_CHR:
.incbin "graphics/cutScenes/scene5/scene5.bg4K.chr"
SCENE_5_PAL:
.incbin "graphics/cutScenes/scene5/scene5.bg.pal"
SCENE_5_NAM:
.incbin "graphics/cutScenes/scene5/scene5.rle.nam"

SCENE_6_CHR:
.incbin "graphics/cutScenes/scene6/scene6.bg4K.chr"
SCENE_6_PAL:
.incbin "graphics/cutScenes/scene6/scene6.bg.pal"
SCENE_6_NAM:
.incbin "graphics/cutScenes/scene6/scene6.rle.nam"



.segment "BANK3"

SCENE_7_CHR:
.incbin "graphics/cutScenes/scene7/scene7.bg4K.chr"
SCENE_7_PAL:
.incbin "graphics/cutScenes/scene7/scene7.bg.pal"
SCENE_7_NAM:
.incbin "graphics/cutScenes/scene7/scene7.rle.nam"

SCENE_8_CHR:
.incbin "graphics/cutScenes/scene8/scene8.bg4K.chr"
SCENE_8_PAL:
.incbin "graphics/cutScenes/scene8/scene8.bg.pal"
SCENE_8_NAM:
.incbin "graphics/cutScenes/scene8/scene8.rle.nam"

SCENE_9_CHR:
.incbin "graphics/cutScenes/scene9/scene9.bg4K.chr"
SCENE_9_PAL:
.incbin "graphics/cutScenes/scene9/scene9.bg.pal"
SCENE_9_NAM:
.incbin "graphics/cutScenes/scene9/scene9.rle.nam"


.segment "BANK4"

SCENE_10_CHR:
.incbin "graphics/cutScenes/scene10/scene10.bg4K.chr"
SCENE_10_PAL:
.incbin "graphics/cutScenes/scene10/scene10.bg.pal"
SCENE_10_NAM:
.incbin "graphics/cutScenes/scene10/scene10.rle.nam"

SCENE_11_CHR:
.incbin "graphics/cutScenes/scene11/scene11.bg4K.chr"
SCENE_11_PAL:
.incbin "graphics/cutScenes/scene11/scene11.bg.pal"
SCENE_11_NAM:
.incbin "graphics/cutScenes/scene11/scene11.rle.nam"


.segment "BANKF"

