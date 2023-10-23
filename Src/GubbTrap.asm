//----------------------------------------------------------
// Code for creating the breakpoint file sent to Vice.
//----------------------------------------------------------
.var _useBinFolderForBreakpoints = cmdLineVars.get("usebin") == "true"
.var _createDebugFiles = cmdLineVars.get("afo") == "true"
.print "File creation " + [_createDebugFiles
    ? "enabled (creating breakpoint file)"
    : "disabled (no breakpoint file created)"]
.var brkFile
.if(_createDebugFiles) {
    .if(_useBinFolderForBreakpoints)
        .eval brkFile = createFile("bin/breakpoints.txt")
    else
        .eval brkFile = createFile("breakpoints.txt")
}
.macro break() {
.if(_createDebugFiles) {
    .eval brkFile.writeln("break " + toHexString(*))
    }
}

// --------------------------------------------------------------------------

.var music = LoadSid("music\TrappedAgain6581.sid")

.const debug = false

.const NumOfStars = 32 //32 // Number of stars in starfield
.const StarSpeed1 = 5
.const StarSpeed2 = 4
.const StarSpeed3 = 3
.const StarSpeed4 = 1
.const StarFieldHeight=200-(7*8)
.const StarFieldWidth=158

.pc = $0801 "Basic Upstart Program"
					:BasicUpstart($080d)

.pc = $080d "Code Main"
Main:				sei 
					lda #$35
					sta $01
//					lda #$0b
//					sta $d011
					lda #$d8
					sta $d016
					lda #$3e
					sta $dd00
					lda #$80
					sta $d018
					lda #0
					sta $d020
					sta $d021
					sta $d015
					sta $d01b
					sta $d017
					sta $d01d
					sta $d01c
					ldx #$10
ClrVIC:				sta $d000,x
					dex
					bpl ClrVIC

					ldx #0
					txa
ClrColRam:			sta $d800,x
					sta $d900,x
					sta $da00,x
					sta $db00,x
					inx
					bne ClrColRam

					ldx #0
zpinit:				sta zp_begin,x
					inx
					cpx #zp_end-zp_begin
					bne zpinit

					jsr SpaceGuy.InitBeams

					lda #$30
					sta $01
					ldx #0 							// Set all black background attributes to StarFieldColor
					ldy #0
SetStarFieldColor:	lda screenbuffer,x
					bne !+
					lda StarFieldColors,y //#StarFieldColor
					iny
					sta screenbuffer,x
!:					lda screenbuffer+$100,x
					bne !+
					lda StarFieldColors,y //#StarFieldColor
					iny
					sta screenbuffer+$100,x
!:					lda screenbuffer+$200,x
					bne !+
					lda StarFieldColors,y //#StarFieldColor
					iny
					sta screenbuffer+$200,x
!:					lda screenbuffer+$2f8,x
					bne !+
					lda StarFieldColors,y //#StarFieldColor
					iny
!:					sta screenbuffer+$2f8,x
					inx
					bne SetStarFieldColor
					lda #$35
					sta $01

					ldx #$00
					ldy #$00
					lda #music.startSong-1
					jsr music.init

					StoryboardInit(StoryBoard)		// Init storyboard
					
					jsr Fadeinscreen

					jsr StarField.FullSpeed 		// Prerender starfield
					lda #1
					sta ScreenSwitch
					jsr StarField.FullSpeed
					lda #0
					sta ScreenSwitch

					lda #$7f
					sta $dc0d
					sta $dd0d
					lda $dc0d
					lda $dd0d
					lda #$01
					sta $d019
					sta $d01a
					lda #0
					sta $d012
					lda #<irqTop
					sta $fffe
					lda #>irqTop
					sta $ffff
					lda #<NMI
					sta $fffa 
					lda #>NMI
					sta $fffb
					cli

					lda #1
					sta FLAG_StartDemo
