extends "res://scripts/combat/tuantuan22.gd"
var debug_body: MeshInstance3D

func _ready() -> void:
	super._ready()
	var capsule := CapsuleShape3D.new()
	capsule.radius = .52
	capsule.height = 1.6
	hit_area.get_child(0).shape = capsule
	hit_area.position.y = .8
	debug_body = MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = capsule.radius
	mesh.height = capsule.height
	debug_body.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(.4,1.,.8,.23)
	debug_body.material_override = material
	debug_body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hit_area.add_child(debug_body)
	debug_body.visible = battle.show_hit_bodies

func _pose(key: String,lift: float) -> void:
	super._pose(key,lift)
	# Rendering hops; the forgiving, real 3D capsule remains anchored to the ground.
	hit_area.position.y = .8
	if is_instance_valid(debug_body): debug_body.visible = battle.show_hit_bodies and not dead
