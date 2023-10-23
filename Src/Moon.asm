.namespace Moon {

FLAG_EnableMoon:		.byte 0

Enable:				lda #1
					sta FLAG_EnableMoon
					rts

Disable:			//lda moonsinexcounter
					//cmp #255
					//beq DisableMoon
					//rts
DisableMoon:		lda #0
					sta FLAG_EnableMoon
					rts

Execute:			lda MissileNoRider.FLAG_FireMissile
					beq !+
					rts
!:					lda FLAG_EnableMoon
					bne !+
					lda #0
					sta Moon1X+1
					sta Moon2X+1
					rts
!:					
					lda moonsinexcounter
					cmp #255
					bne DrawMoon
					lda #$a0
					sta Moon1Y+1
					sta Moon2Y+1
					lda #$0
					sta Moon1X+1
					sta Moon2X+1
					sta Moonmsb+1

moondelay1:			lda #0  // Wait until next round
					cmp #1
					beq !+
					inc moondelay1+1
					rts
!:					lda #0
					sta moondelay1+1
moondelay2:			lda #0
					cmp #140
					beq !+
					inc moondelay2+1
					rts
!:					lda #0
					sta moondelay1+1
					sta moondelay2+1
					sta moonsinexcounter
					rts



DrawMoon:			lda #$88
					sta Moon1Y+1
					sta Moon2Y+1

					ldx moonsinexcounter
					lda moonsinex,x
					sta Moon1X+1
					sta Moon2X+1
					lda Moonmsb+1
					and #%00111111
					sta Moonmsb+1
					lda moonsinexh,x
					beq !+
					lda Moonmsb+1
					ora #%11000000
					sta Moonmsb+1
!:					lda moonsiney,x
					sta Moon1Y+1
					sta Moon2Y+1

					lda #spr_moon/64
					sta Moon1Ptr+1
					lda #spr_moon/64+1 //Backside
					sta Moon2Ptr+1
					
					lda moonsinexcounter // Remove backside of moon when behind planet
					cmp #48
					bcs !+
					lda #0
					sta Moon2X+1
!:
					jsr animatemoon

					lda moondelay
					cmp #1
					beq !+
					inc moondelay
					rts
moondelay:			.byte 0
!:					lda #0
					sta moondelay
					inc moonsinexcounter
					rts

animatemoon:		jsr GetSourceMoon
					jsr GetMoonMask
					ldx #63
!:					
moonsurfacesrc:		lda $1234,x
moonmask:			and $1234,x
					sta spr_moon,x
					dex
					bpl !-
					rts

GetMoonMask:		lda moonsinexcounter // Fix overflow
					cmp #32
					bcc !+
					lda #31
!:					tax
					lda moonmaskindex,x
					tax
					lda moonmaskptrlo,x
					sta moonmask+1
					lda moonmaskptrhi,x
					sta moonmask+2
					rts

GetSourceMoon:		lda #0
					cmp #5
					beq !+
					inc GetSourceMoon+1
					rts
!:					lda #0
					sta GetSourceMoon+1
mooncnt:			ldx #0
					lda moon_surf_ptr_lo,x
					sta moonsurfacesrc+1
					lda moon_surf_ptr_hi,x
					sta moonsurfacesrc+2
					lda mooncnt+1
					cmp #7
					beq resetmoonanim
					inc mooncnt+1
					rts
resetmoonanim:		lda #0
					sta mooncnt+1
					rts

moon_surf_ptr_lo:	.fill 8,<spr_moon_surface+(i*64)
moon_surf_ptr_hi:	.fill 8,>spr_moon_surface+(i*64)

moonanimcounter:	.byte 0

moonsinexcounter:	.byte 0

moonsinex: 			.fill 64,  <$70 + 320 + 320*sin(toRadians(238+i*360/1024))&254
					.fill 192, <$74 + 370 + 370*sin(toRadians(270+i*360/1024))

moonsinexh:			.fill 64,  >$70 + 320 + 320*sin(toRadians(238+i*360/1024))&254
					.fill 192, >$74 + 370 + 370*sin(toRadians(270+i*360/1024))

moonsiney:			.fill 64,  <$84 + 120 + 120*sin(toRadians(230+i*360/1024))
					.fill 192, <$89 + 60 + 60*sin(toRadians(270+i*360/1024))

moonmaskindex:		.byte 16,16,16,16,16,16,15,14,14,13,13,12,11,10,9,9
					.byte 8,8,7,6,5,4,4,3,3,2,2,1,1,0,0,0,0,0,0,0

moonmaskptrlo:		.fill 17,<spr_moon_mask+(i*64)
moonmaskptrhi:		.fill 17,>spr_moon_mask+(i*64)

}