!:					lda FLAG_vsync
					beq !-
					lda #0
					sta FLAG_vsync
					jsr music.play
					jsr Scroller.Scroll
					jsr StarField.Execute
					jsr Drummer.Execute
					jsr FlashingHead.Execute
					jsr DEMOSYS_StoryboardExecute	// Execute storyboard code
					jsr SpaceShip.HideExec
					jsr SpaceGuy.BeamAnim
					jsr SpaceGuy.Execute
					jsr SpaceShip.DrawPlatform
					jsr Planet.Execute
					jsr Moon.Execute
					jmp !-
FLAG_vsync:			.byte 0

FLAG_StartDemo:		.byte 0
#import "macros.asm"

// -----------------------------------------------------------------

irqTop:				pha
					txa
					pha
					tya
					pha
					inc $d019
					
					lda FLAG_StartDemo
					bne scrypos
					jmp GotoTopIRQ

scrypos:			lda #$3b
					sta $d011
scrxpos:			lda #$d8
					sta $d016
//jsr debugstuff
ScreenColor:		lda #0
					sta $d020
					sta $d021
					jsr SwitchBank
					lda #0
					sta $d017
					sta $d01d

					lda Scroller.FLAG_EnableScrollerIRQ
					beq !+
					jmp Scroller.IRQ
!:					
					lda SmallShip.FLAG_FlySmallShip
					beq !+
					jsr SmallShip.Execute
!:
					lda SmallShip.FLAG_LeaveSmallShip
					beq !+
					jsr SmallShip.Execute
!:
					lda GubbShip.FLAG_EnableGubbShipIRQ
					beq !+
					jmp GubbShip.IRQ
!:
					lda GubbShip.FLAG_ExitSmall
					beq !+
					jmp GubbShip.ExitSmall
!:
					lda SpaceShip.FLAG_EnableSpaceShipIRQ
					bne !+
					jmp NoSpaceShip
!:					jmp SpaceShip.SpaceShipIRQ

ReturnSpaceShipIRQ:

					lda FLAG_EnableBeam
					bne !+
					jmp SkipEnableBeam
!: 
beamcols:			lda #1
					sta $d029
					sta $d02a
					sta $d02b
					lda #0
					sta $d010
					lda #spr_Beam/64
					sta Screen0+$3fa
					sta Screen0+$3fb
					sta Screen0+$3fc
					lda #$6e+42 // Beam
					sta $d005
					clc
					adc #42
					sta $d007
					adc #42
					sta $d009
					lda #$be
					sta $d004
					sta $d006
					sta $d008
					lda #%10111100
					sta $d017
					//lda #%01011111
					//sta $d01c


SpaceGuyYpos:		lda #$cb 	// SpaceGuy
					sta $d001
					clc
					adc #21
					sta $d003
					lda #$bd
					sta $d000
					sta $d002
					lda #6
					sta $d025
					lda #1
					sta $d026
					lda #15
					sta $d027
					lda #8
					sta $d028
					lda $d010
					and #%11111100
					sta $d010
					lda #spr_SpaceGuy/64
					sta Screen0+$3f8
					lda #spr_SpaceGuy/64+1
					sta Screen0+$3f9
					jmp BeamContinueIRQ
SkipEnableBeam:

NoSpaceShip:		
					lda FlashingHead.FLAG_EnableFHead
					beq !+
					jmp FlashingHead.IRQ
!:					

rasterMissile:		lda #$80
					ldx #<irqMiddle
					ldy #>irqMiddle
					jmp EndIRQ

irqMiddle:			pha
					txa
					pha
					tya
					pha
					inc $d019

					lda SmallShip.FLAG_LeaveSmallShip
					beq !+
					lda #0
					sta $d008
					sta $d00a
!:
ReturnSmallExit:	lda Moon.FLAG_EnableMoon
					beq NoMoon

					lda Moon1Y+1
					beq SkipMoonIRQ
					sec 
					sbc #3
					ldx #<irqMoon
					ldy #>irqMoon
					jmp EndIRQ

irqMoon:			pha
					txa
					pha
					tya
					pha
					inc $d019

