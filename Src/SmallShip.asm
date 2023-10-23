.namespace SmallShip {

FLAG_FlySmallShip:	.byte 0
FLAG_LeaveSmallShip:	.byte 0

Exit:				lda #1
					sta FLAG_LeaveSmallShip
					rts

Enter:				lda #1
					sta FLAG_FlySmallShip
					rts

Execute:			lda #$88
					sta rasterMissile+1
					lda #9
					sta $d025
					lda #15
					sta $d026
					lda #8
					sta $d02b
					sta $d02c
					sta $d02d
					sta $d02e
					lda $d010
					and #%11000000
					sta $d010
					lda #$00
					sta $d017
					sta $d01d
					lda #$ff
					sta $d01c
					lda FLAG_FlySmallShip
					cmp #1
					beq EnterShip
					lda FLAG_LeaveSmallShip
					cmp #1
					beq ExitShip
					rts
ExitShip:
					lda #$8c
					sta rasterMissile+1

MoveCnt2:			ldx #104
					cpx #0
					beq ExitDone
					lda xpos,x
					sec 
					sbc #12
					sta $d008
					lda ypos,x
					clc
					adc #40
					sta $d009
					dec MoveCnt2+1
					jmp DrawShip
ExitDone:			lda #$80
					sta rasterMissile+1
					lda #0
					sta FLAG_LeaveSmallShip
					lda #104
					sta MoveCnt2+1
					rts

EnterShip:
MoveCnt:			ldx #0
					lda xpos,x
					cmp #0
					bne ContinueMove
					jmp FlyDone
ContinueMove:		sec 
					sbc #12
					sta $d008
					lda ypos,x
					clc
					adc #40
					sta $d009
					inc MoveCnt+1

DrawShip:			lda #0
					sta $d00a // not updated every frame, so reset
					lda SprPtrs,x
					cmp #0
					beq spr1
					cmp #1
					beq spr2
					cmp #2
					beq spr3
					cmp #3
					bne !+
					jmp spr4
!:					cmp #4
					bne !+
					jmp spr5
!:					cmp #5
					bne !+
					jmp spr6
!:					cmp #6
					bne !+
					jmp spr7
!:					cmp #7
					bne !+
					jmp spr8
!:					cmp #8
					bne !+
					jmp spr9
!:					cmp #9
					bne !+
					jmp spr10
					cmp #10
					bne !+
!:					jmp spr11
					cmp #11
					bne !+
					jmp spr12					
!:					rts
spr1:				lda #spr_smallship/64
					sta Screen0+$3fc
					rts
spr2:				lda #spr_smallship/64+1
					sta Screen0+$3fc
					rts
spr3:				lda #spr_smallship/64+2
					sta Screen0+$3fc
					rts
spr4:				lda #spr_smallship/64+3
					sta Screen0+$3fc
					rts
spr5:				ldx #spr_smallship/64+4
					stx Screen0+$3fc
					inx
					stx Screen0+$3fd
					lda $d008
					sec
					sbc #12
					sta $d008
					clc
					adc #24
					sta $d00a
					lda $d009
					sta $d00b
					rts
spr6:				ldx #spr_smallship/64+6
					stx Screen0+$3fc
					inx
					stx Screen0+$3fd
					lda $d008
					sec
					sbc #12
					sta $d008
					clc
					adc #24
					sta $d00a
					lda $d009
					sta $d00b
					rts
spr7:				ldx #spr_smallship/64+8
					stx Screen0+$3fc
					inx
					stx Screen0+$3fd
					lda $d008
					sec
					sbc #12
					sta $d008
					clc
					adc #24
					sta $d00a
					lda $d009
					sta $d00b
					rts
spr8:				ldx #spr_smallship/64+10
					stx Screen0+$3fc
					inx
					stx Screen0+$3fd
					lda $d008
					sec
					sbc #12
					sta $d008
					clc
					adc #24
					sta $d00a
					lda $d009
					sta $d00b
					rts
spr9:				ldx #spr_smallship/64+12
					stx Screen0+$3fc
					inx
					stx Screen0+$3fd
					lda $d008
					sec
					sbc #12
					sta $d008
					clc
					adc #24
					sta $d00a
					lda $d009
					sta $d00b
					rts
spr10:				ldx #spr_smallship/64+14
					stx Screen0+$3fc
					inx
					stx Screen0+$3fd
					lda $d008
					sec
					sbc #12
					sta $d008
					clc
					adc #24
					sta $d00a
					lda $d009
					sta $d00b
					rts

spr11:				ldx #spr_smallship/64+16
					stx Screen0+$3fc
					inx
					stx Screen0+$3fd
					ldx #spr_smallship/64+20
					stx Screen0+$3fe
					inx
					stx Screen0+$3ff
					lda $d008
					sec
					sbc #12
					sta $d008
					sta $d00c
					clc
					adc #24
					sta $d00a
					sta $d00e
					lda $d009
					sec 
					sbc #10
					sta $d009
					sta $d00b
					clc
					adc #21
					sta $d00d
					sta $d00f
					rts
spr12:				ldx #spr_smallship/64+18
					stx Screen0+$3fc
					inx
					stx Screen0+$3fd
					ldx #spr_smallship/64+22
					stx Screen0+$3fe
					inx
					stx Screen0+$3ff
					lda $d008
					sec
					sbc #12
					sta $d008
					sta $d00c
					clc
					adc #24
					sta $d00a
					sta $d00e
					lda $d009
					sec 
					sbc #10
					sta $d009
					sta $d00b
					clc
					adc #21
					sta $d00d
					sta $d00f
					rts

SprPtrs:			.fill 10,0
					.fill 10,1
					.fill 10,2
					.fill 10,3
					.fill 5,4
					.fill 5,5
					.fill 5,6
					.fill 5,7
					.fill 5,8
					.fill 5,9
					.fill 5,10
					.fill 30,11

xpos: 				.byte 17,18,20,21,22,24,25,26,27,29,30,31,33,34,35,36,38,39,40,42,43,44,46,47,48,50,51,52,54,55,56,58,59,60,62,63,65,66,67,69,70,72,73,74,76,77,79,80,82,83,85,86,88,89,91,92,94,96,97,99,100,102,104,105,107,109,111,113,115,118,120,122,124,126,128,130,132,134,136,138,139,141,143,145,147,148,150,152,153,155,157,158,160,162,163,165,167,168,170,172,173,175,177
					.byte 0
ypos: 				.byte 63,63,64,64,64,65,65,65,66,66,67,67,67,68,68,69,69,70,70,70,71,71,72,72,72,73,73,74,74,74,75,75,76,76,76,77,77,77,78,78,78,78,79,79,79,79,80,80,80,80,80,80,80,80,80,80,80,80,80,79,79,79,78,78,77,76,75,73,72,70,68,66,64,61,59,57,54,51,49,46,44,41,38,35,33,30,27,24,21,18,16,13,10,7,4,1,-2,-5,-8,-11,-14,-17,-20


FlyDone:			lda #$80
					sta rasterMissile+1
					lda #0
					sta FLAG_FlySmallShip
					sta MoveCnt+1
					rts

}
