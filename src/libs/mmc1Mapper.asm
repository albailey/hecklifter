; File:   mmc1Mapper.asm
;
; This library contains routines for controlling and making use of the MMC1 mapper
; Information in this library was mostly provided through 
; www.nesdevwiki.org
; www.nesdev.com
; Special thanks to Disch for lots of clarifications and helpful info
;
; Directions:
; In your RESET routine.  set the value of X for the MMC1 mapper's mode and call  initMMC1Mapper
; Then whenever you wish to switch a CHR or PRG bank, call the setCHRPage000  setCHRPage1000 or setPRGBank routine


.export _initMMC1Mapper;

;void __fastcall__ initMMC1Mapper(int controlMode);




;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; initMMC1Mapper:
; Value in X is the argument to this routine for initializing the MMC1 mapper including settings its mode (to value in X)
; For example:
;  LDX  #%00011110   ; 4K CHR Mode. PRG swapping at $8000. Vertical mirroring
;  JSR initMMC1Mapper
;
;---------------------------------------------------------------------------------------------
.IFREF initMMC1Mapper
initMMC1Mapper:
	; Step 5: Initialize Mapper
	; MMC1
	; A program's reset code will reset the mapper first by writing a value of $80..$FF to any address in $8000-$FFFF. To do any bankswitching
	; According to the wiki: A program's reset code will reset the mapper first by writing a value of $80 through $FF to any address in $8000-$FFFF. 
	LDA #$80
	STA $8000

	TXA  ; we needed to set X before calling this routine
	JSR setMMC1ControlMode

	LDA #$00
	jsr setMMC1CHRPage0000

	LDA #$01
	jsr setMMC1CHRPage1000

	LDA #$00
	jsr setMMC1PRGBank
rts
.ENDIF
;---------------------------------------------------------------------------------------------






;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; setMMC1ControlMode
; Value in A is used to as the argument to this routine for setting the MMC1 control mode
; MMC1 Control mode is controlled by $8000-9FFF
;
; From the wiki
; 4bit0
; -----
; CPRMM
; |||||
; |||++- Mirroring (0: one-screen, lower bank; 1: one-screen, upper bank;
; |||               2: vertical; 3: horizontal)
; ||+--- PRG ROM bank location (0: switch 16 KB bank at $C000; 1: switch 16 KB bank at $8000
; ||                            only used when PRG bank mode bit below is set to 1)
; |+---- PRG ROM bank mode (0: switch 32 KB at $8000, ignoring low bit of bank number;
; |                         1: switch 16 KB at address specified by location bit above)
; +----- CHR ROM bank mode (0: switch 8 KB at a time; 1: switch two separate 4 KB banks)
;---------------------------------------------------------------------------------------------
.IFREF setMMC1ControlMode
setMMC1ControlMode:
	STA $8000 
	LSR A 
	STA $8000 
	LSR A 
	STA $8000 
	LSR A 
	STA $8000 
	LSR A 
	STA $8000 
rts
.ENDIF
;---------------------------------------------------------------------------------------------










;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; setMMC1CHRPage0000
; Value in A is used to indicate the CHR Bank to set for CHR 0000
; MMC1 CHR 0000 is controlled by $A000-BFFF
;
; From the wiki:
;4bit0
;-----
;CCCCC
;|||||
;+++++- Select 4 KB or 8 KB CHR bank at PPU $0000 (low bit ignored in 8 KB mode)
;---------------------------------------------------------------------------------------------
.IFREF setMMC1CHRPage0000
setMMC1CHRPage0000:
	STA $A000
	LSR A
	STA $A000
	LSR A
	STA $A000
	LSR A
	STA $A000
	LSR A
	STA $A000
rts
.ENDIF
;---------------------------------------------------------------------------------------------








;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; setMMC1CHRPage1000
; MMC1 CHR 1000 is controlled by $C000-DFFF
; Value in A is used to indicate the CHR Bank to set for CHR 1000
;
; From the wiki:
;4bit0
;-----
;CCCCC
;|||||
;+++++- Select 4 KB CHR bank at PPU $1000 (ignored in 8 KB mode)
;---------------------------------------------------------------------------------------------
.IFREF setMMC1CHRPage1000
setMMC1CHRPage1000:
	STA $C000
	LSR A
	STA $C000
	LSR A
	STA $C000
	LSR A
	STA $C000
	LSR A
	STA $C000
rts
.ENDIF
;---------------------------------------------------------------------------------------------









;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; setPRGBank
; MMC1 PRG is controlled by $E000-FFFF
; Value in A is used to indicate the PRG Bank to set based on the MMC1 mode being used
;
; From the wiki:
;4bit0
;-----
;RPPPP
;|||||
;|++++- Select 16 KB PRG ROM bank (low bit ignored in 32 KB mode)
;+----- PRG RAM chip enable (0: enabled; 1: disabled; ignored on MMC1A)
;---------------------------------------------------------------------------------------------
.IFREF setMMC1PRGBank
setMMC1PRGBank:
        STA CURRENT_BANK
	STA $E000 
	LSR A 
	STA $E000 
	LSR A 
	STA $E000 
	LSR A 
	STA $E000 
	LSR A 
	STA $E000 
rts
.ENDIF
;---------------------------------------------------------------------------------------------



