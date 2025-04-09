@echo off
odin build . -o:size -out:pixelhash.exe
rem odin build . -out:pixelhash.exe -debug -show-timings
pixelhash.exe D:\dev\Odin\tests\core\assets\BMP\pal8topdown.bmp D:\dev\Odin\tests\core\assets\BMP\pal8nonsquare.bmp D:\dev\Odin\tests\core\assets\PNG\basn6a16.png
