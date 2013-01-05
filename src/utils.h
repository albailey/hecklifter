// Utility methods


// showLine indicates where in the screen drawing we are in order to help know how much rendering tim remains
void __fastcall__ showLine(void);

void __fastcall__ inc1WithGraphicsOff(void);
void __fastcall__ inc32WithGraphicsOff(void);

//wait until sprite zero has been intersected
void __fastcall__ ppu_wait_SpriteZeroHit(void);

void __fastcall__ setSplitScroll(unsigned char x);
void __fastcall__ scrollXNow(unsigned char x);
void __fastcall__ setScreenNow(unsigned char ppuctrl);


// reset jmps to the reset vector, the same as pressing the reset button
void __fastcall__ reset(void);

void __fastcall__ updateCompressedNametable(unsigned char ntHighVal, int srcAddr);
