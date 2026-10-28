extends "res://scripts/world/world_surface142.gd"
const FOREST180=preload("res://scripts/world/forest_plan180.gd")
func height_at(x: float,z: float,enabled: bool) -> float:
 var previous := super.height_at(x,z,enabled)
 if not enabled or not FOREST180.affects180(Vector2(x,z)): return previous
 return minf(previous,FOREST180.height180(Vector2(x,z)-FOREST180.CENTER))
func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
 if rect.intersects(Rect2(-66.,-14.,54.,28.)): return 80
 return super._terrain_divisions19(rect,ids)
