@echo off
java.exe -jar C:\c64\Tools\KickAssembler\KickAss.jar gubbtrap.asm -o \bin\gubbtrap.prg
exomizer.exe sfx 0x080d .\bin\gubbtrap.prg -C -p 1 -o bin\GubbTrap_packed.prg
x64sc bin\GubbTrap_packed.prg


