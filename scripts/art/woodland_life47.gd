extends "res://scripts/art/woodland_life46.gd"

func _build_lantern() -> void:
	super._build_lantern()
	var ratio := 2.65/1.85
	var sprite: Sprite3D=lantern_root.get_child(0)
	sprite.pixel_size*=ratio
	var collider: CollisionShape3D=lantern_body.get_child(0)
	collider.shape.height=2.65
	collider.shape.radius=.16
	collider.position.y=1.325
	lantern_light.position*=ratio
	lantern_light.omni_range=2.9
	lantern_light.light_energy=.8
