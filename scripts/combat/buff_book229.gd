extends "res://scripts/combat/buff_book168.gd"
func rate() -> float:
 var eye=level("eye_exercise")
 var old_rate=1. if eye==0 else (1.5 if eye==1 else 1.875)
 var new_rate=1. if eye==0 else (1.25 if eye==1 else 1.5)
 return super.rate()*new_rate/old_rate
