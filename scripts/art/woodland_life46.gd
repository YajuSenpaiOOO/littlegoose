extends Node3D
const CAPACITY := 32
var world: Node3D
var wind_enabled := true
var leaves_enabled := true
var lantern_enabled := true
var tree_ids := {}
var near_trees: Array[Dictionary]=[]
var wind_materials: Array[ShaderMaterial]=[]
var leaves: Array[Dictionary]=[]
var leaf_batch: MultiMeshInstance3D
var lantern_root: Node3D
var lantern_body: StaticBody3D
var lantern_light: OmniLight3D
var elapsed := 0.
var refresh_left := 0.
var rng := RandomNumberGenerator.new()
var refresh_at46 := Vector2.INF
var wind_tick46 := -1
var wind_state46 := -1

func _ready() -> void:
	name="WoodlandLife46"
	rng.seed=460018
	rebind_trees()
	_build_leaves()
	_build_lantern()
	_refresh_nearby()
	for i in CAPACITY:
		leaves.append({})
		_spawn(i,true)
	print("WOODLAND46_READY leaf_capacity=",CAPACITY)

func rebind_trees() -> void:
	tree_ids.clear()
	for tree in world.trees:
		tree_ids[tree.visual.get_instance_id()]=true
		if tree.has("shadow19"):
			tree.shadow19.material_override.shader=preload("res://scripts/art/forest_wind46.gdshader")
	_refresh_nearby()

func _refresh_nearby() -> void:
	for material in wind_materials: material.set_shader_parameter("wind_strength",0.)
	near_trees.clear()
	wind_materials.clear()
	var candidates: Array[Dictionary]=[]
	var at := Vector2(world.hero.position.x,world.hero.position.z)
	for tree in world.trees:
		var point := Vector2(tree.root.position.x,tree.root.position.z)
		if point.distance_squared_to(at)<26.*26.: candidates.append(tree)
	candidates.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.root.position.distance_squared_to(world.hero.position)<b.root.position.distance_squared_to(world.hero.position))
	for i in mini(48,candidates.size()):
		var tree: Dictionary=candidates[i]
		near_trees.append(tree)
		wind_materials.append(tree.visual.material_override)
		if tree.has("shadow19"): wind_materials.append(tree.shadow19.material_override)

func _leaf_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rim: Array[Vector3]=[Vector3(-.28,0,0),Vector3(-.21,.30,0),Vector3(0,.57,0),Vector3(.22,.30,0),Vector3(.28,0,0),Vector3(0,-.43,0)]
	for i in rim.size():
		st.set_normal(Vector3.FORWARD)
		st.set_color(Color(.82,.88,.78) if i<3 else Color(1.,1.,1.))
		for p in [Vector3(0,.04,.045),rim[i],rim[(i+1)%rim.size()]]: st.add_vertex(p)
	return st.commit()

func _build_leaves() -> void:
	leaf_batch=MultiMeshInstance3D.new()
	leaf_batch.name="NearbyLeafPool32"
	leaf_batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	leaf_batch.extra_cull_margin=8.
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/leaves46.gdshader")
	leaf_batch.material_override=material
	var multi := MultiMesh.new()
	multi.transform_format=MultiMesh.TRANSFORM_3D
	multi.use_custom_data=true
	multi.mesh=_leaf_mesh()
	multi.instance_count=CAPACITY
	leaf_batch.multimesh=multi
	add_child(leaf_batch)

func _spawn(index: int,initial := false) -> void:
	var leaf: Dictionary=leaves[index]
	leaf.clear()
	var valid := false
	var at := Vector2.ZERO
	var height := 3.
	if not near_trees.is_empty():
		for attempt in 8:
			var tree: Dictionary=near_trees[rng.randi_range(0,mini(near_trees.size()-1,15))]
			at=Vector2(tree.root.position.x,tree.root.position.z)+Vector2(rng.randf_range(-2.,2.),rng.randf_range(-.8,1.4))
			if at.distance_to(Vector2(world.hero.position.x,world.hero.position.z))>18.: continue
			if world.meadow.is_water(at) or Rect2(-7.7,-7.5,6.5,4.2).has_point(at): continue
			height=tree.height*rng.randf_range(.49,.78)
			valid=true
			break
	if not valid:
		leaf.active=false
		leaf_batch.multimesh.set_instance_transform(index,Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO),Vector3.ZERO))
		return
	leaf.active=true
	leaf.at=Vector3(at.x,world.floor_height(at)+height,at.y)
	leaf.age=rng.randf_range(0.,5.) if initial else 0.
	leaf.fall=rng.randf_range(7.,11.)
	leaf.linger=rng.randf_range(2.,3.5)
	leaf.drift=Vector2(rng.randf_range(.10,.22),rng.randf_range(.04,.11))
	leaf.phase=rng.randf()*TAU
	leaf.size=rng.randf_range(.075,.13)
	leaf.land=Vector3.ZERO
	leaf.landed=false
	leaf.color=[Color("8b9347"),Color("a6a251"),Color("738a3e"),Color("b5a360")][rng.randi_range(0,3)]

