.namespace StarField {

Enable:
					lda #1
					sta FLAG_ScrollStarfield
					rts

FLAG_ScrollStarfield:	.byte 0

Accelerate:			.fill 128, 128 + 128*sin(toRadians(270+i*360/256))
speed:	.word 0

Execute:			lda FLAG_ScrollStarfield
					bne AccCnt
					rts
AccCnt:				ldx #0
					cpx #128
					beq FullSpeed
					lda speed
					clc
					adc Accelerate,x
					sta speed
					lda speed+1
					adc #0
					sta speed+1
					inc AccCnt+1

					lda speed+1
					bne !+
					rts
!:					lda #0
					sta speed+1

FullSpeed:
					lda ScreenSwitch
					beq !+
					jsr StarField1.Clear
					jsr StarField1.Move
					jmp StarField1.Draw
!:
					jsr StarField2.Clear
					jsr StarField2.Move
					jmp StarField2.Draw

}
.namespace StarField1 {
Clear:				lda #NumOfStars-1				// Clear old stars using existing coordinates
					sta ClrStarCnt+1
					ldy #0
ClrStarCnt:			ldx #0
!:					lda StarArrayClrFlag,x
					bne SkipPlot
					lda StarClrLo,x
					sta clr+1
					lda StarClrHi,x
					sta clr+2
clr:				sty $1234					
SkipPlot:			dex
					bpl !-
//-----------------------------------------------------------
Move:
sp1:				lda #StarSpeed1					// Calculate new positions
					beq !+
					dec sp1+1
					jmp Speed1Set
!:					lda #StarSpeed1
					sta sp1+1
					ldx #0
					clc
MoveStars1:			dec StarArrayX,x
					bne !+
					lda #StarFieldWidth
					sta StarArrayX,x
!:					dec StarArrayY,x
					bne !+
					lda #StarFieldHeight
					sta StarArrayY,x
!:					inx
					cpx #NumOfStars/2
					bne MoveStars1
Speed1Set: 

sp2:				lda #StarSpeed2
					beq !+
					dec sp2+1
					jmp Speed2Set
!:					lda #StarSpeed2
					sta sp2+1
					ldx #NumOfStars/2
MoveStars2:			dec StarArrayX,x
					bne !+
					lda #StarFieldWidth
					sta StarArrayX,x
!:					dec StarArrayY,x
					bne !+
					lda #StarFieldHeight
					sta StarArrayY,x
!:					inx
					cpx #(NumOfStars/4)*4
					bne MoveStars2
Speed2Set:			rts

//------------------------------------------------------------
Draw:				lda #NumOfStars-1 			// plot new stars using new coordinates
					sta StarCnt+1
StarCnt:			ldx #0
!:					stx.zp zp_temp
					ldy StarArrayY,x
					lda StarArrayX,x
					tax
					sty ypos2+1
					sta xpos2+1

					lda tableDiv8,y 				// Check if we are drawing in a masked out area
					tay
					lda tableMul40lo,y
					sta MaskCheck2+1
					lda tableMul40hi,y
					sta MaskCheck2+2
					lda tableDiv4,x
					tax
					ldy.zp zp_temp
MaskCheck2:			lda $1234,x
					sta StarArrayClrFlag,y 			// set or clear - used by clearing code
					bne SkipPlot2
ypos2:				ldy #0
xpos2:				ldx #0
					clc
	PlotStar:			lda tbl_yposlo,y 			// Get framebuffer and add y-pos
						adc tbl_xposlo,x
						sta dst1+1
						sta dst2+1
						lda #$40
						adc tbl_yposhi,y
						adc tbl_xposhi,x
						sta dst1+2
						sta dst2+2
	dst1:				lda $1234
						ora xposlo,x
	dst2:				sta $1234
SkipPlot2:			ldx.zp zp_temp
					lda dst1+1
					sta StarClrLo,x
					lda dst1+2
					sta StarClrHi,x
					dex
					bpl !-
					rts

StarClrLo:			.fill NumOfStars,0
StarClrHi:			.fill NumOfStars,0
StarArrayX:				.fill NumOfStars,1+random()*(StarFieldWidth-1)
StarArrayY:				.fill NumOfStars,1+random()*(StarFieldHeight-1)
StarArrayClrFlag:		.fill NumOfStars,1

}




.namespace StarField2 {
Clear:				lda #NumOfStars-1				// Clear old stars using existing coordinates
					sta ClrStarCnt+1
					ldy #0
ClrStarCnt:			ldx #0
!:					lda StarArrayClrFlag,x
					bne SkipPlot
					lda StarClrLo,x
					sta clr+1
					lda StarClrHi,x
					sta clr+2
clr:				sty $1234					
SkipPlot:			dex
					bpl !-
//-----------------------------------------------------------
Move:
sp1:				lda #StarSpeed3					// Calculate new positions
					beq !+
					dec sp1+1
					jmp Speed1Set
!:					lda #StarSpeed3
					sta sp1+1
					ldx #0
					clc
MoveStars1:			dec StarArrayX,x
					bne !+
					lda #StarFieldWidth
					sta StarArrayX,x
!:					dec StarArrayY,x
					bne !+
					lda #StarFieldHeight
					sta StarArrayY,x
!:					inx
					cpx #NumOfStars/2
					bne MoveStars1
Speed1Set: 

sp2:				lda #StarSpeed4
					beq !+
					dec sp2+1
					jmp Speed2Set
!:					lda #StarSpeed4
					sta sp2+1
					ldx #NumOfStars/2
MoveStars2:			dec StarArrayX,x
					bne !+
					lda #StarFieldWidth
					sta StarArrayX,x
!:					dec StarArrayY,x
					bne !+
					lda #StarFieldHeight
					sta StarArrayY,x
!:					inx
					cpx #(NumOfStars/4)*4
					bne MoveStars2
Speed2Set:			rts

//------------------------------------------------------------
Draw:				lda #NumOfStars-1 			// plot new stars using new coordinates
					sta StarCnt+1
StarCnt:			ldx #0
!:					stx.zp zp_temp
					ldy StarArrayY,x
					lda StarArrayX,x
					tax
					sty ypos2+1
					sta xpos2+1

					lda tableDiv8,y 				// Check if we are drawing in a masked out area
					tay
					lda tableMul40lo,y
					sta MaskCheck2+1
					lda tableMul40hi,y
					sta MaskCheck2+2
					lda tableDiv4,x
					tax
					ldy.zp zp_temp
MaskCheck2:			lda $1234,x
					sta StarArrayClrFlag,y 			// set or clear - used by clearing code
					bne SkipPlot2
ypos2:				ldy #0
xpos2:				ldx #0
					clc
	PlotStar:			lda tbl_yposlo,y 			// Get framebuffer and add y-pos
						adc tbl_xposlo,x
						sta dst1+1
						sta dst2+1
						lda #$40
						adc tbl_yposhi,y
						adc tbl_xposhi,x
						sta dst1+2
						sta dst2+2
	dst1:				lda $1234
						ora xposlo,x
	dst2:				sta $1234
SkipPlot2:			ldx.zp zp_temp
					lda dst1+1
					sta StarClrLo,x
					lda dst1+2
					sta StarClrHi,x
					dex
					bpl !-
					rts

StarClrLo:			.fill NumOfStars,0
StarClrHi:			.fill NumOfStars,0
StarArrayX:				.fill NumOfStars,1+random()*(StarFieldWidth-1)
StarArrayY:				.fill NumOfStars,1+random()*(StarFieldHeight-1)
StarArrayClrFlag:		.fill NumOfStars,1

}
