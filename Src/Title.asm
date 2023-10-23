
.namespace title {
Execute:		sei
				jsr vsync
				lda #0
				sta 53280
				sta $d011

				lda #$30
				sta $01
				ldx #0
CopyCols:		lda Colors,x
				sta $0400,x
				lda Colors+$100,x
				sta $0500,x
				lda Colors+$200,x
				sta $0600,x
				lda Colors+$300,x
				sta $0700,x
				inx
				bne CopyCols
				lda #$35
				sta $01
				ldx #0
!:				lda $0400,x
				sta $d800,x
				lda $0500,x
				sta $d900,x
				lda $0600,x
				sta $da00,x
				lda $0700,x
				sta $db00,x
				inx
				bne !-

				lda $dd00
				and #%11111100
				sta $dd00
				lda #%00111000
				sta $d018
				lda #24
				sta $d016

				jsr ResetSprites
				jsr SetupIRQ

!:				lda counter
				cmp #192 // frames to show picture
				bne !-
				lda #0
				sta counter
!:				lda counter
				cmp #222 // frames to show picture
				bne !-
				
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
				cli
				rts				

/*				sei
				lda #$36
				sta $01
				jsr $ff81
				lda #0
				sta $d020
				lda #$0b
				sta $d011
				sta screenonoff+1

				rts
*/
vsync:
!:				ldx $d011
				bpl !-
!:				ldx $d011
				bmi !-
				rts
saveirq:			.word 0
savenmi:			.word 0
counter:			.byte 0

.pc = $cb00 "title extra code"
SetupIRQ:		sei
				lda #$7f
				sta $dc0d
				sta $dd0d

				lda $dc0d
				lda $dd0d

				lda #$01
				sta $d01a

				lda #44
				sta $d012

				lda #$0b
				sta $d011

				lda #$35
				sta $01

				lda #<NMI
				sta $fffa
				lda #>NMI
				sta $fffb

				lda #<IRQ
				sta $fffe
				lda #>IRQ
				sta $ffff

				// Disable restore key
				lda #$00					// stop timer A
				sta $dd0e
				sta $dd04					// set timer A to 0, after starting
				sta $dd05					// NMI will occur immediately
				lda #$81
				sta $dd0d					// set timer A as source for NMI
				lda #$01
				sta $dd0e					// start timer A -> NMI

				cli
				rts


.macro BeginIRQ() {
	pha
	txa
	pha
	tya
	pha
	lda #1
	sta $d019
}

.macro NextIRQ(ad, y) {
	lda #<ad
	ldx #>ad
	ldy #y
	sta $fffe
	stx $ffff
	sty $d012
	jmp EndIRQ
}

EndIRQ:			pla
				tay
				pla
				tax
				pla
NMI:			rti



//-----------------------------------------------------------------------------------------------

				.pc = $a400 "IRQ code (screen in walk part)"

IRQ:			BeginIRQ()
restoreirql:	lda #<IRQ2
restoreirqh:	ldx #>IRQ2
				ldy #46
				sta $fffe
				stx $ffff
				sty $d012
				cli
				.fill 50,234
				jmp EndIRQ

IRQ2:			BeginIRQ()
screenonoff:	lda #$3b
				sta $d011
				lda #2
				sta 53281
				lda #0
				sta dummy
				lda #0
				sta dummy
				bit 0
				lda $d012
				cmp $d012
				beq !+
!:
.const SB = 53281-11*1

				ldy #0
				lda #16
				ldx #24
				jsr P44
				jsr P44
				jsr P44
				jsr P24
lda #0
sta $d020
lda #16
				jsr P44
				
		// 0
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr AdvY
				sta SB
				stx SB

		// 1
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr P36

				sta SB
				stx SB

		// 2
				sta SB,y
				stx SB
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				jsr P12
				jsr SB6
				jsr AdvY
				sta SB
				stx SB

		// 3
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr P36
				sta SB
				stx SB

		// 4
				sta SB,y
				stx SB
				jsr P36
				jsr SB4
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				.fill 4,234
				jsr SB2
				jsr P36
				sta SB
				stx SB

		// 5
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr AdvY
				sta SB
				stx SB

		// 6
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr P28
				ldy #1
				sty dummy
				ldy #0
				sta SB
				stx SB

		// 7
				sta SB,y
				stx SB
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				jsr P12
				jsr SB6
				jsr AdvY
				sta SB
				stx SB

		// 8
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr P28
				ldy #96
				sty dummy
				ldy #0
				sta SB
				stx SB

		// 9
				sta SB,y
				stx SB
				jsr P24

				lda #10
				sta $d02b
				sta $d02c
				lda #16

				jsr SB4
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				.fill 4,234
				jsr SB2
				jsr P36
				sta SB
				stx SB

		// 10
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr AdvY
				sta SB
				stx SB

		// 11
				sta SB,y
				stx SB
				jsr P28
				ldy #126
				sty dummy
				ldy #0
				jsr SB6
				jsr P28
				lda #11
				sta $d02b
				lda #16

				sta SB
				stx SB

		// 12
				sta SB,y
				stx SB
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				jsr P12
				jsr SB6
				jsr AdvY
				sta SB
				stx SB

		// 13
				sta SB,y
				stx SB
				jsr P28
				lda #11
				sta $d02c
				lda #16

				jsr SB6
				jsr P36

				sta SB
				stx SB

		// 14
				sta SB,y
				stx SB
				jsr P36
				jsr SB4
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				.fill 4,234
				jsr SB2
				jsr P22
				ldy #%10110000
				sty dummy
				ldy #304
				sty dummy
				ldy #0
				sta SB
				stx SB


		// 15
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr AdvY
				sta SB
				stx SB

		// 16
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr P36
				sta SB
				stx SB

		// 17
				sta SB,y
				stx SB
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				jsr P12
				jsr SB6
				jsr P36 
				sta SB
				stx SB

		// 18
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr P36
				sta SB
				stx SB

		// 19
				sta SB,y
				stx SB
				jsr P28
				ldy #272
				sty dummy
				ldy #0
				jsr SB4
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				.fill 4,234
				jsr SB2
				jsr P36
				sta SB
				stx SB




		// 20
				sta SB,y
				stx SB
				jsr AdvY
				jsr SB6				
				jsr P36
				sta SB
				stx SB

		// 21
				sta SB,y
				stx SB
				jsr P36
				jsr SB6
				jsr P22
				ldy #%10010000
				sty dummy
				ldy #238
				sty dummy
				ldy #0
				sta SB
				stx SB

		// 22
				sta SB,y
				stx SB
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				jsr P12
				jsr SB6
				jsr AdvY
				sta SB
				stx SB
		// 23
				sta SB,y
				stx SB
				jsr P22

				ldy #%10000000
				sty dummy
				ldy #196
				sty dummy
				ldy #0
				jsr SB6
				jsr P36
				sta SB
				stx SB

		// 24
				sta SB,y
				stx SB
				jsr P30
				ldy #9
				sty dummy
				jsr SB4
				inc SprPtr+4
				inc SprPtr+5
				inc SprPtr+6
				inc SprPtr+7
				.fill 4,234
				jsr SB2
				jsr P34
				ldy #0
				sta SB
				stx SB
sty $d020
sty $d021
				jsr ResetSprites

				NextIRQ(IRQ, 44)

SB6:			sta SB
				stx SB
				jsr P42
SB5:			sta SB
				stx SB
				jsr P42
SB4:			sta SB
				stx SB
				jsr P42
SB3:			sta SB
				stx SB
				jsr P42
SB2:			sta SB
				stx SB
				jsr P42
SB1:			sta SB
				stx SB
				rts

P46:			nop
P44:			nop
P42:			nop
P40:			nop
P38:			nop
P36:			nop
P34:			nop
P32:			nop
P30:			nop
P28:			nop
P26:			nop
P24:			nop
P22:			nop
P20:			nop
P18:			nop
P16:			nop
P14:			nop
P12:			nop
				rts

ResetSprites:	lda #%11110000
				sta $d015
				lda #$ff
				sta $d01c
				lda #%00000000
				sta $d01d
				lda #%11010000
				sta $d010
				lda #0
				sta $d017
				sta $d01b
				lda #224
				sta $d008
				lda #0
				sta $d00a
				lda #88
				sta $d00c
				lda #88+24
				sta $d00e

				lda #0
				sta $d025
				lda #1
				sta $d026
				lda #10
				sta $d02d
				sta $d02e
				lda #3
				sta $d02b
				sta $d02c

				lda #48
				jsr SetY

				lda #SpritesR1/64
				sta SprPtr+6
				lda #SpritesR2/64
				sta SprPtr+7
				lda #SpritesL1/64
				sta SprPtr+4
				lda #SpritesL2/64
				sta SprPtr+5
				inc counter
				jsr $b803
				rts

AdvY:			lda $d009
				clc
				adc #21
SetY:			sta $d009
				sta $d00b
				sta $d00d
				sta $d00f
				lda #16
				rts
dummy:			.byte 0

				.pc = $d800 "colors"
Colors:			.import c64 "graphics\title\Loading_pic_borders_MC_Colors.prg"

//------------------------------------------------------------------------------------------------

				.pc = $e000 "bitmap"
Bitmap:			.import c64 "graphics\title\Loading pic borders_MC.prg"

				.pc = $cc00 "Screen"
Screen:			.import c64 "graphics\title\Loading_pic_borders_MC_Attr.prg"
				.fill 16,0
SprPtr:			.fill 8,0

				.pc = $c000 "Sprites1"
SpritesL1:		.import c64 "graphics\title\Loading pic borders_sprleft1.prg"
SpritesL2:		.import c64 "graphics\title\Loading pic borders_sprleft2.prg"
SpritesR1:		.import c64 "graphics\title\Loading pic borders_sprright1.prg"
SpritesR2:		.import c64 "graphics\title\Loading pic borders_sprright2.prg"

}