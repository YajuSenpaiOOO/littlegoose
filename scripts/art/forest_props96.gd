extends "res://scripts/art/forest_props95.gd"
const LAYOUT96=preload("res://scripts/world/rest_layout96.gd")
var rest_stone96 := false
func _flower_specs94() -> Array: return [Vector4(-6.5,-4.8,6.8,4.3)]
func _flower_attempts94() -> int: return 1250
func _flower_height94(rng: RandomNumberGenerator) -> float: return rng.randf_range(.13,.28)
func _flower_variant94(_spec: Vector4,rng: RandomNumberGenerator) -> int: return 0 if rng.randf()<.94 else 1
func _flower_support94(at: Vector2) -> bool:
	if not super._flower_support94(at): return false
	var p: Vector2=at-Vector2(world.meadow.landmarks.grove)
	if LAYOUT96.trail96(p)>.1: return false
	# A connected drift wraps the stone, with green pockets and a loose edge.
	var wave := sin(p.x*.85+p.y*.5)*.5+sin(p.y*1.4-p.x*.25)*.5
	return wave>-.62

func _finger_rock93(at: Vector2,width: float,variant: int) -> void:
	var g: Vector2=world.meadow.landmarks.grove
	if at.distance_to(g+Vector2(-6.8,-1))<.1:
		var previous := rocks87.size()
		super._finger_rock93(g+LAYOUT96.STONE,4.5,2)
		rest_stone96=rocks87.size()>previous
		return
	super._finger_rock93(at,width,variant)

func _ready() -> void:
	super._ready()
	for batch in flower_batches94: batch.material_override.set_shader_parameter("tint",Vector3(.9,.94,.86))
	print("REST96 stone=",rest_stone96," low_flowers=",flower_points94.size())
