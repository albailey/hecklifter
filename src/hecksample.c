#define DEV_MODE 1

// scroll engine defines
#define LEFT_SCROLL_TRIGGER  32
#define RIGHT_SCROLL_TRIGGER 224

// 0x88 = %10001000
// 0x89 = %10001001
// 0x01 to flip the bottom bit using XOR
#define PAGE_ZERO_PPU_SETTINGS     0x88
#define PAGE_ONE_PPU_SETTINGS      0x89
#define PAGE_EOR_PPU_SETTINGS      0x01


#define NTSC_FPS 60

#define NUM_FADE_STEPS 5
#define FADE_DURATION 24
#define MAX_TEXT      90

#define NTADR(x,y)      ((0x2000|((y)<<5)|x))
#define MSB(x)          (((x)>>8))
#define LSB(x)          (((x)&0xff))

#define SET_ODD_OAM_MASK    0x33
#define SET_EVEN_OAM_MASK   0xCC




#include "neslib.h"
#include "utils.h"
#include "mmc1Mapper.h"
#include "cutSceneEngine.h"
#include "titleScreen.h"
#include "statusBar.h"

#include "level1.h"



// Memory starts at 0x0327

//general purpose vars
static unsigned char currentPRGBank;
static unsigned char scroll_x;
static unsigned char nmiLoad;
unsigned char* charAddr;
static unsigned char numTiles;
int addr;
unsigned char tmpPalette1[16];
int tmpAddr;

unsigned char tmpPalette2[16];
static unsigned char i,j,k,l;
static unsigned char single_update[3];
unsigned char* tmpCharAddr;

// ---------------------------------------------------------------------------
// DATA VARIABLES FOR CUT SCENES
// ---------------------------------------------------------------------------
static unsigned char numCutScenes;
static unsigned char abortCutScenes = FALSE;
static unsigned char currentCutScene = 0;

// ---------------------------------------------------------------------------
// DATA VARIABLES FOR TITLE SCENES
// ---------------------------------------------------------------------------
static unsigned char animateTitleScreen = FALSE;

// ---------------------------------------------------------------------------
// DATA VARIABLES FOR GAME ENGINE
// ---------------------------------------------------------------------------
#define PALETTE_TABLE_OFFSET 0
#define METATILE_TABLE_OFFSET 1
#define TILE_TABLE_OFFSET 2
#define COLUMNS_TABLE_OFFSET 3

#define NUM_TILES_OFFSET 0
#define NUM_SCREENS_OFFSET 1


// This offset means we are using a top status bar of 8 columns
#define NAMETABLE_OFFSET 256
#define NAMETABLE_OAM_OFFSET 16
#define COLUMN_HEIGHT 11
#define NUM_OAM_UPDATES 6

#define NUM_LEVELS 1

static unsigned char level;
static unsigned char meta;
unsigned char columnSet1[ COLUMN_HEIGHT * 2 ];
unsigned char columnSet2[ COLUMN_HEIGHT * 2 ];

unsigned char columnOAM[ NUM_OAM_UPDATES ];
unsigned char columnOAM1[ COLUMN_HEIGHT ];
unsigned char columnOAM2[ COLUMN_HEIGHT ];
unsigned char allOAM1[ 64 - NAMETABLE_OAM_OFFSET];
unsigned char allOAM2[ 64 - NAMETABLE_OAM_OFFSET];

unsigned char collision[ COLUMN_HEIGHT ];

static unsigned char column1_update[COLUMN_HEIGHT * 2 * 3];
static unsigned char column2_update[COLUMN_HEIGHT * 2 * 3];
static unsigned char oam_column_update[NUM_OAM_UPDATES * 3];

const int level_ptrs[ NUM_LEVELS * 4 ] = {
   &LEVEL1_PALETTE_ADDR, &LEVEL1_METATILES_ADDR, &LEVEL1_TILES_ADDR,  &LEVEL1_COLUMNS_ADDR
};

