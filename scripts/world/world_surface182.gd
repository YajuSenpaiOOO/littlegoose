extends "res://scripts/world/world_surface142.gd"
const FOREST182=preload("res://scripts/world/forest_plan182.gd")
func height_at(x: float,z: float,enabled: bool) -> float:
 var previous := super.height_at(x,z,enabled)
 if not enabled or not FOREST182.affects182(Vector2(x,z)): return previous
 return minf(previous,FOREST182.height182(Vector2(x,z)-FOREST182.CENTER))
func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
 if rect.intersects(Rect2(-69.,-14.,57.,40.)): return 80
 return super._terrain_divisions19(rect,ids)

