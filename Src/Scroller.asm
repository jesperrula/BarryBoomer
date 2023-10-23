.namespace Scroller {

.const zp_rasterpos = $20
.const zp_spritelinecnt = $21
.const zp_charsrc = $22 // + $23
.const zp_chardst = $24 // + $25

FLAG_EnableScrollerIRQ:	.byte 0
FLAG_EnableScroller: .byte 0

ScrollColor:		.byte 1

.const ScrollPtr_location = $0200

EnableScroller:		lda #1
					sta FLAG_EnableScroller
					rts

EnableIRQ:			ldx #0
					txa
!:					sta spr_Scroller,x
					sta spr_Scroller+$200,x
					sta spr_Scroller+$400,x
					sta spr_Scroller+$600,x
					sta spr_Scroller+$800,x
					sta spr_Scroller+$a00,x
					sta spr_Scroller+$c00,x
					sta spr_Scroller+$e00,x
					sta spr_Scroller+$1000,x
					inx
					bne !-
!:					sta spr_Scroller+$100,x
					sta spr_Scroller+$300,x
					sta spr_Scroller+$500,x
					sta spr_Scroller+$700,x
					sta spr_Scroller+$900,x
					sta spr_Scroller+$b00,x
					sta spr_Scroller+$d00,x
					sta spr_Scroller+$f00,x
					sta spr_Scroller+$1100,x
					inx
					cpx #63
					bne !-

					ldx #0
					lda #spr_Scroller/64
!:					sta ScrollPtr_location,x
					clc
					adc #1
					inx
					cpx #9*9
					bne !-

					lda #1
					sta FLAG_EnableScrollerIRQ
					rts

ypos:				.byte 50

// -----------------------------------------------------------------

IRQ:				lda $d01c
					and #%11000000
					sta $d01c
					lda Drummer.FLAG_zzz
					beq nozzz
zzzypos:			lda #$a6
					sta $d00b
zzzxpos:			lda #0
					sta $d00a
					lda #<spr_platform/64
					sta Screen0+$3fd
zzzcol:				lda #0
					sta $d02c
					jsr Movezzz
nozzz:
					lda ypos
					sta $d001 
					sta $d003 
					sta $d005 
					sta $d007 
					sta $d009
					clc
					adc #22
					sta zp_rasterpos
					lda #0-40-44
					sta $d000
					lda #24-40-44
					sta $d002 
					lda #48-40-44
					sta $d004
					lda #48+24-40-44
					sta $d006 
					lda #48+48-40-44
					sta $d008 
					lda $d010
					ora #%00010000
					sta $d010
					ldx #4
!:					lda ScrollColor
					sta $d027,x
					lda ScrollPtr_location,x
					sta Screen0+$3f8,x
					dex
					bpl !-
					
					ldx #0
RepeatSprites:		stx zp_spritelinecnt

					lda zp_rasterpos
					ldx #<SpritesIRQ
					ldy #>SpritesIRQ
					jmp EndIRQ

SpritesIRQ:			pha
					txa
					pha
					tya
					pha
					inc $d019
					ldx zp_rasterpos
					inx
					inx
					inx
					stx $d001
					stx $d003
					stx $d005
					stx $d007
					stx $d009
					ldx zp_spritelinecnt
					inx
					txa
					asl
					asl
					asl
					tay
					ldx #0
!:					lda ScrollPtr_location,y
					sta Screen0+$3f8,x
					iny
					inx
					cpx #5
					bne !-

					lda zp_rasterpos
					clc
					adc #25
					sta zp_rasterpos

					lda zp_spritelinecnt
					cmp #5 ///////////////////// if I need to move vsync, this is where
					bne !+
					lda #1
					sta FLAG_vsync
!:
					ldx zp_spritelinecnt
					inx
					cpx #8 // Number of rows
					bne RepeatSprites
					jmp ReturnFromScroller //NextIRQ,0

// ---------------------------------------------------------------------

Scroll:				lda FLAG_EnableScroller
					bne !+
					rts
!:					lda #0
					cmp #1
					beq slowscr
					inc !-+1
					rts
slowscr:			lda #0
					sta !-+1
					lda ypos
					cmp #50-12
					beq plotline2
					cmp #50-24
					beq NextLine
					dec ypos
					rts
plotline2:			dec ypos
					jmp PlotNextLine					

NextLine:			jsr PlotNextLine
					lda #50
					sta ypos
					ldx #4
!:					lda ScrollPtr_location,x
					sta ScrollPtr_location+72,x
					lda ScrollPtr_location+8,x
					sta ScrollPtr_location,x
					lda ScrollPtr_location+16,x
					sta ScrollPtr_location+8,x
					lda ScrollPtr_location+24,x
					sta ScrollPtr_location+16,x
					lda ScrollPtr_location+32,x
					sta ScrollPtr_location+24,x
					lda ScrollPtr_location+40,x
					sta ScrollPtr_location+32,x
					lda ScrollPtr_location+48,x
					sta ScrollPtr_location+40,x
					lda ScrollPtr_location+56,x
					sta ScrollPtr_location+48,x
					lda ScrollPtr_location+64,x
					sta ScrollPtr_location+56,x
					lda ScrollPtr_location+72,x
					sta ScrollPtr_location+64,x
					dex
					bpl !-
					rts

scrolldstlo:		.fill 9,<spr_Scroller+(i*512)
scrolldsthi:		.fill 9,>spr_Scroller+(i*512)
scrolldstlo2:		.fill 9,<spr_Scroller+(i*512)+36
scrolldsthi2:		.fill 9,>spr_Scroller+(i*512)+36

SetDestination:		lda #0
					bne OddLines
pnl1:				ldx #0
					lda scrolldstlo,x
					sta chardst+1
					sta chardstlo2+1

					lda scrolldsthi,x
					sta chardst+2
					sta chardsthi2+1

					ldx pnl1+1
					inx
					cpx #9
					bne !+
					ldx #0
!:					stx pnl1+1
					inc SetDestination+1
					rts
OddLines:
pnl2:				ldx #0
					lda scrolldstlo2,x
					sta chardst+1
					sta chardstlo2+1

					lda scrolldsthi2,x
					sta chardst+2
					sta chardsthi2+1

					ldx pnl2+1
					inx
					cpx #9
					bne !+
					ldx #0
!:					stx pnl2+1
					dec SetDestination+1
					rts

PlotNextLine:		
					jsr SetDestination

TextPtr:			ldx Text // get char
					cpx #0
					beq linedone

					cpx #255
					bne !+

					lda #<Text 	// reset scroller
					sta TextPtr+1
					lda #>Text
					sta TextPtr+2
					lda #0
					sta dstindex
					jmp TextPtr
!:

					lda CharMap,x // find in charmap
					tax
					lda CharSrclo,x
					sta charsrc+1
					lda CharSrchi,x
					sta charsrc+2

					ldy #7
					ldx #7*3
!:
charsrc:			lda $1234,y
chardst:			sta $1234,x
					dey
					dex
					dex
					dex
					bpl !-

					inc dstindex
chardstlo2:			lda #<spr_Scroller
					sta chardst+1
chardsthi2:			lda #>spr_Scroller
					sta chardst+2
					ldx dstindex
					lda chardst+1
					clc
					adc dstindexlo,x
					sta chardst+1
					lda chardst+2
					adc dstindexhi,x
					sta chardst+2
					jsr NextChar
					jmp TextPtr

linedone:			lda #0
					sta dstindex
NextChar:			lda TextPtr+1
					clc
					adc #1
					sta TextPtr+1
					lda TextPtr+2
					adc #0
					sta TextPtr+2
					rts

dstindex:			.byte 0
dstindexlo:			.byte 0,1,2, 64,65,66, 128,129,130, 192,193,194, 0,1,2
dstindexhi:			.byte 0,0,0,    0,0,0,       0,0,0,       0,0,0, 1,1,1

// -------------------------------------------

Movezzz:
q:					lda #0
					cmp #3
					beq !+
					inc q+1
					rts
!:					lda #0
					sta q+1
sincnt:				ldx #0
					lda #$38
					clc
					adc zsin,x
					sta zzzxpos+1
					lda zzzcolors,x
					sta zzzcol+1
					lda sincnt+1
					cmp #23
					bne !+
					lda #$a6
					sta zzzypos+1
					lda #$ff
					sta sincnt+1
!:					inc sincnt+1
					dec zzzypos+1
					rts
zsin:				.fill 24, 3 + 3*sin(toRadians(i*360/24))
zzzcolors:			.byte 15,15,3,3,14,14,6,6
					.fill 16,0
.pc = $0668 "Scroll data"

					//    "123123123123123"
Text:				.text " a celebration @"
					.text "of the classic @"
					.text " trap demo by  @"
					.text " the legendary @"
					.text "   ratt+benn   @"
					.text "               @"
					.text "     +++++     @"
					.text "               @"
					.text "  released at  @"
					.text " gubbdata 2021 @"
					.text "               @"
					.text "     +++++     @"
					.text "               @"
					.text "    made by    @"
					.text "3 guys who are @"
					.text "getting gubbier@"
					.text " by the minute @"
					.text "               @"
					.text "     +++++     @"
					.text "               @"
					.text "  endorsed by  @"
					.text "     ratt      @"
					.text "               @"
					.text "     +++++     @"
					.text "               @"

					.byte 255
.pc = $1e98 "Scroll data"
CharSrclo:			.fill 40,<Font+(i*8)
CharSrchi:			.fill 40,>Font+(i*8)
CharMap:			.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,0,0,0,0,0
					.byte 0,0,0,0,0,0,0,0,0,0,0,39,38,40,37,41,36,27,28,29,30,31,32,33,34,35
}
