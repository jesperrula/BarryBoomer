.function CalcFontScreen(Font, Screen) {
	.return ((Screen & $3c00)/64) + ((Font & $3800)/1024)
}

.function CalcBank(Adr) {
	.return $3c+(Adr/$4000)
}

.macro StoryboardEntry(code, time, runstatus) {
	.word code, time
	.byte runstatus
}

.macro EndStoryboardTable() {
	StoryboardEntry(0, $ffff, 0)
}

.macro SetXXAA(val) {
	lda #<val
	ldx #>val
}

.macro SetupFontScreen(Font, Screen) {		// Sets both VIC_ScreenMemory and BankSelect
	lda #CalcFontScreen(Font, Screen)
	sta $d018

	lda #CalcBank(Screen)
	sta $dd00
}

.macro CopyBlocks(from, to, len) {
	lda #>from
	ldx #>to
	ldy #>len
	jsr DEMOSYS_CopyBlocks
}

.macro StoryboardInit(StoryboardLocation) {
	SetXXAA(StoryboardLocation)
	jsr DEMOSYS_StoryboardInit
}

/**********************************************************************
							Copy blocks
**********************************************************************&

/*
		Copies block (a number of $100 bytes blocks starting in $xx00)
		from source A to destination X for a total of Y blocks

		E.g.

			lda #$90		// Copy from $9000
			ldx #$10		// Copy to $1000
			ldy #$12		// Copy 18 blocks ($1200 bytes)

*/
DEMOSYS_CopyBlocks:	sta internal_CopyFrom+2
					stx internal_CopyTo+2
					ldx #0
internal_CopyFrom:	lda $9000,x
internal_CopyTo:	sta $1000,x
					inx
					bne internal_CopyFrom
					inc internal_CopyFrom+2
					inc internal_CopyTo+2
					dey
					bne internal_CopyFrom
					rts

DEMOSYS_CheckDemoCounter:
						cpx DemocounterMSB
						beq internal_CDC2				// same, check LSB
						bcc internal_ReturnTrue			// Larger, set carry
internal_ReturnFalse:	clc								// Smaller, clear carry
						rts

internal_ReturnTrue:	sec
						rts

internal_CDC2:			cmp DemocounterLSB				// same MSB, check LSB
						beq internal_ReturnTrue			// same LSB, set carry
						bcc internal_ReturnTrue         // Larger, set carry
						jmp internal_ReturnFalse		// Smaller, clear carry

DEMOSYS_StoryboardInit:
					sta internal_SBZP
					stx internal_SBZP+1
					lda #160			// LDY #
					sta DEMOSYS_StoryboardExecute
					lda #96				// RTS
					sta internal_NotReached
					rts

DEMOSYS_StoryboardExecute:	rts ; .byte 3		// Is replaced with LDY # when initialized
					lda (internal_SBZP),y
					tax
					dey
					lda (internal_SBZP),y		// Timecode is now in XXAA
					jsr DEMOSYS_CheckDemoCounter
					bcc internal_NotReached
					dey
					lda (internal_SBZP),y		// hi byte of storyboard code
					sta internal_NotReached+2
					bne !+						// if zero disable storyboard

					lda #96						// RTS
					sta DEMOSYS_StoryboardExecute
					rts

!:					dey
					lda (internal_SBZP),y		// low byte of storyboard code
					sta internal_NotReached+1

					ldx #76						// JMP
					stx internal_NotReached
					ldy #4
					lda (internal_SBZP),y		// Runmode from storyboard code (0 = run once)
					bne !+

					ldx #96						// RTS when runmode is once

!:					stx internal_RunMode+1

					lda internal_SBZP
					clc
					adc #5
					sta internal_SBZP
					bcc !+

					inc internal_SBZP+1

!:					jsr internal_NotReached		// Run once

internal_RunMode:	lda #169					// A value replaced with JMP or RTS opcode
					sta internal_NotReached		// Next runs
					rts

internal_NotReached: rts; .byte 0,0				// Replaced with JMP $xxxx or RTS depending on storyboard table