ReturnFromScroller:
SkipMoonIRQ:
					lda #$ff
					sta $d015
					lda $d01c
					ora #%11000000
					sta $d01c
					lda $d017
					and #%00111111
					sta $d017
					lda $d01d
					and #%00111111
					sta $d01d
					lda #15
					sta $d025
MoonCol1:			lda #6
					sta $d026
MoonCol2:			lda #12
					sta $d02d
					lda #0
					sta $d02e
Moon1X:				lda #0
					sta $d00c
Moon1Y:				lda #0
					sta $d00d
Moon2X:				lda #0
					sta $d00e
Moon2Y:				lda #0
					sta $d00f
					lda $d010
					and #%00111111
Moonmsb:			ora #0
					sta $d010
Moon1Ptr:			lda #spr_moon/64
					sta Screen0+$3fe
Moon2Ptr:			lda #spr_moon/64+1 //Backside
					sta Screen0+$3ff
NoMoon:
					lda Scroller.FLAG_EnableScrollerIRQ
					beq !+
					jmp GotoTopIRQ
!:
					jsr Missile.Execute
					jsr MissileNoRider.Execute

BeamContinueIRQ:

					lda #$c2
					sta $d012
					ldx #<irqLower
					ldy #>irqLower
					jmp EndIRQ

irqLower:			pha
					txa
					pha
					tya
					pha
					inc $d019

					lda SpaceGuy.FLAG_SpaceGuyStationary
					beq !+
					lda #0
					sta $d017
					sta $d01d
					sta $d010
					lda #$ff
					sta $d015
					lda SpaceGuyYpos+1 	// SpaceGuy
					clc
					adc Planet.GlobalShakeY
					sta $d001
					clc
					adc #21
					sta $d003
					lda #$bd
					clc
					adc Planet.GlobalShakeX
					sta $d000
					sta $d002
					lda #6
					sta $d025
					lda #1
					sta $d026
					lda #15
					sta $d027
					lda #8
					sta $d028
					lda #spr_SpaceGuy/64
					sta Screen0+$3f8
					lda #spr_SpaceGuy/64+1
					sta Screen0+$3f9
!:
ReturnGubbShipIRQ:

					lda #1
					sta FLAG_vsync

					// Platform
					lda SpaceShip.FLAG_EnablePlatform
					beq !+
					jsr SpaceShip.ShowPlatform
!:

					jsr ReadMusicEvents
					jsr SpritePusher.Execute

GotoTopIRQ:			lda #0
					ldx #<irqTop
					ldy #>irqTop
EndIRQ:				sta $d012
					stx $fffe
					sty $ffff
PopRegs:			pla
					tay
					pla
					tax
					pla
NMI:				rti

// -----------------------------------------------------------------

ReadMusicEvents: 	lda $203f
					cmp #$20
					beq noevents
					cmp #$13
					beq TriggerFlexing
					cmp #$12
					beq TriggerFlashScreen
					cmp #$11
					beq TriggerFlashingHead
					cmp #$10
					beq TriggerEventDrummer
noevents:			rts

TriggerFlexing:		lda #1
					sta Drummer.FLAG_Flex
					jmp ResetMusicDriver

TriggerFlashingHead:
					lda #1
					sta EVENT_FlashingHead
					jmp ResetMusicDriver

TriggerFlashScreen:	lda #1
					sta EVENT_FlashScreen
					jmp ResetMusicDriver

TriggerEventDrummer:
					lda #1
					sta EVENT_DrummerHit
ResetMusicDriver:	lda #$20
					sta $203f
					rts

EVENT_DrummerHit:		.byte 0
EVENT_FlashScreen:		.byte 0
EVENT_FlashingHead:		.byte 0

// -----------------------------------------------------------------

SwitchBank:			lda ScreenSwitch
					eor #1
					sta ScreenSwitch
					inc DemocounterLSB // DemoTimer
					bne !+
					inc DemocounterMSB // DemoTimer+1
!:					rts

// -----------------------------------------------------------------

