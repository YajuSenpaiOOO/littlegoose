extends "res://scripts/combat/encounter_roster265.gd"
func needs_entry(alive: int) -> bool:
 var fighting=maxi(0,alive-incoming)
 # Call ahead while current fighters still occupy the player. Total admission remains bounded.
 if spawned==target and wave<WAVES.size() and fighting<=3 and (defeated>0 or seconds>=1.):
  target+=WAVES[wave];wave+=1
 return spawned<target and alive<live_cap() and retry_left<=0.
func entered() -> bool:
 var final=super.entered();retry_left=.30;return final
