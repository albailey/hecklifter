
.export _inc1WithGraphicsOff;
.export _inc32WithGraphicsOff;
.export _ppu_wait_SpriteZeroHit
.export _scrollXNow;
.export _setScreenNow;
.export _showLine;
.export _reset;
.export _updateCompressedNametable;

.import popa

; I cannot get import to work so I will redeclare TEMP here the same as in crt0.s
VRAMUPDATE      =$03
TEMP            =$1c

TEMP_VAR1 = TEMP
TEMP_VAR2 = TEMP+1
TEMP_VAR3 = TEMP+2
TEMP_VAR4 = TEMP+3


;void __fastcall__ inc1WithGraphicsOff();
_inc1WithGraphicsOff:
	LDA #%00000000
	STA $2000
	RTS

;void __fastcall__ inc32WithGraphicsOff();
_inc32WithGraphicsOff:
	LDA #%00000100
	STA $2000
	RTS

;void __fastcall__ ppu_wait_SpriteZeroHit(void);
_ppu_wait_SpriteZeroHit:
	LDA #1
	STA VRAMUPDATE
        ; Wait for Scanline #0 to reset the Sprite #0 hit flag
:       BIT $2002
        BVS :-

        ; Wait for the first intersected pixel of sprite #0 to be rendered
:       BIT $2002
        BVC :-

        RTS


;void __fastcall__ scrollXNow(unsigned char x);
_scrollXNow:
	STA $2005
	LDA #$00
	STA $2005
	rts

;void __fastcall__ setScreenNow(unsigned char ppuctrl);
_setScreenNow:
	STA $2000
	rts


;void __fastcall__ showLine();

_showLine:
  ldx #%00011111  ; sprites + background + monochrome 
  stx $2001
  ldy #21  ; add about 23 for each additional line 
  @loop: 
    dey 
    bne @loop 
  dex    ; sprites + background + NO monochrome 
  stx $2001
  rts 

;void __fastcall__ reset();

_reset:
	JMP ($FFFC)


; A is high address of dest nametable
; X is low address of src data for nametable
; Y is high address of src data for nametable
; LDA #$20
; ldX #<NAMETABLE
; ldY #>NAMETABLE
;void __fastcall__ updateCompressedNametable(unsigned char ntHighVal, int srcAddr);
_updateCompressedNametable:

_set_vram_update:
        ; skip over the first byte since I know its compressed
	TAY
	INY
        BNE :+
        INX
:       

	STY TEMP_VAR1 ; X had the low byte of the src address
	STX TEMP_VAR2 ; Y had the high byte of the src address

        LDA $2002 ; reset latch
        jsr popa
        STA $2006
        LDA #$00 ; start writing to PPU address AA00 (ie: 2000)
        STA $2006

	JSR uncompressRLENameTableSetupValsStored
        rts

; Version 1.0 Completed on July 28, 2007
;
; function:  uncompressRLENameTable
;
; This file decompresses data to $2007
; A different but similar library decompresses to an arbitrary memory areaA
; 
;  Basing the decompression code on RLE (packbits variant)
;  This deconmpression utility will decompress data compressed using my java utility.
;  Here is my java decompression code to use as a reference
;
;    private final static byte[] rleDeCompress(byte srcdata[]){
;        byte b[] = new byte[1024*1024]; // support 1 MEG
;        int resultPos = 0;
;        int srcPos = 0;
;        while(srcPos < srcdata.length){
;            int hedVal = (int)srcdata[srcPos++]; // may be negative
;            if(hedVal >= 0){
;                int len = hedVal + 1;
;                System.arraycopy(srcdata,srcPos,b, resultPos,len);
;                resultPos += len;
;                srcPos += len;
;            } else {
;                // decode a run
;                int len = 2 - hedVal;
;                byte val = srcdata[srcPos++];
;                for(int i=0;i<len;i++){
;                    b[resultPos++] = val;
;                }
;            }
;        }
;        
;        byte results[] = new byte[resultPos];
;        System.arraycopy(b,0,results,0,resultPos);
;        
;        return results;
;        
;    }
;
;
; ****************************************************************************  
;   VARIABLE DECLARATION REQUIREMENTS:  
; You must declare 2 zero page variables (contiguously) to use this function
; TEMP_VAR1
; TEMP_VAR2
; And normally you would add to your code:
; .include "uncompressRLENameTable.asm"
; ****************************************************************************  
;
;  
; Usage Requirements:
; ** This assumes the PPU address has been specified before calling the routine (using writes to $2006)
; ** This assumes that when this function is called the X register has the srcData lowByte and the Y register has the srcData highByte
; ** This assumes that the first 2 bytes in srcData are the size of the compressed data (low byte then high byte).  No bounds checking is done, you can extract more than $1024 bytes.
;
; ** This routine does NOT enforce an entire NameTable write and can be used for a partial extraction 
; ** This routine does NOT have a clue where the PPU pointer will be when done.  If you only extract half a nametable, the PPU is at the halfway point
;
; This routine may alter the A,X and Y registers on completion
; This routine may alter the flags
; This routine does not alter the stack.
; This routine requires 4 temp variables (TEMP_VAR1, TEMP_VAR2) and (TEMP_VAR3, TEMP_VAR4) be declared contigusously on Zero Page.  The contents of those variables will be changed by this function.
;  


; To do this...
; LDX #<srcAddress
; LDY #>srcAddress
; JSR uncompressRLENameTableSetup