.pc = * "Code Starfield"
#import "StarField.asm"
.pc = * "Code Drummer"
#import "Drummer.asm"
.pc = * "Code SpritePusher"
#import "SpritePusher.asm"

// -----------------------------------------------------------------

.pc = $02 "ZP" virtual
zp_begin:
DemoTimer:				.word 0 // Frame counter used by storyboard
ScreenSwitch:			.byte 0 // 0 = Showing bank 0, 1 = Showing bank 1
FrameBufferBitmap:		.word 0 // Contains the location of the bitmap we can write to right now
FrameBufferBitmapBack:	.word 0 // Currently shown bitmap
FrameBufferScreen:		.word 0 // Contains the location of the screen we can write to right now
zp_temp:				.byte 0 // Temp storage
internal_SBZP:			.word 0 // Used by storyboard
DemocounterLSB:			.byte 0
DemocounterMSB:			.byte 0

zp_end:
FLAG_EnableBeam:		.byte 0

// -----------------------------------------------------------------

.pc = $2000 "Music"
					.fill music.size, music.getData(i)

.pc = $4000 "Framebuffer Bitmap 1"
Bitmap0:
					.import c64 "graphics\Background\background_bitmap.prg"

.pc = $6000 "Framebuffer Screen 1"
Screen0: 			.fill $3f8,0

.pc = $6400 "Framebuffer Sprites 1"
spr_moon:			.fill 1*64,0
spr_moon_back:		.import c64 "graphics\Moon\Moonblack_spr.prg"
spr_Scroller:
spr_FlashingHead:
spr_GubbShip:
spr_GubbShipSmall:
spr_Spaceship:		.import c64 "graphics\Spaceship\Spaceship_spr.prg" // FlashingHead and GubbShip will be copied here
spr_smallship:		.import c64 "graphics\SmallShip\spaceship_spr1.prg"
					.import c64 "graphics\SmallShip\spaceship_spr2.prg"
					.import c64 "graphics\SmallShip\spaceship_spr3.prg"
spr_Missile:		.import c64 "graphics\Missile\MISSILE_spr.prg"
spr_MissileRider:	.import c64 "graphics\Missile\Rider_spr.prg"
spr_MissilePuff:	.import c64 "graphics\Missile\Puff_spr.prg"
spr_MissileExplode:	.import c64 "graphics\Missile\Explosion_spr.prg"
spr_platform:		.import c64 "graphics\Platform\Platform_spr.prg"
spr_platformmask:	.import c64 "graphics\Platform\PlatformBlack_mask.prg"
spr_Beam:			.fill 64,$aa
spr_SpaceGuy:		.fill 2*64,0

.pc = $0500 "Font"
Font:				.import c64 "Graphics\Font\Font_bm.prg"
Mul8:				.fill 30,i*8

// -------------------------------------------------------------------------

.pc = $3845 "Code GubbShip"
#import "GubbShip.asm"

