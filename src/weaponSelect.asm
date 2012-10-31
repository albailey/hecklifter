; This file contains everything pertaining to WEAPON SELECT screens
; It does not compile or stand on its own.  Basically it is just where the code from game.asm has been cut out



initWeaponSelectNMI:
; Under construction
rts



processWeaponSelectNMI:
; Under construction
rts

processWeaponSelectNonNMI:
        LDA CHANGE_DETECTION_FLAG
        BEQ :+
        jsr loadWeaponSelectNonNMI

        LDA #STATE_UNCHANGED
        STA CHANGE_DETECTION_FLAG
:
	jsr processWeaponSelectNonNMIControls
        ; Weapon Select screen loaded if we are here.  Add controls interaction
        ; To Do: Add controls interaction, etc..
rts


; The following are used INTERNALLY to the three routines above

processWeaponSelectNonNMIControls:
; Under construction
rts

loadWeaponSelectNonNMI:
; Under construction
rts


