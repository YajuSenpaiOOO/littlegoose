extends "res://scripts/living_path18.gd"
## Whole-map geography; first authored run is home -> forest -> central junction.
var world_ready := false
var grass_batches: Array[Dictionary] = []
var ground_templates: Array[ShaderMaterial] = []
var map_panel: Control
var water_material19: ShaderMaterial
var bridge_collision: CollisionShape3D
var region_names := {"home":"小院","junction":"中央岔路","grove":"西侧林地","shore":"东侧湖岸","station":"出发站预留区","landing":"码头预留区"}

func _build_lab_floor() -> void:
	meadow = preload("res://scripts/world/world_surface19.gd").new()
	ground = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(200,200)
	ground.mesh = plane
	add_child(ground)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	floor_collider = CollisionShape3D.new()
	floor_collider.shape = plane.create_trimesh_shape()
	body.add_child(floor_collider)
	ground.add_child(body)
	var bounds: Rect2 = meadow.world_bounds
	for x in [bounds.position.x,bounds.end.x]: _box(Vector3(x,2,bounds.get_center().y),Vector3(.3,6,bounds.size.y),Color.TRANSPARENT,true,false)
	for z in [bounds.position.y,bounds.end.y]: _box(Vector3(bounds.get_center().x,2,z),Vector3(bounds.size.x,6,.3),Color.TRANSPARENT,true,false)

func _grass_allowed19(_at: Vector2) -> bool:
	return true

func _grass_road_distance19(at: Vector2) -> float: return meadow.route_distance(at)

func _build_lab_grass() -> void:
	cross_mesh = _cross_mesh()
	blade_mesh = _blade_mesh()
	meadow_meshes.append(blade_mesh)
	for kind in range(1,4): meadow_meshes.append(meadow.blades(kind))
	var bounds: Rect2 = meadow.world_bounds
	for iz in ceili(bounds.size.y/12.):
		for ix in ceili(bounds.size.x/12.):
			var center := bounds.position+Vector2(ix,iz)*12.+Vector2(6,6)
			var rng := RandomNumberGenerator.new()
			rng.seed = 190019+ix*173+iz*337
			var points: Array[Transform3D] = []
			var colors: Array[Color] = []
			for attempt in 720:
				var at := center+Vector2(rng.randf_range(-6,6),rng.randf_range(-6,6))
				if not bounds.has_point(at) or meadow.is_water(at) or meadow.bridge_rect.has_point(at): continue
				if meadow.station_paving_rect().has_point(at): continue
				if not _grass_allowed19(at): continue
				if at.x> -8.2 and at.x< -1.2 and at.y> -9.7 and at.y< -4.5: continue
				var d: float = _grass_road_distance19(at)
				if d<.86: continue
				var scale := rng.randf_range(.65,1.05) if d>1.2 else rng.randf_range(.38,.62)
				var basis := Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*scale)
				points.append(Transform3D(basis,Vector3(at.x,0,at.y)))
				var seed_value := rng.randf()
				colors.append(Color(0,seed_value,1. if seed_value<.3 and d>1.2 else 0.,1))
			if points.is_empty(): continue
			var node := MultiMeshInstance3D.new()
			node.name = "GrassChunk_%d_%d"%[ix,iz]
			node.position = Vector3(center.x,0,center.y)
			node.visibility_range_end = 46.
			node.extra_cull_margin = .65
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var multi := MultiMesh.new()
			multi.transform_format = MultiMesh.TRANSFORM_3D
			multi.use_custom_data = true
			multi.mesh = meadow_meshes[2]
			multi.instance_count = points.size()
			node.multimesh = multi
			for i in points.size(): multi.set_instance_custom_data(i,colors[i])
			add_child(node)
			grass_batches.append({"node":node,"points":points})
	grass = grass_batches[0].node
	planting.assign(grass_batches[0].points)

func _refresh_planting() -> void:
	for batch in grass_batches:
		for i in batch.points.size():
			var original: Transform3D = batch.points[i]
			var at: Vector3 = original.origin
			var normal: Vector3 = meadow.normal_at(at.x,at.z,terrain_enabled)
			var right := Vector3.RIGHT.slide(normal).normalized()
			var frame := Basis(right,normal,right.cross(normal))
			var basis := frame*original.basis
			var pos: Vector3 = Vector3(at.x,meadow.height_at(at.x,at.z,terrain_enabled),at.z)-batch.node.position
			batch.node.multimesh.set_instance_transform(i,Transform3D(basis,pos))

