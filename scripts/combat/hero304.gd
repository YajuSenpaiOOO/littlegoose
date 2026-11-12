extends "res://scripts/combat/hero192.gd"
var launch304 := false
func reset_actions() -> void:
 super.reset_actions();launch304=false
func _physics_process(delta: float) -> void:
 if launch304 and not battle.combat_paused:
  launch304=false
  velocity=Vector3(combat_impulse.x,6.,combat_impulse.y)
  move_and_slide()
 super._physics_process(delta)
