extends "res://scripts/art/forest_lighting201.gd"
var rejected_tree_casters202 := 0
func caster(at: Vector3,radius: float,height: float) -> void:
 # A tall invisible cylinder was casting a literal column onto the painted
 # roots. Keep the existing alpha-contour projection and ground contact only.
 if is_equal_approx(radius,.65) and is_equal_approx(height,4.):
  rejected_tree_casters202+=1;return
 super.caster(at,radius,height)
