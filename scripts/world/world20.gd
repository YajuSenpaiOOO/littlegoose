extends "res://scripts/world/world19.gd"
## Layout first: reuse approved art while testing a landmark ring and raised arena.
const HOUSE_SCALE := 1.30
var landmark_tree: Dictionary = {}
var stairs_mesh: MeshInstance3D

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow = preload("res://scripts/world/world_surface20.gd").new()

func _ready() -> void:
	house_fits = house_fits.duplicate(true)
	for fit in house_fits:
		for key in ["height","width","eave","peak","depth"]: fit[key] *= HOUSE_SCALE
	super._ready()
	_build_stairs()
	_status()
	print("WORLD20_READY ring_radius=",meadow.RING_RADIUS," grove_level=",meadow.GROVE_LEVEL)

func _set_house_variant(index: int) -> void:
	super._set_house_variant(index)
	if not draw_ready: return
	# Fit-driven wall/roof/collision already grew together. The chimney uses fixed dimensions.
	var chimney: Node3D = shadow_volume.get_child(shadow_volume.get_child_count()-1)
	chimney.position *= HOUSE_SCALE
	chimney.scale = Vector3.ONE*HOUSE_SCALE

func _build_props15() -> void:
	super._build_props15()
	props15[0].root.position.x -= 1.1

func _build_woodland() -> void:
	super._build_woodland()
	_add_route_tree(meadow.landmarks.junction,18.)
	landmark_tree = trees[-1]
	landmark_tree.root.name = "GreatTreePlaceholder"
	landmark_tree.visual.visibility_range_end = 90.
	for child in landmark_tree.root.get_children():
		if child is StaticBody3D:
			var collider: CollisionShape3D = child.get_child(0)
			collider.shape.radius = 1.45
			collider.shape.height = 5.
			collider.position.y = 2.5

func _build_lab_grass() -> void:
	super._build_lab_grass()
	for batch in grass_batches:
		var kept: Array[Transform3D] = []
		var colors: Array[Color] = []
		for i in batch.points.size():
			var original: Transform3D = batch.points[i]
			var at := Vector2(original.origin.x,original.origin.z)
			if meadow.is_stair(at) or at.distance_to(meadow.landmarks.junction)<2.5: continue
			kept.append(original)
			colors.append(batch.node.multimesh.get_instance_custom_data(i))
		batch.points = kept
		batch.node.multimesh.instance_count = kept.size()
		for i in kept.size(): batch.node.multimesh.set_instance_custom_data(i,colors[i])

func _junction_sign_position() -> Vector2:
	return meadow.landmarks.junction+Vector2(2.3,meadow.RING_RADIUS+1.4)

func _travel_region(key: String) -> void:
	if key=="junction":
		_teleport15(meadow.landmarks.junction+Vector2(0,meadow.RING_RADIUS+1.))
		return
	if key=="steps":
		_teleport15(meadow.landmarks.grove+meadow.stair_direction*(meadow.STAIR_OUTER+2.))
		return
	super._travel_region(key)

func _build_stairs() -> void:
	stairs_mesh = MeshInstance3D.new()
	stairs_mesh.name = "StoneStairsBlockout"
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var direction: Vector2 = meadow.stair_direction
	var right := Vector2(-direction.y,direction.x)
	var base: Vector2 = meadow.landmarks.grove+direction*meadow.STAIR_OUTER
	var bottom: float = meadow.height_at(base.x,base.y,true)
	var count := 18
	for i in count:
		var far_t := float(i)/count
		var near_t := float(i+1)/count
		var u := lerpf(meadow.STAIR_OUTER,meadow.STAIR_INNER,far_t)
		var v := lerpf(meadow.STAIR_OUTER,meadow.STAIR_INNER,near_t)
		var y := lerpf(bottom,meadow.GROVE_LEVEL,near_t)+.012
		var low := lerpf(bottom,meadow.GROVE_LEVEL,far_t)+.012
		var a: Vector2 = meadow.landmarks.grove+direction*u-right*meadow.STAIR_WIDTH*.5
		var b: Vector2 = a+right*meadow.STAIR_WIDTH
		var c: Vector2 = meadow.landmarks.grove+direction*v+right*meadow.STAIR_WIDTH*.5
		var d: Vector2 = c-right*meadow.STAIR_WIDTH
		var aa := Vector3(a.x,y,a.y)
		var bb := Vector3(b.x,y,b.y)
		var cc := Vector3(c.x,y,c.y)
		var dd := Vector3(d.x,y,d.y)
		for triangle in [[aa,bb,cc],[aa,cc,dd],[aa,Vector3(a.x,low,a.y),Vector3(b.x,low,b.y)],[aa,Vector3(b.x,low,b.y),bb]]:
			st.set_normal((triangle[2]-triangle[0]).cross(triangle[1]-triangle[0]).normalized())
			for p in triangle:
				st.set_uv(Vector2(p.x,p.z))
				st.add_vertex(p)
	stairs_mesh.mesh = st.commit()
	var stone := ShaderMaterial.new()
	stone.shader = preload("res://scripts/art/stone_steps20.gdshader")
	stairs_mesh.material_override = stone
	# Physical floor is a continuous terrain ramp: no capsule snagging at every riser.
	add_child(stairs_mesh)
	stairs_mesh.visible = terrain_enabled

func _rebuild_terrain() -> void:
	super._rebuild_terrain()
	if is_instance_valid(stairs_mesh): stairs_mesh.visible = terrain_enabled

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	for material in ground_materials:
		material.shader = preload("res://scripts/art/world_ground20.gdshader")
		material.set_shader_parameter("grove_center",meadow.landmarks.grove)

func _status() -> void:
	super._status()
	if not world_ready: return
	label.text = label.text.replace("连续世界19","连续世界20").replace("中央岔路；其余区域为可达骨架","世界树环路；西侧林地高台＋石阶占位").replace("本轮重点：小院—林路—","本轮重点：")
	label.text = label.text.replace("2 岔路","2 世界树").replace("3 林地","3 高台")
	label.text = label.text.replace("P 摆件","P 摆件 · F6 石阶入口")

func _unhandled_input(event: InputEvent) -> void:
	if world_ready and event is InputEventKey and event.pressed and event.physical_keycode==KEY_F6:
		_travel_region("steps")
		return
	super._unhandled_input(event)
