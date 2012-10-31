   ; This is an MMC1 SNROM file for a 256 KB PRG, 0 CHR and Battery backed SRAM and vertical mirroring
  .byt "NES", 26
  .byt 16  ; number of 16 KB program segments
  .byt 0  ; number of 8 KB chr segments
  .byt 19 ; The upper byte is the mapper number, the lower byte is the mapper info ( mirroring, etc)
  .byt 0  ; extended mapper info
  .byt 0,0,0,0,0,0,0,0  ; the rest of the header is empty

