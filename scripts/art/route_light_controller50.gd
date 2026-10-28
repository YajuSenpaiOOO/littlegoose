extends "res://scripts/art/porch_study49.gd"
const LABELS50 := ["49暖院原版","林路柔和","林路明暗交替"]
var route_mode := 2
@export_file("*.tres") var palette_path := "res://assets/lighting50/warm_woodland.tres"
@export_file("*.png") var atlas_path := "res://assets/lighting50/home_trail_field.png"
var palette: Resource
var field_texture: Texture2D
var field_image: Image
var field_bounds := Vector4()
var field_data: Dictionary

func _ready() -> void:
	palette=load(palette_path)
	field_texture=load(atlas_path)
	field_image=field_texture.get_image()
	if field_image.is_compressed(): field_image.decompress()
	field_data=JSON.parse_string(FileAccess.get_file_as_string(atlas_path.trim_suffix(".png")+".json"))
	var b: Array=field_data.bounds
	field_bounds=Vector4(b[0],b[1],b[2],b[3])
	super._ready()
	# Flowers and lower shrubs share the same field as the road and canopy.
	_bind_decoration_materials(world.atmosphere41)
	_bind_decoration_materials(world.garden)

func _bind_decoration_materials(node: Node) -> void:
	if node is GeometryInstance3D and node.material_override is ShaderMaterial:
		var code: String=node.material_override.shader.code
		if "ALBEDO" in code and not "screen_image" in code and not "shadow" in code and not "depth_test_disabled" in code:
			shade_material(node.material_override)
	for child in node.get_children(): _bind_decoration_materials(child)

func _shader_include() -> String:
	return super._shader_include()+"#include \"res://scripts/art/route_light50.gdshaderinc\"\n"

func _shader_apply() -> String:
	return super._shader_apply()+"\n ALBEDO=route_light50(ALBEDO,porch_position49);"

func _configure_material(material: ShaderMaterial) -> void:
	material.set_shader_parameter("route_field50",field_texture)
	material.set_shader_parameter("route_bounds50",field_bounds)
	material.set_shader_parameter("route_strength50",_route_strength())

func _route_strength() -> float:
	return [0.,.6,1.][route_mode]

func set_profile(value: int) -> void:
	route_mode=clampi(value,0,2)
	# Keep the approved courtyard in all three comparisons.
	super.set_profile(2)
	for material in materials.values(): _configure_material(material)
	world._title35()

func sample_field(at: Vector2) -> Color:
	var uv := (at-Vector2(field_bounds.x,field_bounds.y))/Vector2(field_bounds.z,field_bounds.w)
	if uv.x<0. or uv.y<0. or uv.x>1. or uv.y>1.: return Color(.8,.8,.8,0.)
	var pixel := uv*Vector2(field_image.get_size())-Vector2.ONE*.5
	var x := clampi(floori(pixel.x),0,field_image.get_width()-2)
	var y := clampi(floori(pixel.y),0,field_image.get_height()-2)
	var f := (pixel-Vector2(x,y)).clamp(Vector2.ZERO,Vector2.ONE)
	return field_image.get_pixel(x,y).lerp(field_image.get_pixel(x+1,y),f.x).lerp(field_image.get_pixel(x,y+1).lerp(field_image.get_pixel(x+1,y+1),f.x),f.y)

func _update_actor() -> void:
	super._update_actor()
	if field_image==null: return
	var p: Vector3=world.hero.global_position
	var field := sample_field(Vector2(p.x,p.z))
	var weight: float=field.a*_route_strength()*palette.actor_response
	world.hero.visual.modulate*=Color.WHITE.lerp(Color(field.r*1.25,field.g*1.25,field.b*1.25),weight)
