extends Node3D
const LABELS := ["48原版","檐下与墙根暗部","林荫暖院"]
var world: Node3D
var profile := 2
var materials: Dictionary = {}
var shader_cache: Dictionary = {}
var custom_shaders: Dictionary = {}
var house_material: ShaderMaterial

func _ready() -> void:
	name="PorchStudy49"
	house_material=world.house_art.material_override
	house_material.shader=preload("res://scripts/art/cottage_depth49.gdshader")
	for material in world.ground_materials: shade_material(material)
	shade_material(world.grass_material)
	for tree in world.trees: shade_material(tree.visual.material_override)
	for piece in world.root_pieces:
		shade_material(piece.sprite.material_override)
		shade_material(piece.node.material_override)
	for prop in world.props15: shade_material(prop.sprite.material_override)
	set_profile(2)

func _shader_include() -> String:
	return "#include \"res://scripts/art/porch_light49.gdshaderinc\"\n"

func _shader_apply() -> String:
	return "ALBEDO=porch_light49(ALBEDO,porch_position49);"

func _configure_material(_material: ShaderMaterial) -> void:
	pass

func shade_material(material: Material,base_shader: Shader=null) -> void:
	if not material is ShaderMaterial or material.shader==null: return
	var source: Shader=base_shader if base_shader!=null else material.shader
	if custom_shaders.has(source.get_instance_id()): return
	var key := source.get_instance_id()
	if not shader_cache.has(key):
		var code: String=source.code
		var first := code.find("\n")
		code=code.insert(first+1,_shader_include())
		var pos := "porch_position49=VERTEX;" if "world_vertex_coords" in code else "porch_position49=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;"
		if "void vertex()" in code:
			var start := code.find("{",code.find("void vertex()"))
			code=code.insert(start+1,pos)
		else: code+="\nvoid vertex(){"+pos+"}\n"
		# Insert at the end of fragment(), preserving each existing wind/fade path.
		var begin := code.find("{",code.find("void fragment()"))
		var nesting := 1
		var end := begin+1
		while nesting>0:
			if code[end]=="{": nesting+=1
			if code[end]=="}": nesting-=1
			end+=1
		code=code.insert(end-1,"\n "+_shader_apply()+"\n")
		var shader := Shader.new()
		shader.code=code
		shader_cache[key]=shader
		custom_shaders[shader.get_instance_id()]=true
	if material.shader==shader_cache[key]: return
	material.shader=shader_cache[key]
	materials[material.get_instance_id()]=material
	material.set_shader_parameter("porch_light_strength49",1. if profile==2 else 0.)
	_configure_material(material)

func set_profile(value: int) -> void:
	profile=clampi(value,0,2)
	house_material.set_shader_parameter("structure49",1. if profile>0 else 0.)
	house_material.set_shader_parameter("porch_light_strength49",1. if profile==2 else 0.)
	for material in materials.values(): material.set_shader_parameter("porch_light_strength49",1. if profile==2 else 0.)
	_update_actor()
	world._title35()

func _process(_delta: float) -> void:
	_update_actor()

func _update_actor() -> void:
	var at: Vector3=world.hero.global_position
	var shelter := (1.-smoothstep(7.,13.,Vector2(at.x+4.7,at.z+2.8).length())) if profile==2 else 0.
	var feedback := Color.WHITE
	if world.legacy_feel and world.combat_ready:
		feedback=Color(1.,.4,.45).lerp(Color.WHITE,1.-world.hurt_flash/.2) if world.hurt_flash>0. else Color.WHITE
	elif world.invulnerability>.12 and world.wave_state=="fighting": feedback=Color(1.4,.7,.7)
	world.hero.visual.modulate=feedback*Color(lerpf(1.,.96,shelter),lerpf(1.,.95,shelter),lerpf(1.,.91,shelter),1.)
