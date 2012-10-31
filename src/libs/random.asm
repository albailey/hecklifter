; this code comes From 6502.org
; http://www.6502.org/source/integers/random/random.html
; I just modified the variable names
;
; To Use:
; Declare the following 4 variables on Zero Page
;   RND_SEED0
;   RND_SEED1
;   RND_SEED2
;   RND_SEED3




; Note: Random8 is the function you want to use....
; Linear congruential pseudo-random number generator
;
; Get the next RND_SEED and obtain an 8-bit random number from it
;
; Requires the RAND subroutine
;
; Enter with:
;
;   accumulator = modulus
;
; Exit with:
;
;   accumulator = random number, 0 <= accumulator < modulus
;
; RND_MOD, RND_TMP, RND_TMP+1, and RND_TMP+2 are overwritten
;
; Note that RND_TMP to RND_TMP+2 are only used after RAND is called.
;
.IFREF RANDOM8
RANDOM8:  STA RND_MOD    ; store modulus in RND_MOD
         JSR RAND   ; get next seed
         LDA #0     ; multiply RND_SEED by RND_MOD
         STA RND_TMP+2
         STA RND_TMP+1
         STA RND_TMP
         SEC
         ROR RND_MOD    ; shift out modulus, shifting in a 1 (will loop 8 times)
R8A:      BCC R8B    ; branch if a zero was shifted out
         CLC        ; add RND_SEED, keep upper 8 bits of product in accumulator
         TAX
         LDA RND_TMP
         ADC RND_SEED0
         STA RND_TMP
         LDA RND_TMP+1
         ADC RND_SEED1
         STA RND_TMP+1
         LDA RND_TMP+2
         ADC RND_SEED2
         STA RND_TMP+2
         TXA
         ADC RND_SEED3
R8B:      ROR        ; shift product right
         ROR RND_TMP+2
         ROR RND_TMP+1
         ROR RND_TMP
         LSR RND_MOD    ; loop until all 8 bits of RND_MOD have been shifted out
         BNE R8A
         RTS

updateRandSeeds:
	INC RND_SEED0
        DEC RND_SEED1
        INC RND_SEED2
	BNE skipSeed3
        DEC RND_SEED3
skipSeed3:
        rts
.ENDIF

;
;
; Linear congruential pseudo-random number generator
;
; Calculate RND_SEED = RND_SEED * 69069 + 1
; 
; Enter with:
;
;   RND_SEED0 = byte 0 of seed
;   RND_SEED1 = byte 1 of seed
;   RND_SEED2 = byte 2 of seed
;   RND_SEED3 = byte 3 of seed
;
; Returns:
;
;   RND_SEED0 = byte 0 of seed
;   RND_SEED1 = byte 1 of seed
;   RND_SEED2 = byte 2 of seed
;   RND_SEED3 = byte 3 of seed
;
; RND_TMP, RND_TMP+1, RND_TMP+2 and RND_TMP+3 are overwritten
;
; Assuming that RND_SEED0 to RND_SEED3 and RND_TMP+0 to RND_TMP+3 are all located on page
; zero:
;
;   Space: 173 bytes
;   Speed: JSR RAND takes 326 cycles
;

.IFREF RAND
RAND:     LDA RND_SEED0 ; RND_TMP = RND_SEED * 2
         ASL
         STA RND_TMP
         LDA RND_SEED1
         ROL
         STA RND_TMP+1
         LDA RND_SEED2
         ROL
         STA RND_TMP+2
         LDA RND_SEED3
         ROL
         STA RND_TMP+3
         CLC       ; RND_TMP = RND_TMP + RND_SEED (= RND_SEED * 3)
         LDA RND_SEED0
         ADC RND_TMP
         STA RND_TMP
         LDA RND_SEED1
         ADC RND_TMP+1
         STA RND_TMP+1
         LDA RND_SEED2
         ADC RND_TMP+2
         STA RND_TMP+2
         LDA RND_SEED3
         ADC RND_TMP+3
         STA RND_TMP+3
         CLC       ; RND_SEED = RND_SEED + $10000 * RND_SEED
         LDA RND_SEED2
         ADC RND_SEED0
         TAX       ; keep byte 2 in X for now (for speed)
         LDA RND_SEED3
         ADC RND_SEED1
         TAY       ; keep byte 3 in Y for now
         CLC       ; RND_SEED = RND_SEED + $100 * RND_SEED
         LDA RND_SEED1
         ADC RND_SEED0
         PHA       ; push byte 1 onto stack
         TXA
         ADC RND_SEED1
         TAX
         TYA
         ADC RND_SEED2
         TAY
         LDA RND_TMP   ; RND_TMP = RND_TMP * 4 (= old seed * $0C)
         ASL
         ROL RND_TMP+1
         ROL RND_TMP+2
         ROL RND_TMP+3
         ASL
         ROL RND_TMP+1
         ROL RND_TMP+2
         ROL RND_TMP+3
         STA RND_TMP
         CLC       ; RND_SEED = RND_SEED + RND_TMP
         ADC RND_SEED0
         STA RND_SEED0
         PLA       ; pull byte 1 from stack
         ADC RND_TMP+1
         STA RND_SEED1
         TXA
         ADC RND_TMP+2
         TAX
         TYA
         ADC RND_TMP+3
         TAY
         CLC
         LDA RND_TMP   ; RND_SEED = RND_SEED + RND_TMP * $100
         ADC RND_SEED1
         STA RND_SEED1
         TXA
         ADC RND_TMP+1
         TAX
         TYA
         ADC RND_TMP+2
         TAY
         LDA RND_TMP   ; RND_TMP = RND_TMP * $10 (= old seed * $C0)
         ASL       ; put byte 0 of RND_TMP in the accumulator
         ROL RND_TMP+1
         ROL RND_TMP+2
         ROL RND_TMP+3
         ASL
         ROL RND_TMP+1
         ROL RND_TMP+2
         ROL RND_TMP+3
         ASL
         ROL RND_TMP+1
         ROL RND_TMP+2
         ROL RND_TMP+3
         ASL
         ROL RND_TMP+1
         ROL RND_TMP+2
         ROL RND_TMP+3
         SEC       ; RND_SEED = RND_SEED + RND_TMP + 1
         ADC RND_SEED0
         STA RND_SEED0
         LDA RND_TMP+1
         ADC RND_SEED1
         STA RND_SEED1
         TXA
         ADC RND_TMP+2
         STA RND_SEED2
         TYA
         ADC RND_TMP+3
         STA RND_SEED3
         RTS

.ENDIF
