; ********************
;
; BCD 
;
; Compiler Format:
;   CA65 (6502)
;
; Functions:
;
;  Bin16ToDec5
;    converts a binary value into a decimal value
;    this version converts a 16 bit value into 5 decimal values
;
;  Bin8ToDec3
;    converts a binary value into a decimal value
;    this version converts a 8 bit value into 3 decimal values
;
; ********************
; Originally written by Tokumaru on NESDEV (http://nesdev.parodius.com/bbs/viewtopic.php?p=10824&sid=55359b42282d1e02b91bebcf1caf56ef#10824)
;
; When this subroutine is invoked the following occurs:
;  - The contents of the two bytes in BINARY are converted into decimal format and stored in 5 DECIMAL bytes
;
; Requires 7 ZeroPage variables.
; -  DECIMAL (5 sequential bytes) corresponding to 5 decimal values
; -  BINARY (2 sequential bytes)
;
; Registers and Flags affected:
; - A register has changed 
; - X register has changed 
; - Y register has changed 
; - Carry flag MAY be set due to ROL commands
; - Zero flag will be set (by the last DEX)
; - Negative flag will be clear (by the last DEX)
;
; Cost: Bin16ToDec5 =  920 CPU cycles







; Making use of IFREF so we only pull these in if used
.IFREF Bin8ToDec3 
.IFNDEF BINARY
.ERROR "BINARY (1 or 2 bytes) needs to be declared."
.ENDIF

.IFNDEF DECIMAL
.ERROR "DECIMAL (3 or 5 bytes) needs to be declared"
.ENDIF

Bin8ToDec3: 
   lda #$00 
   sta DECIMAL+0 
   sta DECIMAL+1 
   sta DECIMAL+2 
   ldx #$08 
: 
   asl BINARY+0 

   ldy DECIMAL+0 
   lda BCDTable, y 
   rol 
   sta DECIMAL+0 

   ldy DECIMAL+1 
   lda BCDTable, y 
   rol 
   sta DECIMAL+1 

   rol DECIMAL+2 
   dex 
   bne :-
   rts 

.ENDIF


.IFREF Bin16ToDec5
.IFNDEF BINARY
.ERROR "BINARY (2 bytes) needs to be declared."
.ENDIF

.IFNDEF DECIMAL
.ERROR "DECIMAL (5 bytes) needs to be declared"
.ENDIF

Bin16ToDec5: 
   lda #$00 
   sta DECIMAL+0 
   sta DECIMAL+1 
   sta DECIMAL+2 
   sta DECIMAL+3 
   sta DECIMAL+4 
   ldx #$10 
: 
   asl BINARY+0 
   rol BINARY+1 

   ldy DECIMAL+0 
   lda BCDTable, y 
   rol 
   sta DECIMAL+0 

   ldy DECIMAL+1 
   lda BCDTable, y 
   rol 
   sta DECIMAL+1 

   ldy DECIMAL+2 
   lda BCDTable, y 
   rol 
   sta DECIMAL+2 

   ldy DECIMAL+3 
   lda BCDTable, y 
   rol 
   sta DECIMAL+3 

   rol DECIMAL+4 

   dex 
   bne :-
   rts 

.ENDIF



; We pull in the Shared BCDTable based on the IFREFs above
.IFREF BCDTable
BCDTable: 
   .byt $00, $01, $02, $03, $04, $80, $81, $82, $83, $84
.ENDIF


