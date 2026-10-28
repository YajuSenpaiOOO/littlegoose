extends "res://scripts/art/day_fill67.gd"
var local_image88: Image
var local_texture88: Texture2D
var local_bounds88 := Vector4.ZERO

func _shader_include() -> String:
	return super._shader_include().replace("route_light50.gdshaderinc","route_light88.gdshaderinc")

func _configure_material(material: ShaderMaterial) -> void:
	super._configure_material(material)
	if local_texture88==null: return
	material.set_shader_parameter("forest_field88",local_texture88)
	material.set_shader_parameter("forest_bounds88",local_bounds88)
	material.set_shader_parameter("forest_ready88",1.)

func _ready() -> void:
	super._ready()
	var g: Vector2=world.meadow.landmarks.grove
	var rect := Rect2(g-Vector2(36.,34.),Vector2(72.,68.))
	local_bounds88=Vector4(rect.position.x,rect.position.y,rect.size.x,rect.size.y)
	var baker := preload("res://scripts/art/woodland_light_baker51.gd").new()
	var settings: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/lighting51/regions.json"))
	baker.prepare(world.trees,world.meadow,settings)
	local_image88=Image.create(128,128,false,Image.FORMAT_RGBA8)
	for y in 128:
		for x in 128:
			var at := rect.position+Vector2((x+.5)/128.,(y+.5)/128.)*rect.size
			var density: float=baker.density_at(at)
			var tint := Vector3(.98,1.,.96).lerp(Vector3(.74,.84,.77),density*.78)
			# A persistent canopy opening. No player-entry trigger or spotlight.
			var open := 1.-smoothstep(.65,1.25,((at-g-Vector2(-2.,0.))/Vector2(17.,12.)).length())
			tint=tint.lerp(Vector3(1.02,1.015,.97),open*.8)
			local_image88.set_pixel(x,y,Color(tint.x/1.25,tint.y/1.25,tint.z/1.25,1.))
	local_texture88=ImageTexture.create_from_image(local_image88)
	for material in materials.values(): _configure_material(material)
	print("WOODLAND88_LOCAL_FIELD current_trees=",world.trees.size())

func sample_field(at: Vector2) -> Color:
	var old := super.sample_field(at)
	if local_image88==null: return old
	var uv := (at-Vector2(local_bounds88.x,local_bounds88.y))/Vector2(local_bounds88.z,local_bounds88.w)
	if uv.x<0. or uv.x>1. or uv.y<0. or uv.y>1.: return old
	var edge := 1.-smoothstep(.72,.98,maxf(absf(uv.x-.5),absf(uv.y-.5))*2.)
	var pos := (uv*127.).clamp(Vector2.ZERO,Vector2.ONE*127.)
	return old.lerp(local_image88.get_pixel(int(pos.x),int(pos.y)),edge)
