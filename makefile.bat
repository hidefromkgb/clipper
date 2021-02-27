@echo off

taskkill /F /IM clipper.exe

if exist clipper.obj del clipper.obj
if exist clipper.exe del clipper.exe

rc.exe ./res/data.rc
ml.exe /c /coff clipper.asm
if errorlevel 1 goto errasm

PoLink.exe /SUBSYSTEM:WINDOWS /stub:.\res\stub.exe /merge:.rsrc=.text /section:.text,RE clipper.obj .\res\data.res
if errorlevel 1 goto errlink
dir clipper.exe
goto TheEnd

:errlink
echo There has been an error while linking this project.
goto TheEnd

:errasm
echo There has been an error while assembling this project.
goto TheEnd

:TheEnd
if exist clipper.obj del clipper.obj

pause
