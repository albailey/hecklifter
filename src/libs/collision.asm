
; If the carry flag is set, there has been a collision
; If the carry flag is cleared there has NOT been a collision
; Untested
CheckBoundaries:
       lda rect1.leftortop
       cmp rect2.leftortop
       bmi Check2
       cmp rect2.rightorbottom
       bmi InsideBoundingBox
Check2:
       lda rect2.leftortop
       cmp rect1.leftortop
       bmi NotInsideBoundingBox
       cmp rect1.rightorbottom
       bpl NotInsideBoundingBox
InsideBoundingBox:
       sec
       rts
NotInsideBoundingBox:
       clc
       rts