uncompressRLENameTableSetup:  
	; Note: uncompressRLENameTableSetup costs: 3+3+2+5+3+5+2(+1+6)+5+3+5+2(+1+6) = 38 cycles min, 52  cycles max
	; Step 1: put the src address into zero page so we can start reading the stuff
	STX TEMP_VAR1 ; X had the low byte of the src address
	STY TEMP_VAR2 ; Y had the high byte of the src address
uncompressRLENameTableSetupValsStored:  

	; Now query the first two bytes to determine the size
	LDY #$00
	LDA (TEMP_VAR1),Y
	STA TEMP_VAR3
	INC TEMP_VAR1   ; We are going to change the address so that eventually it points to the first byte of DATA (it was just pointing to the size info prefixing the data)
	BNE :+
	INC TEMP_VAR2 ; Whoops. We've gone past FF for the low byte, we need to increment the high byte.
:
	LDA (TEMP_VAR1),Y
	STA TEMP_VAR4
	INC TEMP_VAR1
	BNE :+
	INC TEMP_VAR2 ; Whoops. We've gone past FF for the low byte, we need to increment the high byte.
:

	; Here is where I get sneaky....
	; TEMP_VAR3 is the low byte, TEMP_VAR4 is the high byte.
	; Wouldnt it be nice if we could lie about the starting address by manipulating the starting Y value so that it just needs to run to "wrap-around"
	; until the high byte of the size is decremented to zero
	; initial Y = $FF-lowByte+1, therefore $FF-0+1 = $00
	; starting address is address-initialY
	; Example:  dataAddress = $C02D ($C02F after skipping over the 2 size bytes). Size = $0100
	; Therefore set the initial Y value to be 0 ,the starting address to be $C02F
	LDA TEMP_VAR3
	BNE :+
	LDA TEMP_VAR4
	BNE :+
	RTS ; size (low and high byte) were both zero

:	
	; CLD ; I shouldnt need to clear the decimal flag so I am commenting this out
	SEC
	LDA #$FF
	SBC TEMP_VAR3
	TAY
	INY

	; we can now IGNORE TEMP_VAR3 and just copy pages based on TEMP_VAR4 and the remainder in Y
	; But I need a different address now....
	STY TEMP_VAR3
	LDA TEMP_VAR1
	CMP TEMP_VAR3
	BCS :+
	DEC TEMP_VAR2
:
	SEC
	LDA TEMP_VAR1
	SBC TEMP_VAR3
	STA TEMP_VAR1
	

	; Special case...
	; If Y is initially zero, we leave the upper val alone, otherwise we need to increment it by 1 
	; since we are not starting the page at y index=0
	TYA 
	BEQ uncompressRLENameTable
	INC TEMP_VAR4
        ; By using a named BEQ above, we automatically compile uncompressRLENameTable if uncompressRLENameTableSetup is called


uncompressRLENameTable:
	; I assume that uncompressRLENameTableSetup was called which flows into this code.
	; If it wasnt called, the following needs to have been done
	; TEMP_VAR1 and 2 are the src address of the src data (the ACTUAL data, not the size part)
	; TEMP_VAR3 and 4 are the compressed size of the src data (these would normally be the first two bytes at the src address)
	; Y should be zero
	
;        while(srcPos < srcdata.length){
;            int hedVal = (int)srcdata[srcPos++]; // may be negative
;            if(hedVal >= 0){
;                int len = hedVal + 1;
;                System.arraycopy(srcdata,srcPos,b, resultPos,len);
;                resultPos += len;
;                srcPos += len;
;            } else {
;                // decode a run
;                int len = 2 - hedVal;
;                byte val = srcdata[srcPos++];
;                for(int i=0;i<len;i++){
;                    b[resultPos++] = val;
;                }


	LDA (TEMP_VAR1),Y ; get hedVal (Y == srcPos)
	INY		  ; increment srcPos
	BNE :+
	INC TEMP_VAR2	  ;  Indirect indexed Y value needed to increment
	DEC TEMP_VAR4	  ; changed page
	BEQ rleAllDone
:
	TAX
	BMI rleExtractRun ; if (hedVal >= 0) direct extraction

rleDirectExtract:	  ; we get here, it is just a direct extraction, not an RLE run. I dont use this label, it just makes the code easier to read
	INX 		  ; len = hedVal+1

directExtractLoop:
	; the following copies values one at a time to $2007
	LDA (TEMP_VAR1),Y
	STA $2007

	INY		  ; increment srcPos
	BNE :+
	INC TEMP_VAR2	  ;  Indirect indexed Y value needed to increment
	DEC TEMP_VAR4	  ; changed page
	BEQ rleAllDone
:
	DEX
	BNE directExtractLoop
	JMP uncompressRLENameTable  ; I could use BEQ here, but there is NO cycle savings

rleExtractRun:
	STX TEMP_VAR3	; temp store hedVal which is negative

	; int len = 2 - hedval
	; hedval is negative
	LDA #$02
	SEC
	SBC TEMP_VAR3
	TAX
	BEQ rleRunEnded

	LDA (TEMP_VAR1),Y ; get run value
	; the following copies that run X number of times to $2007
:	STA $2007
	DEX
	BNE :-

	INY		  ; increment srcPos
	BNE :+
	INC TEMP_VAR2	  ;  Indirect indexed Y value needed to increment
	DEC TEMP_VAR4	  ; changed page
	BEQ rleAllDone
:
rleRunEnded:
	JMP uncompressRLENameTable
	
rleAllDone:
	RTS


	



