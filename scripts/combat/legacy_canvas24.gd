extends Node2D
## Projects existing 2D art at a world anchor; all collision stays in the 3D world.
const Art = preload("res://scripts/combat/legacy/candy_bullet_art.gd")
var battle: Node3D
var at := Vector3.ZERO
var follow: Node3D
var facing := Vector2.RIGHT
var projectile := false
var age := 0.
var lifetime := .65
var scale_gain := 1.

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if projectile: draw.connect(_draw_bullet)

func _process(delta: float) -> void:
	age += delta
	if projectile:
		if not is_instance_valid(follow): queue_free(); return
		at = follow.get_global_transform_interpolated().origin
	elif age>lifetime: queue_free(); return
	visible = not battle.camera.is_position_behind(at)
	position = battle.camera.unproject_position(at)
	var pixel_scale: float = (battle.camera.unproject_position(at+battle.camera.global_basis.x)-position).length()/battle.Profile.PPM
	scale = Vector2.ONE*pixel_scale
	if projectile: queue_redraw()

func _draw_bullet() -> void:
	Art.draw_projectile(self,0,facing,age,scale_gain)