.pc = $1dc4 "Code GubbShip Supplement"
.namespace GubbShip {
FLAG_ExitSmall:		.byte 0

InitExitSmall:		lda #4 								// Num of sprites
					sta SpritePusher.NumOfSprites
					lda #<GubbShipSmallSpr 					// Source
					sta SpritePusher.Source
					lda #>GubbShipSmallSpr
					sta SpritePusher.Source+1
					lda #<spr_GubbShipSmall 				// Destination
					sta SpritePusher.Destination
					lda #>spr_GubbShipSmall+1
					sta SpritePusher.Destination+1
					inc sestory+1
					jmp SpritePusher.Init // Will copy one sprite per frame until done

ExitSmall:			jsr sestory
					jmp ReturnSmallExit

sestory:			lda #0
					beq InitExitSmall
					cmp #32
					beq RunSmallExit
					inc sestory+1
					rts
RunSmallExit:		lda #12
					sta $d025
					lda #6
					sta $d026
					lda #1
					sta $d027
					lda #1
					sta $d01c
					lda #1
					sta $d015
					sta $d01c
					lda #0
					sta $d010
gg:					lda #0
					cmp #1
					beq !+
					inc gg+1
					rts
!:					lda #0
					sta gg+1
sprposcnt:			ldx #0
					lda xpossmall,x
					cmp #0
					beq SmallExitDone
					sta $d000
					lda #$80
					sta $d001
					inc sprposcnt+1
					inc slowdown+1
slowdown:			lda #4
					cmp #5
					beq !+
					rts
!:					lda #0
					sta slowdown+1
spr:				ldx #0
					lda gssspr,x
					sta Screen0+$3f8
					inc spr+1
					rts
SmallExitDone:		lda #0
					sta $d000
					sta FLAG_ExitSmall
					rts

gssspr:				.fill 2,spr_GubbShipSmall/64
					.byte spr_GubbShipSmall/64+1
					.byte spr_GubbShipSmall/64+1
					.byte spr_GubbShipSmall/64+2
					.byte spr_GubbShipSmall/64+2
					.byte spr_GubbShipSmall/64+3
					.byte spr_GubbShipSmall/64+3
					.byte spr_GubbShipSmall/64+2
					.byte spr_GubbShipSmall/64+2
					.byte spr_GubbShipSmall/64+1
					.byte spr_GubbShipSmall/64+1
xpossmall:			.byte 5,10,14,19,24,28,33,37,42,46,51,55,59,64,68,72,76,80,84,88,92,95,99,103,106,109,113,116,119,122,125,128,130,133,135,137,139,141,143,144,145,146,147,147,147
.byte 0
}
// -------------------------------------------------------------------------


.pc = $8000 "Background colormap"
DrummerBitmap: // Destination for sleeping drummer
BackgroundColors:	.import c64 "graphics\Background\background_bitmap_colors.prg"

.pc = $8400 "Starfield data"
tableDiv4:			.fill 160,i/4
tableDiv8:			.fill 200,i/8
tableMul40lo:		.fill 25,<StarFieldMask+(i*40)
tableMul40hi:		.fill 25,>StarFieldMask+(i*40)
xposlo:				.fill 40,[%10000000,%00100000,%00001000,%00000010]
tbl_xposlo:			.fill 40,[<i*8,<i*8,<i*8,<i*8]
tbl_xposhi:			.fill 40,[>i*8,>i*8,>i*8,>i*8]
tbl_yposlo:			.for(var j=0; j<25; j++) { .fill 8,<i+(j*320) }
tbl_yposhi:			.for(var j=0; j<25; j++) { .fill 8,>i+(j*320) }
.pc = * "StarField mask"
StarFieldMask:		.import c64 "graphics\Background\backgroundmask_mask_Screen.prg" // 1 = do not plot
DrummerMask:		.import c64 "graphics\Drummer\Drummermask_mask_Screen.prg"
StarFieldColors:	.fill 16,[11,11,11,11,6,6,6,6,12,12,12,12,9,9,9,9]
.pc = * "Drummer graphics"
Drummer1bit:		.import c64 "graphics\Drummer\Drummer_frame1.prg"
Drummer1Attr:		.import c64 "graphics\Drummer\Drummer_frame1_attr.prg"
Drummer1Cols:		.import c64 "graphics\Drummer\Drummer_frame1_colors.prg"
Drummer2bit:		.import c64 "graphics\Drummer\Drummer_frame2.prg"
Drummer2Attr:		.import c64 "graphics\Drummer\Drummer_frame2_attr.prg"
Drummer2Cols:		.import c64 "graphics\Drummer\Drummer_frame2_colors.prg"
Drummer3bit:		.import c64 "graphics\Drummer\Drummer_frame3.prg"
Drummer3Attr:		.import c64 "graphics\Drummer\Drummer_frame3_attr.prg"
Drummer3Cols:		.import c64 "graphics\Drummer\Drummer_frame3_colors.prg"
Drummer4bit:		.import c64 "graphics\Drummer\Drummer_frame4.prg"
Drummer4Attr:		.import c64 "graphics\Drummer\Drummer_frame4_attr.prg"
Drummer4Cols:		.import c64 "graphics\Drummer\Drummer_frame4_colors.prg"
Drummer5bit:		.import c64 "graphics\Drummer\Drummer_frame5.prg"
Drummer5Attr:		.import c64 "graphics\Drummer\Drummer_frame5_attr.prg"
Drummer5Cols:		.import c64 "graphics\Drummer\Drummer_frame5_colors.prg"
Drummer6bit:		.import c64 "graphics\Drummer\Drummer_frame6.prg"
Drummer6Attr:		.import c64 "graphics\Drummer\Drummer_frame6_attr.prg"
Drummer6Cols:		.import c64 "graphics\Drummer\Drummer_frame6_colors.prg"
DrummerHead:		.import c64 "graphics\Drummer\DrummerHead_headturn.prg"
DrummerHeadAttr:	.import c64 "graphics\Drummer\DrummerHead_headturn_Attr.prg"
DrummerHeadCols:	.import c64 "graphics\Drummer\DrummerHead_headturn_Colors.prg"
.pc = * "Moon data"
spr_moon_surface:	.import c64 "graphics\Moon\Moon_spr.prg"
spr_moon_mask:		.import c64 "graphics\Moon\moonmask_mask.prg"
str_empty:			.fill 64,0


