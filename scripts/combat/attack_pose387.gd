extends "res://scripts/combat/attack_pose386.gd"
# Hold whenever the .32s release would leave less than .12s for stable idle.
func advance(dt: float,trigger: bool,rate: float,beam: bool,shot: bool,preparing: bool) -> void:
 var was_rapid:=rapid
 super.advance(dt,trigger,rate,beam,shot,preparing)
 rapid=rate>=1./.44 or (was_rapid and rate>=2.)
 if not beam:
  var held: bool=since_shot<RELEASE_HOLD or (rapid and trigger and since_shot<maxf(.4,1.35/maxf(.1,rate)))
  phase="release" if held else ("ready" if preparing and not rapid else "idle")
