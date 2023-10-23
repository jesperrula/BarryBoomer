.namespace SpaceShip {

FLAG_EnableSpaceShipIRQ:	.byte 0
FLAG_EnablePlatform:		.byte 0

Execute:			rts //

SpaceShipYpos:		.byte 243
FLAG_CompressShip:	.byte 1

EnableIRQ:			lda #1
					sta FLAG_EnableSpaceShipIRQ
					rts

DisableIRQ:			lda #0
					sta FLAG_EnableSpaceShipIRQ
					rts

SpaceShipIRQ:		lda #%11000011
					sta $d01d
					lda SpaceShipYpos
					sta $d001
					sta $d003
					sta $d005
					sta $d007
					sta $d009
					sta $d00b
					sta $d00d
					sta $d00f
					lda #56
					sta $d000
					clc
					adc #48
					sta $d002
					adc #48
					sta $d004
					adc #24
					sta $d006
					adc #24
					sta $d008
					adc #24
					sta $d00a
					adc #24
					sta $d00c
					clc
					adc #48
					sta $d00e
					lda #$ff
					sta $d015
					sta $d01c
					lda #9
					sta $d025
					lda #8
					sta $d026

					.for(var i=0; i<8; i++) {
						lda SpaceShipLanePtr+i
						sta Screen0+$3f8+i
						lda SpaceShipLaneCol+i
						sta $d027+i
					}
					lda #$80
					sta $d010

lda FLAG_CompressShip
bne CompressShip

					lda SpaceShipYpos
					clc
					adc #8
					ldx #<SpaceShipIRQLine2
					ldy #>SpaceShipIRQLine2
					jmp EndIRQ

SpaceShipIRQLine2:	pha
					txa
					pha
					tya
					pha
					inc $d019
					lda SpaceShipYpos
					clc 
					adc #21
					sta $d001
					sta $d003
					sta $d005
					sta $d007
					sta $d009
					sta $d00b
					sta $d00d
					sta $d00f

					lda SpaceShipYpos
					clc
					adc #18
					ldx #<SpaceShipIRQLine3
					ldy #>SpaceShipIRQLine3
					jmp EndIRQ

SpaceShipIRQLine3:	pha
					txa
					pha
					tya
					pha
					inc $d019
CompressShip:
					ldx #5
!:					dex
					bpl !-
					.for(var i=0; i<8; i++) {
						lda SpaceShipLanePtr+i+8
						sta Screen0+$3f8+i
//						lda SpaceShipLaneCol+i+8
//						sta $d027+i
					}
					lda #0
					sta $d01d
					lda #60
					sta $d000
					lda #56+24+24+24
					sta $d002
					lda #56
					sta $d00e
					.for(var i=0; i<8; i++) {
						lda SpaceShipLaneCol+i+8
						sta $d027+i
					}

					lda SpaceShipYpos
					clc
					adc #18+10
					ldx #<SpaceShipIRQLine4
					ldy #>SpaceShipIRQLine4
					jmp EndIRQ

SpaceShipIRQLine4:	pha
					txa
					pha
					tya
					pha
					inc $d019
					lda SpaceShipYpos
					clc 
					adc #42
					sta $d001
					sta $d003
					sta $d005
					sta $d007
					sta $d009
					sta $d00b
					sta $d00d
					sta $d00f

					lda SpaceShipYpos
					clc
RasterCorrect:		adc #17+21 //14+21						//17+21
					ldx #<SpaceShipIRQLine5
					ldy #>SpaceShipIRQLine5
					jmp EndIRQ

SpaceShipIRQLine5:	pha
					txa
					pha
					tya
					pha
					inc $d019
					.for(var i=0; i<8; i++) {
						lda SpaceShipLanePtr+i+16
						sta Screen0+$3f8+i
					}
					.for(var i=0; i<6; i++) {
						lda SpaceShipLaneCol+i+16+1
						sta $d028+i
					}

lda FLAG_EnableBeam
beq !+
					lda #spr_Beam/64
					sta Screen0+$3ff
					lda #$6e
					sta $d00f
					lda #$be
					sta $d00e
//					lda $d01c
//					and #$7f
//					ora #$80
//					sta $d01c
					lda $d017
					ora #$80
					sta $d017
					lda $d010
					and #$7f
					sta $d010
beamcols:			lda #1
					sta $d02e
!:

					lda SpaceShipYpos
					clc
					adc #57
					sta $d012
					ldx #<SpaceShipIRQLine7
					ldy #>SpaceShipIRQLine7
					jmp EndIRQ

SpaceShipIRQLine7:	pha
					txa
					pha
					tya
					pha
					inc $d019
					.for(var i=0; i<7; i++) {
						lda SpaceShipLanePtr+i+24
						sta Screen0+$3f8+i
					}

					lda SpaceShipYpos
					clc
					adc #65
					ldx #<SpaceShipIRQLine8
					ldy #>SpaceShipIRQLine8
					jmp EndIRQ

SpaceShipIRQLine8:	pha
					txa
					pha
					tya
					pha
					inc $d019
					lda #0
					sta $d004
					sta $d006
					sta $d008
					sta $d00a
					sta $d00c

					jsr FlashLights
					jmp ReturnSpaceShipIRQ // Return to Main IRQ code

// ----------------------------------------------------------------------------
Accel:				.fill 52,i
					.byte 0,1,1,1,0,1,1,0,1,0,1,0,1
					.byte 1,0,1,0,1,0,1,0,1,0,1,0
					.byte 1,0,0,0,1,0,0,0,1,0,0,0
					.byte 255
Deccel:				.byte 1,0,1,0,1,0,1,0,1,0,1,0
					.byte 0,1,1,1,0,1,1,0,1,0,1,0,1
					.fill 52,i
					.byte 255

Hide:				lda #1
					sta FLAG_HideShip
					rts
FLAG_HideShip:		.byte 0

HideExec:			lda FLAG_HideShip
					bne !+
					rts
!:					jsr MoveUp
					jmp UpdateStarMaskUp

Show:				jsr MoveDown
					jmp UpdateStarMaskDown

UpdateStarMaskDown:	lda SpaceShipYpos
					clc
					adc #256-243
					lsr
					lsr
					lsr
					cmp #2
					bcs !+
					rts
!:					sec
					sbc #2
					tax
					tay
					lda tableMul40lo,x
					sta Mask+1
					lda tableMul40hi,x
					sta Mask+2
					ldx #39-10 			// 21
					lda #1
Mask:				sta $1234,x
					dex
					cpx #8+5
					bne Mask
					tya
					tax
					inx
					lda tableMul40lo,x
					sta tip1+1
					lda tableMul40hi,x
					sta tip1+2
					ldx #14
					lda #1
tip1:				sta $1234,x
					inx
					cpx #25
					bne tip1

					cpy #4
					bcs !+
					rts
!:					tya
					sec
					sbc #4
					tax
					lda tableMul40lo,x
					sta Mask2+1
					lda tableMul40hi,x
					sta Mask2+2
					ldx #39 			// 21
					lda #1
Mask2:				sta $1234,x
					dex
					cpx #7
					bne Mask2
					rts					

UpdateStarMaskUp:	lda SpaceShipYpos
					clc
					adc #256-243
					lsr
					lsr
					lsr
					cmp #2
					bcs !+
					rts
!:					sec
					sbc #2
					tax
					tay
					lda tableMul40lo,x
					sta Mask3+1
					lda tableMul40hi,x
					sta Mask3+2
					ldx #39-10 			// 21
					lda #0
Mask3:				sta $1234,x
					dex
					cpx #8+5
					bne Mask3
					
					tya
					tax
					inx
					lda tableMul40lo,x
					sta tip2+1
					lda tableMul40hi,x
					sta tip2+2
					ldx #14
					lda #0
tip2:				sta $1234,x
					inx
					cpx #25
					bne tip2

					cpy #4
					bcs !+
					rts
!:					tya
					sec
					sbc #4
					tax
					lda tableMul40lo,x
					sta Mask4+1
					sta Mask42+1
					lda tableMul40hi,x
					sta Mask4+2
					sta Mask42+2
					lda #0
					ldx #13 			// 21
Mask4:				sta $1234,x
					dex
					cpx #7
					bne Mask4
					ldx #39 			// 21
Mask42:				sta $1234,x
					dex
					cpx #26
					bne Mask42
					rts


// Remember when remove to keep +1 upmost line

MoveUp:				lda DownDelay
					cmp #3
					beq !+
					inc DownDelay
					rts
!:					lda #0
					sta DownDelay

AccelCnt2:			ldx #0
					lda Deccel,x
					cmp #255
					bne !+
					rts
!:					cmp #0
					bne !+
					inc AccelCnt2+1
					rts
!:					inc AccelCnt2+1

					dec SpaceShipYpos
					lda SpaceShipYpos
					cmp #8
					beq PackShip
					cmp #243
					beq DoneUp
					rts
PackShip:			lda #1
					sta FLAG_CompressShip
					rts

DoneUp:				lda #$60
					sta MoveUp
					rts


MoveDown:			lda DownDelay
					cmp #3
					beq !+
					inc DownDelay
					rts
DownDelay:			.byte 0
LocalCount:			.byte 0
!:					lda #0
					sta DownDelay
DisablePlatformSpr:	lda #1
					sta FLAG_EnablePlatform
					lda PlatformYpos+1			// Move platform in place
					cmp #$ea
					beq !+
					dec PlatformYpos+1
					jmp AccelCnt
!: 					// Platform is in place
					lda #0
					sta DisablePlatformSpr+1
					lda #1
					sta FLAG_DrawPlatform

AccelCnt:			ldx #0
					lda Accel,x
					cmp #255
					bne !+
					rts
!:					cmp #0
					bne !+
					inc AccelCnt+1
					rts
!:					inc AccelCnt+1

					inc SpaceShipYpos
					lda SpaceShipYpos
					cmp #8
					beq ExpandShip
					cmp #50
					beq Done
					rts
ExpandShip:			lda #0
					sta FLAG_CompressShip
					rts

Done:				lda #$60
					sta MoveDown
					rts

SpaceShipLanePtr:
					.fill 8,(spr_Spaceship/64)+i
					.fill 8,(spr_Spaceship/64)+8+i
					.fill 8,(spr_Spaceship/64)+16+i
					.fill 8,(spr_Spaceship/64)+24+i
					.fill 24,(spr_Spaceship/64)+31
SpaceShipLaneCol:	.byte 12,12,12,5,5,12,12,12
					.byte 12,2,3,15,12,5,2,10
					.byte 0,3,3,7,12,5,5,0
					.byte 0,3,3,7,15,5,5,0
					.fill 16,0

FlashLights:		lda #0
					cmp #3
					beq !+
					inc FlashLights+1
					rts
!:					lda #0
					sta FlashLights+1
FlashLightCnt:		ldx #0
					lda RedFlashes,x
					sta SpaceShipLaneCol+9
					sta SpaceShipLaneCol+14
					lda FlashLightCnt+1
					cmp #24
					beq !+
					inc FlashLightCnt+1
					rts
!:					lda #0
					sta FlashLightCnt+1
					rts
RedFlashes:			.byte 9,9,9,1,7,10,8,8,2,2,2,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9

// -----------------------------------------------------------------------

ShowPlatform:		ldx #spr_platformmask/64
					stx Screen0+$3fe
					inx
					stx Screen0+$3ff
					ldx #spr_platform/64
					stx Screen0+$3fa
					inx
					stx Screen0+$3fb
					inx
					stx Screen0+$3fc
					inx
					stx Screen0+$3fd
					lda #0
					sta $d010
					lda $d01d
					ora #%11000000
					and #%11001111
					sta $d01d
					lda $d017
					and #%00000011
					sta $d017
					lda $d01c
					ora #%00111100
					and #%00111111
					sta $d01c
PlatformYpos:		lda #$ff
					sta $d005
					sta $d007
					sta $d009
					sta $d00b
					sta $d00d
					sta $d00f
					lda #$98
					sta $d004
					sta $d00c
					lda #$98+24
					sta $d006
					lda #$98+48
					sta $d008
					sta $d00e
					lda #$98+72
					sta $d00a
					lda #4
					sta $d025
					lda #7
					sta $d026
					lda #10
					sta $d029
					sta $d02a
					sta $d02b
					sta $d02c
					lda #0
					sta $d02d
					sta $d02e
					rts

// -------------------------------------------------------

FLAG_DrawPlatform:	.byte 0

DrawPlatform:		lda FLAG_DrawPlatform
					bne !+
					rts
!:					ldx #(8*12)-1
!:					lda bitmap,x
					sta Bitmap0+(23*320)+(16*8),x
					lda bitmap+(12*8),x
					sta Bitmap0+(24*320)+(16*8),x
					dex
					bpl !-
					ldx #11
!:					lda chars,x
					sta Screen0+(23*40)+16,x
					lda chars+12,x
					sta Screen0+(24*40)+16,x
					lda cols,x
					sta $d800+(23*40)+16,x
					lda cols+12,x
					sta $d800+(24*40)+16,x
					dex
					bpl !-
					lda #$60
					sta DrawPlatform
					rts

bitmap:				.import c64 "graphics\platform\PlatformCutout_platform.prg"
chars:				.import c64 "graphics\platform\PlatformCutout_platform_attr.prg"
cols:				.import c64 "graphics\platform\PlatformCutout_platform_colors.prg"

// ----------------------------------------------------------


OpenHatch:			lda #0
					cmp #6
					beq !+
					inc OpenHatch+1
					rts
!:					lda #0
					sta OpenHatch+1
					inc fcnt+1
fcnt:				lda #255
					cmp #0
					beq f1
					cmp #1
					beq f2
					cmp #2
					beq f3
					cmp #3
					beq f4
					rts
f1:					ldx #63-21
!:					lda Hatch+128+9,x
					sta spr_Spaceship+(19*64)+9,x
					lda Hatch+192+9,x
					sta spr_Spaceship+(20*64)+9,x
					dex
					bpl !-
					rts
f2:					ldx #63-21
!:					lda Hatch+128+9+128,x
					sta spr_Spaceship+(19*64)+9,x
					lda Hatch+192+9+128,x
					sta spr_Spaceship+(20*64)+9,x
					dex
					bpl !-
					rts
f3:					ldx #63-21
!:					lda Hatch+128+9+256,x
					sta spr_Spaceship+(19*64)+9,x
					lda Hatch+192+9+256,x
					sta spr_Spaceship+(20*64)+9,x
					dex
					bpl !-
					lda #15
					sta SpaceShipLaneCol+20
					sta SpaceShipLaneCol+28
					rts
f4:					ldx #63-12
!:					lda Hatch+128+384,x
					sta spr_Spaceship+(19*64),x
					lda Hatch+192+384,x
					sta spr_Spaceship+(20*64),x
					dex
					bpl !-
					lda #7
					sta SpaceShipLaneCol+20
					sta SpaceShipLaneCol+28
					lda #$60
					sta OpenHatch
					rts

CloseHatch:			lda #0
					cmp #6
					beq !+
					inc CloseHatch+1
					rts
!:					lda #0
					sta CloseHatch+1
					inc fcnt2+1
fcnt2:				lda #255
					cmp #0
					beq f4
					cmp #1
					beq f3
					cmp #2
					beq f2
					cmp #3
					beq f1jmp
					cmp #4
					beq f0
					rts
f1jmp:				jmp f1

f0:					ldx #63-12
!:					lda Hatch,x
					sta spr_Spaceship+(19*64),x
					lda Hatch+64,x
					sta spr_Spaceship+(20*64),x
					dex
					bpl !-
					lda #$60
					sta CloseHatch
					rts

Hatch:				.import c64 "Graphics\SpaceShip\Hatch_spr.prg"

}