func _update_leaves(delta: float) -> void:
	for i in leaves.size():
		var leaf: Dictionary=leaves[i]
		if not leaf.active:
			_spawn(i)
			continue
		leaf.age+=delta
		if leaf.age>leaf.fall+leaf.linger:
			_spawn(i)
			continue
		if leaf.at.distance_to(world.hero.position)>24.:
			_spawn(i,true)
			continue
		var t: float=minf(leaf.age,leaf.fall)
		var at: Vector3=leaf.at+Vector3(leaf.drift.x*t+sin(t*1.7+leaf.phase)*.30,0.,leaf.drift.y*t+sin(t*1.1+leaf.phase)*.15)
		var floor_y: float=world.floor_height(Vector2(at.x,at.z))+.018
		at.y=lerpf(leaf.at.y,floor_y,t/leaf.fall)
		if leaf.age>=leaf.fall and not leaf.landed:
			leaf.land=Vector3(at.x,floor_y,at.z)
			leaf.landed=true
		var basis: Basis
		var color: Color=leaf.color
		if leaf.landed:
			at=leaf.land
			basis=Basis(Vector3.UP,leaf.phase)*Basis(Vector3.RIGHT,-PI/2.)
			color.a=1.-smoothstep(leaf.fall+.8,leaf.fall+leaf.linger,leaf.age)
		else:
			basis=Basis(Vector3.UP,t*.9+leaf.phase)*Basis(Vector3.RIGHT,sin(t*2.+leaf.phase)*.7)*Basis(Vector3.FORWARD,sin(t*1.4+leaf.phase)*.8)
			color.a=smoothstep(0.,.7,leaf.age)
		leaf_batch.multimesh.set_instance_transform(i,Transform3D(basis.scaled(Vector3.ONE*leaf.size),at))
		leaf_batch.multimesh.set_instance_custom_data(i,color)

func _build_lantern() -> void:
	# Outside the right end of the short fence, with a visible gap to both rails
	# and the walking entrance. Keep the whole painted bracket clear as well.
	var at := Vector2(-1.0,.85)
	lantern_root=Node3D.new()
	lantern_root.name="CourtyardLantern"
	lantern_root.position=Vector3(at.x,world.floor_height(at),at.y)
	add_child(lantern_root)
	var sprite: Sprite3D=world._sprite(preload("res://assets/woodland46/lantern.png"),Vector2(435,1458),1.85,1376.)
	sprite.billboard=BaseMaterial3D.BILLBOARD_DISABLED
	sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/lantern46.gdshader")
	material.set_shader_parameter("paint",sprite.texture)
	sprite.material_override=material
	lantern_root.add_child(sprite)
	lantern_body=StaticBody3D.new()
	lantern_body.collision_layer=2
	var collider := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius=.13
	cylinder.height=1.85
	collider.shape=cylinder
	collider.position.y=.925
	lantern_body.add_child(collider)
	lantern_root.add_child(lantern_body)
	lantern_light=OmniLight3D.new()
	lantern_light.position=Vector3(.40,1.02,.12)
	lantern_light.light_color=Color("ffc27b")
	lantern_light.light_energy=.65
	lantern_light.omni_range=2.3
	lantern_light.omni_attenuation=1.7
	lantern_light.shadow_enabled=false
	lantern_root.add_child(lantern_light)
	world.garden._contact(lantern_root,at,Vector2(.35,.24),.017,.20)

func set_wind(value: bool) -> void:
	wind_enabled=value
	for material in wind_materials: material.set_shader_parameter("wind_strength",1. if value else 0.)

func set_leaves(value: bool) -> void:
	leaves_enabled=value
	leaf_batch.visible=value

func set_lantern(value: bool) -> void:
	lantern_enabled=value
	lantern_root.visible=value
	lantern_body.collision_layer=2 if value else 0

func _process(delta: float) -> void:
	elapsed+=delta
	refresh_left-=delta
	if refresh_left<=0.:
		refresh_left=.75
		# The near list only changes when the hero actually travels; skip the
		# 600-tree rescan while standing still.
		var at46 := Vector2(world.hero.position.x,world.hero.position.z)
		if at46.distance_squared_to(refresh_at46)>1.: refresh_at46=at46;_refresh_nearby()
	# Wind sways slowly: a 20 Hz clock upload is visually identical to
	# per-frame, and strength only changes through set_wind().
	var tick46 := int(world.clock*20.)
	if tick46!=wind_tick46:
		wind_tick46=tick46
		for material in wind_materials:
			material.set_shader_parameter("wind_clock",world.clock)
	var strength46 := 1 if wind_enabled else 0
	if strength46!=wind_state46:
		wind_state46=strength46
		for material in wind_materials:
			material.set_shader_parameter("wind_strength",1. if wind_enabled else 0.)
	if leaves_enabled: _update_leaves(delta)
