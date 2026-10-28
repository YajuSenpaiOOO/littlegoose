extends Node3D
## Authored world-space accents: no camera-space haze or per-plant CPU simulation.
var world: Node3D
var enabled := true
var shafts_enabled := true
var environment: Environment
var original_environment: Environment
var original_sun_color: Color
var original_sun_energy: float
var flowers: MultiMeshInstance3D
var flower_material: ShaderMaterial
var shafts: Node3D
var frame_trees: Array[Dictionary] = []
var focus_card: MeshInstance3D
var focus_material: ShaderMaterial
var focus_enabled := false

func _ready() -> void:
	name="WoodlandAtmosphere41"
	for child in world.get_children():
		if child is WorldEnvironment:
			environment=child.environment
			original_environment=environment.duplicate(true)
	original_sun_color=world.sun.light_color
	original_sun_energy=world.sun.light_energy
	_build_frame_trees()
	_build_flowers()
	_build_shafts()
	_build_focus()
	set_enabled(not "--no-atmosphere" in OS.get_cmdline_user_args())

func _build_frame_trees() -> void:
	# Foreground framing keeps the door and walking centre open. All tree roots,
	# collision and fitted shadows still use the accepted grounding pipeline.
	for spec in [Vector3(-12.4,6.5,2.0),Vector3(5.8,6.1,2.8)]:
		var at := Vector2(spec.x,spec.z)
		if world.meadow.route_distance(at)<2.: continue
		world._add_route_tree(at,spec.y)
		var index: int=world.trees.size()-1
		world._replace_sprite(world.trees[-1].visual,"young" if index%3==1 else "oak",spec.y,world.style_packs[1])
		frame_trees.append(world.trees[-1])
	world._rebuild_root_pieces()
	world._bake_root_shade()

func _flower_mesh(texture: Texture2D) -> ArrayMesh:
	var image := texture.get_image()
	if image.is_compressed(): image.decompress()
	var used := image.get_used_rect()
	var foot := Vector2(used.get_center().x,used.end.y)
	var scale := 1./float(used.size.y)
	var size := Vector2(image.get_size())*scale
	var left := -foot.x*scale
	var bottom := (foot.y-image.get_height())*scale
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for uv in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]:
		st.set_uv(uv)
		st.set_normal(Vector3(0,.85,.53).normalized())
		st.add_vertex(Vector3(left+uv.x*size.x,bottom+(1.-uv.y)*size.y,0))
	return st.commit()

func _build_flowers() -> void:
	var image: Image=preload("res://assets/atmosphere41/daisy_sprig.png").get_image()
	if image.is_compressed(): image.decompress()
	image.generate_mipmaps()
	var texture := ImageTexture.create_from_image(image)
	flower_material=ShaderMaterial.new()
	flower_material.shader=preload("res://scripts/art/flower41.gdshader")
	flower_material.set_shader_parameter("paint",texture)
	flowers=MultiMeshInstance3D.new()
	flowers.name="LowDaisies_WorldSpace"
	flowers.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	flowers.material_override=flower_material
	flowers.visibility_range_end=44.
	flowers.extra_cull_margin=.3
	var multi := MultiMesh.new()
	multi.transform_format=MultiMesh.TRANSFORM_3D
	multi.use_colors=true
	multi.mesh=_flower_mesh(texture)
	var positions: Array[Vector2] = []
	var rng := RandomNumberGenerator.new()
	rng.seed=410041
	# Irregular little colonies near walls, the house corners and the outside
	# of the approach bend; never an evenly scattered lawn or solid bush border.
	var colonies: Array[Vector2]=[Vector2(-8.9,-3.7),Vector2(-1.6,-4.1),Vector2(-8.,.8),Vector2(-10.2,.9),Vector2(-2.4,-1.),Vector2(1.3,-2.8),Vector2(3.8,-4.5),Vector2(4.5,-7.8)]
	var route: PackedVector2Array=world.meadow.route
	for i in range(5,mini(route.size(),34),6):
		var tangent: Vector2=(route[i+1]-route[i-1]).normalized()
		colonies.append(route[i]+Vector2(-tangent.y,tangent.x)*(1.25 if i%2==0 else -1.3))
	for center in colonies:
		for i in rng.randi_range(6,11):
			var at := center+Vector2(rng.randf_range(-.75,.75),rng.randf_range(-.36,.36))
			if world.meadow.route_distance(at)<.91 or world.meadow.is_water(at): continue
			if at.x> -8.1 and at.x< -1.3 and at.y< -4.7: continue
			positions.append(at)
	multi.instance_count=positions.size()
	for i in positions.size():
		var at := positions[i]
		var height := rng.randf_range(.22,.42)
		var basis := Basis(Vector3.RIGHT,deg_to_rad(-25.)).scaled(Vector3(height*(1. if i%3 else -1.),height,height))
		var y: float=world.meadow.height_at(at.x,at.y,world.terrain_enabled)-.025
		multi.set_instance_transform(i,Transform3D(basis,Vector3(at.x,y,at.y)))
		multi.set_instance_color(i,Color(1.,rng.randf_range(.95,1.),rng.randf_range(.88,.98)))
	flowers.multimesh=multi
	add_child(flowers)

