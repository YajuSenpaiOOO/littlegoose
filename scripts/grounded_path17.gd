extends "res://scripts/house_draw16.gd"
var surface_ready := false
var detailed_path := true
var fitted_cards: Array[Dictionary] = []

func _rebuild_root_pieces() -> void:
	super._rebuild_root_pieces()
	# Painted cards retain scene illumination and cast ground shadows. Receiving
	# their own flat-card shadow on a bent root strip creates a false dark cut.
	for piece in root_pieces:
		piece.sprite.material_override.shader = preload("res://scripts/art/forest_cutout17.gdshader")
		piece.node.material_override.shader = preload("res://scripts/art/forest_cutout17.gdshader")

func _build_lab_grass() -> void:
	super._build_lab_grass()
	var colors: Array[Color] = []
	for i in planting.size(): colors.append(grass.multimesh.get_instance_custom_data(i))
	var rng := RandomNumberGenerator.new()
	rng.seed = 170017
	# Sparse short growth crosses the broken border; leave the walking center clear.
	for i in 480:
		var segment := rng.randi_range(0,meadow.route.size()-2)
		var a: Vector2 = meadow.route[segment]
		var b: Vector2 = meadow.route[segment+1]
		var tangent := (b-a).normalized()
		var side := -1. if rng.randf()<.5 else 1.
		var at := a.lerp(b,rng.randf())+Vector2(-tangent.y,tangent.x)*side*rng.randf_range(.86,1.16)
		if meadow.route_distance(at)<.84: continue
		if at.x< -6.2 and at.y> -.8 and at.y<1.: continue
		var basis := Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*rng.randf_range(.38,.62))
		planting.append(Transform3D(basis,Vector3(at.x,0,at.y)))
		colors.append(Color(0,rng.randf(),0,1))
	grass.multimesh.instance_count = planting.size()
	for i in planting.size():
		grass.multimesh.set_instance_transform(i,planting[i])
		grass.multimesh.set_instance_custom_data(i,colors[i])

func _ready() -> void:
	grounding = preload("res://scripts/art/grounding17.gd").new()
	super._ready()
	for material in ground_materials:
		material.shader = preload("res://scripts/art/ground_path17.gdshader")
		material.set_shader_parameter("detailed_path",true)
	for prop in props15:
		var card := MeshInstance3D.new()
		card.name = "DepthFittedPaintedShadow"
		card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		var material: ShaderMaterial = prop.sprite.material_override.duplicate()
		material.set_shader_parameter("root_cut_y",1.)
		material.set_shader_parameter("fade",1.)
		card.material_override = material
		prop.root.add_child(card)
		fitted_cards.append({"prop":prop,"card":card})
	surface_ready = true
	for arg in OS.get_cmdline_user_args():
		if arg=="--view=mid": _teleport15(Vector2(0,-9))
		if arg=="--view=props":
			camera_distance = 12.
			_teleport15(Vector2(-6.,-1.))
	_update_prop_contacts()
	_status()

func _support_pixel(prop: Dictionary,x: float) -> Vector2:
	var feet: Array = prop.feet16
	if x<=feet[0].pixel.x: return Vector2(x,feet[0].pixel.y)
	for i in range(feet.size()-1):
		var a: Vector2 = feet[i].pixel
		var b: Vector2 = feet[i+1].pixel
		if x<=b.x: return Vector2(x,lerpf(a.y,b.y,(x-a.x)/maxf(b.x-a.x,.001)))
	return Vector2(x,feet[-1].pixel.y)

func _depth_fitted_point(prop: Dictionary,pixel: Vector2) -> Vector3:
	return camera.global_position+(_pixel_world(prop.sprite,pixel)-camera.global_position)*_depth_factor(prop,pixel.x)

func _depth_factor(prop: Dictionary,x: float) -> float:
	var origin := camera.global_position
	var support := _pixel_world(prop.sprite,_support_pixel(prop,x))
	var on_floor := _ground_below_image(support)-Vector3.UP*.014
	var ray := support-origin
	var factor := (on_floor-origin).dot(ray)/ray.length_squared()
	# Scaling each column along camera rays retains the painted projection while
	# giving its foot the actual depth of that particular leg or wall corner.
	return factor

func _ground_below_image(point: Vector3) -> Vector3:
	var origin := camera.global_position
	var direction := (point-origin).normalized()
	# Use the actual triangulated floor, both faster and more accurate than
	# repeatedly solving the analytic height function at every camera movement.
	var query := PhysicsRayQueryParameters3D.create(origin,origin+direction*200.,1)
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	if not collision.is_empty() and collision.collider==floor_collider.get_parent():
		return collision.position+Vector3.UP*.014
	# Ready-time geometry can precede its first physics synchronization.
	var low := 0.
	var high := maxf((origin.y+4.)/-direction.y,1.)
	for i in 20:
		var middle := (low+high)*.5
		var at := origin+direction*middle
		if at.y>meadow.height_at(at.x,at.z,terrain_enabled): low = middle
		else: high = middle
	var hit := origin+direction*((low+high)*.5)
	return hit+Vector3.UP*.014

func _update_prop_contacts() -> void:
	super._update_prop_contacts()
	if not surface_ready: return
	for entry in fitted_cards:
		var prop: Dictionary = entry.prop
		prop.volume16.hide()
		entry.card.visible = contact_enabled
		var size: Vector2 = prop.sprite.texture.get_size()
		var columns: Array[float] = [0.,size.x]
		for i in range(1,13): columns.append(size.x*float(i)/13.)
		for foot in prop.feet16: columns.append(foot.pixel.x)
		columns.sort()
		var factors: Array[float] = []
		for x in columns: factors.append(_depth_factor(prop,x))
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(columns.size()-1):
			var a: float = columns[i]/size.x
			var b: float = columns[i+1]/size.x
			for uv in [Vector2(a,0),Vector2(b,0),Vector2(b,1),Vector2(a,0),Vector2(b,1),Vector2(a,1)]:
				st.set_normal(Vector3.BACK)
				st.set_uv(uv)
				var factor: float = factors[i] if uv.x==a else factors[i+1]
				var world := camera.global_position+(_pixel_world(prop.sprite,uv*size)-camera.global_position)*factor
				st.add_vertex(prop.root.to_local(world))
		entry.card.mesh = st.commit()

func _status() -> void:
	super._status()
	if surface_ready:
		label.text = label.text.replace("正面小屋16","接地与土径17")+"\nJ 土径边缘/纹理对照："+("碎边土径" if detailed_path else "旧模糊边")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_J:
		detailed_path = not detailed_path
		for material in ground_materials: material.set_shader_parameter("detailed_path",detailed_path)
		_status()
		return
	super._unhandled_input(event)
