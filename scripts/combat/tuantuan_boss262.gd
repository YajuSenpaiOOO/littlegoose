extends "res://scripts/combat/tuantuan_boss260.gd"
## Adhesion reduces horizontal reach, never the established bounce/parry beat.
func lock247() -> void:
 super.lock247()
 var scale=1. if reflected248 else 1.-(1.-clampf(float(get_meta("locomotion_scale153",1.)),.6,1.))*.5
 var original=goal247
 goal247=from247+(goal247-from247)*scale
 if not flights247.is_empty():
  flights247[-1].goal=goal247;flights247[-1]["adhesion_scale262"]=scale;flights247[-1]["unmodified_goal262"]=original
 draw_marker247()