func _build_woodland() -> void:
	var bounds: Rect2 = meadow.world_bounds
	var rng := RandomNumberGenerator.new()
	rng.seed = 190031
	for iz in ceili(bounds.size.y/3.9):
		for ix in ceili(bounds.size.x/3.9):
			var at := bounds.position+Vector2(ix,iz)*3.9+Vector2(rng.randf_range(-.7,.7),rng.randf_range(-.7,.7))
			if not bounds.grow(-.6).has_point(at) or meadow.is_water(at) or meadow.is_open_ground(at): continue
			if meadow.route_distance(at)<1.85: continue
			# Author camera-facing sight wedges at the two first-stage focal areas.
			# Trunks outside a clearing can still cover it with a huge near canopy.
			var home_front := at.y> -2.5 and at.y<14. and at.x> -15. and at.x<6.
			var view_front := false
			for key in ["junction","grove","shore","station","landing"]:
				var delta: Vector2 = at-meadow.landmarks[key]
				if delta.y>0. and delta.y<13. and absf(delta.x)<3.+delta.y*.55:
					view_front = true
					break
			if home_front or view_front: continue
			_add_route_tree(at,rng.randf_range(5.5,7.3))
			var tree: Dictionary = trees[-1]
			tree.root.name = "WorldTree%03d"%(trees.size()-1)
			tree.visual.visibility_range_end = 72.

func _add_route_tree(at: Vector2,height: float) -> void:
	# Placement was already checked against ALL routes; do not shift it again
	# using the old sample's single-route correction.
	var root := Node3D.new()
	root.position = Vector3(at.x,meadow.height_at(at.x,at.y,terrain_enabled),at.y)
	add_child(root)
	var visual := _art("oak",height)
	root.add_child(visual)
	var body := StaticBody3D.new()
	body.collision_layer = 2
	var collider := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = .35
	cylinder.height = 2.6
	collider.shape = cylinder
	collider.position.y = 1.3
	body.add_child(collider)
	root.add_child(body)
	trees.append({"root":root,"visual":visual,"height":height})
	if at.distance_to(Vector2(-4.7,-4.8))>35.: distant_roots.append(root)

func _rebuild_root_pieces() -> void:
	super._rebuild_root_pieces()
	for piece in root_pieces:
		piece.node.visibility_range_end = 72.
		piece.sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_update_tree_blending()
	for tree in trees:
		var sprite: Sprite3D = tree.visual
		var shadow: Sprite3D
		if tree.has("shadow19"):
			shadow = tree.shadow19
		else:
			shadow = Sprite3D.new()
			shadow.name = "IndependentTreeShadow"
			tree.root.add_child(shadow)
			tree.shadow19 = shadow
		shadow.texture = sprite.texture
		shadow.pixel_size = sprite.pixel_size
		shadow.offset = sprite.offset
		shadow.position = sprite.position
		shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		shadow.visibility_range_end = 72.
		var material: ShaderMaterial = sprite.material_override.duplicate()
		material.shader = preload("res://scripts/art/forest_cutout17.gdshader")
		material.set_shader_parameter("fade",1.)
		shadow.material_override = material

func _build_props15() -> void:
	super._build_props15()
	for offset in [Vector2(-5,1.8),Vector2(5,1.8)]:
		_add_prop15("bench",meadow.landmarks.station+offset,1.15,Vector3(2.1,.8,.65))

func _configure_route() -> void:
	pass # Each terrain chunk receives only its nearby road segments below.

func _ready() -> void:
	super._ready()
	ground_templates.assign(ground_materials)
	for material in meadow_materials: material.shader = preload("res://scripts/art/world_grass19.gdshader")
	world_ready = true
	_assign_ground_materials()
	for batch in grass_batches:
		batch.node.material_override = grass_material
	_build_water_and_bridge()
	_build_wayfinding()
	_build_map_panel()
	_bake_root_shade()
	_update_prop_contacts()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--region="): _travel_region(arg.trim_prefix("--region="))
		if arg=="--map": map_panel.show()
	_status()
	print("WORLD19_READY trees=",trees.size()," grass_chunks=",grass_batches.size()," terrain_chunks=",meadow.chunks.size())

