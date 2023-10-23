//----------------------------------------------------------
// Code for creating the breakpoint file sent to Vice.
//----------------------------------------------------------
.var _useBinFolderForBreakpoints = cmdLineVars.get("usebin") == "true"
.var _createDebugFiles = cmdLineVars.get("afo") == "true"
.print "File creation " + [_createDebugFiles
    ? "enabled (creating breakpoint file)"
    : "disabled (no breakpoint file created)"]
.var brkFile
.if(_createDebugFiles) {
    .if(_useBinFolderForBreakpoints)
        .eval brkFile = createFile("bin/breakpoints.txt")
    else
        .eval brkFile = createFile("breakpoints.txt")
}
.macro break() {
.if(_createDebugFiles) {
    .eval brkFile.writeln("break " + toHexString(*))
    }
}

.pc = $0801 "Basic Upstart Program"
					:BasicUpstart($080d)

.pc = $080d "Code Main"
					lda #$50
					sta $d000
					sta $d002
					sta $d001
					clc
					adc #42
					sta $d003
					lda #spr_beam/64
					sta $07f8
					sta $07f9
					lda #$ff
					sta $d015
					sta $d01c
					sta $d017
//					sta $d01d
					lda #0
					sta $d020
					sta $d021
					lda #8
					sta $d025
					lda #15
					sta $d026
					lda #1
					sta $d027
					sta $d028
					jmp Main

Main:				lda $d012
					cmp #$d0
					bne Main
dec $d020
					jsr BeamAnim
inc $d020
					jmp Main

// --------------------------------------------------------------------------

BeamAnim:			jsr beam1
					jsr beam2
					jsr beam3
					ldx #21*3
!:					lda layer1,x
					ora layer2,x
					ora layer3,x
					sta spr_beam,x
					dex
					bpl !-
					rts

beam3:				lda layer3+61
					sta l3b2+1
					ldx #20*3
!:					lda layer3+1,x
					sta layer3+4,x
					dex
					dex
					dex
					bpl !-
l3b2:				lda #0
					sta layer3+1
					rts

beam2:				lda #0
					cmp #1
					beq !+
					inc beam2+1
					rts
!:					lda #0
					sta beam2+1
					lda layer2+60
					sta l2b1+1
					lda layer2+61
					sta l2b2+1
					lda layer2+62
					sta l2b3+1
					ldx #20*3
!:					lda layer2,x
					sta layer2+3,x
					dex
					bpl !-
l2b1:				lda #0
					sta layer2
l2b2:				lda #0
					sta layer2+1
l2b3:				lda #0
					sta layer2+2
					rts

beam1:				lda #0
					cmp #3
					beq !+
					inc beam1+1
					rts
!:					lda #0
					sta beam1+1
					lda layer1+60
					sta l1b1+1
					lda layer1+61
					sta l1b2+1
					lda layer1+62
					sta l1b3+1
					ldx #20*3
!:					lda layer1,x
					sta layer1+3,x
					dex
					bpl !-
l1b1:				lda #0
					sta layer1
l1b2:				lda #0
					sta layer1+1
l1b3:				lda #0
					sta layer1+2
					rts
randombitpos:			.byte %11000000,%00110000,%00001100,%00000011,0,0,0,0
layer1:				.byte 128,0,0
					.byte 0,0,64
					.byte 0,0,0
					.byte 0,96,0
					.byte 128,0,0
					.byte 0,0,64
					.byte 0,0,3
					.byte 0,96,0
					.byte 128,0,0
					.byte 0,0,64
					.byte 0,0,0
					.byte 0,96,0
					.byte 128,0,0
					.byte 0,0,64
					.byte 0,0,1
					.byte 0,96,0
					.byte 128,0,0
.fill 8,0
layer2:				.byte $f0,0,0,$f0,0,0,$f0,0,0,$f0,0,0
					.byte 0,0,0
					.byte 0,0,0
					.byte 0,0,0
					.byte 0,$0f,0,0,$0f,0,0,$0f,0,0,$0f,0
					.byte 0,0,0
					.byte 0,0,0
					.byte 0,0,0
					.byte $0f,0,0,$0f,0,0,$0f,0,0,$0f,0,0
					.byte 0,0,0
					.byte 0,0,0
					.byte 0,0,0
.fill 8,0
layer3:				.byte 0,255,0
					.byte 0,0,0
					.byte 0,%00111100,0
					.byte 0,0,0
.byte 0,255,0,0,0,0,0,%00111100,0,0,0,0
.byte 0,255,0,0,0,0,0,%00111100,0,0,0,0
.byte 0,255,0,0,0,0,0,%00111100,0,0,0,0
.byte 0,255,0,0,0,0,0,%00111100,0,0,0,0
.byte 0,255,0,0,0,0,0,%00111100,0,0,0,0
					.byte 0,0,0

.align $40
spr_beam:			.fill 64,0