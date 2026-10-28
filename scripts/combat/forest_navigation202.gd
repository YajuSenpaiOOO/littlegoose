extends "res://scripts/combat/woodland_navigation21.gd"
const PLAN=preload("res://scripts/world/forest_plan188.gd")
func grid_half_extent21() -> Vector2i: return Vector2i(19,18)
func bake(space: PhysicsDirectSpaceState3D,surface: RefCounted,_center: Vector2) -> void:
 super.bake(space,surface,PLAN.CENTER+Vector2(0,2))
 for y in grid.region.size.y:
  for x in grid.region.size.x:
   var at: Vector2=origin+Vector2(x,y)*CELL
   if absf(surface.walk_height(at,true)-PLAN.BASE)>.45 or surface.normal_at(at.x,at.y,true).y<.85:
    grid.set_point_solid(Vector2i(x,y),true)
