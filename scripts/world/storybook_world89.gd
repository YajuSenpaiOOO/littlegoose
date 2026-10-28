extends "res://scripts/world/world88.gd"
var look_enabled89 := true
var floor_shader89: Shader
var soil_texture89: ImageTexture
var soil_bounds89 := Vector4.ZERO

func _porch_script() -> Script: return preload("res://scripts/art/woodland_look89.gd")
func _time_script() -> Script: return preload("res://scripts/world/storybook_time89.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 89 · 林地材质层次对照 · Ctrl+Alt+J")

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	if floor_shader89==null:
		floor_shader89=Shader.new()
		var code: String=ground_shader87.code.replace("vec3(.30,.38,.19),.36","vec3(.36,.41,.23),.12")
		# The helper follows soft_noise/grain, before vertex/fragment entry points.
		code=code.replace("void vertex()",preload("res://scripts/art/forest_floor89.gdshaderinc").code+"\nvoid vertex()")
		floor_shader89.code=code.replace(" ALBEDO=albedo_view ?"," col=forest_floor89(col,world,normal76,path);\n ALBEDO=albedo_view ?")
	for material in ground_materials:
		material.shader=floor_shader89
		if is_instance_valid(porch49): porch49.shade_material(material,floor_shader89)
		material.set_shader_parameter("soil_field89",soil_texture89)
		material.set_shader_parameter("soil_bounds89",soil_bounds89)
		material.set_shader_parameter("floor_strength89",1. if look_enabled89 else 0.)

func _bake_soil89() -> void:
	var g: Vector2=meadow.landmarks.grove
	var rect := Rect2(g-Vector2(38.,36.),Vector2(76.,72.))
	soil_bounds89=Vector4(rect.position.x,rect.position.y,rect.size.x,rect.size.y)
	var field := Image.create(192,192,false,Image.FORMAT_RGBA8)
	field.fill(Color(0,0,0,1))
	for tree in trees:
		var at := Vector2(tree.root.position.x,tree.root.position.z)
		if not rect.grow(5.).has_point(at): continue
		var pixel: Vector2=(at-rect.position)/rect.size*192.
		for y in range(maxi(0,int(pixel.y)-13),mini(192,int(pixel.y)+14)):
			for x in range(maxi(0,int(pixel.x)-13),mini(192,int(pixel.x)+14)):
				var p := rect.position+(Vector2(x+.5,y+.5)/192.)*rect.size
				var d := ((p-at)/Vector2(4.2,3.1)).length()
				var value := (1.-smoothstep(.10,1.,d))*.9
				if value>field.get_pixel(x,y).r: field.set_pixel(x,y,Color(value,0,0,1))
	soil_texture89=ImageTexture.create_from_image(field)
	for material in ground_materials:
		material.set_shader_parameter("soil_field89",soil_texture89)
		material.set_shader_parameter("soil_bounds89",soil_bounds89)

func set_look89(value: bool) -> void:
	look_enabled89=value
	porch49.set_look89(value)
	for material in ground_materials: material.set_shader_parameter("floor_strength89",1. if value else 0.)
	# Preserve the existing time palette; compare material and focus at identical times.
	time55.apply_look()

func _ready() -> void:
	super._ready()
	while not is_instance_valid(forest87): await get_tree().physics_frame
	_bake_soil89()
	set_look89(true)
	time55.update_guide()
	print("STORYBOOK89_READY trees=",trees.size())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_J:
		set_look89(not look_enabled89);return
	super._unhandled_input(event)
