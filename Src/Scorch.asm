.namespace Planet {

FLAG_ScorchEarth:	.byte 0

// May have to wait for lower raster to avoid tearing
// Remember platform

Scorch:				lda #1
					sta FLAG_ScorchEarth
					lda #9
					sta MoonCol1+1
					lda #10
					sta MoonCol2+1
					rts

Execute:			
					lda FLAG_ScorchEarth
					cmp #1
					beq ScorchRender
					cmp #2
					beq MaskAndExit
					rts

MaskAndExit:		ldx #28
!:					lda #14
					sta Screen0+240+11,x
					lda #0
					sta StarFieldMask+240+11,x
					dex
					bpl !-
					lda #6
					ldx #4
!:					sta Screen0+280+23,x
					dex
					bpl !-
					sta Screen0+320+23
					sta Screen0+280+30
					sta Screen0+280+35

					lda #0
					ldx #4
!:					sta StarFieldMask+280+23,x
					dex
					bpl !-

					sta StarFieldMask+320+23
					sta StarFieldMask+280+30
					sta StarFieldMask+280+35
					
					lda #$60
					sta Execute
					rts

ScorchRender:		inc delscorch+1
delscorch:			lda #255
					cmp #0
					beq step0
					cmp #1
					beq step1 
					cmp #2
					beq step2
					rts
step0:				jsr PlotBitmapAndWhite
					jmp ShakeScreen
step1:				jsr ColorWave1.Wave
					jmp ColorWave2.Wave
step2:				jsr ColorWave3.Wave
					jsr ColorWave4.Wave
					lda #255
					sta delscorch+1
					rts

InternalCounter:	.byte 0
ShakeScreen:		lda InternalCounter
					cmp #0
					beq Shake
					cmp #20
					beq Shake
					cmp #28
					beq ShakeFull
					inc InternalCounter
					rts
ShakeFull:			lda #<ShakeDataX2
					sta sd1+1
					lda #>ShakeDataX2
					sta sd1+2
					lda #<ShakeDataY2
					sta sd2+1
					lda #>ShakeDataY2
					sta sd2+2
					lda #28
					sta sd3+1

Shake:				ldx #0
					lda #$d8
					clc
sd1:				adc ShakeDataX1,x
					sta scrxpos+1
					and #7
					sta GlobalShakeX
					lda #$38
					clc
sd2:				adc ShakeDataY1,x
					sta scrypos+1
					and #7
					sec
					sbc #3
					sta GlobalShakeY
					lda Shake+1
sd3:				cmp #11
					beq ShakeDone
					inc Shake+1
					rts
ShakeDone:			inc InternalCounter
					lda #0
					sta Shake+1
					rts

GlobalShakeX:		.byte 0
GlobalShakeY:		.byte 0

ShakeDataX1:		.byte 2,0,1,0,1,2,0,1,0,1,0,0
ShakeDataY1:		.byte 2,4,3,4,3,3,2,3,3,3,3,3

ShakeDataX2:		.byte 4,0,3,1,3,2,4,3,2,1,0,0,1,0,1,0,1,0,0,1,0,1,0,1,0,1,0,0,1,0
ShakeDataY2:		.byte 2,4,1,5,2,5,3,4,3,4,3,3,2,3,3,4,3,3,2,3,3,2,3,3,2,3,3,2,2,3

.namespace ColorWave1 {
Wave:
					lda #0
					cmp #3
					beq xcoord
					inc Wave+1
					rts

xcoord:				ldx Coordinates					 	// Go through all coordinates
					cpx #255
					beq ScorchDone
					cpx #254
					beq ReadNextAndExit
ycoord:				ldy Coordinates+1
					jsr PlotChar
					jsr GetNextCoords
					jmp Wave
ReadNextAndExit: 	jsr GetNextCoords
ScorchDone:			rts

GetNextCoords:		lda xcoord+1
					clc
					adc #2
					sta xcoord+1 
					lda xcoord+2
					adc #0
					sta xcoord+2
					lda ycoord+1
					clc
					adc #2
					sta ycoord+1 
					lda ycoord+2
					adc #0
					sta ycoord+2
					rts
PlotChar:			lda scrposl,y
					sta scrdst+1
					lda scrposh,y
					sta scrdst+2
					lda colposl,y
					sta coldst+1
					lda colposh,y
					sta coldst+2
					stx xpos+1 //store source X

					txa 				// Align coords to cutouts, sub 11,7
					sec 
					sbc #11
					tax
					tya
					sec 
					sbc #6
					tay

					lda scrcutoutl,y
					sta cutscrsrc+1
					lda scrcutouth,y
					sta cutscrsrc+2
					lda colcutoutl,y
					sta cutcolsrc+1
					lda colcutouth,y
					sta cutcolsrc+2

xpos:				ldy #0
					stx rememberx
cutscrsrc:			lda temp,x
					sta remembera
					and #$0f
					tax
					lda cols,x
					sta c1+1
					lda remembera
					and #$f0
					lsr
					lsr
					lsr
					lsr
					tax
					lda cols,x
					asl
					asl
					asl
					asl
c1:					ora #0
scrdst:				sta temp,y
					ldx rememberx
cutcolsrc:			lda temp,x
					and #$0f
					tax
					lda cols,x
coldst:				sta temp,y
					rts

rememberx:			.byte 0
remembera:			.byte 0
cols:				.byte 15,1,7,13,13,13,3,7,7,7,7,3,13,13,13,7
}

.namespace ColorWave2 {
Wave:
					lda #0
					cmp #3+3
					beq xcoord
					inc Wave+1
					rts

xcoord:				ldx Coordinates					 	// Go through all coordinates
					cpx #255
					beq ScorchDone
					cpx #254
					beq ReadNextAndExit
ycoord:				ldy Coordinates+1
					jsr PlotChar
					jsr GetNextCoords
					jmp Wave
ReadNextAndExit: 	jsr GetNextCoords
ScorchDone:			rts

GetNextCoords:		lda xcoord+1
					clc
					adc #2
					sta xcoord+1 
					lda xcoord+2
					adc #0
					sta xcoord+2
					lda ycoord+1
					clc
					adc #2
					sta ycoord+1 
					lda ycoord+2
					adc #0
					sta ycoord+2
					rts
PlotChar:			lda scrposl,y
					sta scrdst+1
					lda scrposh,y
					sta scrdst+2
					lda colposl,y
					sta coldst+1
					lda colposh,y
					sta coldst+2
					stx xpos+1 //store source X

					txa 				// Align coords to cutouts, sub 11,7
					sec 
					sbc #11
					tax
					tya
					sec 
					sbc #6
					tay

					lda scrcutoutl,y
					sta cutscrsrc+1
					lda scrcutouth,y
					sta cutscrsrc+2
					lda colcutoutl,y
					sta cutcolsrc+1
					lda colcutouth,y
					sta cutcolsrc+2

xpos:				ldy #0
					stx rememberx
cutscrsrc:			lda temp,x
					sta remembera
					and #$0f
					tax
					lda cols,x
					sta c1+1
					lda remembera
					and #$f0
					lsr
					lsr
					lsr
					lsr
					tax
					lda cols,x
					asl
					asl
					asl
					asl
c1:					ora #0
scrdst:				sta temp,y
					ldx rememberx
cutcolsrc:			lda temp,x
					and #$0f
					tax
					lda cols,x
coldst:				sta temp,y
					rts

rememberx:			.byte 0
remembera:			.byte 0
cols: 				.byte 12,1,10,3,3,3,12,7,15,10,15,12,3,13,3,15
}

.namespace ColorWave3 {
Wave:
					lda #0
					cmp #3+3+3
					beq xcoord
					inc Wave+1
					rts

xcoord:				ldx Coordinates					 	// Go through all coordinates
					cpx #255
					beq ScorchDone
					cpx #254
					beq ReadNextAndExit
ycoord:				ldy Coordinates+1
					jsr PlotChar
					jsr GetNextCoords
					jmp Wave
ReadNextAndExit: 	jsr GetNextCoords
ScorchDone:			rts

GetNextCoords:		lda xcoord+1
					clc
					adc #2
					sta xcoord+1 
					lda xcoord+2
					adc #0
					sta xcoord+2
					lda ycoord+1
					clc
					adc #2
					sta ycoord+1 
					lda ycoord+2
					adc #0
					sta ycoord+2
					rts
PlotChar:			lda scrposl,y
					sta scrdst+1
					lda scrposh,y
					sta scrdst+2
					lda colposl,y
					sta coldst+1
					lda colposh,y
					sta coldst+2
					stx xpos+1 //store source X

					txa 				// Align coords to cutouts, sub 11,7
					sec 
					sbc #11
					tax
					tya
					sec 
					sbc #6
					tay

					lda scrcutoutl,y
					sta cutscrsrc+1
					lda scrcutouth,y
					sta cutscrsrc+2
					lda colcutoutl,y
					sta cutcolsrc+1
					lda colcutouth,y
					sta cutcolsrc+2

xpos:				ldy #0
					stx rememberx
cutscrsrc:			lda temp,x
					sta remembera
					and #$0f
					tax
					lda cols,x
					sta c1+1
					lda remembera
					and #$f0
					lsr
					lsr
					lsr
					lsr
					tax
					lda cols,x
					asl
					asl
					asl
					asl
c1:					ora #0
scrdst:				sta temp,y
					ldx rememberx
cutcolsrc:			lda temp,x
					and #$0f
					tax
					lda cols,x
coldst:				sta temp,y
					rts

rememberx:			.byte 0
remembera:			.byte 0
cols: .byte 11,1,8,3,12,5,4,7,10,2,10,4,12,13,14,15
}

.namespace ColorWave4 {
Wave:
					lda #0
					cmp #3+3+3+3+3
					beq xcoord
					inc Wave+1
					rts

xcoord:				ldx Coordinates					 	// Go through all coordinates
					cpx #255
					beq ScorchDone
					cpx #254
					beq ReadNextAndExit
ycoord:				ldy Coordinates+1
					jsr PlotChar
					jsr GetNextCoords
					jmp Wave
ReadNextAndExit: 	jsr GetNextCoords
					rts
ScorchDone:			lda #2
					sta FLAG_ScorchEarth
					rts

GetNextCoords:		lda xcoord+1
					clc
					adc #2
					sta xcoord+1 
					lda xcoord+2
					adc #0
					sta xcoord+2
					lda ycoord+1
					clc
					adc #2
					sta ycoord+1 
					lda ycoord+2
					adc #0
					sta ycoord+2
					rts
PlotChar:			lda scrposl,y
					sta scrdst+1
					lda scrposh,y
					sta scrdst+2
					lda colposl,y
					sta coldst+1
					lda colposh,y
					sta coldst+2
					stx xpos+1 //store source X

					txa 				// Align coords to cutouts, sub 11,7
					sec 
					sbc #11
					tax
					tya
					sec 
					sbc #6
					tay

					lda scrcutoutl,y
					sta cutscrsrc+1
					lda scrcutouth,y
					sta cutscrsrc+2
					lda colcutoutl,y
					sta cutcolsrc+1
					lda colcutouth,y
					sta cutcolsrc+2

xpos:				ldy #0
					stx rememberx
cutscrsrc:			lda temp,x
					sta remembera
					and #$0f
					tax
					lda cols,x
					sta c1+1
					lda remembera
					and #$f0
					lsr
					lsr
					lsr
					lsr
					tax
					lda cols,x
					asl
					asl
					asl
					asl
c1:					ora #0
scrdst:				sta temp,y
					ldx rememberx
cutcolsrc:			lda temp,x
					and #$0f
					tax
					lda cols,x
coldst:				sta temp,y
					rts

rememberx:			.byte 0
remembera:			.byte 0
cols: .byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
}

PlotBitmapAndWhite:
xcoord:				ldx Coordinates					 	// Go through all coordinates
					cpx #255
					beq ScorchDone
					cpx #254
					beq ReadNextAndExit
ycoord:				ldy Coordinates+1
					jsr PlotChar
					jsr GetNextCoords
					jmp PlotBitmapAndWhite
ReadNextAndExit: 	jsr GetNextCoords
ScorchDone:			rts

GetNextCoords:		lda xcoord+1
					clc
					adc #2
					sta xcoord+1 
					lda xcoord+2
					adc #0
					sta xcoord+2
					lda ycoord+1
					clc
					adc #2
					sta ycoord+1 
					lda ycoord+2
					adc #0
					sta ycoord+2
					rts
PlotChar:			lda scrposl,y
					sta scrdst+1
					lda scrposh,y
					sta scrdst+2
					lda colposl,y
					sta coldst+1
					lda colposh,y
					sta coldst+2
					stx xpos+1 //store source X

					txa 				// Align coords to cutouts, sub 11,7
					sec 
					sbc #11
					tax
					tya
					sec 
					sbc #6
					tay

					lda dstbitmapl,y
					clc
					adc Mul8,x
					sta dstbitmap+1
					lda dstbitmaph,y
					adc #0
					sta dstbitmap+2

					lda srcbitmapl,y
					clc
					adc Mul8,x
					sta srcbitmap+1
					lda srcbitmaph,y
					adc #0
					sta srcbitmap+2

					// x = cutoutpos
xpos:				ldy #0
					lda #$11
//cutscrsrc:			lda $1234,x
scrdst:				sta $1234,y
//cutcolsrc:			lda $1234,x
coldst:				sta $1234,y

					ldx #7
srcbitmap:			lda scorchedbitmap,x
dstbitmap:			sta Bitmap0,x
					dex
					bpl srcbitmap
					rts

temp:				.byte 0,0

scrposl:			.fill 25,<Screen0+(i*40)
scrposh:			.fill 25,>Screen0+(i*40)
colposl:			.fill 25,<$d800+(i*40)
colposh:			.fill 25,>$d800+(i*40)

scrcutoutl:			.fill 19,<scorchedAttr+(29*i)
scrcutouth:			.fill 19,>scorchedAttr+(29*i)
colcutoutl:			.fill 19,<scorchedCols+(29*i)
colcutouth:			.fill 19,>scorchedCols+(29*i)
srcbitmapl:			.fill 19,<scorchedbitmap+(i*(29*8))
srcbitmaph:			.fill 19,>scorchedbitmap+(i*(29*8))

dstbitmapl:			.fill 19,<Bitmap0+(i*320)+88+(6*320)
dstbitmaph:			.fill 19,>Bitmap0+(i*320)+88+(6*320)

scorchedAttr:		.import c64 "graphics\Background\Scorched_bm_attr.prg"
scorchedCols:		.import c64 "graphics\Background\Scorched_bm_colors.prg"
scorchedbitmap:		.import c64 "graphics\Background\Scorched_bm.prg"
Coordinates:		.import c64 "Scorch\ScorchCoordinates.prg"
					.byte 255,255

}
