extends "res://scripts/art/forest_lighting193.gd"
var rejected_craft_casters194 := 0
func caster(at: Vector3,radius: float,height: float) -> void:
 if is_equal_approx(radius,.38) and is_equal_approx(height,.65):
  rejected_craft_casters194+=1;return
 super.caster(at,radius,height)
