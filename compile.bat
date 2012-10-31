del hecksample.nes

cd src
del *.o
del hecksample.s


set STATUS_DEFINES=-DTOP_STATUS=1

set DEFINES=%STATUS_DEFINES%

cc65 -Oi hecksample.c --add-source %DEFINES%
ca65 crt0.s
ca65 mmc1Mapper.s
ca65 utils.s
ca65 cutSceneEngine.s -I ../cutScene  -I ..
ca65 titleScreen.s -I ../title -I ..
ca65 statusBar.s -I ../statusBar -I .. %STATUS_DEFINES%
ca65 level1.s -I ../levels/level1 -I ..
ca65 hecksample.s
ld65 -C nes.cfg -o ../hecksample.nes crt0.o mmc1Mapper.o utils.o  cutSceneEngine.o titleScreen.o statusBar.o level1.o hecksample.o runtime.lib

cd ..
rem pause
hecksample.nes

