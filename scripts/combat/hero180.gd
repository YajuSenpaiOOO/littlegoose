extends "res://scripts/combat/hero173.gd"
const FOREST180=preload("res://scripts/world/forest_plan180.gd")
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if is_on_floor() and FOREST180.affects180(Vector2(position.x,position.z)):
  var p := Vector2(position.x,position.z)-FOREST180.CENTER
  visual.position.y+=clampf(FOREST180.visible180(p)-position.y,0.,.15)