func _assign_ground_materials() -> void:
	ground_materials.clear()
	for i in meadow.chunks.size():
		var chunk: Dictionary = meadow.chunks[i]
		var material: ShaderMaterial = ground_templates[3].duplicate()
		material.shader = preload("res://scripts/art/world_ground19.gdshader")
		var lines := PackedVector4Array()
		var widths := PackedFloat32Array()
		assert(chunk.segments.size()<=64,"road chunk exceeds uniform capacity")
		for id in chunk.segments:
			var s: Dictionary = meadow.segments[id]
			lines.append(Vector4(s.a.x,s.a.y,s.b.x,s.b.y))
			widths.append(s.radius)
		var count := lines.size()
		lines.resize(64)
		widths.resize(64)
		material.set_shader_parameter("route_layout",true)
		material.set_shader_parameter("route_segments",lines)
		material.set_shader_parameter("route_widths",widths)
		material.set_shader_parameter("route_count",count)
		material.set_shader_parameter("road_relief",meadow.profile.enabled)
		material.set_shader_parameter("surface_spots",soil_spots)
		material.set_shader_parameter("detailed_path",detailed_path)
		material.set_shader_parameter("forest_depth",depth_lighting)
		ground.mesh.surface_set_material(i,material)
		ground_materials.append(material)
	ground.material_override = null
	uploaded_revision = -1
	_sync_tracks()

func set_candidate(index: int) -> void:
	if not world_ready:
		super.set_candidate(index)
		return
	# The accepted ground/house style stays locked; grass controls still work.
	var saved: Array[ShaderMaterial] = ground_materials
	ground_materials = ground_templates
	super.set_candidate(3)
	ground_materials = saved
	ground.material_override = null
	for batch in grass_batches:
		batch.node.material_override = grass_material
		batch.node.multimesh.mesh = grass.multimesh.mesh

func set_art_style(index: int) -> void:
	if not world_ready: super.set_art_style(index)

func _rebuild_terrain() -> void:
	super._rebuild_terrain()
	if world_ready:
		_assign_ground_materials()
		if is_instance_valid(bridge_collision): bridge_collision.shape = _bridge_mesh().create_trimesh_shape()
		_bake_root_shade()

func _teleport15(at: Vector2) -> void:
	super._teleport15(at)
	if meadow.has_method("walk_height"):
		hero.position.y = meadow.walk_height(at,terrain_enabled)+.08
		hero.reset_physics_interpolation()
		_update_camera(0,true)

func _bake_root_shade() -> void:
	if not world_ready:
		super._bake_root_shade()
		return
	var mask := Image.create(768,512,false,Image.FORMAT_RGBA8)
	mask.fill(Color(0,0,0,1))
	for tree in trees:
		if not tree.root.visible: continue
		var at: Vector3 = tree.root.position
		_stamp_world(mask,Vector2(at.x,at.z),Vector2(2.5,2.),0)
		_stamp_world(mask,Vector2(at.x,at.z),Vector2(.55,.4),1)
	_stamp_world(mask,Vector2(-4.7,-4.95),Vector2(2.1,.36),2)
	shade_texture = ImageTexture.create_from_image(mask)
	var bounds: Rect2 = meadow.world_bounds
	for material in ground_materials+meadow_materials:
		material.set_shader_parameter("forest_mask",shade_texture)
		material.set_shader_parameter("forest_mask_bounds",Vector4(bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y))
	for material in ground_materials: material.set_shader_parameter("forest_layout",true)

func _stamp_world(mask: Image,at: Vector2,radius: Vector2,channel: int) -> void:
	var bounds: Rect2 = meadow.world_bounds
	var center := (at-bounds.position)/bounds.size*Vector2(mask.get_size())
	var extent := radius/bounds.size*Vector2(mask.get_size())*2.4
	var rect := Rect2i(Vector2i(center-extent),Vector2i(extent*2)+Vector2i.ONE).intersection(Rect2i(Vector2i.ZERO,mask.get_size()))
	for y in range(rect.position.y,rect.end.y):
		for x in range(rect.position.x,rect.end.x):
			var p := (Vector2(x,y)+Vector2.ONE*.5)/Vector2(mask.get_size())*bounds.size+bounds.position
			var strength := exp(-((p-at)/radius).length_squared()*1.7)
			var color := mask.get_pixel(x,y)
			color[channel] = maxf(color[channel],strength)
			mask.set_pixel(x,y,color)

