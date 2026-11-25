extends "res://scripts/world/woodland_world405.gd"
const SIZE409:=.68
func _init() -> void:
 super._init();memory_save116="user://home_fit409.cfg"
func door405() -> Vector2:return Vector2(-5.3,-6.3)
func set_mode405(value: int) -> void:
 model405.scale=Vector3.ONE*SIZE409
 super.set_mode405(value)
 if value!=1:
  var door:=door405();model405.position=Vector3(door.x,root_y405,door.y-2.88*SIZE409)
  model405.door404.position=Vector3(-1.015,.025,2.88);model405.door404.reset_physics_interpolation()
func footprint405() -> Rect2:
 return Rect2(Vector2(model405.position.x-6.7*SIZE409,model405.position.z-4.95*SIZE409),Vector2(13.4,8.0)*SIZE409)
func floor_height(at: Vector2) -> float:
 var height:=terrain405(at)
 if not ready405 or mode405==1:return height
 if footprint405().has_point(at):return maxf(height,root_y405)
 var local: Vector2=(at-Vector2(model405.position.x,model405.position.z))/SIZE409
 if absf(local.x)<1.05 and local.y>=3.05 and local.y<=5.35:return maxf(height,root_y405-ramp_drop405*SIZE409*(local.y-3.05)/2.3)
 return height