.pc = * "Code Missile"
#import "Missile.asm"
.pc = * "Code SpaceShip"
#import "Spaceship.asm"

.pc = * "Code SpaceGuy"
#import "SpaceGuy.asm"
.pc = * "Code SmallShip"
#import "SmallShip.asm"

.pc = * "Code FlashingHead"
#import "FlashingHead.asm"

.pc = * "Storyboard table"
#import "StoryboardFULLSTORY.asm"
//#import "Storyboard.asm"

.pc = * "Code Moon"
#import "Moon.asm"

.pc = * "Code Scroller"
#import "Scroller.asm"

.pc = $d000 "Graphics FlashingHead"
FlashingHeadSpr:	.import c64 "Graphics\FlashingHead\Head mc_mc.prg"
					.import c64 "Graphics\FlashingHead\beams_glow.prg"
					.import c64 "Graphics\FlashingHead\beams_glow2.prg"
.pc = * "Graphics GubbShip"
GubbShipSpr:		.import c64 "Graphics\GubbShip\GubbShip_all.prg"
.pc = * "Sleeping drummer"
SleepBitmap:		.import c64 "Graphics\Drummer\sleep_sleep.prg"
SleepAttr:			.import c64 "Graphics\Drummer\sleep_sleep_attr.prg"
SleepCols:			.import c64 "Graphics\Drummer\sleep_sleep_colors.prg"
ZzzSprite:			.import c64 "Graphics\Drummer\zzz_spr.prg"
.pc = * "Graphics Small GubbShip"
GubbShipSmallSpr: 	.import c64 "Graphics\GubbShip\Gubbship_small_all.prg"
.pc = $dc00 "screenbuffer"
screenbuffer:		.import c64 "graphics\Background\background_bitmap_attr.prg"

.pc = $e000 "Code Scorch"
#import "Scorch.asm"

.pc = $1f22 "Code Fadein"
Fadeinscreen:		ldx #0
					lda #$ff
!:					sta spr_SpaceGuy,x
					inx 
					cpx #9*3
					bne !-
					ldx #7
					lda #spr_SpaceGuy/64
!:					sta Screen0+$3f8,x
					dex
					bpl !-
					lda #$3b
					sta $d011
					jsr initsprites
					lda #$ff
					jsr spritey
fadedrummer:		jsr vsync
spr1ypos:			lda #$f4
					jsr spritey
					dec spr1ypos+1
					dec spr1ypos+1
					and #7
					bne cnt
					jsr nextcharline1
cnt:				lda #0
					cmp #11*4
					beq curtain
					inc cnt+1
					jmp fadedrummer
