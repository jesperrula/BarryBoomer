.var music = LoadSid("music\TrappedAgainTSJ6581.sid")

.const introonly = false

.if(introonly) {
	.pc = $0801 "Basic Upstart Program"
					:BasicUpstart($c000)	
} else {
	.pc = $0801 "packeddata"
	.import c64 "introbuild\gubbtrapfull.prg"
}

.namespace preintro {
/*
.pc = $1000 "Code Main"
					sei
					lda #$35
					sta $01
					jmp $e000
*/
// ---------------------------------------------------------------

.pc = $c000 "preintro"

Execute:			sei
!:					jsr vsync
					lda #$0b
					sta $d011
					lda #0
					jsr music.init

!:					jsr vsync
					jsr vsync
					jsr vsync
					jsr vsync
fadeincnt:			ldx #0
					lda fadeinscreen,x
					sta $d020
					sta $d021
					inc fadeincnt+1
					lda fadeincnt+1
					cmp #4
					bne !-
					lda #$3c
					sta $dd00
					lda #%11000000
					sta $d018
					ldx #0
					lda #11
!:					sta $d800,x
					sta $d900,x
					sta $da00,x
					sta $daf8,x
					inx
					bne !-
					jsr vsync
					lda #$1b
					sta $d011

					lda #$ff
					sta $d015
					lda #0
					sta $d017
					sta $d01c
					sta $d01d
					sta $d010

					lda #0
					sta $d000
					sta $d002
					sta $d004
					sta $d006
					sta $d008
					sta $d00a
					sta $d00c
					sta $d00e
					sta $d027
					sta $d028
					sta $d029
					sta $d02a
					sta $d02b
					sta $d02c
					sta $d02d
					sta $d02e

loop:				jsr vsync
					ldx #0
					lda #Sprites/64
!:					sta sprptr,x
					clc
					adc #1
					inx
					cpx #7
					bne !-
					lda #Sprites/64+6
					sta sprptr+7

					jsr MoveT
					jsr MoveS
					jsr MoveJ
					jsr Wait
					jsr ShowDots
					jsr FadeToBlack
					jsr Wait2
					jsr FadeAll

					jsr music.play

					lda FLAG_TSJDone
					beq loop
					lda #$b3
!:					cmp $d012
					bne !-
					jsr ShowProd
					lda FLAG_Complete
					beq loop

					ldx #0
!:					jsr vsync
					txa
					pha
					jsr music.play
					pla
					tax
					inx
					cpx #25
					bne !-

					lda #$90
					sta $d001
					sta $d003
					sta $d005
					sta $d007
					lda #$88
					sta $d000
					clc
					adc #24
					sta $d002
					adc #24
					sta $d004
					adc #24
					sta $d006
					ldx #Sprites/64+9
					stx sprptr
					inx
					stx sprptr+1
					inx
					stx sprptr+2
					inx
					stx sprptr+3

					ldx #0
!:					jsr vsync
					txa
					pha
					jsr music.play
					pla
					tax
					inx
					cpx #128
					bne !-

					jsr vsync
					lda #$0b
					sta $d011
					lda #0
					sta $d015

					lda #$01
					sta $d020
					jsr vsync
					jsr vsync
					jsr vsync

					lda #$0f
					sta $d020
					jsr vsync
					jsr vsync
					jsr vsync

					lda #$0c
					sta $d020
					jsr vsync
					jsr vsync
					jsr vsync

					lda #$0b
					sta $d020
					jsr vsync
					jsr vsync
					jsr vsync

					lda #0
					sta $d020
					sta $d021
					ldx #0
!:					lda #0
					sta $d800,x
					sta $d900,x
					sta $da00,x
					sta $daf8,x
					lda #$20
					sta $0400,x
					sta $0500,x
					sta $0600,x
					sta $06f8,x
					inx
					bne !-
					jsr vsync
					lda #$1b
					sta $d011
					jsr vsync
					lda #$3f
					sta $dd00
					lda #$15
					sta $d018
					lda #90
					sta $05cc
					ldx #$10
					txa
!:					sta $d000,x
					dex
					bpl !-
					cli
					jmp $080d

FLAG_IntroDone:		.byte 0

fadeinscreen:		.byte 1,15,12,11
// -----------------------------------------------------------------------------

vsync:				bit	$d011
					bpl	vsync
vsync2:				bit	$d011
					bmi	vsync2
					rts

// -----------------------------------------------------------------------------
FLAG_Complete:		.byte 0
FLAG_FadeAll:		.byte 0
FadeAll:			lda FLAG_FadeAll
					bne !+
					rts
!:					lda #$60
					sta ShowProd
					lda t_xpos+1
					cmp #0
					beq !+
					dec t_xpos+1

!:					lda s_xpos+1
					cmp #0-48-8
					bne !+
inc FLAG_Complete
!:					dec s_xpos+1

					lda j_xpos+1
					cmp #0
					beq !+
					dec j_xpos+1
!:
					lda dot_xpos1+1
					cmp #0
					beq !+
					dec dot_xpos1+1
!:
					lda dot_xpos2+1
					cmp #0
					beq !+
					dec dot_xpos2+1
!:
					rts

Wait2:				lda FLAG_Wait2
					bne !+
					rts
!:					lda #0
					cmp #96
					beq NextSeq2
					inc !-+1
					rts
NextSeq2:			lda #1
					sta FLAG_FadeAll
					rts
FLAG_Wait2:			.byte 0

ShowProd:			lda #$bc
					sta $d001
					sta $d003
					lda #$9a
					sta $d000
					clc
					adc #24
					sta $d002
					ldx #Sprites/64+7
					stx sprptr
					inx
					stx sprptr+1
prodcol:			ldx #0
					lda #0
					sta $d027
					sta $d028
					lda prodcol+1
					cmp #10
					beq !+
					inc prodcol+1
					rts					
!:					lda #1
					sta FLAG_Wait2
					rts

FadeToBlack:		lda FLAG_FadeToBlack
					bne !+
					rts
FLAG_FadeToBlack:	.byte 0
!:					ldx #0
					lda tblack,x
					sta $d027
					sta $d028
					lda sblack,x
					sta $d029
					sta $d02a
					lda jblack,x
					sta $d02b
					sta $d02c
					cpx #32+9
					beq !+
					inc !-+1
					rts
!:					lda #1 
					sta FLAG_TSJDone
					rts

jblack:				.fill 16,1
sblack:				.fill 16,1
tblack:				.byte 1,1,15,15,12,12,11,11,0,0
					.fill 32,0
ShowDots:			lda FLAG_ShowDots
					bne !+
					rts
FLAG_ShowDots:		.byte 0
!:					ldx #0
					lda flashdotcolors,x
					sta $d02d
					sta $d02e
					lda #$ba
					sta $d00c
dot_xpos1:			lda #$87
					sta $d00d
					lda #$a6
					sta $d00e
dot_xpos2:			lda #$a1
					sta $d00f
					lda !-+1
					cmp #22
					beq !+
					inc !-+1
					rts
!:					lda #1
					sta FLAG_FadeToBlack
					rts

flashdotcolors:		.byte 11,11,11,12,12,12,15,15,15,1,1,1,15,15,15,12,12,12,11,11,11,0,0,0

Wait:				lda FLAG_Wait
					bne !+
					rts
!:					lda #0
					cmp #12
					beq NextSeq
					inc !-+1
					rts
NextSeq:			lda #1
					sta FLAG_ShowDots
					rts
FLAG_Wait:			.byte 0

FLAG_TSJDone:		.byte 0

MoveT:				lda FLAG_MoveT
					bne !+
					rts
!:
tcnt:				ldx #0
					lda sineeasein,x
					clc
					adc #99
					sta $d000
					sta $d002
					lda colors,x
					sta $d027
					sta $d028
t_xpos:				lda #$5c
					sta $d001
					clc
					adc #21
					sta $d003

					lda tcnt+1
					cmp #31
					beq !+
					inc tcnt+1
					inc t_xpos+1
					rts
!:					lda #1
					sta FLAG_MoveJ
					rts

FLAG_MoveT:			.byte 0
FLAG_MoveJ:			.byte 0

MoveS:				ldx #0
					lda sineeasein,x
					clc
s_xpos:				adc #103-32
					sta $d005
					clc
					adc #21
					sta $d007
					lda colors,x
					sta $d029
					sta $d02a
					lda #24+160-12
					sta $d004
					sta $d006
					lda MoveS+1
					cmp #31
					beq !+
					inc MoveS+1
					rts
!:					lda #1
					sta FLAG_MoveT
					rts

MoveJ:				lda FLAG_MoveJ
					bne !+
					rts
!:
					ldx #0
					lda #$f1
					sec
					sbc sineeasein,x
					sta $d008
					sta $d00a
					lda colors,x
					sta $d02b
					sta $d02c
j_xpos:				lda #$ae
					sta $d009
					clc
					adc #21
					sta $d00b
					lda !-+1
					cmp #31
					beq !+
					inc !-+1
					dec j_xpos+1
					rts
!:					lda #1
					sta FLAG_Wait
					rts

sineeasein:			.fill 32, 64*sin(toRadians(i*360/128))
colors:				.byte 12,12,12,12,15,15,15,15,1,1,1,1
					.fill 24,1

.align $40
Sprites:			.import c64 "graphics\TSJ\TSJ hires_spr.prg"

.pc = $c900 "music"
					.fill music.size, music.getData(i)

.pc = $f000 "screen"
screen:				.fill $3f8 ,0
sprptr:				.fill 8,0
}