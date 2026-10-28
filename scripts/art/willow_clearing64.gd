extends "res://scripts/art/landmark_studies63.gd"
var seated_roots := true
var understory_enabled := true
var understory: Node3D
var stones64: Array[Sprite3D]=[]

func _root_fitter() -> RefCounted:
	return preload("res://scripts/art/landmark_roots64.gd").new() if seated_roots else super._root_fitter()

func _ready() -> void:
	super._ready()
	name="WillowRootClearing64"
	understory=Node3D.new()
	understory.name="MossStonesAndRest64"
	add_child(understory)
	_floor_bed()
	for spec in [Vector3(-3.8,.48,3.7),Vector3(-4.5,.32,3.1),Vector3(3.8,.52,3.0),Vector3(4.4,.29,3.7),Vector3(2.7,.35,5.0)]:
		_stone64(Vector2(spec.x,spec.z),spec.y,stones64.size()%4)
	set_understory(true)

func set_seated_roots(enabled: bool) -> void:
	seated_roots=enabled
	set_tree(variant)

func set_understory(enabled: bool) -> void:
	understory_enabled=enabled
	if not is_instance_valid(understory): return
	understory.visible=enabled
	world.tree_bench64.root.visible=enabled
	world.tree_bench64.body.collision_layer=2 if enabled else 0
	world._limit_prop_shadows()

func _floor_bed() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var center: Vector2=world.meadow.landmarks.junction+Vector2(0,1.1)
	for z in 12:
		for x in 16:
			for corner in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var uv: Vector2=(Vector2(x,z)+corner)/Vector2(16,12)
				var at := center+(uv-Vector2(.5,.5))*Vector2(10.0,8.0)
				st.set_normal(world.floor_normal(at))
				st.set_uv(uv)
				st.add_vertex(Vector3(at.x,world.floor_height(at)+.012,at.y))
	var node := MeshInstance3D.new()
	node.name="BrokenMossAndEarthBed64"
	node.mesh=st.commit()
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/willow_floor64.gdshader")
	material.set_shader_parameter("paint",world.ground_templates[3].get_shader_parameter("paint"))
	node.material_override=material
	understory.add_child(node)
	world.porch49.shade_material(material)

func _stone64(offset: Vector2,height: float,index: int) -> void:
	var decor: Node3D=world.atmosphere41.decor
	var profile: Dictionary=decor.profiles.stones[index]
	var texture: Texture2D=decor.textures.stones[index]
	var at: Vector2=world.meadow.landmarks.junction+offset
	var root := Node3D.new()
	root.position=Vector3(at.x,world.floor_height(at)-.04,at.y)
	understory.add_child(root)
	var sprite: Sprite3D=world._sprite(texture,Vector2(profile.foot[0],profile.foot[1]),height,float(profile.height))
	sprite.billboard=BaseMaterial3D.BILLBOARD_DISABLED
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/forest_cutout17.gdshader")
	material.set_shader_parameter("paint",texture)
	material.set_shader_parameter("fade",1.)
	sprite.material_override=material
	root.add_child(sprite)
	world.porch49.shade_material(material)
	world.garden._contact(understory,at,Vector2(height*1.5,height*.75),.025,.23)
	stones64.append(sprite)
