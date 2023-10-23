.namespace SpritePusher {

NumOfSprites:		.byte 0
Source:				.word 0
Destination:		.word 0
FLAG_Execute:		.byte 0

Init:				lda #1
					sta FLAG_Execute
					rts

Done:				lda #0
					sta FLAG_Execute
					rts

Execute:			lda FLAG_Execute
					cmp #1
					beq !+
					rts
!:					ldx NumOfSprites
					cpx #0
					beq Done
					dex
					lda Source
					clc
					adc Mul64lo,x
					sta CopySrc+1
					lda Source+1
					adc Mul64hi,x
					sta CopySrc+2
					lda Destination
					clc
					adc Mul64lo,x
					sta CopyDst+1
					lda Destination+1
					adc Mul64hi,x
					sta CopyDst+2
					lda #$30
					sta $01
					ldx #63
CopySrc:			lda $1234,x
CopyDst:			sta $1234,x
					dex
					bpl CopySrc
					lda #$35
					sta $01
					dec NumOfSprites
					rts

Mul64lo:			.fill 32,<i*64
Mul64hi:			.fill 32,>i*64
}
