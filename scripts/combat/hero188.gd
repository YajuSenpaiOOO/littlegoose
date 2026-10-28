extends "res://scripts/combat/hero173.gd"
const FOREST188=preload("res://scripts/world/forest_plan188.gd")
func _ready() -> void:
 super._ready()
 # The hero is authored as a lit pixel sprite.  Per-lamp 3D shading created a
 # hard roaming patch across the face; regional grading still affects it.
 visual.shaded=false
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if is_on_floor() and FOREST188.affects188(Vector2(position.x,position.z)):
  var p := Vector2(position.x,position.z)-FOREST188.CENTER
  visual.position.y+=clampf(FOREST188.visible188(p)-position.y,0.,.15)
