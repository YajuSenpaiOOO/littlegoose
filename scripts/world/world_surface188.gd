extends "res://scripts/world/world_surface142.gd"
const FOREST188=preload("res://scripts/world/forest_plan188.gd")
func _init() -> void:
 super._init()
 # Preserve the established north/west/east coordinates.  Add only the south
 # strip required by the relocated forest and its camera margin.
 world_bounds.size.y+=30.
func height_at(x: float,z: float,enabled: bool) -> float:
 var previous := super.height_at(x,z,enabled)
 if not enabled or not FOREST188.affects188(Vector2(x,z)): return previous
 return minf(previous,FOREST188.height188(Vector2(x,z)-FOREST188.CENTER))
func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
 if rect.intersects(Rect2(FOREST188.CENTER+Vector2(-20.,-19.),Vector2(58.,36.))): return 80
 return super._terrain_divisions19(rect,ids)
