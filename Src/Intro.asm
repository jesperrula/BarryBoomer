
.var music = LoadSid("music\TrappedAgainIntro6581.sid")

.const introonly = false

.const FramesToShowTextBobble = 96+30

.if(introonly) {
	.pc = $0801 "Basic Upstart Program"
					:BasicUpstart($9ca0)	
	.pc = * "packeddata"
//	.import c64 "introbuild\gubbtrapprepack.prg"
} else {
	.pc = $0801 "packeddata"
	.import c64 "introbuild\gubbtrapprepack.prg"
}

.namespace intro {

//.pc = $a400 "Screen" virtual
.const Screen = $a400 //.fill $3f8,0
.const SprPtr = $a7f8 //.fill 8,0

.pc = $9ca0 "Code Main"

Execute:			lda #$36
					sta $01
					lda #0
					jsr music.init
					jsr title.Execute
					sei 
					lda #0
					sta $d020
					sta $d021
					lda #$35
					sta $01
					lda #$3d
					sta $dd00
					lda #%10011000
					sta $d018
					ldx #0
!:					lda #8
					sta $d800,x
					sta $d900,x
					sta $da00,x
					sta $daf8,x
					lda #0
					sta Screen,x
					sta Screen+$100,x
					sta Screen+$200,x
					sta Screen+$2f8,x
					inx
					bne !-
					lda #$d8
					sta $d016
					lda #$ff
					sta $d015
					sta $d01b
					sta $d000
					sta $d002
					sta $d004
					sta $d006
					sta $d008
					sta $d00a
					sta $d00c
					sta $d00e
					lda #0
					sta $d01c
					sta $d01d
					lda #$f0
					sta $d017
					sta $d01d
					lda #$f3
					sta $d010
					lda #$7f
					sta $dc0d
					sta $dd0d
					lda $dc0d
					lda $dd0d
					lda #$01
					sta $d019
					sta $d01a
					lda #$00
					sta $d012
					lda #<sprrow1
					sta $fffe
					lda #>sprrow1
					sta $ffff
					lda #<NMI
					sta $fffa 
					lda #>NMI
					sta $fffb					
					cli
!:					lda FLAG_IntroDone
					beq !-
					jsr vsync
					sei
					lda #$36
					sta $01
					lda #$0b
					sta $d011
					lda #$7f
					sta $dc0d
					sta $dd0d
					lda $dc0d
					lda $dd0d
					lda #$48
					sta $fffe
					lda #$ff
					sta $ffff
					ldx #0
					stx $d01a
					inx
					stx $d019
					jmp $080d

// -----------------------------------------------------------------------------

FLAG_IntroDone:		.byte 0

sprrow1:			pha
					txa
					pha
					tya
					pha
					inc $d019
					jsr Run
					jsr CheckStops
					jsr WalkFront

screenypos:			lda #$10
					sta $d011
col14_1:			lda #14
					sta $d022
col6_1:				lda #6
					sta $d023

bobxpos:			lda #$80
					sta $d000
					clc
					adc #24
					sta $d002
					adc #24
					sta $d004
bobypos:			lda #$90-$10
					sta $d001
					sta $d003
					sta $d005
					lda #1
					sta $d027
					sta $d028
					sta $d029
bobptr1:			lda #Sprites/64
					sta SprPtr
bobptr2:			lda #Sprites/64
					sta SprPtr+1
bobptr3:			lda #Sprites/64
					sta SprPtr+2
					lda $d010
					and guymsb+1
beammsb:			ora #$f0
					sta $d010
pos_beam:			lda #$60 			// Beam
					sta $d008
					sta $d00a
					sta $d00c
					sta $d00e
col14_2:			lda #14
					sta $d02d
					sta $d02b
col6_2:				lda #6
					sta $d02c
					sta $d02e
					lda #$30+42-$10
					sta $d009
					sta $d00b
					lda #$30-$10
					sta $d00d
					sta $d00f
					lda #Sprites/64+14
					sta SprPtr+6
					lda #Sprites/64+10
					sta SprPtr+7
					lda #Sprites/64+15
					sta SprPtr+4
					lda #Sprites/64+11
					sta SprPtr+5
					jsr music.play
					lda #$30+42+41-$10
					sta $d012
rirql:				lda #<sprrow2
					sta $fffe
rirqh:				lda #>sprrow2
					sta $ffff
PopRegs:			pla
					tay
					pla
					tax
					pla
NMI:				rti

sprrow2:			pha
					txa
					pha
					tya
					pha
					inc $d019
					lda #$30+42+42+42-$10
					sta $d009
					sta $d00b
					lda #$30+42+42-$10
					sta $d00d
					sta $d00f
					lda #Sprites/64+16
					sta SprPtr+6
					lda #Sprites/64+12
					sta SprPtr+7
					lda #Sprites/64+17
					sta SprPtr+4
					lda #Sprites/64+13
					sta SprPtr+5
					lda #$30+42+42+35-$10
					sta $d012
					lda #<sprrow3
					sta $fffe
					lda #>sprrow3
					sta $ffff
					jmp PopRegs

sprrow3:			pha
					txa
					pha
					tya
					pha
					inc $d019
guymsb:				lda #$f3
					sta $d010
					lda #0 	// Guy
					sta $d027
					sta $d028
pos_guy:			lda #$70
					sta $d000
					sta $d002
pos_guy_y:			lda #$a9-$10
					sta $d001
					clc
					adc #21
					sta $d003
ptr_guy:			lda #Sprites/64
					sta SprPtr
					clc
ptr_guy_delta:		adc #18
					sta SprPtr+1
					lda #0
					sta $d012
					lda #<sprrow1
					sta $fffe
					lda #>sprrow1
					sta $ffff
					jmp PopRegs

//---------------------------------

FLAG_WalkIn:		.byte 1

Run:				lda FLAG_WalkIn
					bne AnimSeq
					rts
AnimSeq: 			lda #0
					cmp #2
					beq move1
					cmp #4
					beq !+
					inc AnimSeq+1
					rts
move1:				inc AnimSeq+1
					dec pos_guy+1
					dec pos_beam+1
					jmp CheckMSB

!:					lda #0
					sta AnimSeq+1

animnum:			ldx #0
					lda animation,x
					sta ptr_guy+1
					inx
					cpx #10
					bne !+
					ldx #0
!:					stx animnum+1
					dec pos_guy+1
					dec pos_beam+1
					inc textboblecnt					
CheckMSB:
skip1:				lda #0
					bne !+
					lda pos_guy+1
					cmp #$ff
					bne !+
					inc skip1+1
					lda guymsb+1 //$d010
					eor #3
					sta guymsb+1 //$d010
!:					
skip2:				lda #0
					bne !+
					lda pos_beam+1
					cmp #$ff
					bne !+
					inc skip2+1
					lda guymsb+1 //$d010
					eor #$f0
					sta guymsb+1 //$d010
					sta beammsb+1
!:					rts

// ------------------------------------------------------------------------------

CheckStops:			lda textboblecnt
					cmp #$20+8
					bne EnableText1
					lda #1
					sta FLAG_EnableText1
EnableText1:		cmp #$48+7
					bne EnableText2
					lda #1
					sta FLAG_EnableText2
					lda #0
					sta guymsb+1 //$d010
					sta beammsb+1

EnableText2:		cmp #$70+6
					bne EnableText3
					lda #1
					sta FLAG_EnableText3
EnableText3:		cmp #$99
					beq stopmovement
					lda #0
					sta bobypos+1
					jsr boble1
					jsr boble2
					jmp boble3

stopmovement:		lda #0
					sta FLAG_WalkIn
					lda #1
					sta FLAG_WalkFront
					rts
					
boble1:				lda FLAG_EnableText1
					bne f
					rts
f:					lda #$90-$10
					sta bobypos+1
					lda pos_guy+1
					sec
					sbc #$14
					sta bobxpos+1
					bmi below
					lda $d010
					and #$fe 
					ora #1
					sta $d010
					jmp over
below:				lda $d010
					and #$fe
					sta $d010
over:				lda #(<Sprites/64)+31
					sta bobptr1+1
					lda #(<Sprites/64)+34
					sta bobptr2+1
					sta bobptr3+1
d1:					lda #0
					cmp #FramesToShowTextBobble
					beq !+
					inc d1+1
					rts
!:					lda #0
					sta FLAG_EnableText1
					rts

boble2:				lda FLAG_EnableText2
					bne g 
					rts
g:					lda #$90-$10
					sta bobypos+1
					lda pos_guy+1
					sec
					sbc #$2a
					sta bobxpos+1
					lda #Sprites/64+28
					sta bobptr1+1
					lda #Sprites/64+29
					sta bobptr2+1
					lda #Sprites/64+30
					sta bobptr3+1
d2:					lda #0
					cmp #FramesToShowTextBobble
					beq !+
					inc d2+1
					rts
!:					lda #0
					sta FLAG_EnableText2
					rts

.pc = $a2f0 "counters"
textboblecnt:		.byte 0
waiter:				.word 0
FLAG_EnableText1:	.byte 0
FLAG_EnableText2:	.byte 0
FLAG_EnableText3:	.byte 0

.pc = $b700 "more intro code"

animation:			.byte Sprites/64,Sprites/64+1,Sprites/64+2,Sprites/64+3,Sprites/64+4,Sprites/64+5,Sprites/64+6,Sprites/64+7,Sprites/64+8,Sprites/64+9

// ---------------------------------------------------------

ShowBitmap:			rts

// -----------------------------------------------------------------------------

vsync:				bit	$d011
					bmi	vsync
vsync2:				bit	$d011
					bpl	vsync2
					rts

// -----------------------------------------------------------------------------
drumscreen:			.import c64 "graphics\drum_drum_Screen.prg"

.pc = $a000 "Charset"
Charset:			.import c64 "graphics\drum_drum.prg"


// -----------------------------------------------------------------------------
FLAG_WalkFront:		.byte 0
animation2:			.fill 11,SpritesFront/64+i

WalkFront:			lda FLAG_WalkFront
					bne !+
					rts
!:					jsr ShowDrum
					jsr animatedrummer
					jsr faerun
movedown:			lda #0
					cmp #20 // was 12 <<< slowing down to 15 now
					beq !+
					inc movedown+1
					rts
!:					lda #0
					sta movedown+1
					inc pos_guy_y+1
ggg:				lda #0
					cmp #20
					beq fadeoutandexit2
					inc ggg+1
					rts
fadeoutandexit2:	lda #1
					sta FLAG_fadeoutandexit
					rts
FLAG_fadeoutandexit:	.byte 0

faerun:				lda FLAG_fadeoutandexit
					bne fadeoutandexit
					rts
fadeoutandexit:		lda #0
					cmp #3
					beq !+
					inc fadeoutandexit+1
					rts
!:					lda #0
					sta fadeoutandexit+1
colcnt:				ldx #0
					lda col6to0,x
					sta col6_1+1
					sta col6_2+1
					lda col14to0,x
					sta col14_1+1
					sta col14_2+1
					lda colcnt+1
					cmp #3
					beq exitnow
					inc colcnt+1
					rts
exitnow:			lda #1
					sta FLAG_IntroDone
					rts
col6to0:			.byte 6,11,0,0
col14to0:			.byte 14,6,11,0

animatedrummer:		
slowfront:			lda #0
					cmp #6
					beq !+
					inc slowfront+1
					rts
!:					lda #0
					sta slowfront+1
					lda #11
					sta ptr_guy_delta+1
animnum2:			ldx #0
					lda animation2,x
					sta ptr_guy+1
					inx
					cpx #11
					bne !+
					ldx #0
!:					stx animnum2+1
					rts

ShowDrum:			lda #0
					cmp #6
					beq slowdowndrum
					inc ShowDrum+1
					rts
slowdowndrum:		lda #0
					sta ShowDrum+1
					lda screenypos+1
					cmp #$10
					beq NextChar
					dec screenypos+1
					rts
NextChar:			lda #$17
					sta screenypos+1
					ldx #11
!:					lda Screen+(40*19),x
					sta Screen+(40*18),x
					lda Screen+(40*20),x
					sta Screen+(40*19),x
					lda Screen+(40*21),x
					sta Screen+(40*20),x
					lda Screen+(40*22),x
					sta Screen+(40*21),x
					lda Screen+(40*23),x
					sta Screen+(40*22),x
					lda Screen+(40*24),x
					sta Screen+(40*23),x
					dex
					bpl !-
					ldx #11
drawdrum:			lda drumscreen,x
					sta Screen+(40*24),x
					dex
					bpl drawdrum
					lda drawdrum+1
					clc
					adc #12
					sta drawdrum+1
					lda drawdrum+2
					adc #0
					sta drawdrum+2
ddd:				lda #0
					cmp #6
					beq drumdrawdone
					inc ddd+1
					rts
drumdrawdone:		lda #$60
					sta ShowDrum
					rts

.pc = $a880 "intro sprites"
Sprites:			.import c64 "graphics\intro_sprites.prg"
SpritesFront:		.import c64 "graphics\intro_frontfacing.prg"



// -----------------------------------------------------------------------------
.pc = $b800 "music"
					.fill music.size, music.getData(i)

.pc = $a300 "Code title main"
#import "title.asm"

.pc = $cb60 "more intro code"

boble3:				lda FLAG_EnableText3
					bne h
					rts
h:					lda #$90-$10
					sta bobypos+1
					lda pos_guy+1
					clc
					adc #$08
					sta bobxpos+1
					lda #(<Sprites/64)+32
					sta bobptr1+1
					lda #(<Sprites/64)+33
					sta bobptr2+1
					lda #(<Sprites/64)+34
					sta bobptr3+1
d3:					lda #0
					cmp #FramesToShowTextBobble
					beq !+
					inc d3+1
					rts
!:					lda #0
					sta FLAG_EnableText3
					rts

}