func _water_mesh(polygon: PackedVector2Array,height: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in Geometry2D.triangulate_polygon(polygon):
		var p := polygon[index]
		st.set_normal(Vector3.UP)
		st.set_uv(p)
		st.add_vertex(Vector3(p.x,height,p.y))
	return st.commit()

func _bridge_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rect: Rect2 = meadow.bridge_rect
	for i in 80:
		var a := rect.position.x+rect.size.x*float(i)/80.
		var b := rect.position.x+rect.size.x*float(i+1)/80.
		for p in [Vector2(a,rect.position.y),Vector2(b,rect.position.y),Vector2(b,rect.end.y),Vector2(a,rect.position.y),Vector2(b,rect.end.y),Vector2(a,rect.end.y)]:
			st.set_normal(Vector3.UP)
			st.set_uv(p)
			st.add_vertex(Vector3(p.x,meadow.bridge_height(p.x)+.015,p.y))
	return st.commit()

func _water_pieces19() -> Array[PackedVector2Array]:
	return Geometry2D.clip_polygons(meadow.water,meadow.island)

func _build_water_and_bridge() -> void:
	water_material19 = ShaderMaterial.new()
	water_material19.shader = preload("res://scripts/art/world_water19.gdshader")
	var pieces: Array[PackedVector2Array] = _water_pieces19()
	for polygon in pieces:
		var lake := MeshInstance3D.new()
		lake.name = "LakeSurface"
		lake.mesh = _water_mesh(polygon,-.28)
		lake.material_override = water_material19
		lake.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(lake)
		var rect: Rect2 = meadow.bridge_rect.grow(.2)
		var bridge_cut := PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
		for outline in Geometry2D.clip_polygons(polygon,bridge_cut):
			var triangles := Geometry2D.triangulate_polygon(outline)
			var body := StaticBody3D.new()
			body.name = "WaterBoundary"
			body.collision_layer = 2
			add_child(body)
			for i in range(0,triangles.size(),3):
				var vertices := PackedVector3Array()
				for j in 3:
					var p: Vector2 = outline[triangles[i+j]]
					vertices.append(Vector3(p.x,-3,p.y))
					vertices.append(Vector3(p.x,2,p.y))
				var shape := ConvexPolygonShape3D.new()
				shape.points = vertices
				var collision := CollisionShape3D.new()
				collision.shape = shape
				body.add_child(collision)
	var deck := MeshInstance3D.new()
	deck.name = "ContinuousBridgeDeck"
	deck.mesh = _bridge_mesh()
	var wood := ShaderMaterial.new()
	wood.shader = preload("res://scripts/art/world_wood19.gdshader")
	deck.material_override = wood
	add_child(deck)
	bridge_collision = CollisionShape3D.new()
	bridge_collision.shape = deck.mesh.create_trimesh_shape()
	floor_collider.get_parent().add_child(bridge_collision)
	var bridge: Rect2 = meadow.bridge_rect
	for z in [bridge.position.y,bridge.end.y]:
		var center := Vector3(bridge.get_center().x,.68,z)
		var rail := _box(center,Vector3(bridge.size.x,.09,.10),Color("856044"))
		rail.material_override = wood
		for i in 10:
			var x := lerpf(bridge.position.x,bridge.end.x,float(i)/9.)
			var post := _box(Vector3(x,meadow.bridge_height(x)+.42,z),Vector3(.13,.84,.13),Color("916a44"))
			post.material_override = wood

func _build_wayfinding() -> void:
	var at: Vector2 = _junction_sign_position()
	var y: float = meadow.height_at(at.x,at.y,true)
	_box(Vector3(at.x,y+.75,at.y),Vector3(.12,1.5,.12),Color("705536"))
	for i in 3:
		var z := at.y+.03
		var h := y+1.42-float(i)*.29
		_box(Vector3(at.x,h,z),Vector3(1.7,.25,.12),Color("8e6842"),false)
		var text := Label3D.new()
		text.text = ["↑ 出发站","← 林地","湖岸 →"][i]
		text.font_size = 32
		text.pixel_size = .005
		text.position = Vector3(at.x,h,z+.07)
		text.modulate = Color("f5e7b7")
		text.outline_size = 2
		add_child(text)
	# Reserve the original departure square without inventing a finished station.
	var station: Vector2 = meadow.landmarks.station
	var paving := MeshInstance3D.new()
	paving.name = "DeparturePlaza"
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in 6:
		for x in 16:
			var a := Vector2(x,z)
			for p in [a,a+Vector2(1,0),a+Vector2.ONE,a,a+Vector2.ONE,a+Vector2(0,1)]:
				var at2: Vector2 = station+Vector2(-8,-4.8)+p
				st.set_normal(Vector3.UP)
				st.set_uv(p/Vector2(16,6))
				st.add_vertex(Vector3(at2.x,meadow.height_at(at2.x,at2.y,true)+.03,at2.y))
	paving.mesh = st.commit()
	var material := StandardMaterial3D.new()
	material.albedo_texture = load("res://assets/departure_plaza_v1/paving.png")
	material.albedo_color = Color(.70,.71,.62)
	material.uv1_scale = Vector3(8,3,1)
	material.roughness = 1.
	paving.material_override = material
	add_child(paving)

func _junction_sign_position() -> Vector2:
	return meadow.landmarks.junction+Vector2(1.35,1.1)

func _build_map_panel() -> void:
	map_panel = preload("res://scripts/world/world_map19.gd").new()
	map_panel.surface = meadow
	map_panel.actor = hero
	map_panel.position = Vector2(1165,20)
	map_panel.size = Vector2(410,310)
	label.get_parent().add_child(map_panel)
	map_panel.hide()

func _travel_region(key: String) -> void:
	if key=="trail":
		_teleport15(meadow.main_route[5])
		return
	if not meadow.landmarks.has(key): return
	var at: Vector2 = meadow.landmarks[key]
	if key=="home": at = Vector2(-4.7,-2.6)
	if key=="station": at += Vector2(0,3.)
	_teleport15(at)

func _process(delta: float) -> void:
	super._process(delta)
	if world_ready:
		_update_tree_blending()
		_limit_prop_shadows()
		water_material19.set_shader_parameter("clock",clock)
		if map_panel.visible: map_panel.queue_redraw()

func _update_tree_blending() -> void:
	# Only the handful of occluding crowns need alpha blending/depth prepass.
	# Keep the rest on the accepted opaque cutout path to avoid full-forest overdraw.
	for piece in root_pieces:
		var fade: float = piece.sprite.material_override.get_shader_parameter("fade")
		var shader: Shader = preload("res://scripts/art/world_tree19.gdshader") if fade<.999 else preload("res://scripts/art/forest_cutout17.gdshader")
		if piece.sprite.material_override.shader!=shader: piece.sprite.material_override.shader = shader
		if piece.node.material_override.shader!=shader: piece.node.material_override.shader = shader

func _update_prop_contacts() -> void:
	super._update_prop_contacts()
	if world_ready: _limit_prop_shadows()

func _limit_prop_shadows() -> void:
	for entry in fitted_cards:
		entry.card.visible = contact_enabled and entry.prop.root.position.distance_to(hero.position)<40.
	for foot in contact_marks:
		foot.mark.visible = contact_enabled and props_enabled and foot.prop.root.position.distance_to(hero.position)<40.

func _status() -> void:
	if not world_ready:
		super._status()
		return
	var nearest := "home"
	var distance := INF
	var at := Vector2(hero.position.x,hero.position.z)
	for key in meadow.landmarks:
		var d: float = at.distance_to(meadow.landmarks[key])
		if d<distance: distance = d; nearest = key
	label.text = "连续世界19 · %s · 25°透视 · 1号青灰房\nWASD / Shift 移动 · 滚轮缩放 · Tab 路线图 · F1 隐藏说明\n1 小院 / 2 岔路 / 3 林地 / 4 湖岸 / 5 车站预留 / 6 码头预留\nU 浅路肩 · I 土色斑 · F4 脚印 · V 接地 · P 摆件\n本轮重点：小院—林路—中央岔路；其余区域为可达骨架"%region_names[nearest]
	var panel: ColorRect = label.get_parent().get_child(0)
	panel.position.y = get_viewport().get_visible_rect().size.y-178.
	panel.size.y = 163.
	label.position.y = panel.position.y+10.

func _unhandled_input(event: InputEvent) -> void:
	if world_ready and event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6:
				_travel_region(["home","junction","grove","shore","station","landing"][event.physical_keycode-KEY_1]); return
			KEY_TAB: map_panel.visible = not map_panel.visible; return
			KEY_F2: _travel_region("junction"); return
			KEY_F3,KEY_R: _travel_region("home"); return
	super._unhandled_input(event)
	if world_ready and event is InputEventKey and event.pressed and event.physical_keycode==KEY_G:
		for batch in grass_batches: batch.node.visible = plants_enabled
