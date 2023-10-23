.namespace Missile {

FLAG_FireMissile:	.byte 0
FLAG_DisableRider:	.byte 0

FLAG_MissileEnable:	.byte 0

Enable:				lda #1
					sta FLAG_MissileEnable
					rts

Disable:			lda #0
					sta FLAG_MissileEnable
					rts


Fire:				lda #1
					sta FLAG_FireMissile
					lda #0
					sta FLAG_DisableRider
					lda #$60
					sta Fire
					lda #$40
					sta rasterMissile+1
					rts

Execute:			lda FLAG_MissileEnable
					bne !+
					rts
!:					lda #15
					sta $d025
					lda #6
					sta $d026
					lda $d01c
					and #%11100111
					ora #%11100000
					sta $d01c
					lda $d010
					and #%11000111
					sta $d010
					lda FLAG_FireMissile
					bne !+
					lda #0
					sta $d006 // MissilePuff
					sta $d008 // MissileRider
					sta $d00a // Missile
					sta MissileXpos
					lda #$70  // Starting y pos for new missiles
					sta MissileYpos
					rts
!:
MissileExhCol:		lda #7    // Missile color & Lower Explosion
					sta $d02c
					lda #14
					sta $d02b // Rider color & Upper Explosion
					lda MissileXpos
					cmp #170
					bne MoveMissile
					clc
					adc #4
					clc
					adc Planet.GlobalShakeX
					sta $d008 // Cause explosion
					sta $d00a
					lda MissileYpos
					clc
					adc #2
					clc
					adc Planet.GlobalShakeY

					sta $d00b
					sec 
					sbc #21
					sta $d009 // Disable Rider
					lda $d01c
					ora #%00010000
					sta $d01c
					lda #0
					sta $d006 // Remove Puff

ExplCnt:			ldx #0
					lda AnimMissileExpl,x
					sta Screen0+$3fc
					clc
					adc #11
					sta Screen0+$3fd
					lda ExplosionAnimColorsUpper,x
					sta $d02b
					lda ExplosionAnimColorsLower,x
					sta $d02c
ExplDly:			lda #0
					cmp #4
					beq !+
					inc ExplDly+1
					rts
!:					lda #0
					sta ExplDly+1
					lda ExplCnt+1
					cmp #10
					beq ExplDone
					inc ExplCnt+1
					rts
ExplDone:			lda #0
					sta MissileXpos
					sta $d006
					sta $d008
					sta $d00a
					sta ExplCnt+1 // Explosion Ptr
					jmp seqcontrol

MoveMissile:		sta $d00a // Move Missile
					sta $d008
					cmp #25   // Add Puff
					bcc SkipPuff
					lda MissileXpos
					sec
					sbc #24
					sta $d006
					lda MissileYpos
					sta $d007

SkipPuff:
					lda FLAG_DisableRider
					beq !+
					lda #0
					sta $d008
!:
					jsr AnimateMissileWR

					inc MissileXpos

					lda MissileYpos
					sta $d009
					clc
					adc #2
					sta $d00b
MissileYposDly:		lda #0
					cmp #3
					beq !+
					inc MissileYposDly+1
					rts
!:					lda #0
					sta MissileYposDly+1
					inc MissileYpos
					rts

MissileXpos:		.byte 0
MissileYpos:		.byte $70

AnimateMissileWR:	
MissilePtrCnt:		ldx #0
					lda AnimMissilePtr,x
					sta Screen0+$3fd
RiderPtrCnt:		ldx #0
					lda AnimRiderPtr,x
					sta Screen0+$3fc
PuffPtrCnt:			ldx #0
					lda AnimPuffPtr,x
					sta Screen0+$03fb
					lda AnimPuffCol,x
					sta $d02a
					jsr AnimateRider
					jsr AnimatePuff

AnimateMissileDly:	lda #0
					cmp #6
					beq !+
					inc AnimateMissileDly+1
					rts
!:					lda #0
					sta AnimateMissileDly+1
					lda MissilePtrCnt+1
					cmp #4
					beq !+
					inc MissilePtrCnt+1

					lda MissileExhCol+1
					eor #3
					sta MissileExhCol+1

					rts
!:					lda #0
					sta MissilePtrCnt+1
					rts
AnimateRider:		
					lda #0
					cmp #7
					beq !+
					inc AnimateRider+1
					rts
!:					lda #0
					sta AnimateRider+1
					lda RiderPtrCnt+1
					cmp #3
					beq !+
					inc RiderPtrCnt+1
					rts
!:					lda #0
					sta RiderPtrCnt+1
					rts

AnimatePuff:
					lda #0
					cmp #2
					beq !+
					inc AnimatePuff+1
					rts
!:					lda #0
					sta AnimatePuff+1
					lda PuffPtrCnt+1
					cmp #14
					beq !+
					inc PuffPtrCnt+1
					rts
!:					lda #0
					sta PuffPtrCnt+1
					rts

seqcontrol:
seqcnt:				ldx #0
					lda missilevarsy,x
					sta MissileYpos
					lda seqcnt+1
					cmp #2
					beq EndSeq
					inc seqcnt+1
					lda #1
					sta FLAG_DisableRider
					rts
EndSeq:				lda #0
					sta FLAG_FireMissile
					rts
missilevarsy:		.byte $78,$58

AnimPuffPtr:		.fill 6,(spr_MissilePuff/64)+i
					.fill 10,(spr_MissilePuff/64)+6
AnimPuffCol:		.byte 15,15,12,12,11,11
					.byte 0,0,0,0,0,0,0,0,0,0
AnimMissilePtr:		.fill 5,(spr_Missile/64)+i
AnimRiderPtr:		.byte (spr_MissileRider/64),(spr_MissileRider/64)+1,(spr_MissileRider/64)+2,(spr_MissileRider/64)+1
AnimMissileExpl:	.fill 11,spr_MissileExplode/64+i

ExplosionAnimColorsUpper:		.byte 0,0,0,1,7,1,1,1,1,7,7
ExplosionAnimColorsLower:		.byte 1,1,1,1,1,13,7,7,7,0,0
PufAnimColors:					.byte 15,15,12,12,11,11

}

