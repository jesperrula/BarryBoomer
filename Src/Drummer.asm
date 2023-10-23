
// Masking when drumming is not working correctly

.namespace Drummer {
.var maskoffset = 0 // used to set offset for the masking

.const StarFieldColorDrummer = 8 // color for stars around drummer

.const Mask = StarFieldMask // For debugging only

FLAG_Sleep:			.byte 0
FLAG_Flex:			.byte 0
FLAG_Flex2rest:		.byte 0

Flex2rest:			lda #1
					sta FLAG_Flex2rest
					rts

Sleep:				lda #1
					sta FLAG_Sleep
					rts

Execute:			lda FLAG_Flex2rest
					beq !+
					jmp Flex2restexec
!:					lda FLAG_Sleep
					beq !+
					jmp PutToSleep // When sleeping, make sure nothing else is happening
!:					lda FLAG_Flex
					beq !+
					jmp Flex
!:					lda FLAG_EnableDrummer
					bne !+
					rts
!:					jmp Drumming

FLAG_EnableDrummer:		.byte 0

Enable:				lda #1
					sta FLAG_EnableDrummer
					rts

Disable:			lda #0
					sta FLAG_EnableDrummer
					rts

Flex2restexec:		lda #0
					cmp #3
					beq !+
					inc Flex2restexec+1
					rts
!:					lda #0
					sta Flex2restexec+1
					inc fl2recnt+1
fl2recnt:			lda #255
					cmp #0
					beq f2r1
					cmp #1
					beq f2r2
					cmp #2
					beq f2r3
					cmp #3
					beq f2r4
					cmp #4
					beq f2r5
					cmp #5
					beq f2r6
f2r1:				lda #$9d
					sta PrepGfxFlex+1
					jsr PrepGfxFlex
					jsr LeftArm_Frame3
					rts
f2r2:				jsr LeftArm_Frame4
					rts
f2r3:				jsr LeftArm_Frame6
					rts
f2r4:				jsr RightArm_Frame4
					rts
f2r5:				jsr RightArm_Frame6
					rts
f2r6:				lda #0
					sta FLAG_Flex2rest
					rts

// ----------------------------------------------------------------------------------

PrepGfxFlex:		lda #$ad
					sta clrleft1
					sta clrleft2
					sta clrleft3
					sta clrleft4
					sta clrleft5
					sta clrright1
					sta clrright2
					sta clrright3
					lda #$00
					sta $5804 // remove stray pixel from drummer right side
					lda #2
					sta $57e4
					rts
// ----------------------------------------------------------------------------------

PrepareFlex:		inc prepcnt+1
prepcnt:			lda #$ff
					cmp #0
					beq stance1
					cmp #4
					beq stance2
					cmp #8
					beq stance3
					rts
stance1:			jsr RightArm_Frame4
					jsr LeftArm_Frame4
					jmp PrepGfxFlex // Disable plotting the lowest line of the drummer
					
stance2:			jmp LeftArm_Frame3
stance3:			lda #$60
					sta PrepareFlex
					jmp LeftArm_Frame2

// ----------------------------------------------------------------------------------

Flex:				
					lda #0
					bne flexright
// left upper to low
flexleft:			
					inc flcnt+1
flcnt:				lda #255
					beq leftstance1
					cmp #4
					beq leftstance2
					rts
leftstance1:		jsr LeftArm_Frame3
					jmp RightArm_Frame3
leftstance2:		jsr LeftArm_Frame4
					jsr RightArm_Frame2
					lda #0
					sta FLAG_Flex
					lda #255
					sta flcnt+1
					lda Flex+1
					eor #1
					sta Flex+1
					rts

flexright:			inc frcnt+1
frcnt:				lda #255
					beq rightstance1
					cmp #4
					beq rightstance2
					rts
rightstance1:		jsr LeftArm_Frame3
					jmp RightArm_Frame3
rightstance2:		jsr LeftArm_Frame2
					jsr RightArm_Frame4
					lda #0
					sta FLAG_Flex
					lda #255
					sta frcnt+1
					lda Flex+1
					eor #1
					sta Flex+1
					rts

// ----------------------------------------------------------------------------------

RestInit:		 	lda #0
					sta AnimRestCnt+1
					rts

RestAnim:			
					lda #1
					sta FLAG_TempDrumBlock
AnimRestCnt:		ldx #19
					cpx #19
					beq !+
					lda AnimRest,x
					cmp #1
					beq rest1
					cmp #2
					beq rest2
					cmp #3
					beq rest3
					cmp #4
					beq rest4
					cmp #5
					beq rest5
!:					rts
rest1:				inc AnimRestCnt+1
					jsr RightArm_Frame1
					jmp LeftArm_Frame1
rest2:				inc AnimRestCnt+1
					jsr RightArm_Frame2
					jmp LeftArm_Frame2
rest3:				inc AnimRestCnt+1
					jsr RightArm_Frame3
					jmp LeftArm_Frame3
rest4:				inc AnimRestCnt+1
					jsr RightArm_Frame4
					jmp LeftArm_Frame4
rest5:				inc AnimRestCnt+1
					jsr RightArm_Frame6
					jmp LeftArm_Frame6

AnimRest:			.byte 1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,5

// ----------------------------------------------------------------------------------

RaiseArmsFromRest:	lda #11
					sta AnimSel2+1
					sta AnimSel+1
					rts

// ----------------------------------------------------------------------------------

Drumming:			
					lda FLAG_TempDrumBlock
					beq !+
					lda #0
					sta FLAG_TempDrumBlock
					rts
FLAG_TempDrumBlock: .byte 0
!:					lda EVENT_DrummerHit
					bne !+
go:					jsr AnimateLeftArm
					jmp AnimateRightArm

!:					lda #0
					sta EVENT_DrummerHit
					lda ArmSelector
					beq GoArmLeft
					lda #18
					sta AnimSel2+1
					lda ArmSelector
					eor #1
					sta ArmSelector
					jmp go
GoArmLeft:			lda #18
					sta AnimSel+1
					lda ArmSelector
					eor #1
					sta ArmSelector
					jmp go


ArmSelector:		.byte 0

// ------------------------------------------------------------------------

AnimateLeftArm:		
AnimSel:			ldx #0
					beq !+
					lda AnimSeq,x
					cmp #1
					beq la1
					cmp #2
					beq la2
					cmp #3
					beq la3
					cmp #4
					beq la4
					cmp #5
					beq la5
!:					rts
la1:				dec AnimSel+1
					jmp LeftArm_Frame1
la2:				dec AnimSel+1
					jmp LeftArm_Frame2
la3:				dec AnimSel+1
					jmp LeftArm_Frame3
la4:				dec AnimSel+1
					jmp LeftArm_Frame4
la5:				dec AnimSel+1
					jmp LeftArm_Frame5

AnimSeq:			.byte 1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,3

LeftArm_Frame1:		ldx #31
!:					lda Drummer1bit,x
					sta $4000+(13*320)+16,x
					lda Drummer1bit+(64*1),x
					sta $4000+(14*320)+16,x
					lda Drummer1bit+(64*2),x
					sta $4000+(15*320)+16,x
					lda Drummer1bit+(64*3),x
					sta $4000+(16*320)+16,x
					lda Drummer1bit+(64*4),x
					sta $4000+(17*320)+16,x
					lda Drummer1bit+(64*5),x
					sta $4000+(18*320)+16,x
					lda Drummer1bit+(64*6),x
					sta $4000+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda Drummer1Attr,x
					sta Screen0+(13*40)+2,x
					lda Drummer1Attr+8,x
					sta Screen0+(14*40)+2,x
					lda Drummer1Attr+16,x
					sta Screen0+(15*40)+2,x
					lda Drummer1Attr+24,x
					sta Screen0+(16*40)+2,x
					lda Drummer1Attr+32,x
					sta Screen0+(17*40)+2,x
					lda Drummer1Attr+40,x
					sta Screen0+(18*40)+2,x
					lda Drummer1Attr+48,x
					sta Screen0+(19*40)+2,x
					lda Drummer1Cols,x
					sta $d800+(13*40)+2,x
					lda Drummer1Cols+8,x
					sta $d800+(14*40)+2,x
					lda Drummer1Cols+16,x
					sta $d800+(15*40)+2,x
					lda Drummer1Cols+24,x
					sta $d800+(16*40)+2,x
					lda Drummer1Cols+32,x
					sta $d800+(17*40)+2,x
					lda Drummer1Cols+40,x
					sta $d800+(18*40)+2,x
					lda Drummer1Cols+48,x
					sta $d800+(19*40)+2,x
					dex
					bpl !-
					.eval maskoffset = 0
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+2,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+2,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+2,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+2,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+2,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+2,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+2,x
					dex
					bpl !-					
					rts

LeftArm_Frame2:
					ldx #31
!:					lda #0
					sta $4000+(13*320)+16,x
					lda Drummer2bit,x
					sta $4000+(14*320)+16,x
					lda Drummer2bit+(64*1),x
					sta $4000+(15*320)+16,x
					lda Drummer2bit+(64*2),x
					sta $4000+(16*320)+16,x
					lda Drummer2bit+(64*3),x
					sta $4000+(17*320)+16,x
					lda Drummer2bit+(64*4),x
					sta $4000+(18*320)+16,x
					lda Drummer2bit+(64*5),x
clrleft1:			sta $4000+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda #StarFieldColorDrummer
					sta Screen0+(13*40)+2,x
					lda Drummer2Attr,x
					sta Screen0+(14*40)+2,x
					lda Drummer2Attr+8,x
					sta Screen0+(15*40)+2,x
					lda Drummer2Attr+16,x
					sta Screen0+(16*40)+2,x
					lda Drummer2Attr+24,x
					sta Screen0+(17*40)+2,x
					lda Drummer2Attr+32,x
					sta Screen0+(18*40)+2,x
					lda Drummer2Attr+40,x
					sta Screen0+(19*40)+2,x
					lda Drummer2Cols,x
					sta $d800+(14*40)+2,x
					lda Drummer2Cols+8,x
					sta $d800+(15*40)+2,x
					lda Drummer2Cols+16,x
					sta $d800+(16*40)+2,x
					lda Drummer2Cols+24,x
					sta $d800+(17*40)+2,x
					lda Drummer2Cols+32,x
					sta $d800+(18*40)+2,x
					lda Drummer2Cols+40,x
					sta $d800+(19*40)+2,x
					dex
					bpl !-
					.eval maskoffset = 8
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+2,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+2,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+2,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+2,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+2,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+2,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+2,x
					dex
					bpl !-					
					rts

LeftArm_Frame3:
					ldx #31
!:					lda Drummer3bit,x
					sta $4000+(14*320)+16,x
					lda Drummer3bit+(64*1),x
					sta $4000+(15*320)+16,x
					lda Drummer3bit+(64*2),x
					sta $4000+(16*320)+16,x
					lda Drummer3bit+(64*3),x
					sta $4000+(17*320)+16,x
					lda Drummer3bit+(64*4),x
					sta $4000+(18*320)+16,x
					lda Drummer3bit+(64*5),x
clrleft2:			sta $4000+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda Drummer3Attr,x
					sta Screen0+(14*40)+2,x
					lda Drummer3Attr+8,x
					sta Screen0+(15*40)+2,x
					lda Drummer3Attr+16,x
					sta Screen0+(16*40)+2,x
					lda Drummer3Attr+24,x
					sta Screen0+(17*40)+2,x
					lda Drummer3Attr+32,x
					sta Screen0+(18*40)+2,x
					lda Drummer3Attr+40,x
					sta Screen0+(19*40)+2,x
					lda Drummer3Cols,x
					sta $d800+(14*40)+2,x
					lda Drummer3Cols+8,x
					sta $d800+(15*40)+2,x
					lda Drummer3Cols+16,x
					sta $d800+(16*40)+2,x
					lda Drummer3Cols+24,x
					sta $d800+(17*40)+2,x
					lda Drummer3Cols+32,x
					sta $d800+(18*40)+2,x
					lda Drummer3Cols+40,x
					sta $d800+(19*40)+2,x
					dex
					bpl !-
					.eval maskoffset = 16
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+2,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+2,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+2,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+2,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+2,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+2,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+2,x
					dex
					bpl !-					
					rts

LeftArm_Frame4:
					ldx #31
!:					lda Drummer4bit,x
					sta $4000+(16*320)+16,x
					lda Drummer4bit+(64*1),x
					sta $4000+(17*320)+16,x
					lda Drummer4bit+(64*2),x
					sta $4000+(18*320)+16,x
					lda Drummer4bit+(64*3),x
clrleft3:			sta $4000+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda Drummer4Attr,x
					sta Screen0+(16*40)+2,x
					lda Drummer4Attr+8,x
					sta Screen0+(17*40)+2,x
					lda Drummer4Attr+16,x
					sta Screen0+(18*40)+2,x
					lda Drummer4Attr+24,x
clrleft4:			sta Screen0+(19*40)+2,x
					lda Drummer4Cols,x
					sta $d800+(16*40)+2,x
					lda Drummer4Cols+8,x
					sta $d800+(17*40)+2,x
					lda Drummer4Cols+16,x
					sta $d800+(18*40)+2,x
					lda Drummer4Cols+24,x
clrleft5:			sta $d800+(19*40)+2,x
					dex
					bpl !-
					jsr frame3line123left
					.eval maskoffset = 24
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+2,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+2,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+2,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+2,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+2,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+2,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+2,x
					dex
					bpl !-					
					rts

LeftArm_Frame5:
					ldx #31
!:					lda Drummer5bit,x
					sta $4000+(16*320)+16,x
					lda Drummer5bit+(64*1),x
					sta $4000+(17*320)+16,x
					lda Drummer5bit+(64*2),x
					sta $4000+(18*320)+16,x
					lda Drummer5bit+(64*3),x
					sta $4000+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda Drummer5Attr,x
					sta Screen0+(16*40)+2,x
					lda Drummer5Attr+8,x
					sta Screen0+(17*40)+2,x
					lda Drummer5Attr+16,x
					sta Screen0+(18*40)+2,x
					lda Drummer5Attr+24,x
					sta Screen0+(19*40)+2,x
					lda Drummer5Cols,x
					sta $d800+(16*40)+2,x
					lda Drummer5Cols+8,x
					sta $d800+(17*40)+2,x
					lda Drummer5Cols+16,x
					sta $d800+(18*40)+2,x
					lda Drummer5Cols+24,x
					sta $d800+(19*40)+2,x
					dex
					bpl !-
					jsr frame3line123left
					.eval maskoffset = 32
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+2,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+2,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+2,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+2,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+2,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+2,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+2,x
					dex
					bpl !-					
					rts

LeftArm_Frame6:
					ldx #31
!:					lda Drummer5bit,x
					sta $4000+(16*320)+16,x
					lda Drummer5bit+(64*1),x
					sta $4000+(17*320)+16,x
					lda Drummer6bit,x
					sta $4000+(18*320)+16,x
					lda Drummer6bit+(64*1),x
					sta $4000+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda Drummer5Attr,x
					sta Screen0+(16*40)+2,x
					lda Drummer5Attr+8,x
					sta Screen0+(17*40)+2,x
					lda Drummer6Attr,x
					sta Screen0+(18*40)+2,x
					lda Drummer6Attr+8,x
					sta Screen0+(19*40)+2,x
					lda Drummer5Cols,x
					sta $d800+(16*40)+2,x
					lda Drummer5Cols+8,x
					sta $d800+(17*40)+2,x
					lda Drummer6Cols,x
					sta $d800+(18*40)+2,x
					lda Drummer6Cols+8,x
					sta $d800+(19*40)+2,x
					dex
					bpl !-
					jsr frame3line123left
					.eval maskoffset = 40
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+2,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+2,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+2,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+2,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+2,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+2,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+2,x
					dex
					bpl !-					
					rts

frame3line123left:	ldx #31
!:					lda #0
					sta $4000+(13*320)+16,x
					lda Drummer3bit,x
					sta $4000+(14*320)+16,x
					lda Drummer3bit+(64*1),x
					sta $4000+(15*320)+16,x
					dex
					bpl !-					
					ldx #3
!:					lda Drummer3Attr,x
					sta Screen0+(14*40)+2,x
					lda Drummer3Attr+8,x
					sta Screen0+(15*40)+2,x
					lda Drummer3Cols,x
					sta $d800+(14*40)+2,x
					lda Drummer3Cols+8,x
					sta $d800+(15*40)+2,x
					dex
					bpl !-
					rts

// --------------------------------------------------------------------------

AnimateRightArm:		
AnimSel2:			ldx #0
					beq !+
					lda AnimSeq,x
					cmp #1
					beq ra1
					cmp #2
					beq ra2
					cmp #3
					beq ra3
					cmp #4
					beq ra4
					cmp #5
					beq ra5
!:					rts
ra1:				dec AnimSel2+1
					jmp RightArm_Frame1
ra2:				dec AnimSel2+1
					jmp RightArm_Frame2
ra3:				dec AnimSel2+1
					jmp RightArm_Frame3
ra4:				dec AnimSel2+1
					jmp RightArm_Frame4
ra5:				dec AnimSel2+1
					jmp RightArm_Frame5

RightArm_Frame1:	ldx #31
!:					lda Drummer1bit+32,x
					sta $4020+(13*320)+16,x
					lda Drummer1bit+32+(64*1),x
					sta $4020+(14*320)+16,x
					lda Drummer1bit+32+(64*2),x
					sta $4020+(15*320)+16,x
					lda Drummer1bit+32+(64*3),x
					sta $4020+(16*320)+16,x
					lda Drummer1bit+32+(64*4),x
					sta $4020+(17*320)+16,x
					lda Drummer1bit+32+(64*5),x
					sta $4020+(18*320)+16,x
					lda Drummer1bit+32+(64*6),x
					sta $4020+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda Drummer1Attr+4,x
					sta Screen0+4+(13*40)+2,x
					lda Drummer1Attr+4+8,x
					sta Screen0+4+(14*40)+2,x
					lda Drummer1Attr+4+16,x
					sta Screen0+4+(15*40)+2,x
					lda Drummer1Attr+4+24,x
					sta Screen0+4+(16*40)+2,x
					lda Drummer1Attr+4+32,x
					sta Screen0+4+(17*40)+2,x
					lda Drummer1Attr+4+40,x
					sta Screen0+4+(18*40)+2,x
					lda Drummer1Attr+4+48,x
					sta Screen0+4+(19*40)+2,x
					lda Drummer1Cols+4,x
					sta $d804+(13*40)+2,x
					lda Drummer1Cols+4+8,x
					sta $d804+(14*40)+2,x
					lda Drummer1Cols+4+16,x
					sta $d804+(15*40)+2,x
					lda Drummer1Cols+4+24,x
					sta $d804+(16*40)+2,x
					lda Drummer1Cols+4+32,x
					sta $d804+(17*40)+2,x
					lda Drummer1Cols+4+40,x
					sta $d804+(18*40)+2,x
					lda Drummer1Cols+4+48,x
					sta $d804+(19*40)+2,x
					dex
					bpl !-
					.eval maskoffset = 4
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+6,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+6,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+6,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+6,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+6,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+6,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+6,x
					dex
					bpl !-					
					rts

RightArm_Frame2:
					ldx #31
!:					lda #0
					sta $4020+(13*320)+16,x
					lda Drummer2bit+32,x
					sta $4020+(14*320)+16,x
					lda Drummer2bit+32+(64*1),x
					sta $4020+(15*320)+16,x
					lda Drummer2bit+32+(64*2),x
					sta $4020+(16*320)+16,x
					lda Drummer2bit+32+(64*3),x
					sta $4020+(17*320)+16,x
					lda Drummer2bit+32+(64*4),x
					sta $4020+(18*320)+16,x
					lda Drummer2bit+32+(64*5),x
clrright1:			sta $4020+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda #StarFieldColorDrummer
					sta Screen0+4+(13*40)+2,x
					lda Drummer2Attr+4,x
					sta Screen0+4+(14*40)+2,x
					lda Drummer2Attr+4+8,x
					sta Screen0+4+(15*40)+2,x
					lda Drummer2Attr+4+16,x
					sta Screen0+4+(16*40)+2,x
					lda Drummer2Attr+4+24,x
					sta Screen0+4+(17*40)+2,x
					lda Drummer2Attr+4+32,x
					sta Screen0+4+(18*40)+2,x
					lda Drummer2Attr+4+40,x
					sta Screen0+4+(19*40)+2,x
					lda Drummer2Cols+4,x
					sta $d804+(14*40)+2,x
					lda Drummer2Cols+4+8,x
					sta $d804+(15*40)+2,x
					lda Drummer2Cols+4+16,x
					sta $d804+(16*40)+2,x
					lda Drummer2Cols+4+24,x
					sta $d804+(17*40)+2,x
					lda Drummer2Cols+4+32,x
					sta $d804+(18*40)+2,x
					lda Drummer2Cols+4+40,x
					sta $d804+(19*40)+2,x
					dex
					bpl !-
					.eval maskoffset = 8+4
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+6,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+6,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+6,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+6,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+6,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+6,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+6,x
					dex
					bpl !-					
					rts

RightArm_Frame3:
					ldx #31
!:					lda #0
					sta $4020+(13*320)+16,x
					lda Drummer3bit+32,x
					sta $4020+(14*320)+16,x
					lda Drummer3bit+32+(64*1),x
					sta $4020+(15*320)+16,x
					lda Drummer3bit+32+(64*2),x
					sta $4020+(16*320)+16,x
					lda Drummer3bit+32+(64*3),x
					sta $4020+(17*320)+16,x
					lda Drummer3bit+32+(64*4),x
					sta $4020+(18*320)+16,x
					lda Drummer3bit+32+(64*5),x
clrright2:			sta $4020+(19*320)+16,x
					dex
					bpl !-

					ldx #3
!:					lda Drummer3Attr+4,x
					sta Screen0+4+(14*40)+2,x
					lda Drummer3Attr+4+8,x
					sta Screen0+4+(15*40)+2,x
					lda Drummer3Attr+4+16,x
					sta Screen0+4+(16*40)+2,x
					lda Drummer3Attr+4+24,x
					sta Screen0+4+(17*40)+2,x
					lda Drummer3Attr+4+32,x
					sta Screen0+4+(18*40)+2,x
					lda Drummer3Attr+4+40,x
					sta Screen0+4+(19*40)+2,x
					lda Drummer3Cols+4,x
					sta $d804+(14*40)+2,x
					lda Drummer3Cols+4+8,x
					sta $d804+(15*40)+2,x
					lda Drummer3Cols+4+16,x
					sta $d804+(16*40)+2,x
					lda Drummer3Cols+4+24,x
					sta $d804+(17*40)+2,x
					lda Drummer3Cols+4+32,x
					sta $d804+(18*40)+2,x
					lda Drummer3Cols+4+40,x
					sta $d804+(19*40)+2,x
					dex
					bpl !-
					.eval maskoffset = 16+4
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+6,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+6,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+6,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+6,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+6,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+6,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+6,x
					dex
					bpl !-					
					rts

RightArm_Frame4:
					ldx #31
!:					lda Drummer4bit+32,x
					sta $4020+(16*320)+16,x
					lda Drummer4bit+32+(64*1),x
					sta $4020+(17*320)+16,x
					lda Drummer4bit+32+(64*2),x
					sta $4020+(18*320)+16,x
					lda Drummer4bit+32+(64*3),x
clrright3:			sta $4020+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda Drummer4Attr+4,x
					sta Screen0+4+(16*40)+2,x
					lda Drummer4Attr+4+8,x
					sta Screen0+4+(17*40)+2,x
					lda Drummer4Attr+4+16,x
					sta Screen0+4+(18*40)+2,x
					lda Drummer4Attr+4+24,x
					sta Screen0+4+(19*40)+2,x
					lda Drummer4Cols+4,x
					sta $d804+(16*40)+2,x
					lda Drummer4Cols+4+8,x
					sta $d804+(17*40)+2,x
					lda Drummer4Cols+4+16,x
					sta $d804+(18*40)+2,x
					lda Drummer4Cols+4+24,x
					sta $d804+(19*40)+2,x
					dex
					bpl !-
					jsr frame3line123
					.eval maskoffset = 24+4
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+6,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+6,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+6,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+6,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+6,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+6,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+6,x
					dex
					bpl !-					
					rts

RightArm_Frame5:
					ldx #31
!:					lda Drummer5bit+32,x
					sta $4020+(16*320)+16,x
					lda Drummer5bit+32+(64*1),x
					sta $4020+(17*320)+16,x
					lda Drummer5bit+32+(64*2),x
					sta $4020+(18*320)+16,x
					lda Drummer5bit+32+(64*3),x
					sta $4020+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda Drummer5Attr+4,x
					sta Screen0+4+(16*40)+2,x
					lda Drummer5Attr+4+8,x
					sta Screen0+4+(17*40)+2,x
					lda Drummer5Attr+4+16,x
					sta Screen0+4+(18*40)+2,x
					lda Drummer5Attr+4+24,x
					sta Screen0+4+(19*40)+2,x
					lda Drummer5Cols+4,x
					sta $d804+(16*40)+2,x
					lda Drummer5Cols+4+8,x
					sta $d804+(17*40)+2,x
					lda Drummer5Cols+4+16,x
					sta $d804+(18*40)+2,x
					lda Drummer5Cols+4+24,x
					sta $d804+(19*40)+2,x
					dex
					bpl !-
					jsr frame3line123
					.eval maskoffset = 32+4
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+6,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+6,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+6,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+6,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+6,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+6,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+6,x
					dex
					bpl !-					
					rts

RightArm_Frame6:
					ldx #31
!:					lda Drummer5bit+32,x
					sta $4020+(16*320)+16,x
					lda Drummer5bit+32+(64*1),x
					sta $4020+(17*320)+16,x
					lda Drummer5bit+32,x
					sta $4020+(16*320)+16,x
					lda Drummer5bit+32+(64*1),x
					sta $4020+(17*320)+16,x
					lda Drummer6bit+32,x
					sta $4020+(18*320)+16,x
					lda Drummer6bit+32+(64*1),x
					sta $4020+(19*320)+16,x
					dex
					bpl !-
					ldx #3
!:					lda Drummer5Attr+4,x
					sta Screen0+4+(16*40)+2,x
					lda Drummer5Attr+4+8,x
					sta Screen0+4+(17*40)+2,x
					lda Drummer6Attr+4,x
					sta Screen0+4+(18*40)+2,x
					lda Drummer6Attr+4+8,x
					sta Screen0+4+(19*40)+2,x
					lda Drummer5Cols+4,x
					sta $d804+(16*40)+2,x
					lda Drummer5Cols+4+8,x
					sta $d804+(17*40)+2,x
					lda Drummer6Cols+4,x
					sta $d804+(18*40)+2,x
					lda Drummer6Cols+4+8,x
					sta $d804+(19*40)+2,x
					dex
					bpl !-
					jsr frame3line123
					.eval maskoffset = 40+4
					ldx #3
!:					lda DrummerMask+maskoffset,x
					sta Mask+(13*40)+6,x
					lda DrummerMask+(1*48)+maskoffset,x
					sta Mask+(14*40)+6,x
					lda DrummerMask+(2*48)+maskoffset,x
					sta Mask+(15*40)+6,x
					lda DrummerMask+(3*48)+maskoffset,x
					sta Mask+(16*40)+6,x
					lda DrummerMask+(4*48)+maskoffset,x
					sta Mask+(17*40)+6,x
					lda DrummerMask+(5*48)+maskoffset,x
					sta Mask+(18*40)+6,x
					lda DrummerMask+(6*48)+maskoffset,x
					sta Mask+(19*40)+6,x
					dex
					bpl !-					
					rts

frame3line123:		ldx #31
!:					lda #0
					sta $4020+(13*320)+16,x
					lda Drummer3bit+32,x
					sta $4020+(14*320)+16,x
					lda Drummer3bit+32+(64*1),x
					sta $4020+(15*320)+16,x
					dex
					bpl !-					
					ldx #3
!:					lda Drummer3Attr+4,x
					sta Screen0+4+(14*40)+2,x
					lda Drummer3Attr+4+8,x
					sta Screen0+4+(15*40)+2,x
					lda Drummer3Cols+4,x
					sta $d804+(14*40)+2,x
					lda Drummer3Cols+4+8,x
					sta $d804+(15*40)+2,x
					dex
					bpl !-
					rts

//-----------------------------------------------------------------------------

TurnHeadDownInit:	lda #0
					sta delayheadd+1
					sta headcounterd+1
					rts

TurnHeadDown:			
delayheadd:			lda #0
					cmp #4
					beq !+
					inc delayheadd+1
					rts
!: 					lda #0
					sta delayheadd+1

headcounterd:		lda #0
					cmp #0
					bne !+ 
					jsr turnhead3
					jmp headcontd
!:					cmp #1
					bne !+
					jsr turnhead2
					jmp headcontd
!:					cmp #2
					bne !+
					jsr turnhead1
					jmp headcontd
!:					cmp #3
					bne !+
					jsr turnhead0
					jmp headcontd
!:					cmp #4
					beq TurnDoned
headcontd:			inc headcounterd+1
TurnDoned:			rts

TurnHeadUpInit:		lda #0
					sta delayhead+1
					sta headcounter+1
					rts
TurnHeadUp:			
delayhead:			lda #0
					cmp #4
					beq !+
					inc delayhead+1
					rts
!: 					lda #0
					sta delayhead+1

headcounter:		lda #0
					cmp #0
					bne !+ 
					jsr turnhead0
					jmp headcont
!:					cmp #1
					bne !+
					jsr turnhead1
					jmp headcont
!:					cmp #2
					bne !+
					jsr turnhead2
					jmp headcont
!:					cmp #3
					bne !+
					jsr turnhead3
					jmp headcont
!:					cmp #4
					beq TurnDone
headcont:			inc headcounter+1
TurnDone:			rts

turnhead0:			ldx #0
!:					lda DrummerHead,x
					sta $4000+(14*320)+8+32,x
					lda DrummerHead+96,x
					sta $4000+(15*320)+8+32,x
					lda DrummerHead+96+96,x
					sta $4000+(16*320)+8+32,x
					lda DrummerHead+96+96+96,x
					sta $4000+(17*320)+8+32,x
					inx
					cpx #24
					bne !-
					ldx #2
!:					lda DrummerHeadAttr,x
					sta Screen0+(14*40)+5,x
					lda DrummerHeadAttr+12,x
					sta Screen0+(15*40)+5,x
					lda DrummerHeadAttr+24,x
					sta Screen0+(16*40)+5,x
					lda DrummerHeadAttr+36,x
					sta $d800+(17*40)+5,x
					lda DrummerHeadCols,x
					sta $d800+(14*40)+5,x
					lda DrummerHeadCols+12,x
					sta $d800+(15*40)+5,x
					lda DrummerHeadCols+24,x
					sta $d800+(16*40)+5,x
					lda DrummerHeadCols+36,x
					sta $d800+(17*40)+5,x
					dex
					bpl !-
					rts
turnhead1:			ldx #0
!:					lda DrummerHead+24,x
					sta $4000+(14*320)+8+32,x
					lda DrummerHead+24+96,x
					sta $4000+(15*320)+8+32,x
					lda DrummerHead+24+96+96,x
					sta $4000+(16*320)+8+32,x
					lda DrummerHead+24+96+96+96,x
					sta $4000+(17*320)+8+32,x
					inx
					cpx #24
					bne !-
					ldx #2
!:					lda DrummerHeadAttr+3,x
					sta Screen0+(14*40)+5,x
					lda DrummerHeadAttr+12+3,x
					sta Screen0+(15*40)+5,x
					lda DrummerHeadAttr+24+3,x
					sta Screen0+(16*40)+5,x
					lda DrummerHeadAttr+36+3,x
					sta Screen0+(17*40)+5,x
					lda DrummerHeadCols+3,x
					sta $d800+(14*40)+5,x
					lda DrummerHeadCols+12+3,x
					sta $d800+(15*40)+5,x
					lda DrummerHeadCols+24+3,x
					sta $d800+(16*40)+5,x
					lda DrummerHeadCols+36+3,x
					sta $d800+(17*40)+5,x
					dex
					bpl !-
					rts
turnhead2:			ldx #0
!:					lda DrummerHead+48,x
					sta $4000+(14*320)+8+32,x
					lda DrummerHead+48+96,x
					sta $4000+(15*320)+8+32,x
					lda DrummerHead+48+96+96,x
					sta $4000+(16*320)+8+32,x
					lda DrummerHead+48+96+96+96,x
					sta $4000+(17*320)+8+32,x
					inx
					cpx #24
					bne !-
					ldx #2
!:					lda DrummerHeadAttr+6,x
					sta Screen0+(14*40)+5,x
					lda DrummerHeadAttr+12+6,x
					sta Screen0+(15*40)+5,x
					lda DrummerHeadAttr+24+6,x
					sta Screen0+(16*40)+5,x
					lda DrummerHeadAttr+36+6,x
					sta Screen0+(17*40)+5,x
					lda DrummerHeadCols+6,x
					sta $d800+(14*40)+5,x
					lda DrummerHeadCols+12+6,x
					sta $d800+(15*40)+5,x
					lda DrummerHeadCols+24+6,x
					sta $d800+(16*40)+5,x
					lda DrummerHeadCols+36+6,x
					sta $d800+(17*40)+5,x
					dex
					bpl !-
					rts
turnhead3:			ldx #0
!:					lda DrummerHead+72,x
					sta $4000+(14*320)+8+32,x
					lda DrummerHead+72+96,x
					sta $4000+(15*320)+8+32,x
					lda DrummerHead+72+96+96,x
					sta $4000+(16*320)+8+32,x
					lda DrummerHead+72+96+96+96,x
					sta $4000+(17*320)+8+32,x
					inx
					cpx #24
					bne !-
					ldx #2
!:					lda DrummerHeadAttr+9,x
					sta Screen0+(14*40)+5,x
					lda DrummerHeadAttr+12+9,x
					sta Screen0+(15*40)+5,x
					lda DrummerHeadAttr+24+9,x
					sta Screen0+(16*40)+5,x
					lda DrummerHeadAttr+36+9,x
					sta Screen0+(17*40)+5,x
					lda DrummerHeadCols+9,x
					sta $d800+(14*40)+5,x
					lda DrummerHeadCols+12+9,x
					sta $d800+(15*40)+5,x
					lda DrummerHeadCols+24+9,x
					sta $d800+(16*40)+5,x
					lda DrummerHeadCols+36+9,x
					sta $d800+(17*40)+5,x
					dex
					bpl !-
					rts

CopySleep:			lda #11 								// Num of sprites
					sta SpritePusher.NumOfSprites
					lda #<SleepBitmap 				// Source
					sta SpritePusher.Source
					lda #>SleepBitmap
					sta SpritePusher.Source+1
					lda #<DrummerBitmap 				// Destination
					sta SpritePusher.Destination
					lda #>DrummerBitmap
					sta SpritePusher.Destination+1
					jmp SpritePusher.Init // Will copy one sprite per frame until done

.const StarFieldColor = 8

PutToSleep:			lda FLAG_Sleep
					bne PlotSleeper
					rts
LastFrameJMP:		jmp LastFrame
PlotSleeper:		lda #0
					bne LastFrameJMP

					ldx #63
!:					lda DrummerBitmap,x
					sta $4000+(16*320)+16,x
					lda DrummerBitmap+64,x
					sta $4000+(17*320)+16,x
					lda DrummerBitmap+128,x
					sta $4000+(18*320)+16,x
					lda DrummerBitmap+192,x
					sta $4000+(19*320)+16,x
					dex
					bpl !-
					ldx #7
!:					lda DrummerBitmap+$1c0,x
					sta Screen0+(16*40)+2,x
					lda DrummerBitmap+$1c0+8,x
					sta Screen0+(17*40)+2,x
					lda DrummerBitmap+$1c0+16,x
					sta Screen0+(18*40)+2,x
					lda DrummerBitmap+$1c0+24,x
					sta Screen0+(19*40)+2,x
					lda DrummerBitmap+$1c0+56,x
					sta $d800+(16*40)+2,x
					lda DrummerBitmap+$1c0+64,x
					sta $d800+(17*40)+2,x
					lda DrummerBitmap+$1c0+72,x
					sta $d800+(18*40)+2,x
					lda DrummerBitmap+$1c0+80,x
					sta $d800+(19*40)+2,x
					dex
					bpl !-

					ldx #7
!:					lda #0
					sta StarFieldMask+(13*40)+2,x
					sta StarFieldMask+(14*40)+2,x
					sta StarFieldMask+(15*40)+2,x
					sta StarFieldMask+(16*40)+2,x
					lda #StarFieldColor
					sta $d800+(13*40)+2,x
					sta $d800+(14*40)+2,x
					sta $d800+(15*40)+2,x
					sta $d800+(16*40)+2,x
					dex
					bpl !-
					
					ldx #63
					lda #0
!:					sta $4000+(13*320)+16,x
					sta $4000+(14*320)+16,x
					sta $4000+(15*320)+16,x
					dex
					bpl !-

					lda #1
					sta PlotSleeper+1
					rts
LastFrame:			lda #0
					cmp #16 // Frame between animations
					beq !+
					inc LastFrame+1
					rts

!:					ldx #7
!:					lda #0
					sta StarFieldMask+(16*40)+2,x
					lda #StarFieldColor
					sta $d800+(16*40)+2,x
					dex
					bpl !-
					ldx #63
					lda #0
!:					sta $4000+(16*320)+16,x
					dex
					bpl !-

					ldx #63
!:					lda DrummerBitmap+$100,x
					sta $4000+(17*320)+16,x
					lda DrummerBitmap+$100+64,x
					sta $4000+(18*320)+16,x
					lda DrummerBitmap+$100+128,x
					sta $4000+(19*320)+16,x
					dex
					bpl !-
					ldx #7
!:					lda DrummerBitmap+$1c0+32,x
					sta Screen0+(17*40)+2,x
					lda DrummerBitmap+$1c0+40,x
					sta Screen0+(18*40)+2,x
					lda DrummerBitmap+$1c0+48,x
					sta Screen0+(19*40)+2,x
					lda DrummerBitmap+$1c0+88,x
					sta $d800+(17*40)+2,x
					lda DrummerBitmap+$1c0+96,x
					sta $d800+(18*40)+2,x
					lda DrummerBitmap+$1c0+104,x
					sta $d800+(19*40)+2,x
					dex
					bpl !-
x:					ldx #63 // Copy Zzz sprite to graphics bank
!:					lda DrummerBitmap+$1c0+56+56,x
					sta spr_platform,x
					dex
					bpl !-
					lda #$60
					sta x
					lda #1
					sta FLAG_zzz
					rts
FLAG_zzz:			.byte 0
}
