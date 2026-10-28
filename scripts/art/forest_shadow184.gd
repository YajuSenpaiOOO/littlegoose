extends "res://scripts/combat/actor_shadow105.gd"
# Use a predictable CPU projection for static props. Bounds are already local.
var corrected_upload184 := -1
func _process(delta: float) -> void:
 super._process(delta)
 if uploads105!=corrected_upload184:
  corrected_upload184=uploads105
