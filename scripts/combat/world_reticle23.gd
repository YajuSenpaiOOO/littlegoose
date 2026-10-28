extends Node3D
var battle: Node3D
var target := Vector3.INF
var ground_point := Vector3.ZERO
var head: Node3D
var ground_ring: MeshInstance3D
var stem: MeshInstance3D

func material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	result.albedo_color = color
	result.cull_mode = BaseMaterial3D.CULL_DISABLED
	if color.a<1.: result.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return result

func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	head = Node3D.new()
	head.rotation_degrees.x = -25
	add_child(head)
	for i in 4:
		var bar := MeshInstance3D.new()
		var mesh := QuadMesh.new()
		mesh.size = Vector2(.09,.022)
		bar.mesh = mesh
		bar.position = Vector3(cos(i*PI*.5)*.13,sin(i*PI*.5)*.13,0)
		bar.rotation.z = i*PI*.5
		var ink := material(Color(1.,.89,.63,.95))
		# World position/size, but remain readable when the card occupies the target.
		ink.no_depth_test = true
		ink.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
		ink.render_priority = 5
		bar.material_override = ink
		bar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		head.add_child(bar)
	ground_ring = MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = .17
	ring.outer_radius = .195
	ring.rings = 24
	ring.ring_segments = 6
	ground_ring.mesh = ring
	ground_ring.material_override = material(Color(.17,.22,.12,.65))
	ground_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ground_ring)
	var shadow := MeshInstance3D.new()
	var disk := PlaneMesh.new()
	disk.size = Vector2(.38,.28)
	shadow.mesh = disk
	var soft := ShaderMaterial.new()
	soft.shader = preload("res://scripts/art/foot_contact16.gdshader")
	shadow.material_override = soft
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ground_ring.add_child(shadow)
	stem = MeshInstance3D.new()
	stem.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	stem.material_override = material(Color(1.,.88,.60,.4))
	add_child(stem)

func update_target(at: Vector3) -> void:
	target = at
	visible = battle.world_cursor and at.is_finite()
	if not visible: return
	head.position = at
	var query := PhysicsRayQueryParameters3D.create(battle.projectile_origin(),at,1|2)
	var blocked := not get_world_3d().direct_space_state.intersect_ray(query).is_empty()
	var color := Color(1.,.60,.32,.95) if blocked else Color(1.,.89,.63,.95)
	for bar in head.get_children(): bar.material_override.albedo_color = color
	# Muzzle-line mode hides both of these legacy ground aids.
	if bool(battle.get("combat_budget105")) and int(battle.get("aim_guide_mode"))!=1: return
	ground_point = Vector3(at.x,battle.meadow.walk_height(Vector2(at.x,at.z),battle.terrain_enabled)+.03,at.z)
	ground_ring.position = ground_point
	var normal: Vector3 = battle.meadow.normal_at(at.x,at.z,battle.terrain_enabled)
	ground_ring.rotation = Vector3(atan2(-normal.z,normal.y),0,atan2(normal.x,normal.y))
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for i in 4:
		mesh.surface_add_vertex(ground_point.lerp(at,float(i)/4.))
		mesh.surface_add_vertex(ground_point.lerp(at,(float(i)+.45)/4.))
	mesh.surface_end()
	stem.mesh = mesh
