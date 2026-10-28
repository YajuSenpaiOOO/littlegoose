extends "res://scripts/combat/hero30.gd"
const PLAN=preload("res://scripts/world/forest_plan179.gd")
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 # The three short stair flights use continuous collision support underneath
 # their visible 13cm treads, matching the existing world's stair convention.
 if is_on_floor():
  var p := Vector2(position.x,position.z)-PLAN.CENTER
  visual.position.y+=clampf(PLAN.visible_height(p)-position.y,0.,.15)
