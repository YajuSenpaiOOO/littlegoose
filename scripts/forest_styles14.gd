extends "res://scripts/forest_cottage13.gd"
## Four complete art directions, with layout, physics and lighting held fixed.
var art_style := 1
var style_names := ["原13 · 卡通绘本","A · 轻像素绘本","B · 细节手绘材质","C · 自然像素质感"]
var style_packs: Array[Dictionary] = []
var styles_ready := false

func _ready() -> void:
	super._ready()
	style_packs.append({"profiles":art_profiles,"textures":art_textures.duplicate(),"ground":ground_materials[3].get_shader_parameter("paint")})
	var profiles: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/forest14/profiles.json"))
	for id in ["a","b","c"]:
		var pack := {"profiles":profiles[id],"textures":{}}
		var floor_image := _imported_image("res://assets/forest14/%s_ground.png"%id)
		floor_image.generate_mipmaps()
		pack.ground = ImageTexture.create_from_image(floor_image)
		var trees_image := _imported_image("res://assets/forest14/%s_trees.png"%id)
		for tree_id in ["oak","young"]:
			var cell: Array = profiles[id][tree_id].cell
			var image := trees_image.get_region(Rect2i(cell[0],cell[1],cell[2],cell[3]))
			var padded := Image.create(image.get_width()+8,image.get_height()+8,false,Image.FORMAT_RGBA8)
			padded.fill(Color.TRANSPARENT)
			padded.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),Vector2i(4,4))
			image = padded
			image.generate_mipmaps()
			pack.textures[tree_id] = ImageTexture.create_from_image(image)
		var cottage_image := _imported_image("res://assets/forest14/%s_cottage.png"%id)
		cottage_image.generate_mipmaps()
		pack.textures.cottage = ImageTexture.create_from_image(cottage_image)
		style_packs.append(pack)
	styles_ready = true
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--art="): art_style = clampi(int(arg.trim_prefix("--art=")),0,3)
	set_art_style(art_style)

func _imported_image(path: String) -> Image:
	var texture: Texture2D = load(path)
	var image := texture.get_image()
	if image.is_compressed(): image.decompress()
	return image

func _replace_sprite(sprite: Sprite3D,id: String,height: float,pack: Dictionary) -> void:
	var profile: Dictionary = pack.profiles[id]
	var texture: Texture2D = pack.textures[id]
	sprite.texture = texture
	sprite.pixel_size = height/float(profile.height)
	sprite.offset = Vector2(texture.get_width()/2.-float(profile.foot[0]),float(profile.foot[1])-texture.get_height()/2.)
	sprite.material_override.set_shader_parameter("paint",texture)
	sprite.material_override.set_shader_parameter("alpha_threshold",float(profile.get("cutoff",.5)))

func set_art_style(index: int) -> void:
	if not styles_ready: return
	art_style = clampi(index,0,3)
	var pack := style_packs[art_style]
	# Material updates only: preserve all roots, collision bodies, camera and actor.
	ground_materials[3].set_shader_parameter("paint",pack.ground)
	meadow_materials[3].set_shader_parameter("ground_paint",pack.ground)
	for i in trees.size():
		_replace_sprite(trees[i].visual,"oak" if i%3!=1 else "young",trees[i].height,pack)
	_replace_sprite(house_art,"cottage",4.9,pack)
	_status()

func set_candidate(index: int) -> void:
	super.set_candidate(index)
	if styles_ready: set_art_style(art_style)

func _status() -> void:
	if not is_instance_valid(label): return
	label.text = "森林成套风格14 · %s · 相同布局 / 25°镜头 / 光照\n1 原卡通 / 2 轻像素绘本 / 3 细节手绘 / 4 自然像素 · Tab 下一套\nM 短高混合 %s · 7 短草 / 8 高草 / 9 圆叶 · B 远林 · N 光影 · F 遮挡淡出\nWASD / Shift 移动 · 滚轮缩放 · F2 远看 / F3 屋前 · R 复位 · F1 隐藏" % [style_names[art_style],"开" if mixed_grass else "关"]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1: set_art_style(0); return
			KEY_2: set_art_style(1); return
			KEY_3: set_art_style(2); return
			KEY_4: set_art_style(3); return
			KEY_5,KEY_6: return
			KEY_TAB: set_art_style((art_style+1)%4); return
	super._unhandled_input(event)
