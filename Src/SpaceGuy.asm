.namespace SpaceGuy {

.const Speed1 = 3
.const Speed2 = 2
.const Speed3 = 1

SpaceGuyAction:		.byte 0
FLAG_SpaceGuyStationary: .byte 0

SpaceGuyOffset:		.byte 0 //ypos offset

InitBeams:			jsr Beam0
					jsr Beam1
					jmp Beam2

Wave:				lda #6
					sta SpaceGuyAction
					rts

StopWave:			lda #7
					sta SpaceGuyAction
					rts

WaveExecute:		lda #0
					cmp #4
					beq !+
					inc WaveExecute+1
					rts
!:					lda #0
					sta WaveExecute+1
WaveCnt:			ldx #0
					lda WaveData,x
					cmp #0
					beq donewaving
					tax
					jsr SetSpaceGuyFrame
					inc WaveCnt+1
					rts
donewaving:			lda #0
					sta WaveCnt+1
					jmp StopWave

WaveData:			.byte 15,16,17,18,19,20,19,18,17,18,19,20,19,18,17,18,19,20,19,18,17,18,19,20,19,18,17
					.byte 18,19,20,19,18,17,18,19,20,19,18,17,18,19,20,19,18,17,18,19,20,19,18,17,16,15
					.byte 0

//When SpaceGuyaction=0 do nothing
Execute:			lda SpaceGuyAction // Make different sequences in blocks
					cmp #1
					beq TumbleInJMP
					cmp #2
					beq WaitABitJMP
					cmp #3
					beq Unfold
					cmp #4
					beq WaitABitJMP
					cmp #5
					beq DanceDown
					cmp #6
					beq WaveJMP // Start waving
					cmp #7
					beq AllDone	// Set to normal stationary
					rts
WaveJMP:			jmp WaveExecute
TumbleInJMP:		jmp TumbleIn
WaitABitJMP:		jmp WaitABit
AllDone:			ldx #14
					jsr SetSpaceGuyFrame
					lda #$60
					sta DanceDown
					lda #1
					sta FLAG_SpaceGuyStationary
					rts

DanceDown:			lda #0
					cmp #3
					beq !+
					inc DanceDown+1
					rts
!:					lda #0
					sta DanceDown+1
					inc SpaceGuyYpos+1
					lda SpaceGuyYpos+1
					cmp #$cc
					beq AllDone
					rts

Unfold:				jsr hover
uncnt:				lda #0
					cmp #3
					beq !+
					inc uncnt+1
					rts
!:					lda #0
					sta uncnt+1
					lda SpaceGuyOffset
					cmp #-28
					beq !+
					dec SpaceGuyOffset
!:
f2:					ldx #0
					lda Unfoldframes,x
					cmp #255
					beq unfolddone
					tax
					jsr SetSpaceGuyFrame
					inc f2+1
					rts
unfolddone:			lda #4
					sta SpaceGuyAction
					rts

WaitABit:			lda #0
					cmp #128
					beq !+
					inc WaitABit+1
					ldx #%11011101
					lda WaitABit+1
					cmp #80 //Blink start
					bcc normal
					ldx #%01011101
					lda WaitABit+1
					cmp #96 //Blink end
					bcc normal
					jsr hover
					ldx #%11011101
normal:				stx spr_SpaceGuy+28 // Blink
					stx spr_SpaceGuy+31
					rts
!:					inc SpaceGuyAction
					lda #64
					sta WaitABit+1
					lda #$60 // Disable
					sta normal
					rts

BeamIn:				lda #1 // Trigger the whole sequence
					sta SpaceGuyAction
					rts


hover:				ldx #0
					lda hoversine,x
					cmp #255
					beq !+
					lda SpaceGuyOffset
					clc
					adc hoversine,x
					sta SpaceGuyYpos+1
					lda hover+1
					inc hover+1
					rts
!:					lda #0
					sta hover+1
					rts

TumbleIn:			jsr ticnt // animate

tumbleyposcnt:		ldx #0
					lda tumbleypos,x
					cmp #255
					beq tumblemovestop
					sta SpaceGuyYpos+1
					lda tumbleyposcnt+1
					inc tumbleyposcnt+1
					rts
tumblemovestop:		jsr hover
					lda #2
					sta ticnt+3
l1:					lda #0 // let tumble head 2 times
					cmp #1
					beq !+
					inc l1+1
					rts
!:					lda f1+1
					cmp #5
					beq !+
					rts
!:					lda #$60
					sta ticnt
l2:					lda #0
					cmp #10
					beq !+
					inc l2+1
					rts
!:					ldx #3
					jsr SetSpaceGuyFrame
					lda #2
					sta SpaceGuyAction
					rts
ticnt:				lda #0
					cmp #0
					beq !+
					inc ticnt+1
					rts
!:					lda #0
					sta ticnt+1

f1:					ldx #0
					lda tumbleinframes,x
					cmp #255
					beq tidone
					tax
					jsr SetSpaceGuyFrame
					inc f1+1
					rts
tidone:				lda #0
					sta f1+1
					rts
tumbleinframes:		.byte 0,1,2,3,4,5,0,0,0,0,0,255
tumbleypos:			.fill 16, $78 + 32*sin(toRadians(i*360/64))
					.fill 64, $78 + 32 + 6*sin(toRadians(i*360/64))
hoversine:			.fill 80, $78 + 32 + 2*sin(toRadians(i*360/80))
					.byte $98,255

Unfoldframes:		.byte 3,2,1,1,2,3,4,5,6,7
					.fill 16,8
					.byte 9,9,9,9
					.fill 16,10
					.byte 11,11,11,11
					.fill 24,12
					.byte 13,13,13,13,14
					.byte 255

.const NumOfAnims = 23

// x = index for plot
SetSpaceGuyFrame:	lda GuySrcLo,x
					sta Src1+1
					lda GuySrcLo2,x
					sta Src2+1

					lda GuySrcHi,x
					sta Src1+2
					lda GuySrcHi2,x
					sta Src2+2

					ldx #63
Src1:				lda $1234,x
					sta spr_SpaceGuy,x
Src2:				lda $1234,x
					sta spr_SpaceGuy+64,x
					dex
					bpl Src1
					rts

GuySrcLo:			.fill NumOfAnims,<SpaceGuyGfx+(i*64)
GuySrcHi:			.fill NumOfAnims,>SpaceGuyGfx+(i*64)
GuySrcLo2:			.fill NumOfAnims,<SpaceGuyGfx+(i*64)+(NumOfAnims*64)
GuySrcHi2:			.fill NumOfAnims,>SpaceGuyGfx+(i*64)+(NumOfAnims*64)

// -----------------------------------------------------------------

EnableBeam:			lda #1
					sta FLAG_EnableBeam
					rts

DisableBeam:		lda #0
					sta FLAG_EnableBeam
					rts

BeamAnim:			lda FLAG_EnableBeam
					bne !+
					rts
!:
lda $d012
cmp #$f8
bcc !-
					jsr Beam0
					jsr Beam1
					jsr Beam2
					lda #8
					sta beamcols+1
					sta SpaceShip.beamcols+1
					rts

Beam0:				ldy #0
					ldx #20
!:					stx cnt
					lda SineCnt,x
					tax
					lda sine,x
					tax
					lda lookup1,x
					tax
					lda col1,x
					sta spr_Beam,y
					iny
					inx
					lda col1,x
					sta spr_Beam,y
					iny
					inx
					lda col1,x
					sta spr_Beam,y
					iny
					ldx cnt
					lda SineCnt,x
					clc
					adc #Speed1
					sta SineCnt,x
					dex
					bpl !-
					rts
cnt:				.byte 0
SineCnt:			.fill 21,128/21*i

Beam1:				ldy #0
					ldx #20
!:					stx cnt2
					lda SineCnt2,x
					tax
					lda sine,x
					tax
					lda lookup1,x
					tax
					lda col1,x
					ora spr_Beam,y
					sta spr_Beam,y
					iny
					inx
					lda col1,x
					ora spr_Beam,y
					sta spr_Beam,y
					iny
					inx
					lda col1,x
					ora spr_Beam,y
					sta spr_Beam,y
					iny
					ldx cnt2
					lda SineCnt2,x
					clc
					adc #Speed2
					sta SineCnt2,x
					dex
					bpl !-
					rts
cnt2:				.byte 0
SineCnt2:			.fill 21,128/21*i+42

Beam2:				ldy #0
					ldx #20
!:					stx cnt3
					lda SineCnt3,x
					tax
					lda sine,x
					tax
					lda lookup1,x
					tax
					lda col1,x
					ora spr_Beam,y
					sta spr_Beam,y
					iny
					inx
					lda col1,x
					ora spr_Beam,y
					sta spr_Beam,y
					iny
					inx
					lda col1,x
					ora spr_Beam,y
					sta spr_Beam,y
					iny
					ldx cnt3
					lda SineCnt3,x
					clc
					adc #Speed3
					sta SineCnt3,x
					dex
					bpl !-
					rts
cnt3:				.byte 0
SineCnt3:			.fill 21,256/21*i+42+42

lookup1:			.fill 21,i*3

col1:				.byte %10000000,%00000000,%00000000
					.byte %01000000,%00000000,%00000000
					.byte %00100000,%00000000,%00000000
					.byte %00010000,%00000000,%00000000
					.byte %00001000,%00000000,%00000000
					.byte %00000100,%00000000,%00000000
					.byte %00000010,%00000000,%00000000
					.byte %00000001,%00000000,%00000000
					.byte %00000000,%10000000,%00000000
					.byte %00000000,%01000000,%00000000
					.byte %00000000,%00100000,%00000000
					.byte %00000000,%00010000,%00000000
					.byte %00000000,%00001000,%00000000
					.byte %00000000,%00000100,%00000000
					.byte %00000000,%00000010,%00000000
					.byte %00000000,%00000001,%00000000
					.byte %00000000,%00000000,%10000000
					.byte %00000000,%00000000,%01000000
					.byte %00000000,%00000000,%00100000
					.byte %00000000,%00000000,%00010000
					.byte %00000000,%00000000,%00001000
					.byte %00000000,%00000000,%00000100
					.byte %00000000,%00000000,%00000010
					.byte %00000000,%00000000,%00000001

sine:				.fill 256, 10 + 10*cos(toRadians(i*360/128))
SpaceGuyGfx:		.import c64 "graphics\spaceguy\spaceguy_spr.prg"
}
