extends "res://scripts/combat/cotton350.gd"
# Records and uploads use world coordinates; the pool must not inherit the pig transform.
func _ready() -> void:
 top_level=true
 global_transform=Transform3D.IDENTITY
 physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 super._ready()