func _build_shafts() -> void:
	shafts=Node3D.new()
	shafts.name="CanopyOpenings_Sunlight"
	add_child(shafts)
	# The direction is derived from the actual sun, rather than painted into
	# a fullscreen overlay. The terrain and tree depth buffer occlude each ribbon.
	var direction: Vector3=-world.sun.global_basis.z
	var ends: Array[Vector2]=[Vector2(-10.,0.),Vector2(1.,-2.),Vector2(4.,-9.)]
	var route: PackedVector2Array=world.meadow.route
	if route.size()>20:
		ends.append(route[12]+Vector2(-1.6,0))
		ends.append(route[20]+Vector2(1.7,0))
	for i in ends.size():
		var p := ends[i]
		var bottom := Vector3(p.x,world.meadow.height_at(p.x,p.y,true)+.04,p.y)
		var top := bottom-direction*8.4
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for uv in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]:
			st.set_uv(uv)
			st.add_vertex(top.lerp(bottom,uv.y)+Vector3.RIGHT*(uv.x-.5)*lerpf(.38,1.65,uv.y))
		var ribbon := MeshInstance3D.new()
		ribbon.mesh=st.commit()
		ribbon.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ribbon.visibility_range_end=40.
		var material := ShaderMaterial.new()
		material.shader=preload("res://scripts/art/sunshaft41.gdshader")
		material.set_shader_parameter("phase",float(i)*1.7)
		ribbon.material_override=material
		shafts.add_child(ribbon)

func set_enabled(value: bool) -> void:
	enabled=value
	flowers.visible=enabled
	shafts.visible=enabled and shafts_enabled
	for tree in frame_trees:
		tree.root.visible=enabled
		for child in tree.root.get_children():
			if child is StaticBody3D: child.collision_layer=2 if enabled else 0
	focus_card.visible=enabled and focus_enabled
	if enabled:
		environment.ambient_light_color=Color("b7c6c3")
		environment.ambient_light_energy=.32
		environment.fog_mode=Environment.FOG_MODE_DEPTH
		environment.fog_enabled=true
		environment.fog_depth_begin=24.
		environment.fog_depth_end=95.
		environment.fog_depth_curve=1.35
		environment.fog_density=.48
		environment.fog_light_color=Color("91aba0")
		environment.fog_light_energy=.75
		world.sun.light_color=Color("fff0d5")
		world.sun.light_energy=.77
	else:
		for property in ["ambient_light_color","ambient_light_energy","fog_mode","fog_enabled","fog_depth_begin","fog_depth_end","fog_depth_curve","fog_density","fog_light_color","fog_light_energy"]:
			environment.set(property,original_environment.get(property))
		world.sun.light_color=original_sun_color
		world.sun.light_energy=original_sun_energy
	world._bake_root_shade()

func toggle_shafts() -> void:
	shafts_enabled=not shafts_enabled
	shafts.visible=enabled and shafts_enabled

func _build_focus() -> void:
	focus_card=MeshInstance3D.new()
	focus_card.name="OptionalDepthFocus_NoMotionBlur"
	var quad := QuadMesh.new()
	quad.size=Vector2(2,2)
	focus_card.mesh=quad
	focus_card.extra_cull_margin=1000.
	focus_card.position.z=-1.
	focus_card.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	focus_material=ShaderMaterial.new()
	focus_material.shader=preload("res://scripts/art/scenic_focus41.gdshader")
	# Blur the opaque scenery before translucent crowns, rays and shot guides.
	focus_material.render_priority=-100
	focus_card.material_override=focus_material
	world.camera.add_child(focus_card)

func toggle_focus() -> void:
	focus_enabled=not focus_enabled
	focus_card.visible=enabled and focus_enabled

func _process(_delta: float) -> void:
	if enabled:
		flower_material.set_shader_parameter("walker",world.hero.global_position)
		flower_material.set_shader_parameter("clock",world.clock)
		if shafts.visible:
			for beam in shafts.get_children(): beam.material_override.set_shader_parameter("clock",world.clock)
	if focus_card.visible:
		var view_point: Vector3=world.camera.to_local(world.hero.global_position+Vector3.UP*.65)
		focus_material.set_shader_parameter("focus_distance",-view_point.z)
