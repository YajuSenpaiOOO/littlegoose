extends "res://scripts/art/south_pose_hold_20261116.gd"
# Alternate preview: release returns straight to idle; beam holds release.
func advance(dt: float, trigger: bool, rate: float, beam: bool, shot: bool, preparing: bool) -> void:
 super.advance(dt, trigger, rate, beam, shot, preparing)
 if beam:
  phase = "release" if trigger else ("ready" if preparing else "idle")
 else:
  var held: bool = since_shot < RELEASE_HOLD or (rapid and trigger and since_shot < .4)
  phase = "release" if held else ("ready" if preparing else "idle")