const unsigned char level_banks[ NUM_LEVELS * 4 ] = {
   LEVEL1_PALETTE_BANK, LEVEL1_METATILES_BANK,   LEVEL1_TILES_BANK,   LEVEL1_COLUMNS_BANK
};

const unsigned char level_limits[ NUM_LEVELS * 2 ]={
    LEVEL1_NUM_TILES, LEVEL1_NUM_SCREENS
};

// ---------------------------------------------------------------------------
// DATA VARIABLES FOR GAME PLAY
// ---------------------------------------------------------------------------
static unsigned char currentLevel;
static unsigned char playerHealth;
static unsigned char player_x;
static unsigned char player_y;
static unsigned char player_speed;
static unsigned char playerSprite;

static unsigned char scrollColumn;
static unsigned char scrollPage;
static unsigned char maxScrollPage;
static unsigned char currentPagePPU;
static unsigned char loadColumn;
static unsigned char storeColumn;

#define STARTING_HEALTH 3
#define PLAYER_SPRITE_START_INDEX 4


void gameOver() {
	reset();
}

void initMapper()
{
	// Set the mapper to me MMC1

        // 4K CHR blocks. Swap PRG at $8000. Vertical mirroring (for horizontal scrolling)
        // After calling initMMC1Mapper
        // CHR0000 will be CHR bank 0
        // CHR1000 will be CHR bank 1
        // PRG $8000 will be bank 0
        currentPRGBank = initMMC1Mapper(0x1E); // 0x1E = #%00011110
}





// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// ----------------------- CUT SCENE ROUTINES  ------------------------------------
//
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

void fadeIn() {
// Update each value towards the dest (adding $10 until we hit it)
// first step is  x & 0xF
    for(j=0;j<16;j++){
       if(tmpPalette1[j] == 0x0F) {
          tmpPalette1[j] = tmpPalette2[j] & 0xF;
	} else if(tmpPalette1[j] + 0x10 > tmpPalette2[j]) {
           tmpPalette1[j] = tmpPalette2[j];
	} else {
		tmpPalette1[j] = tmpPalette1[j] + 0x10;
	}
        if(tmpPalette1[j] == 0x0D){
        	tmpPalette1[j] = 0x0F;
	}
    }
    pal_bg(tmpPalette1);
}

void fadeOut() {
// Update each value towards black
    for(j=0;j<16;j++){
       if(tmpPalette1[j] <= 0x10 ) {
          tmpPalette1[j] =  0x0F;
	} else {
	   tmpPalette1[j] = tmpPalette1[j] - 0x10;
       } 
        if(tmpPalette1[j] == 0x0D){
        	tmpPalette1[j] = 0x0F;
	}
    }
    pal_bg(tmpPalette1);
}

void put_char(unsigned int adr,unsigned char letter) 
{
// . = $2E =Char $1B in character set
// , = $2C =Char $1C in character set
// ' = $27 =Char $1D in character set
// ? = $3F =Char $1E in character set
// Space is $1F

     if(letter>= 0x40) {  // letter actually is a letter
         letter+=0x9F;
     } else if(letter == 0x20) {  // space
       letter = 0xFF;
     } else {
        // punctuation is a special case
        if(letter == 0x27) {
            letter = 0xFC;
        }
        if(letter == 0x3F) {
            letter = 0xFD;
        }
        if(letter == 0x2E) {
            letter = 0xFA;
        }
        if(letter == 0x2C) {
            letter = 0xFB;
        }
    }
    single_update[0] = MSB(adr);
    single_update[1] = LSB(adr);
    single_update[2] = letter;
    set_vram_update(3,single_update);
}

