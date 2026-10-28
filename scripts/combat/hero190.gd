extends "res://scripts/combat/hero188.gd"
func _ready() -> void:
 super._ready()
 # One ordinary receiver: sun, ambient and native lamps shade the entire card.
 # No emissive material, body-following point light or screen ellipse gain.
 visual.shaded=true
func render_pose() -> void:
 super.render_pose()
 # Use the built-in atlas-safe light receiver. Tilt the card's normal gently
 # upward to receive overhead theatre light while preserving walking roll.
 if is_instance_valid(visual): visual.rotation.x=deg_to_rad(-25.)
