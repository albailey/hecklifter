; File: devutils.asm
;
;  This file contains routines that are helpful during development but will be taken out of the code when its ready for prime time.





; -------------------------------------------------------------------------------------------------------------------------------
;  showCPUUsageBar
; -------------------------------------------------------------------------------------------------------------------------------
; Tepples posted this method on nesdev.
;  It is a utility function that can be used during development so that you can see where in the main loop you are
; and therefore get a better understanding of how many cycles you have remaining during the screen update before the next VBlank
;
; Quoted from Tepples:
; "Before you wait for vblank, turn on the monochrome bit (PPUMASK bit 0) for about 113 cycles and then turn it back off. 
; This will give you a bright gray line across the screen that shows you how much CPU you're using 
; when it gets too close to the bottom, you're coming close to your CPU budget."
;
; Shows a monochrome bar roughly 1 scanline tall. 
; To measure your CPU usage visually, call this before 
; waiting for vertical blanking. 
; -------------------------------------------------------------------------------------------------------------------------------

.IFREF showCPUUsageBar
; uncomment this if its already defined

.IFNDEF PPUMASK
PPUMASK		= $2001
.ENDIF

showCPUUsageBar: 
  ldx #%00011111  ; sprites + background + monochrome 
  stx PPUMASK 
  ldy #21  ; add about 23 for each additional line 
  @loop: 
    dey 
    bne @loop 
  dex    ; sprites + background + NO monochrome 
  stx PPUMASK 
  rts 


.ENDIF  
; -------------------------------------------------------------------------------------------------------------------------------
