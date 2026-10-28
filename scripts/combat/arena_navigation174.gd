extends "res://scripts/combat/woodland_navigation21.gd"
const PLAN=preload("res://scripts/world/arena_layout174.gd")
class FlatSurface:
 extends RefCounted
 func walk_height(_at: Vector2,_enabled: bool) -> float: return 2.1
func grid_half_extent21() -> Vector2i: return Vector2i(19,18)
func bake(space: PhysicsDirectSpaceState3D,_surface: RefCounted,_center: Vector2) -> void:
 super.bake(space,FlatSurface.new(),PLAN.CENTER)
 for y in grid.region.size.y:
  for x in grid.region.size.x:
   var at := origin+Vector2(x,y)*CELL-PLAN.CENTER
   if not PLAN.BOUNDS.grow(-.65).has_point(at): grid.set_point_solid(Vector2i(x,y),true)
