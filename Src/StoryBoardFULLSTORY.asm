
StoryBoard:

					StoryboardEntry(Drummer.Enable,				$0000, 0) // Consume music events enabled

					StoryboardEntry(Drummer.TurnHeadUpInit,		$01bf, 0) // Init sprites
					StoryboardEntry(Drummer.TurnHeadUp,			$01c0, 1) // Look up - execute animation

					StoryboardEntry(StarField.Enable,		 	$0220, 0) // Star starfield

					StoryboardEntry(Drummer.TurnHeadDownInit,	$0270, 0) // Init sprites
					StoryboardEntry(Drummer.TurnHeadDown,		$0271, 1) // Look down

					StoryboardEntry(Drummer.RaiseArmsFromRest,	$02d0, 0) // Raise arms

					StoryboardEntry(Moon.Enable,			 	$0478, 0) // Enable orbiting moon

					StoryboardEntry(Drummer.RestInit,			$0cb0, 0) // Assume hands are up. Trigger animation to resting position
					StoryboardEntry(Drummer.RestAnim,			$0cb1, 1) // Rest

					StoryboardEntry(SmallShip.Enter,		 	$0ef0, 0) // Small ship flies in
					StoryboardEntry(Drummer.TurnHeadUpInit,		$0f20, 0) // Look up
					StoryboardEntry(Drummer.TurnHeadUp,			$0f30, 1) // Look up - execute animation

					StoryboardEntry(SpaceShip.EnableIRQ,		$0fc0, 0) // Enable IRQ stuff for spaceship
					StoryboardEntry(Moon.Disable,			 	$0fc8, 0) // Temporarily disable orbiting moon (IRQ conflicts)
					StoryboardEntry(SpaceShip.Show,			 	$0fd0, 1) // Show big ship

					StoryboardEntry(SpaceShip.OpenHatch,	 	$11e0, 1) // Open the hatch on the big ship

					StoryboardEntry(SpaceGuy.EnableBeam,	 	$12c8, 0) // Enable beam
					StoryboardEntry(SpaceGuy.BeamIn,		 	$12e0, 0) // Beam in Barry Boomer
					StoryboardEntry(SpaceGuy.DisableBeam,	 	$16c0+$40, 0) // Turn off beam
					StoryboardEntry(Moon.Enable,			 	$16c2+$40, 0) // Now it is safe to enable the orbiting moon again
					StoryboardEntry(SpaceShip.CloseHatch,	 	$16e0+$40, 1) // Close hatch on big ship
					StoryboardEntry(SpaceShip.Hide,			 	$1700+$40, 0) // Remove big ship
					StoryboardEntry(SpaceGuy.Wave,			 	$1780+$40, 0) // Barry waves bye-bye
					StoryboardEntry(SpaceShip.DisableIRQ,		$1900+$40, 0) // Disable IRQ stuff for spaceship

					StoryboardEntry(SmallShip.Exit,			 	$1910+$40, 0) // Small ship flies away

					StoryboardEntry(Drummer.TurnHeadDownInit,	$1a00, 0) // Drummer turns head down
					StoryboardEntry(Drummer.TurnHeadDown,		$1a01, 1)

					StoryboardEntry(Moon.Disable,			 	$1b00, 0) // Disable moon again (conflicts with missiles)

					StoryboardEntry(Missile.Enable,			 	$1bfe, 0) // Missile attack
					StoryboardEntry(MissileNoRider.Enable,	 	$1bfe, 0)
					StoryboardEntry(Missile.Fire,			 	$1c00, 0)
					StoryboardEntry(MissileNoRider.Fire,	 	$1c70, 0)

					StoryboardEntry(Planet.Scorch,			 	$1e10, 0) // Run scorching

					StoryboardEntry(Drummer.TurnHeadUpInit,		$1ea0, 0) // Turn head up
					StoryboardEntry(Drummer.TurnHeadUp,			$1ea1, 1)

					StoryboardEntry(Moon.Enable,			 	$1ee3, 0)
					StoryboardEntry(Missile.Disable,		 	$1f11, 0)
					StoryboardEntry(MissileNoRider.Disable,	 	$1f12, 0)

					StoryboardEntry(Drummer.TurnHeadDownInit,	$1fd0, 0) // Turn head up
					StoryboardEntry(Drummer.TurnHeadDown,		$1fd1, 1)

					StoryboardEntry(Drummer.Disable,			$1fff, 0) // Temporary

					StoryboardEntry(FlashingHead.Init,			$2000, 0) // Copy head sprites to bank
					StoryboardEntry(FlashingHead.Enable,		$2001, 0) // Consume events for flashing from music
					StoryboardEntry(FlashingHead.Disable,		$27d0, 0)

					StoryboardEntry(Moon.Disable,			 	$27d8, 0)
					StoryboardEntry(SmallShip.Enter,		 	$27e8, 0)
					StoryboardEntry(SpaceGuy.Wave,			 	$27f0, 0)

					StoryboardEntry(SmallShip.Enter,		 	$2858, 0)
					StoryboardEntry(Moon.Enable,			 	$28d4, 0)
					StoryboardEntry(SmallShip.Enter,		 	$28d0, 0)
					StoryboardEntry(SmallShip.Enter,		 	$2940, 0)

					// Here we can add the virtual drumming
					StoryboardEntry(Drummer.PrepareFlex,		$2aa0, 1) // Init sprites

					StoryboardEntry(Moon.Disable,			 	$3180, 0)
					StoryboardEntry(GubbShip.EnableIRQ,			$3181, 0) // Enable IRQ stuff for spaceship
					StoryboardEntry(GubbShip.Init,				$3182, 0) // Copy GubbShip sprites to bank
					StoryboardEntry(GubbShip.Enter,			 	$3200, 0)
					StoryboardEntry(SpaceGuy.EnableBeam,	 	$3338, 0)
					StoryboardEntry(GubbShip.BeamUp,		 	$3378, 0)
					StoryboardEntry(SpaceGuy.DisableBeam,	 	$3478, 0)
					StoryboardEntry(GubbShip.Exit,			 	$3488, 0)
					StoryboardEntry(GubbShip.DisableIRQ,		$34b6, 0)

					StoryboardEntry(Moon.Enable,			 	$3510, 0)
					StoryboardEntry(Drummer.Enable,			 	$3520, 0)
					StoryboardEntry(Drummer.CopySleep, 			$3530, 0) // Needs 10 frames
					StoryboardEntry(Scroller.EnableIRQ,		 	$3540, 0)
					StoryboardEntry(Scroller.EnableScroller,	$3550, 0)

					StoryboardEntry(Drummer.TurnHeadUpInit,		$35c0, 0) // Init sprites
					StoryboardEntry(Drummer.TurnHeadUp,			$35c1, 1) // Look up - execute animation
					StoryboardEntry(Drummer.TurnHeadDownInit,	$3640, 0) // Init sprites
					StoryboardEntry(Drummer.TurnHeadDown,		$3641, 1) // Look down

					StoryboardEntry(Drummer.Flex2rest,			$36c0, 0) // Look down

					StoryboardEntry(Drummer.Sleep,				$3880, 0) // Drummer must be enabled but drumming will be disabled

					EndStoryboardTable()
