extends "res://scripts/world/world_surface142.gd"
const FOREST183=preload("res://scripts/world/forest_plan183.gd")
func height_at(x: float,z: float,enabled: bool) -> float:
 var previous := super.height_at(x,z,enabled)
 if not enabled or not FOREST183.affects183(Vector2(x,z)): return previous
 return minf(previous,FOREST183.height183(Vector2(x,z)-FOREST183.CENTER))
func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
 if rect.intersects(Rect2(-67.,-18.,55.,33.)): return 80
 return super._terrain_divisions19(rect,ids)
