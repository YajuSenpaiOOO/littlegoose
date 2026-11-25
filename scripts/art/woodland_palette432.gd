extends "res://scripts/art/woodland_palette255.gd"

var grade_sent := -1.
var budget_was_active := false

func _use_lighting_budget() -> bool:
 return is_instance_valid(world.time55) and world.time55.efficient_updates432

func apply_daylight(value: float) -> void:
 var efficient:=_use_lighting_budget()
 if efficient and budget_was_active and profile==last_profile67:
  # Keep actor/fill sampling current. The static route materials can share a
  # value until the visual difference reaches half a percentage point.
  if value!=0. and value!=1. and absf(value-last_daylight67)<.005:
   daylight55=value
   return
 budget_was_active=efficient
 super.apply_daylight(value)

func apply_grade104() -> void:
 var strength:=strength108()
 if _use_lighting_budget() and (is_equal_approx(strength,grade_sent) or (strength>0. and strength<1. and absf(strength-grade_sent)<.005)):
  return
 grade_sent=strength
 super.apply_grade104()
