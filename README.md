# "Barry Boomer - Trapped again" full source code

## A small [Vandalism News](https://vandalism.news/) present
Here is a little treat for all the readers of Vandalism News. An interactive tour of "The making of Barry Boomer". A demo written entirely in 65xx assembler language for the Commodore 64.

If you are just want to watch the demo, you can download it [here](https://csdb.dk/release/?id=205543) so you can run it on your own machine or you can just watch the demo on [YouTube](https://youtu.be/JeNEyiCiZr0) - if you're the lazy kind.

## The insights of a Commodore 64 demo
Here you will find the full source code for a demo I made with some friends. There are some fun tricks in the code, nothing exceptional, but hopefully by releasing this it will inspire others.

The code wasn't made for sharing, so it is quite a mess. However, with a little bit of persistence you should be able to compile and run it.

You need a few tools for this:

[KickAss assembler](http://www.theweb.dk/KickAssembler/Main.html#frontpage)

[PicConv](https://csdb.dk/release/?id=172436)

Python (find the latest version - verify that you can run 'python' from the commandline)

Exomizer

## Build the demo

The main file for the demo is **GubbTrap.asm**. You need to compile this into an executable PRG file (gubbtrap.prg). When built, you cannot just run this, if you load it in a Commodore 64, it will just crash the machine because it uses all memory and by loading it you will (try to) overwrite BASIC and kernal functions. So you have to compress it. It may produce a few warnings when you build it, just ignore that.

The code reflects the fact that this demo was a very dynamic process. We built things as we came up with the ideas. The result is a very messy memory layout. There is only a few hundred bytes left of free memory (Sorry Sarge, I lied - we did have some free memory after all). In case you are just curious, this is what it looks like: 
```
Memory Map
----------
Default-segment:
  *$0002-$0010 ZP
  $0368-$04f9 curtain
  $0500-$0665 Font
  $0668-$07f8 Scroll data
  $0801-$080c Basic Upstart Program
  $080d-$0c16 Code Main
  $0c17-$0fea Code Starfield
  $0feb-$1d1c Code Drummer
  $1d1d-$1dbb Code SpritePusher
  $1dc4-$1e97 Code GubbShip Supplement
  $1e98-$1f21 Scroll data
  $1f22-$1f77 Code Fadein
  $2000-$382f Music
  $3845-$3ffa Code GubbShip
  $4000-$5f3f Framebuffer Bitmap 1
  $6000-$63f7 Framebuffer Screen 1
  $6400-$7fff Framebuffer Sprites 1
  $8000-$83e7 Background colormap
  $8400-$8909 Starfield data
  $890a-$8f41 StarField mask
  $8f42-$9a31 Drummer graphics
  $9a32-$a0f1 Moon data
  $a0f2-$a4f4 Code Missile
  $a4f5-$afa9 Code SpaceShip
  $afaa-$c0fb Code SpaceGuy
  $c0fc-$c481 Code SmallShip
  $c482-$c6f5 Code FlashingHead
  $c6f6-$c867 Storyboard table
  $c868-$ccdd Code Moon
  $ccde-$cff2 Code Scroller
  $d000-$d1bf Graphics FlashingHead
  $d1c0-$d7ff Graphics GubbShip
  $d800-$da6f Sleeping drummer
  $da70-$db6f Graphics Small GubbShip
  $dc00-$dfe7 screenbuffer
  $e000-$ffe2 Code Scorch
  ```

Optional! If you want the full build experience, do as I did: Before you compress it, you need to edit the gubbtrap.prg file in a hex editor. That means you need to remove the first 13 bytes of the file. I guess you could theoretically just skip this step, but then again - I don't remember why I did this in the first place, so maybe there was a good reason that I just don't remember anymore.

You now need to compress the file. Do this with the Python tool tc_encode. Run the following command from where you have the prg (usually in **/BIN**):
```
python tc_encode.py -vx gubbtrap.prg gubbtrappacked.prg
```

You can test it by running the gubbtrappacked.prg in Vice or on the real thing. If it works, you can now attach the intro sequence.

Compile **Intro.asm**. You may need to edit line 15 to set the correct path for the binary you created in the previous steps.

Now you should be able to build the final demo using Exomizer:
```
exomizer.exe sfx 0x9c00 Intro.prg -p 1 -o barryboomer.prg
```

Congratulations! You managed to transform a complete mess into something beautiful :)

## The work log
Here is the full work log of what we did every day:

day 0:
* memory layout
* Initial

day 1:
* Optimized starfield
* Added Drummer

day 2:
* Removed double-buffering. double stars

day 3:
* Added animation for drummer
* Added acceleration for starfield
* Added first events to storyboard engine
* Added border reflections

day 4:
* worked a bit on the intro

day 5:
* Added orbiting moon. Planning the actual orbit.
* Also pressure testing the drummer animations a bit.

day 6:
* Added animated mask to the drummer so the starfield moves correctly around him.
* Worked with Sarge to get animated masks for the orbiting moon.

day 7:
* Added missile with rider (missing the puff)
* Fixed some colorbugs in the graphics

Day 8
* Final missile attack

Day 9
* Added spaceship - using 19px interleaving

Day 10
* Finished the spaceship ... now witness this fully functional battlestation :)

Day 13
* Added movement to the spaceship and some flashing lights. Way more difficult than planned.
* I had forgotten about the expanded sprites, so that caused some issues.

Day 14
* Finished spaceship
* Added beam

Day 15
* Added spaceguy and platform

Day 16
* Added early scorched earth
* Problem with platform

Day 17
* Added final version of schorched earth with starfield mask

Day 18
* Added small ship
* Added animation of hatch

Day 19
* First stab at the flashing heads

Day 20
* Added refinements to the flashing heads

Day 21 and some
* Added GubbShip with exit sequence

Day 22
* Mostly bug fixing and first complete story build

Day 23
* Added credits
* Added sleeping drummer

Day 24-30
* Polishing
* Optimize code
* Update graphics
* Make flashing head move random
* Fix bugs in beaming up
* Final music
* Freeing up memory
* Added flexing of drummer (required extra code for not plotting last line)

## The bonus
There is a folder called /Workload. In it you will find a build for every day during the development of the demo. The last 6 days I got lazy on saving out a copy, but the changes were minimal and mostly polishing stuff.

Also I saved out some of the fun mockups that was thrown around. A special treat is The Sarge humming is way through the opening scene, to give Jammer an idea of the sound following that scene. I never get tired of watching that one :)

# The credits
* The Sarge made all the wonderful graphics.
* Jammer composed the awesome soundtrack.
* I, Trap, wrote the code.


Trap Crap Wrap