
// Moon and MissileNoRider cannot run at the same time
// Missile FX change raster irq temporarily from 60 to 40

// Base timer (1=continuous,0=one time)


StoryBoard:
					//StoryboardEntry(Moon.Enable,			 	$0000, 0)
					StoryboardEntry(StarField.Enable,		 	$0001, 0) // Star starfield

//					StoryboardEntry(GubbShip.EnableIRQ,			$0010, 0) // Enable IRQ stuff for spaceship
//					StoryboardEntry(GubbShip.Init,				$0011, 0) // Copy GubbShip sprites to bank
//					StoryboardEntry(GubbShip.Enter,			 	$3200-$31c0, 0)
//					StoryboardEntry(SpaceGuy.EnableBeam,	 	$3338-$31c0, 0)
//					StoryboardEntry(GubbShip.BeamUp,		 	$3378-$31c0, 0)
//					StoryboardEntry(SpaceGuy.DisableBeam,	 	$3478-$31c0, 0)
//					StoryboardEntry(GubbShip.Exit,			 	$3488-$31c0, 0)
					StoryboardEntry(GubbShip.DisableIRQ,		$0010, 0)

					EndStoryboardTable()