void loadCutScene(unsigned char i) {
     // turn off graphics
     ppu_waitnmi();//wait for next TV frame
     ppu_off();

    // first get the bank where the data is stored and switch to that bank
    currentPRGBank = setMMC1PRGBank(getCutSceneBank(i));
    // Load the numTiles from chrPtr into the CHR bank
    numTiles = getCutSceneNumTiles(i);
    if(numTiles == 0) {
	numTiles = 0xFF;
    }
    addr = getCutSceneCHRAddr(i);
    vram_write((unsigned char*)addr, 0x0000, numTiles * 16);

    // Load in the alphabet characters
    addr = getAlphabetCHRAddr();
    vram_write((unsigned char*)addr, 0x1000 - (ALPHABET_SIZE * 16), ALPHABET_SIZE * 16);


    addr = getCutScenePaletteAddr(i);
    for(j=0;j<16;j++){
       tmpPalette2[j] = *((const char*)addr+j);
       tmpPalette1[j] = 0x0F;
    }
    pal_bg(tmpPalette1);

    // Load the nametable
    addr = getCutSceneNTAddr(i);
    updateCompressedNametable(0x20, addr);

    // Do the text AFTER we do the nametable
    charAddr = (unsigned char*)getCutSceneTextAddr(i);

    // turn back on graphics
    scroll(0,0);
    ppu_on_spr();//enable rendering
    ppu_waitnmi();//wait for next TV frame
    ppu_on_all();//enable rendering
}

void runCutScene(void) {
        // fade in
	for(k=0;k<NUM_FADE_STEPS;k++) { 
		for(j=FADE_DURATION;j>0;--j) { 
			ppu_waitnmi();//wait for next TV frame
        		i = pad_poll(0);
        		if(i&PAD_START) {
           			abortCutScenes = TRUE;
	   			return;
			}
        		if(i&PAD_A) {
          			// A jumps to next scene
	   			return;
        		}
		}
	        fadeIn();
        }

        // addr is the address of the cut screen text
        // draw text one char at a time
        tmpAddr = NTADR(6,20);
        
	for(j=0;j<MAX_TEXT;++j) { 
           ppu_waitnmi();//wait for next TV frame
           if(*charAddr) {
                k = (*charAddr++);
                put_char(tmpAddr, k);
                ++tmpAddr;
            }

           i = pad_poll(0);
           if(i&PAD_START) {
          	abortCutScenes = TRUE;
	   	return;
	   }
           if(i&PAD_A) {
          	// A jumps to next scene
	   	return;
           }

        }

        // fade out
	for(k=0;k<NUM_FADE_STEPS;k++) { 
		for(j=FADE_DURATION;j>0;--j) { 
			ppu_waitnmi();//wait for next TV frame
        		i = pad_poll(0);
        		if(i&PAD_START) {
           			abortCutScenes = TRUE;
	   			return;
			}
        		if(i&PAD_A) {
          			// A jumps to next scene
	   			return;
        		}
		}
	        fadeOut();
        }

}


