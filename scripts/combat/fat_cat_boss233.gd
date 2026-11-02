extends "res://scripts/combat/fat_cat_boss231.gd"
func roll_speed_scale221() -> float:
 return clampf(float(get_meta("locomotion_scale153",1.)),.6,1.)
