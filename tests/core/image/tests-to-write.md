# Tests for loading flipped images

 - [X] load one bottom-left bmp   8 bit greyscale
 - [X] load one bottom-left bmp  24 bit RGB
 - [X] load one top-left    bmp   8 bit paletted 252 colors
 - [ ] load one             png   8 bit greyscale basn0g08
 - [ ] load one             png  16 bit greyscale basn0g16
 - [ ] load one             png  24 bit RGB       basn2c08
 - [ ] load one             png  48 bit RGB       basn2c16
 - [ ] load one             png 128 bit RGBA      basn6a16
 - [/] use Raylib to look at the resulting test images during the test (and remove that insanity afterwards)

 - test png loading of 8 bit channels, 16 bit channels
 - <strike>Test loading of bottom left and top left images for bmp and tga</strike> see explanation below
 - roundtrip all other file firmats somewhere (but not inside a different file formats loop)

### Why don't we test TGA loading?
I originally wanted to include a few TGA files but in the end I've decided against it. I wanted to test if the flip option works while loading them, but after looking at the TGA spec and some conformance test files from Truevision, which do not include any top-to-bottom=true versions, and some other test files created in various applications, I've come to the realization that TGA is quite messy as it was underspecified when it was introduced and seems to never have completely recovered from that. Also alpha channels don't explicitly exist, but were used in practice but modern applications don't seem to properly support them. Not fun and too brittle and not used that much to spend more time on. I'm fine with it, if it doesn't work for all files, it should work for most of them. I've tested GIMP and Krita files, those are fine.

D:\tmp\odin\snippet\pixelhash.exe
D:\dev\Odin\tests\core\assets\PNG\basn0g08.png
D:\dev\Odin\tests\core\assets\PNG\basn0g16.png
D:\dev\Odin\tests\core\assets\PNG\basn2c08.png
D:\dev\Odin\tests\core\assets\PNG\basn2c16.png
D:\dev\Odin\tests\core\assets\PNG\basn6a16.png