void displayCutSceneSequence() {
	ppu_on_all(); //enable rendering. I HAVE to do this otherwise loadCutScene will stall on a call to ppu_off
        abortCutScenes = FALSE;
        numCutScenes = getNumCutScenes();
        for(currentCutScene = 0; currentCutScene < numCutScenes; ++currentCutScene) {
            loadCutScene(currentCutScene);
            runCutScene();
	    // turn off vram updates otherwise we might re-display something next frame or scene we do not want
            set_vram_update(0,single_update);
            if(abortCutScenes) {
		break;
	    }
        }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// ----------------------- TITLE SCREEN CODE  ------------------------------------
//
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

void displayTitleScreen() {
     // turn off graphics
     ppu_on_all(); //enable rendering. I HAVE to do this BEFORE I call pu_off or it might stall
     ppu_waitnmi();//wait for next TV frame
     ppu_off();

    // first get the bank where the data is stored and switch to that bank
    currentPRGBank = setMMC1PRGBank(TITLE_SCREEN_TILE_BANK);
    // Load the numTiles from chrPtr into the CHR bank
    numTiles = TITLE_SCREEN_NUM_TILES;

    vram_write((unsigned char*)&TITLE_CHR, 0x0000, numTiles * 16);

    for(j=0;j<16;j++){
       tmpPalette1[j] = *(((unsigned char*)&TITLE_PAL)+j);
    }
    pal_bg(tmpPalette1);

    // Load the nametable
    vram_write((unsigned char*)&TITLE_NAM ,0x2000, 1024);

    // TODO: figure out animations
    // TODO: figure out sound and music

    // turn back on graphics
    scroll(0,0);
    // HAVE TO turn on SPRITES and then ALL PPU otherwise it shows a glitch
    ppu_on_spr();//enable rendering
    ppu_waitnmi();//wait for next TV frame
    ppu_on_all();//enable rendering

    animateTitleScreen = TRUE;

    while(animateTitleScreen) {
    	ppu_waitnmi();//wait for next TV frame
    	// Process user input
       	i = pad_poll(0);
       	if(i&PAD_START) {
       		animateTitleScreen = FALSE;
	   	return;
	}	
    }
}

void prepareLoadNametableColumn(unsigned char srcIndex, unsigned char destColumn)
{
	// assumes we already have the proper BANK loaded for the metatiles and charAddr is pointed correctly

	// determine start address for metatiles for this level
	tmpAddr = 0x6000 + (srcIndex * 16);

	// set dest address
	addr = (destColumn >= 16) ? 0x2400 : 0x2000;
	addr += ((destColumn % 16) << 1) + NAMETABLE_OFFSET;

	k = 0;
	for(j=0;j<COLUMN_HEIGHT;++j) {
		// each metatile consists of 4 tiles and an OAM attrib
		meta = *((unsigned char*)tmpAddr);
		tmpAddr++;
		tmpCharAddr = (unsigned char*) ((int)charAddr + (meta << 3)); // each metatile is 8 bytes in size
		columnSet1[k]   = *tmpCharAddr;
		columnSet1[k+1] = *(tmpCharAddr+1);
		columnSet2[k]   = *(tmpCharAddr+2);
		columnSet2[k+1] = *(tmpCharAddr+3);

		columnOAM2[j]    = *(tmpCharAddr+4);

		collision[j]    = *(tmpCharAddr+5);
		k+=2;
	}
	if(destColumn % 2 == 0) {
		// copy OAM2 to OAM1 on even columns
		memcpy(columnOAM1, columnOAM2, COLUMN_HEIGHT);
	}

	k=0;
	for(j=0;j<COLUMN_HEIGHT;j+=2) {
		if( j+2 <= COLUMN_HEIGHT ) {
			columnOAM[k] = (columnOAM1[j] ) | (columnOAM2[j]<< 2) | (columnOAM1[j+1]<< 4) | (columnOAM2[j+1] << 6);
		} else {
			columnOAM[k] = (columnOAM1[j] ) | (columnOAM2[j]<< 2);
		}
		k++;
	}

	// Also need to update collision map
}


// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// ----------------------- Level Loading       ------------------------------------
//
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
void nmiLoadNametableColumn(unsigned char srcIndex, unsigned char destColumn)
{
	// assumes we already have the proper BANK loaded for the metatiles and charAddr is pointed correctly
	// determine start address for metatiles for this level
	tmpAddr = 0x6000 + (srcIndex * 16);

	// set dest address
	addr = (destColumn >= 16) ? 0x2400 : 0x2000;
	addr += ((destColumn % 16) << 1) + NAMETABLE_OFFSET;

	k = 0;
        
	for(j=0;j<COLUMN_HEIGHT;++j) {
		// each metatile consists of 4 tiles and an OAM attrib
		meta = *((unsigned char*)tmpAddr);
		tmpAddr++;
		tmpCharAddr = (unsigned char*) ((int)charAddr + (meta << 3)); // each metatile is 8 bytes in size

		column1_update[k] = MSB(addr);
		column1_update[k+1] = LSB(addr);
		column1_update[k+2] = *tmpCharAddr;
		column1_update[k+3] = MSB(addr+32);
		column1_update[k+4] = LSB(addr+32);
		column1_update[k+5] = *(tmpCharAddr+1);

		column2_update[k] = MSB(addr+1);
		column2_update[k+1] = LSB(addr+1);
		column2_update[k+2] = *(tmpCharAddr+2);
		column2_update[k+3] = MSB(addr+33);
		column2_update[k+4] = LSB(addr+33);
		column2_update[k+5] = *(tmpCharAddr+3);

		// OAM needs to be processed by doing READs as well
		columnOAM1[j]    = *(tmpCharAddr+4);

		collision[j]    = *(tmpCharAddr+5);
		addr += 64;
		k+=6;
	}
	// Store OAM starting point
	oam_column_update[0] = destColumn;

        nmiLoad = 3;
        // schedule 3 sets of off screen updates
}

void prepareForNMI() {
	if(nmiLoad == 3) {
		// COL 1
    		set_vram_update(COLUMN_HEIGHT * 2, column1_update);
	}
	if(nmiLoad == 2) {
		// COL 2
    		set_vram_update(COLUMN_HEIGHT * 2, column2_update);
	}
	if(nmiLoad == 1) {
		// OAM
		j = oam_column_update[0];
		addr = ((j >= 16) ? 0x2800 : 0x2400) - 64;
		addr += NAMETABLE_OAM_OFFSET;
		l = ((j % 16) / 2); 	
		addr += l;

		k=0;
		// OAM value = (topleft << 0) | (topright << 2) | (bottomleft << 4) | (bottomright << 6)
		if (j % 2 == 1) {
			if(j>=16) {
				for (j=0;j<NUM_OAM_UPDATES;j++) {
					columnOAM[j] = (allOAM2[ l + (j<<3) ] & SET_ODD_OAM_MASK) | ((columnOAM1[k+1] << 6) | (columnOAM1[k] << 2));
					allOAM2[l+(j<<3)] = columnOAM[j];
					k+=2;
				}
			} else {
				for (j=0;j<NUM_OAM_UPDATES;j++) {
					columnOAM[j] = (allOAM1[ l + (j<<3) ] & SET_ODD_OAM_MASK) | ((columnOAM1[k+1] << 6) | (columnOAM1[k] << 2));
					allOAM1[l+(j<<3)] = columnOAM[j];
					k+=2;
				}
			}

		} else {
			if(j>=16) {
				for (j=0;j<NUM_OAM_UPDATES;j++) {
					columnOAM[j] = (allOAM2[ l + (j<<3) ] & SET_EVEN_OAM_MASK) | ((columnOAM1[k+1] << 4) | columnOAM1[k]);
					allOAM2[l+(j<<3)] = columnOAM[j];
					k+=2;
				}
			} else {
				for (j=0;j<NUM_OAM_UPDATES;j++) {
					columnOAM[j] = (allOAM1[ l + (j<<3) ] & SET_EVEN_OAM_MASK) | ((columnOAM1[k+1] << 4) | columnOAM1[k]);
					allOAM1[l+(j<<3)] = columnOAM[j];
					k+=2;
				}
			}
		}

		k=0;
		for (j=0;j<NUM_OAM_UPDATES;j++) {
			oam_column_update[k] = MSB(addr);
			oam_column_update[k+1] = LSB(addr);
			oam_column_update[k+2] = columnOAM[j];
			addr += 8;
			k+=3;
		}

    		set_vram_update(NUM_OAM_UPDATES, oam_column_update);
	}
	if(nmiLoad == 0) {
    		set_vram_update(0, column1_update);
		return; // jump out early so we do not decrement further
	}
	--nmiLoad;
}

void loadNametableColumn(unsigned char srcIndex, unsigned char destColumn)
{
	prepareLoadNametableColumn(srcIndex, destColumn);

	// set PPU in 32 inc mode and at the proper location
	// this seems to turn ON the PPU for some reason
	inc32WithGraphicsOff();

	// copy data locally and write in a strip
	vram_write(columnSet1, addr, COLUMN_HEIGHT * 2);
	vram_write(columnSet2, addr+1, COLUMN_HEIGHT * 2);

	addr = ((destColumn >= 16) ? 0x2800 : 0x2400) - 64;
	addr += NAMETABLE_OAM_OFFSET;
	k = ((destColumn % 16) / 2 );
	addr += k;
	if (destColumn >= 16) {
		for(j=0;j<NUM_OAM_UPDATES;++j) {
			vram_adr(addr + (j<<3));
			vram_put(columnOAM[j]);
			// store in memory version of OAM
			allOAM2[k + (j << 3)] = columnOAM[j];
			// uncomment next line to help find attribute in debugger
			//allOAM2[k + (j << 3)] = 0xFA;
		}
	} else {
		for(j=0;j<NUM_OAM_UPDATES;++j) {
			vram_adr(addr + (j<<3));
			vram_put(columnOAM[j]);
			// store in memory version of OAM
			allOAM1[k + (j << 3)] = columnOAM[j];
			// uncomment next line to help find attribute in debugger
			//allOAM1[k + (j << 3)] = 0xFB;
		}
	}
	


}

void loadStatusBar() 
{
	// load the tiles for the status bar (at the end of the CHR bank)
    	currentPRGBank = setMMC1PRGBank(STATUS_BAR_TILES_BANK);
    	numTiles = STATUS_BAR_NUM_TILES;
        charAddr = (unsigned char*)&STATUS_BAR_CHR_ADDR;
    	vram_write(charAddr, STATUS_BAR_CHR_DEST, numTiles * 16);

    	numTiles = STATUS_BAR_NUM_SPRITES;
        charAddr = (unsigned char*)&STATUS_BAR_SPRITES_ADDR;
    	vram_write(charAddr, STATUS_BAR_SPRITES_DEST, numTiles * 16);

	// Load the nametable
    	currentPRGBank = setMMC1PRGBank(STATUS_BAR_NAMETABLE_BANK);
        charAddr = (unsigned char*)&STATUS_BAR_NAMETABLE_ADDR;
    	vram_write(charAddr, STATUS_BAR_NAMETABLE_START, STATUS_BAR_SIZE_IN_BYTES);
    	vram_write(charAddr, STATUS_BAR_NAMETABLE_ALT_START, STATUS_BAR_SIZE_IN_BYTES);
	// leaving out OAM for now

	// Not going to load the palette
	/*
	tmpPalette1[0] = STATUS_PALETTE_BG0;
	tmpPalette1[1] = STATUS_PALETTE_BG1;
	tmpPalette1[2] = STATUS_PALETTE_BG2;
	tmpPalette1[3] = STATUS_PALETTE_BG3;
	tmpPalette2[0] = STATUS_PALETTE_SPR0;
	tmpPalette2[1] = STATUS_PALETTE_SPR1;
	tmpPalette2[2] = STATUS_PALETTE_SPR2;
	tmpPalette2[3] = STATUS_PALETTE_SPR3;
    	pal_bg(tmpPalette1);
    	pal_spr(tmpPalette2);
	*/
 
 	oam_spr( SPRITE_ZERO_X_POS,
		 SPRITE_ZERO_Y_POS,
		 SPRITE_ZERO_SPRITE_INDEX,
		 SPRITE_ZERO_ATTRIBUTES,
		 0);

}

void loadLevel(unsigned char tmpLevel)
{
	ppu_on_all(); //enable rendering. I HAVE to do this BEFORE I call pu_off or it might stall
	ppu_waitnmi();//wait for next TV frame
	ppu_off();

	// we are zero indexed so subtract 1
	level = tmpLevel -1;

	// Step 0:  Clear the tiles, palette and nametable
	vram_adr(0x0000);
    	vram_fill(0x0, 9072);
	vram_adr(0x2000);
    	vram_fill(0x0, 2048);
	oam_clear();

	// Step 1:  Load the fixed status bar
	loadStatusBar(); 
	
	// STEP 2: load the tiles for the level
    	currentPRGBank = setMMC1PRGBank(level_banks[(level << 2) + TILE_TABLE_OFFSET]);
    	numTiles = level_limits[(level << 1) + NUM_TILES_OFFSET];
    	if(numTiles == 0) {
	   numTiles = 0xF0;
    	}
        charAddr = (unsigned char*) level_ptrs[ (level << 2)  + TILE_TABLE_OFFSET ];
    	vram_write(charAddr, 0x0000, numTiles * 16);

	// STEP 3: Load the palette for the level
    	currentPRGBank = setMMC1PRGBank(level_banks[(level << 2) + PALETTE_TABLE_OFFSET]);
        charAddr = (unsigned char*)level_ptrs[ (level << 2)  + PALETTE_TABLE_OFFSET ];
	for(i=0;i<16;i++) {
		tmpPalette2[i] = *charAddr;
		tmpPalette1[i] = *(charAddr+16);
		charAddr++;
	}
    	pal_bg(tmpPalette1);
    	pal_spr(tmpPalette2);


	// STEP 4:  Load the level into high RAM (starts at 0x6000)
	// TO DO: support compression someday
    	currentPRGBank = setMMC1PRGBank(level_banks[(level << 2) + COLUMNS_TABLE_OFFSET]);
        charAddr = (unsigned char*)level_ptrs[ (level << 2)  + COLUMNS_TABLE_OFFSET ];
	memcpy((unsigned char*)0x6000, charAddr, level_limits[(level << 1) + NUM_SCREENS_OFFSET] * 16 * 16);
	maxScrollPage = level_limits[(level << 1) + NUM_SCREENS_OFFSET] - 2; // With 8 pages, you can only scroll to 6 (plus 256 to see the end of 7)

	// STEP 5:  Load 32 columns into the nametable
    	currentPRGBank = setMMC1PRGBank(level_banks[(level << 2) + METATILE_TABLE_OFFSET]);
        charAddr = (unsigned char*)level_ptrs[ (level << 2)  + METATILE_TABLE_OFFSET ];

	for(i=0;i<32;++i) {
		loadNametableColumn(i,i);
	}

	// Step 6: Load the player and monster info
	player_x = 40;
	player_y = 200;
	player_speed = 4;
	playerSprite = 0xF7;
	scroll_x = 0;
	currentPagePPU = PAGE_ZERO_PPU_SETTINGS;
	nmiLoad = 0;


    // turn back on graphics
    scroll(0,0);

    // HAVE TO turn on SPRITES and then ALL PPU otherwise it shows a glitch

    ppu_on_spr();//enable rendering
    ppu_waitnmi();//wait for next TV frame

    bank_spr(0xFF);
    ppu_on_all();//enable rendering

}

void prepareColumnForPPU() {
    playerSprite = 	0xF6 + (loadColumn % 10);
    // Uses: loadColumn and storeColumn

    currentPRGBank = setMMC1PRGBank(level_banks[(level << 2) + METATILE_TABLE_OFFSET]);
    charAddr = (unsigned char*)level_ptrs[ (level << 2)  + METATILE_TABLE_OFFSET ];
    nmiLoadNametableColumn(loadColumn,storeColumn);
}

void doLeftLoad(unsigned char tmpChar)
{
  if(tmpChar != scrollColumn) {
    scrollColumn = tmpChar;
    // NEW col to load = (page*16)+cur-7
    k = scrollPage * 16 + scrollColumn;
    if (k >= 7) { 
	k -=7;
	loadColumn = k;
	storeColumn = (k & 0x1F);
        prepareColumnForPPU();
    }
  }

}
void scrollLeft(unsigned char amnt) {
  if (scroll_x >= amnt) {
	scroll_x-=amnt;
  } else {
     if(scrollPage > 0) {
	--scrollPage;
        scroll_x-=amnt; // this should wrap
        currentPagePPU ^= PAGE_EOR_PPU_SETTINGS;       
     } else {
        scroll_x= 0;
     }
  }	
  doLeftLoad(scroll_x / 16);
}

void doRightLoad(unsigned char tmpChar)
{
  if(tmpChar != scrollColumn) {
    scrollColumn = tmpChar;
    // NEW col to load = (page*16)+cur+24
    k = scrollPage * 16 + scrollColumn;
    if (k < (256-24)) { 
	k+=24;
	loadColumn = k;
	storeColumn = (k & 0x1F);
        prepareColumnForPPU();
    }
  }
}


void scrollRight(unsigned char amnt) {
  if (amnt + scroll_x < 256) {
	scroll_x+=amnt;
  } else {
     if(scrollPage < maxScrollPage ) {
	scrollPage++;
        scroll_x+=amnt; // this should wrap
        currentPagePPU ^= PAGE_EOR_PPU_SETTINGS;       
     } else {
        scroll_x = 255;
     }
  }	
  doRightLoad(scroll_x / 16);
}


void getPlayerInput()
{
	i = pad_poll(0);
	if(i != 0) {
       		if(i&PAD_LEFT) {
			if((player_x - player_speed) >  LEFT_SCROLL_TRIGGER) {
				player_x -= player_speed;
			} else {
				scrollLeft(player_speed);
			}
		}
       		if(i&PAD_RIGHT) {
			if((player_x + player_speed) <  RIGHT_SCROLL_TRIGGER) {
				player_x += player_speed;
			} else {
				scrollRight(player_speed);
			}
		}

        	//if(i&PAD_UP   &&player_y>  16) player_y-=STEP;
        	//if(i&PAD_DOWN &&player_y<(240-24)) player_y+=STEP;

		
	}
	//attackMode = (i&PAD_A);

	
}
void updatePlayer()
{
 	oam_spr( player_x,
		 player_y,
                 playerSprite,
		 0x01,
		 PLAYER_SPRITE_START_INDEX);
}
void updateMonsters()
{
}
void updateEnvironment()
{
}

void wtf() {
}

void playLevel() 
{
	loadLevel(currentLevel);
	while(1)
	{
     		ppu_waitnmi();
#ifdef DEV_MODE
		showLine();
#endif
    		setScreenNow(currentPagePPU);
		getPlayerInput();
		updatePlayer();
		updateMonsters();
		updateEnvironment();
		setSplitScroll(scroll_x);
		prepareForNMI();
#ifdef DEV_MODE
		showLine();
#endif
	}
}

void showGameBeaten()
{
}

void showPlayerBeaten()
{
}


// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// ----------------------- MAIN  METHOD        ------------------------------------
//
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
void main(void)
{
	initMapper(); // This must be the first thing we DO

#ifndef DEV_MODE
	// Stage 1:  CUT SCENES
	displayCutSceneSequence();

	// Stage 2:  TITLE SCREEN
	displayTitleScreen();
#endif

	playerHealth = STARTING_HEALTH;
	currentLevel = 1;
	while(playerHealth >0 && currentLevel <= NUM_LEVELS) {
		playLevel();
		if(playerHealth > 0 ) {
			currentLevel++;
		}
	}

	// If we get here, the game is over.
	// Player died or beat every level
	if(playerHealth > 0 ) {
		showGameBeaten();
	} else {
		showPlayerBeaten();
	}
	// Player must have acknowledged being beaten or victorious.  We can reset the game
	reset();

}



