.namespace FlashingHead {

.const HeadXposbase = 112
.const HeadYposbase = $48

Init:				lda #7 								// Num of sprites
					sta SpritePusher.NumOfSprites
					lda #<FlashingHeadSpr 				// Source
					sta SpritePusher.Source
					lda #>FlashingHeadSpr
					sta SpritePusher.Source+1
					lda #<spr_Spaceship 				// Destination
					sta SpritePusher.Destination
					lda #>spr_Spaceship+1
					sta SpritePusher.Destination+1
					jmp SpritePusher.Init // Will copy one sprite per frame until done

FLAG_EnableFHead:	.byte 0

Enable:				lda #1
					sta FLAG_EnableFHead
					rts

Disable:			lda #0
					sta FLAG_EnableFHead
					ldx #$10
!:					sta $d000,x
					dex
					bpl !-
					rts

Execute:			lda FLAG_EnableFHead
					bne !+
					rts
!:					jsr Flasher 
					jmp Header 

// -------------------------------------------------------

Flasher:			lda EVENT_FlashScreen
					bne FlashScreen 
					rts
FlashScreen:		ldx #0
					cpx #5
					beq FlashDone
					lda FlashColors,x
					sta ScreenColor+1
					inc FlashScreen+1
					rts
FlashDone:			lda #0
					sta FlashScreen+1
					sta EVENT_FlashScreen
					rts
FlashColors:		.byte 1,15,12,11,0

// -------------------------------------------------------

Header:				lda EVENT_FlashingHead
					bne colcnt
					lda #0
					sta $d015
					rts
colcnt:				ldx #0
					lda col15,x
					sta c15+1
					lda col9,x
					sta c9+1
					lda col10,x
					sta c10+1
					lda col14,x
					sta c14+1
					lda col8,x
					sta c8+1
					lda col7,x
					sta c7+1
					lda colScreen,x
					sta ScreenColor+1
					lda Expanded,x
					sta HeadExpand
					lda Beammove
					clc
					adc #12
					sta Beammove
					lda BeammoveDiag
					clc
					adc #6
					sta BeammoveDiag
					cpx #6
					beq HeadFlashDone
					inc colcnt+1
					lda #$ff
					sta $d015
					rts
HeadFlashDone:		lda #0
					sta $d015
					sta Beammove
					sta BeammoveDiag
					sta EVENT_FlashingHead
					sta colcnt+1
random:				lda $1000
					and #$3f
					clc
					adc #HeadXposbase
					sta HeadPosX
					and #7
					clc
					adc #HeadYposbase
					sta HeadPosY
					inc random+1
					rts

col15:				.byte 15,15,5,8,2,9,0
col9:				.byte 9, 9, 0,0,0,0,0
col10:				.byte 10,10,8,2,9,0,0
col14:				.byte 14,14,4,2,9,0,0
col8:				.byte 8, 8, 2,9,0,0,0
colScreen:			.byte 9, 0, 0,0,0,0,0
col7:				.byte 7,15,5,8,2,9,0,0
size:				.byte $ff,$ff,$f0,$f0,$f0,$f0,$f0
Expanded:			.byte 1,1,0,0,0,0,0

HeadPosX:			.byte 128
HeadPosY: 			.byte $48
HeadExpand:			.byte 0
Beammove:			.byte 0
BeammoveDiag:		.byte 0
IRQ:				
s:					lda #$f0
					sta $d01d
					sta $d017
					lda HeadExpand
					beq !+
					lda #$ff
					sta $d01d
					sta $d017
!:					lda #$0f
					sta $d01c
:break()
					lda #spr_FlashingHead/64
					ldx #0
!:					sta Screen0+$3f8,x
					clc
					adc #1
					inx
					cpx #6
					bne !-
					sta Screen0+$3fe // ll
					sta Screen0+$3ff // lr

c15:				lda #0
					sta $d025
c9:					lda #0
					sta $d026
c10:				lda #0
					sta $d027
					sta $d029
c14:				lda #0
					sta $d028
c8:					lda #0
					sta $d02a
					lda HeadPosX
					sta $d000
					sta $d004
					clc
					adc #24
					sta $d002
					sta $d006
					lda HeadExpand
					beq !+
					lda HeadPosX
					sec
					sbc #24
					sta $d000
					sta $d004
					clc
					adc #48
					sta $d002
					sta $d006
!:
					lda HeadPosY
					sta $d001
					sta $d003
					clc
					adc #21
					sta $d005
					sta $d007
					lda HeadExpand
					beq !+
					lda HeadPosY
					sec
					sbc #21
					sta $d001
					sta $d003
					clc
					adc #42
					sta $d005
					sta $d007
!:
c7:					lda #0
					sta $d02b
					sta $d02c
					sta $d02d
					sta $d02e

					lda HeadPosX // Upper left
					sec 
					sbc #28
sbc BeammoveDiag
					sta $d008
					lda HeadPosY
					sec 
					sbc #30
sbc BeammoveDiag
					sta $d009
					sta $d00b

					lda HeadPosX // Upper right
					clc 
					adc #36
adc BeammoveDiag
					sta $d00a


					lda HeadPosX // left
					sec 
					sbc #28
sbc Beammove
					sta $d00c
					lda HeadPosY
					sec 
					sbc #17
					sta $d00d
					sta $d00f

					lda HeadPosX // right
					clc 
					adc #36
adc Beammove
					sta $d00e

					lda HeadPosY
					clc
					adc #21+4
					ldx #<irq
					ldy #>irq
					jmp EndIRQ

irq:				pha
					txa
					pha
					tya
					pha
					inc $d019

					ldx #spr_FlashingHead/64+4
					stx Screen0+$3fd // ll
					inx
					stx Screen0+$3fc // lr
					lda HeadPosX // Lower left
					sec 
					sbc #28
sbc BeammoveDiag
					sta $d008 //$d00c
					lda HeadPosY
					clc 
					adc #42
adc BeammoveDiag
					sta $d009 //$d00d
					sta $d00b //$d00f

					lda HeadPosX // Lower right
					clc 
					adc #48-12
adc BeammoveDiag
					sta $d00a //$d00e

skip:				lda #$80
					ldx #<irqMiddle
					ldy #>irqMiddle
					jmp EndIRQ
}
