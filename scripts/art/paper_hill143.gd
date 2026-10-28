extends "res://scripts/art/paper_hill142.gd"
func _boulder99(at: Vector3,size: Vector3,seed_value: float) -> void:
 var p: Vector2=Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
 if p.x< -12. and p.x> -36. and p.y< -6. and p.y> -36.: return
 super._boulder99(at,size,seed_value)
