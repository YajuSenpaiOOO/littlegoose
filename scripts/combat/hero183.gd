extends "res://scripts/combat/hero173.gd"
const FOREST183=preload("res://scripts/world/forest_plan183.gd")
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if is_on_floor() and FOREST183.affects183(Vector2(position.x,position.z)):
  var p := Vector2(position.x,position.z)-FOREST183.CENTER
  visual.position.y+=clampf(FOREST183.visible183(p)-position.y,0.,.15)