curtain:			lda #$ff
					jsr spritey
					ldx #0
!:					jsr vsync
					inx
					cpx #150
					bne !-
					jmp runcurtain2

.pc = $0368 "curtain"
// temp out scorch data
runcurtain2:
					lda #39
					sta nextcharline1+1
					lda #<screenbuffer+(40*24)
					sta src1+1
					lda #>screenbuffer+(40*24)
					sta src1+2
					lda #<Screen0+(40*24)
					sta dst1+1
					lda #>Screen0+(40*24)
					sta dst1+2

					lda #<BackgroundColors+(40*24)
					sta src2+1
					lda #>BackgroundColors+(40*24)
					sta src2+2
					lda #<$d800+(40*24)
					sta dst2+1
					lda #>$d800+(40*24)
					sta dst2+2
					lda #$70
					sta $d000
					sta $d002
					sta $d004
	
runcurtain:			
					ldx #1
!:					jsr vsync
					dex
					bpl !-
spr2ypos:			lda #$f4
					jsr spritey
					cmp #$9c
					bne !+
					pha
					lda #0
					sta $d000
					clc
					adc #48
					sta $d002
					adc #48
					sta $d004
					pla
!:					dec spr2ypos+1
					and #7
					bne cnt2
					jsr nextcharline1
cnt2:				lda #0
					cmp #26*8
					beq curtain3
					inc cnt2+1
					jmp runcurtain
curtain3:			lda #$ff
					jsr spritey
					ldx #0
					lda #$00
!:					sta spr_SpaceGuy,x
					inx 
					cpx #9*3
					bne !-
					rts

ldx #0
!:
					lda #$30
					sta $01
					lda screenbuffer,x
					sta Screen0,x
					lda screenbuffer+$100,x
					sta Screen0+$100,x
					lda screenbuffer+$200,x
					sta Screen0+$200,x
					lda screenbuffer+$2f8,x
					sta Screen0+$2f8,x
					lda #$35
					sta $01
					lda BackgroundColors,x
					sta $d800,x
					lda BackgroundColors+$100,x
					sta $d900,x
					lda BackgroundColors+$200,x
					sta $da00,x
					lda BackgroundColors+$2f8,x
					sta $daf8,x
					inx
					cpx #0
					bne !-
					lda #$35
					sta $01
					rts

vsync:				bit	$d011
					bmi	vsync
vsync2:				bit	$d011
					bpl	vsync2
					rts

initsprites:		lda #0
					sta $d017
					sta $d01c
					lda #$ff
					sta $d015
					sta $d01d
					lda #0
					ldx #7
!:					sta $d027,x
					dex
					bpl !-
					lda #0
					sta $d000
					clc
					adc #48
					sta $d002
					adc #48
					sta $d004
					adc #48
					sta $d006
					adc #48
					sta $d008
					adc #48
					sta $d00a
					adc #46
					sta $d00c
					adc #46
					sta $d00e
					lda #$c0
					sta $d010
					rts

spritey: 			sta $d001
					sta $d003
					sta $d005
					sta $d007
					sta $d009
					sta $d00b
					sta $d00d
					sta $d00f
					rts

nextcharline1:		ldx #10
!:					lda #$30
					sta $01
src1:				lda screenbuffer+(40*24),x
dst1:				sta Screen0+(40*24),x
					lda #$35
					sta $01
src2:				lda BackgroundColors+(40*24),x
dst2:				sta $d800+(40*24),x
					dex
					bpl !-
					lda src1+1
					sec 
					sbc #40
					sta src1+1
					lda src1+2
					sbc #0
					sta src1+2

					lda dst1+1
					sec 
					sbc #40
					sta dst1+1
					lda dst1+2
					sbc #0
					sta dst1+2

					lda src2+1
					sec 
					sbc #40
					sta src2+1
					lda src2+2
					sbc #0
					sta src2+2

					lda dst2+1
					sec 
					sbc #40
					sta dst2+1
					lda dst2+2
					sbc #0
					sta dst2+2
					rts