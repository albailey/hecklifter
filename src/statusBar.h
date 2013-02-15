//--------------------------------------------------------
// statusBar.h
// specify at compile time whether this is a top status bar or a bottom one
//#define TOP_STATUS 1
//--------------------------------------------------------



#define STATUS_REGION_PPU_SETTINGS  %10001000

#define SPRITE_ZERO_SPRITE_INDEX       0xFF
#define SPRITE_ZERO_ATTRIBUTES      0x00

// Last sprite in the sprite bank is the sprite-zero used for the status bar (0x2000 - 16)
#define STATUS_BAR_SPRITE_ADDR      0x1FF0 

#define STATUS_BAR_NUM_TILES        16
// Last 16 tiles in the 0x0000 bank means we start at address 0x1000 - (STATUS_BAR_NUM_TILES * 16)
#define STATUS_BAR_CHR_DEST         0x0F00   

// Adding 10 numbers for the sprites
//#define STATUS_BAR_NUM_SPRITES 10
//#define STATUS_BAR_SPRITES_DEST 0x1F60

#define STATUS_BAR_NUM_SPRITES 40
#define STATUS_BAR_SPRITES_DEST 0x1D80


#ifdef TOP_STATUS
/*
 When using the top, to keep OAM lined up, 8 for status and only 22 for remainder (11 meta per columns)
 If the status area is 8 rows in height, place sprite zero on the first line of the 8th row somewhere on the left side of the screen
 Note: 0xFF bytes worth of status bar is equal to 8 lines
*/
#define SPRITE_ZERO_X_POS          20
#define SPRITE_ZERO_Y_POS          54
#define STATUS_BAR_SIZE_IN_BYTES   256
#define STATUS_BAR_NAMETABLE_START 0x2000
#define STATUS_BAR_NAMETABLE_ALT_START 0x2400
#else
/*
     When using the bottom, to keep OAM lined up, region is 24 rows (12 meta per column) and only 6 for status
     Note: 0xC0 bytes worth of status bar is equal to 6 lines
*/
#define SPRITE_ZERO_X_POS           20
#define SPRITE_ZERO_Y_POS           192
#define STATUS_BAR_SIZE_IN_BYTES    0xC0 
#define STATUS_BAR_NAMETABLE_START  0x2300
#define STATUS_BAR_NAMETABLE_ALT_START 0x2700
#endif


#define STATUS_BAR_TILES_BANK           4
#define STATUS_BAR_NAMETABLE_BANK       4

extern const unsigned char* STATUS_BAR_CHR_ADDR;

extern const unsigned char* STATUS_BAR_NAMETABLE_ADDR;


extern const unsigned char* STATUS_BAR_SPRITES_ADDR;


