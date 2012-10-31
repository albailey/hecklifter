; A is the bank ($00 for bank 0. $10 for bank 1)
; X is the starting sprite to overwrite
; Y is the number of sprites to overwrite
; IIY_LOW and IIY_HIGH are used as the input data address
.IFREF LoadCHRSubset
LoadCHRSubset:
        PHA
        LDA $2002 ; reset 2006 flipflop
        ; divide X by 16 to get high byte and then add in the bank $00 or $10
        TXA
        LSR
        LSR
        LSR
        LSR
        STA TEMP_VAR1
        PLA
        CLC
        ADC TEMP_VAR1
        STA $2006

        TXA
        ASL
        ASL
        ASL
        ASL
        STA $2006

        TYA
        STA TEMP_VAR1
        LDY #$00
        LDX #$10 ; 16
        ; Need to load 16 bytes per sprite
:       LDA (IIY_LOW),Y
        STA $2007
        INY
        BNE @yValid
        INC IIY_HIGH
@yValid:
        DEX
        BNE :-
        DEC TEMP_VAR1
        BEQ :+
        LDX #$10 ; 16
        BNE :-
:
        RTS
.ENDIF



