extends "res://scripts/art/rock_surfaces91.gd"
var edge_points92: Dictionary={}
var edge_grass92: MultiMeshInstance3D
func _stone_shader91() -> Shader: return preload("res://scripts/art/bedrock92.gdshader")
func _stone_texture91() -> Texture2D: return preload("res://assets/stone92/painted_bedrock92.png")
func _needs_edge_distance91() -> bool: return true

func _emit_stone91(st: SurfaceTool,position: Vector3,normal: Vector3,original_normal: Vector3,distance: float) -> void:
	super._emit_stone91(st,position,normal,original_normal,distance)
	if distance<.018 and original_normal.y>.86:
		edge_points92[Vector3i((position/.72).round())]={"position":position,"normal":original_normal}

func _ready() -> void:
	super._ready()
	rock91.material_override.set_shader_parameter("grass_paint92",world.ground_templates[3].get_shader_parameter("paint"))
	var poses: Array[Transform3D]=[]
	for key in edge_points92:
		var item: Dictionary=edge_points92[key]
		var at: Vector3=item.position
		if sin(at.x*.65+at.z*.41)< -.1: continue
		var normal: Vector3=item.normal
		var right := Vector3.RIGHT.slide(normal).normalized()
		var frame := Basis(right,normal,right.cross(normal))
		poses.append(Transform3D(frame.scaled(Vector3(.65,.55,.65)),at+normal*.012))
	edge_grass92=MultiMeshInstance3D.new();edge_grass92.name="BrokenGrassRim92"
	var multi := MultiMesh.new();multi.transform_format=MultiMesh.TRANSFORM_3D
	multi.use_custom_data=true;multi.mesh=world.meadow.blades(2);multi.instance_count=poses.size()
	for i in poses.size(): multi.set_instance_transform(i,poses[i]);multi.set_instance_custom_data(i,Color(0,.4,1,1))
	edge_grass92.multimesh=multi;edge_grass92.material_override=world.grass_material
	edge_grass92.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	edge_grass92.visibility_range_end=46.;add_child(edge_grass92)
	print("GRASS_RIM92 tufts=",poses.size())

func set_enabled91(value: bool) -> void:
	super.set_enabled91(value)
	if is_instance_valid(edge_grass92): edge_grass92.visible=value
