; File:   unromMapper.asm

;  IMPORTANT!!!
;  Make sure you include this code in the last BANK of your UNROM project.
; The last bank is fixed, and this will ensure the code is present that can be used
; to switch to the other banks


;
; This library contains routines for controlling and making use of the UNROM mapper
; Information in this library was mostly provided through 
; www.nesdevwiki.org
; www.nesdev.com
;
; Directions:
; In your RESET routine.  set the value of X for the lower bank wanted and call  setUNROMBank
; If you wish to use Bank0 call initUNROMMapper which does the same thing

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; initUNROMMapper:
; no arguments required
; For example:
;  JSR initUNROMMapper
;
;---------------------------------------------------------------------------------------------

.IFREF initUNROMMapper
initUNROMMapper:
    ;  UNROM being used, ensure bank0 is set
    LDX #$00
    JMP setUNROMBank
.ENDIF

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; setUNROMBank:
; Value in X is the argument of the bank to be used
; Value should be 0 to 15, but in reality it cannot exceed the number of PRG banks specified in the header
; For example (loading PRG bank 2 at $8000):
;  LDX  #2
;  JSR  setUNROMBank
;---------------------------------------------------------------------------------------------
.IFREF setUNROMBank
setUNROMBank:
    LDA bankSwitchingTable,X
    STA bankSwitchingTable,X
    rts


; Note: This is the bank switching table for UNROM
; This swaps the lower 16KB PRG data with that bank
; The upper 16KB bank is permanently wired.
; Example of loading in bank 4 :
;
; LDX #$04
; LDA bankSwitchingTable,X
; STA bankSwitchingTable,X
; In theory we can replace the LDA with a TXA since we KNOW the result in the table is always going to be the same as the X index
;

; We need to write the same OLD data that we just read.  the lower 3 bits indicate which 16KB bank will be loaded in
; Since the upper 16 is always wired, we really dont need to be able to load in the final bank
; I am making this table support 16 banks even though this game is only 8 banks (128KB)
; UNROM can through a simple modification support 256KB

bankSwitchingTable:
.byt $00,$01,$02,$03,$04,$05,$06,$07
.byt $08,$09,$0A,$0B,$0C,$0D,$0E,$0F

.ENDIF