.namespace MissileNoRider {

FLAG_FireMissile:	.byte 0

FLAG_MissileEnable:	.byte 0

Enable:				lda #1
					sta FLAG_MissileEnable
					rts

Disable:			lda #0
					sta FLAG_MissileEnable
					rts

Fire:				lda #1
					sta FLAG_FireMissile
					lda #$60
					sta Fire
					rts

Execute:			lda FLAG_MissileEnable
					bne !+
					rts
!:					lda #15
					sta $d025
					lda #6
					sta $d026
					lda $d01c
					and #%10111111
					ora #%10000000
					sta $d01c
					lda $d010
					and #%00111111
					sta $d010
					lda FLAG_FireMissile
					bne !+
					lda #0
					sta $d00c // MissilePuff
					sta $d00e // Missile
					sta MissileXpos
					rts
!:
MissileExhCol:		lda #7    // Missile color & Lower Explosion
					sta $d02e
					lda MissileXpos
					cmp #200
					bcc MoveMissile
					clc
					adc #4
					clc
					adc Planet.GlobalShakeX
					sta $d00c // Cause explosion
					sta $d00e
					lda MissileYpos
					clc
					adc #2
					clc
					adc Planet.GlobalShakeY
					sta $d00d
					sec 
					sbc #21
					sta $d00f // Disable Rider
					lda $d01c
					ora #%01000000
					sta $d01c

ExplCnt:			ldx #0
					lda AnimMissileExpl,x
					sta Screen0+$3ff
					clc
					adc #11
					sta Screen0+$3fe
					lda ExplosionAnimColorsUpper,x
					sta $d02e
					lda ExplosionAnimColorsLower,x
					sta $d02d
ExplDly:			lda #0
					cmp #4
					beq !+
					inc ExplDly+1
					rts
!:					lda #0
					sta ExplDly+1
					lda ExplCnt+1
					cmp #10
					beq ExplDone
					inc ExplCnt+1
					rts
ExplDone:			lda #0
					sta MissileXpos
					sta $d00c
					sta $d00e
					sta ExplCnt+1 // Explosion Ptr
					jmp seqcontrol

MoveMissile:		ldx #0
					stx $d00c
					//sta $d00c // Move Missile
					sta $d00e
					cmp #25   // Add Puff
					bcc SkipPuff
					lda MissileXpos
					sec
					sbc #24
					sta $d00c
					lda MissileYpos
					sta $d00d

SkipPuff:
					jsr AnimateMissile

					jsr move1px

move1px:			inc MissileXpos

					lda MissileYpos
					sta $d00d
					clc
					adc #2
					sta $d00f
MissileYposDly:		lda #0
					cmp #3
					beq !+
					inc MissileYposDly+1
					rts
!:					lda #0
					sta MissileYposDly+1
					inc MissileYpos
					rts

AnimateMissile:
MissilePtrCnt:		ldx #0
					lda AnimMissilePtr,x
					sta Screen0+$3ff
PuffPtrCnt:			ldx #0
					lda AnimPuffPtr,x
					sta Screen0+$03fe
					lda AnimPuffCol,x
					sta $d02d
					jsr AnimatePuff

AnimateMissileDly:	lda #0
					cmp #6
					beq !+
					inc AnimateMissileDly+1
					rts
!:					lda #0
					sta AnimateMissileDly+1
					lda MissilePtrCnt+1
					cmp #4
					beq !+
					inc MissilePtrCnt+1

					lda MissileExhCol+1
					eor #3
					sta MissileExhCol+1

					rts
!:					lda #0
					sta MissilePtrCnt+1
					rts

AnimatePuff:
					lda #0
					cmp #2
					beq !+
					inc AnimatePuff+1
					rts
!:					lda #0
					sta AnimatePuff+1
					lda PuffPtrCnt+1
					cmp #14
					beq !+
					inc PuffPtrCnt+1
					rts
!:					lda #0
					sta PuffPtrCnt+1
					rts

seqcontrol:
seqcnt:				ldx #0
					lda missilevarsy,x
					sta MissileYpos
					lda seqcnt+1
					cmp #3
					beq EndSeq
					inc seqcnt+1
					rts
EndSeq:				lda #0
					sta FLAG_FireMissile
					lda #$80
					sta rasterMissile+1
					rts
missilevarsy:		.byte $58,$60,$7c
MissileXpos:		.byte 0
MissileYpos:		.byte $50

AnimPuffPtr:		.fill 6,(spr_MissilePuff/64)+i
					.fill 10,(spr_MissilePuff/64)+6
AnimPuffCol:		.byte 15,15,12,12,11,11
					.byte 0,0,0,0,0,0,0,0,0,0
AnimMissilePtr:		.fill 5,(spr_Missile/64)+i
AnimMissileExpl:	.fill 11,spr_MissileExplode/64+i

ExplosionAnimColorsUpper:		.byte 0,0,0,1,7,1,1,1,1,7,7
ExplosionAnimColorsLower:		.byte 1,1,1,1,1,13,7,7,7,0,0
PufAnimColors:					.byte 15,15,12,12,11,11

}
