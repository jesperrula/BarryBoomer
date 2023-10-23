
.namespace GubbShip {

FLAG_EnableGubbShipIRQ:	.byte 0
GubbShipYpos:		.byte $30
GubbShipXpos:		.byte $0
GubbShipXposHi:		.byte %00011111
FLAG_GubbShipMoveIn: .byte 0
FLAG_GubbShipMoveOut: .byte 0
FLAG_GubbShipHover:	.byte 0
FLAG_BeamUp:		.byte 0
FLAG_EnableSpaceGuy: .byte 1

// --------------------------------------------------------------

Init:				lda #25 								// Num of sprites
					sta SpritePusher.NumOfSprites
					lda #<GubbShipSpr 					// Source
					sta SpritePusher.Source
					lda #>GubbShipSpr
					sta SpritePusher.Source+1
					lda #<spr_Spaceship 				// Destination
					sta SpritePusher.Destination
					lda #>spr_Spaceship+1
					sta SpritePusher.Destination+1
					jmp SpritePusher.Init // Will copy one sprite per frame until done

// --------------------------------------------------------------

BeamUp:				lda #1
					sta FLAG_BeamUp
					rts

// --------------------------------------------------------------

EnableIRQ:			lda #1
					sta FLAG_EnableGubbShipIRQ
					rts

// --------------------------------------------------------------

DisableIRQ:			lda #0
					sta FLAG_EnableGubbShipIRQ
					sta SpaceGuy.FLAG_SpaceGuyStationary
					ldx #$10
!:					sta $d000,x
					dex
					bpl !-
					lda #$80
					sta rasterMissile+1
					lda #1
					sta FLAG_ExitSmall
					rts

// --------------------------------------------------------------

Enter:				lda #1
					sta FLAG_GubbShipMoveIn
					rts

// --------------------------------------------------------------

Exit:				lda #1
					sta FLAG_GubbShipMoveOut
					lda #0
					sta FLAG_GubbShipHover
					rts

// --------------------------------------------------------------

Execute:			jsr SpaceGuyExit
					lda FLAG_GubbShipMoveIn
					beq !+
					jmp MoveIn
!:					lda FLAG_GubbShipMoveOut
					beq !+
					jmp MoveOut
!:					lda FLAG_GubbShipHover
					beq !+
					jmp Hover

// ---------------------------------------------------------------
.const DebugGS = false
StoreSpriteYpos:	sta $d001
					sta $d003
					sta $d005
					sta $d007
					sta $d009
!:					rts

// ---------------------------------------------------------------
IRQ:				

					ldx #$10
					lda #0
!:					sta $d000,x
					dex
					bpl !-

					jsr GubbShip.Execute

					lda GubbShipYpos
					jsr StoreSpriteYpos
					//.for(var i=0; i<5; i++) {
						ldx #0
						ldy #(spr_GubbShip/64)
!:						tya
						sta Screen0+$3f8,x
						lda #1 //lda GubbShipLaneCol+i
						sta $d027,x
						iny
						inx
						cpx #5
						bne !-
					//}

					lda #0
					sta $d017
					sta $d01d
					lda #$ff
					sta $d015
					sta $d01c
					lda #10
					sta $d025
					lda #9
					sta $d026

					lda GubbShipYpos
					clc
					adc #18
					ldx #<GubbShipIRQLine2
					ldy #>GubbShipIRQLine2
					jmp EndIRQ

GubbShipIRQLine2:	pha
					txa
					pha
					tya
					pha
					inc $d019
					lda GubbShipYpos
					clc 
					adc #21
					jsr StoreSpriteYpos
					ldy #(spr_GubbShip/64)+5
!:					sty Screen0+$3f8
					iny
					sty Screen0+$3f9
					iny
					sty Screen0+$3fa
					iny
					sty Screen0+$3fb
					iny
					sty Screen0+$3fc
					lda #15
					sta $d026

					lda GubbShipYpos
					clc
					adc #21*2-5
					ldx #<GubbShipIRQLine3
					ldy #>GubbShipIRQLine3
					jmp EndIRQ

GubbShipIRQLine3:	pha
					txa
					pha
					tya
					pha
					inc $d019
					lda GubbShipYpos
					clc 
					adc #21*2
					jsr StoreSpriteYpos
						ldx #0
						ldy #(spr_GubbShip/64)+10
!:						tya
						sta Screen0+$3f8,x
//						lda #1 //lda GubbShipLaneCol+i
//						sta $d027,x
						iny
						inx
						cpx #5
						bne !-
											ldx #20
!:					dex
					bpl !-
					ldx #4
!:					lda GubbShipLaneCol+10,x
					sta $d027,x
					dex
					bpl !-
					lda #14 // HERE
					sta $d025
					lda #15
					sta $d026

					lda GubbShipYpos
					clc
					adc #21*3-7
					ldx #<GubbShipIRQLine4
					ldy #>GubbShipIRQLine4
					jmp EndIRQ

GubbShipIRQLine4:	pha
					txa
					pha
					tya
					pha
					inc $d019
					lda GubbShipYpos
					clc 
					adc #21*3
					jsr StoreSpriteYpos
						ldx #0
						ldy #(spr_GubbShip/64)+15
!:						tya
						sta Screen0+$3f8,x
						iny
						inx
						cpx #5
						bne !-
					lda GubbShipYpos
					clc
					adc #21*3-1
					ldx #<GubbShipIRQLine5
					ldy #>GubbShipIRQLine5
					jmp EndIRQ

GubbShipIRQLine5:	pha
					txa
					pha
					tya
					pha
					inc $d019
					ldx #4
					lda #3
!:					sta $d027,x
					dex
					bpl !-
					lda #14
					sta $d025
					lda #6
					sta $d026

					lda FLAG_EnableBeam
					bne !+
					lda #0
					sta $d00a
					sta $d00c
					sta $d00e
					jmp SkipEnableBeam
!:
beamcols:			lda #4
					sta $d02c
					sta $d02d
					sta $d02e
					lda $d010
					and #%00011111
					sta $d010
					lda #spr_Beam/64
					sta Screen0+$3fd
					sta Screen0+$3fe
					sta Screen0+$3ff
					lda GubbShipYpos
					clc
					adc #21*3+10
					sta $d00b
					clc
					adc #42
					sta $d00d
					clc
					adc #42
					sta $d00f
					lda #$be
					sta $d00a
					sta $d00c
					sta $d00e

					lda #%11100000
					sta $d017
					lda #%11111111
					sta $d01c
SkipEnableBeam:

					lda GubbShipYpos
					clc
					adc #21*4-9
					ldx #<GubbShipIRQLine6
					ldy #>GubbShipIRQLine6
					jmp EndIRQ

GubbShipIRQLine6:	pha
					txa
					pha
					tya
					pha
					inc $d019
					ldx #0
					ldy #(spr_GubbShip/64)+20
!:					tya
					sta Screen0+$3f8,x
					lda #3 //lda GubbShipLaneCol+i
					sta $d027,x
					iny
					inx
					cpx #5
					bne !-

					lda GubbShipYpos
					clc
					adc #21*4
					ldx #<GubbShipIRQLine7
					ldy #>GubbShipIRQLine7
					jmp EndIRQ

GubbShipIRQLine7:	pha
					txa
					pha
					tya
					pha
					inc $d019	
					lda FLAG_EnableSpaceGuy
					beq !+
SpaceGuyYpos:		lda #$cb 	// SpaceGuy
					sta $d001
					clc
					adc #21
					sta $d003
					lda #$be
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
					lda #0
					sta $d010
!:
					jsr puffer1
					jsr puffer2
					jsr puffer3
					jmp ReturnGubbShipIRQ // Return to Main IRQ code

// -----------------------------------------------------------

puffer1:			lda delay1
					cmp #5
					beq !+
					inc delay1
					rts
delay1:				.byte 0
!:					lda #0
					sta delay1
					ldy #0
puffcnt1:			ldx #0
					lda Puffanim1,x
					tax
!:					lda PuffGfx,x
					sta spr_Spaceship+$240+17,y
					lda PuffGfx+32,x
					sta spr_Spaceship+$240+17+24,y
					inx
					iny
					iny
					iny
					cpy #8*3
					bne !-
					lda puffcnt1+1
					clc
					adc #1
					and #7
					sta puffcnt1+1
					rts

puffer2:			lda delay2
					cmp #3
					beq !+
					inc delay2
					rts
delay2:				.byte 0
!:					lda #0
					sta delay2
					ldy #0
puffcnt2:			ldx #0
					lda Puffanim1,x
					tax
					lda PuffGfx+64,x
					sta spr_Spaceship+$380+54+5,y
					lda PuffGfx+64+1,x
					sta spr_Spaceship+$380+54+8,y
!:					lda PuffGfx+64+2,x
					sta spr_Spaceship+$380+2,y
					lda PuffGfx+64+4,x
					sta spr_Spaceship+$380+8,y
					inx
					iny
					iny
					iny
					cpy #3*3
					bne !-

					lda puffcnt2+1
					cmp #5
					beq !+
					inc puffcnt2+1
					rts
!:					lda #0
					sta puffcnt2+1
					rts

puffer3:			lda delay3
					cmp #5
					beq !+
					inc delay3
					rts
delay3:				.byte 0
!:					lda #0
					sta delay3
					ldy #0
puffcnt3:			ldx #4
					lda Puffanim1,x
					tax
!:					lda PuffGfx+96,x
					sta spr_Spaceship+$380+18+2,y
					lda PuffGfx+96+1,x
					sta spr_Spaceship+$380+18+2+3,y
					lda PuffGfx+96+32,x
					sta spr_Spaceship+$380+18+24+2,y //+$240+57,y
					inx
					iny
					iny
					iny
					cpy #7*3
					bne !-
					lda puffcnt3+1
					clc
					adc #1
					and #7
					sta puffcnt3+1
					rts

PuffGfx:			.import c64 "Graphics\GubbShip\Puffs_mc.prg"
Puffanim1:			.byte 0,8,16,24,0,0,0,0

// -----------------------------------------------------------

GubbShipLaneCol:	.fill 5,9
					.fill 5,15
					.byte 7,6,6,6,6 //7,15,7,13,15
					.fill 10,6

// -----------------------------------------------------------

MoveIn:				ldx #0
					lda GubbShipInXhi,x
					beq !+
					cmp #255
					beq InPosition
					lda #%00011111
!:					sta GubbShipXposHi
					lda GubbShipInY,x
					clc
					adc #21
					sta GubbShipYpos
					lda GubbShipInXlo,x
					sta GubbShipXpos
					clc
					adc #24
					bcc !+
					lda GubbShipXposHi
					ora #%00011110
					sta GubbShipXposHi
!:					clc
					adc #24
					bcc !+
					lda GubbShipXposHi
					ora #%00011100
					sta GubbShipXposHi
!:					clc
					adc #24
					bcc !+
					lda GubbShipXposHi
					ora #%00011000
					sta GubbShipXposHi
!:					clc
					adc #24
					bcc !+
					lda GubbShipXposHi
					ora #%00010000
					sta GubbShipXposHi
!:					inc MoveIn+1
					lda GubbShipXpos
					jsr GubbSprPosX
					lda GubbShipXposHi
					sta $d010
					rts
InPosition:			lda #0
					sta FLAG_GubbShipMoveIn
					lda #1
					sta FLAG_GubbShipHover
					jmp Hover

GubbSprPosX:		sta $d000
					clc
					adc #24
					sta $d002
					clc
					adc #24
					sta $d004
					clc
					adc #24
					sta $d006
					clc
					adc #24
					sta $d008
					rts
// -----------------------------------------------------------

MoveOut:			lda GubbShipYpos
					sta BaseYpos
					lda #$ea 
					sta MoveOut+3
					sta MoveOut+4
					sta MoveOut+5
GSYCnt:				ldx #0
					lda GubbShipOutY,x
					cmp #255
					beq ExitComplete
					lda BaseYpos
					sec 
					sbc #40
					clc
					adc GubbShipOutY,x
					sta GubbShipYpos

					lda GubbShipOutX,x
					clc
					adc #24
					jsr GubbSprPosX
					inc GSYCnt+1

					lda GubbShipOutOff,x
					sta $d010
					rts

ExitComplete:		lda #0
					sta FLAG_GubbShipMoveOut
					sta FLAG_EnableGubbShipIRQ
					rts
BaseYpos:			.byte 0
GubbShipOutX:
.byte 111,112,112,112,112,112,111,111,110,109,108,106,105,103,101,98,96,93,90,87,83,80,76,71,67,62,57,52,46,40,34,27,21,13,6
.byte -2,-10,-19,-28,-37,-47,-58,-68,-80,-92,-105,-118,-125

GubbShipOutOff:
.fill 38,0
.byte  1,  1,  1,  3,  3,  7,  7,  255,255,255,255,255


// -----------------------------------------------------------

Hover:				ldx #0
					lda sinehover,x
					clc
					adc #40+21-2
					sta GubbShipYpos
					lda GubbShipOutX
					clc
					adc #24
					jsr GubbSprPosX
					jsr SpaceGuySeq
x:					lda #0
					cmp #3
					beq !+
					inc x+1
					rts
!:					lda #0
					sta x+1
					inc Hover+1
					lda Hover+1
					clc
					adc #1
					and #31
					sta Hover+1
					rts
sinehover:			.fill 32, 2 + 2*sin(toRadians(i*360/32))

GubbShipInY:
.byte 10,11,13,14,16,17,18,19,20,21,23,24,25,25,26,27,28,29,30,30,31,32,32,33,33,34,34,35,35,35,36,36,36,37,37,37,37,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,37,37,37,37,37,37
.byte 36,36,36,36,36,36,35,35,35,35,35,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,35,35,35,36,37,37,38,39,40

GubbShipInXlo:
.byte <322+24,<319+24,<316+24,<312+24,<309+24,<306+24,<303+24,<299+24,<296+24,<293+24,<289+24,<286+24,<283+24,<280+24,<276+24,<273+24,<270+24,<266+24,<263+24,<260+24,<257+24,<254+24,<250+24,<247+24,<244+24,<241+24,<238+24,<235+24,<232+24,<229+24,<226+24,<223+24,<220+24,<217+24,<214+24,<211+24,<208+24,<205+24,<202+24,<200+24,<197+24,<194+24,<192+24,<189+24,<187+24,<184+24,<181+24,<179+24,<177+24,<174+24,<172+24,<170+24,<167+24,<165+24,<163+24,<161+24,<159+24,<157+24,<155+24,<153+24,<151+24,<149+24,<147+24,<145+24,<143+24,<142+24,<140+24,<138+24,<137+24
.byte <135+24,<134+24,<132+24,<131+24,<129+24,<128+24,<127+24,<126+24,<124+24,<123+24,<122+24,<121+24,<120+24,<119+24,<118+24,<117+24,<117+24,<116+24,<115+24,<115+24,<114+24,<113+24,<113+24,<113+24,<112+24,<112+24,<111+24,<111+24,<111+24

GubbShipInXhi:
.byte >322+24,>319+24,>316+24,>312+24,>309+24,>306+24,>303+24,>299+24,>296+24,>293+24,>289+24,>286+24,>283+24,>280+24,>276+24,>273+24,>270+24,>266+24,>263+24,>260+24,>257+24,>254+24,>250+24,>247+24,>244+24,>241+24,>238+24,>235+24,>232+24,>229+24,>226+24,>223+24,>220+24,>217+24,>214+24,>211+24,>208+24,>205+24,>202+24,>200+24,>197+24,>194+24,>192+24,>189+24,>187+24,>184+24,>181+24,>179+24,>177+24,>174+24,>172+24,>170+24,>167+24,>165+24,>163+24,>161+24,>159+24,>157+24,>155+24,>153+24,>151+24,>149+24,>147+24,>145+24,>143+24,>142+24,>140+24,>138+24,>137+24
.byte >135+24,>134+24,>132+24,>131+24,>129+24,>128+24,>127+24,>126+24,>124+24,>123+24,>122+24,>121+24,>120+24,>119+24,>118+24,>117+24,>117+24,>116+24,>115+24,>115+24,>114+24,>113+24,>113+24,>113+24,>112+24,>112+24,>111+24,>111+24,>111+24
.byte 255

GubbShipOutY:
.byte 40,41,41,41,42,42,42,42,43,43,43,43,43,43,43,43,42,42,42,42,42
.byte 41,41,40,40,40,39,39,38,37,37,36,35,34,33,33,32,31,29,28,27,26
.byte 25,23,22
.byte 255

// -------------------------------------------------------------------

SpaceGuySeq:		lda #0
animspeed:			cmp #4
					beq !+
					inc SpaceGuySeq+1
					rts
!:					lda #0
					sta SpaceGuySeq+1
					lda #$60
					sta SpaceGuy.Execute // Disable any other updates
WaveCnt:			ldx #0
					cpx #28
					bne !+
					lda #1
					sta animspeed+1
!:					lda WaveData,x
					cmp #0
					beq donewaving
					tax
					jsr SpaceGuy.SetSpaceGuyFrame
					inc WaveCnt+1
					rts
donewaving:			lda #$60
					sta SpaceGuySeq
					rts

WaveData:			.byte 14,14,14,14
					.byte 15,16,17,18,19,20,19,18,17,18,19,20,19,18,17,18,19,20,19,18,17
					.byte 16,15
					.byte 14,14,21,21,14,14,22,22
					.byte 14,14,21,21,14,14,22,22
					.byte 14,14,21,21,14,14,22,22
					.byte 14,14,21,21,14,14,22,22
					.byte 14
					.byte 0

SpaceGuyExit: 		lda FLAG_BeamUp
					bne SGUp
					rts
SGUp:				lda #0
					cmp #4
					beq !+
					inc SGUp+1
					rts
!:					lda #0
					sta SGUp+1
WaveCnt2:			ldx #0
					lda Foldframes,x
					cmp #255
					beq donebeamup
					tax
					jsr SpaceGuy.SetSpaceGuyFrame
					inc WaveCnt2+1
					dec SpaceGuyYpos+1
					rts
donebeamup:			ldx #80
					cpx #0
					beq TotallyDone
//					lda SpaceGuyYpos+1
//					clc
					lda SpaceGuy.tumbleypos,x
					clc
					adc #16
					sta SpaceGuyYpos+1
					lda #4
					sta SGUp+1
					dec donebeamup+1
					dec donebeamup+1
					rts
TotallyDone:		lda #0
					sta FLAG_EnableSpaceGuy
					rts

Foldframes:			.byte 13,13,13,13
					.fill 4,12
					.fill 4,11
					.fill 4,10
					.fill 4,9
					.fill 4,8
					.byte 7,6,5,4,3,2,1,1,2,3
					.byte 255
}
