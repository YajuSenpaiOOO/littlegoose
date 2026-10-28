extends "res://scripts/art/light_profiles47.gd"
const LABELS48 := ["原版","舞台层次","舞台层次＋局部柔光"]
var glow_rects := PackedVector4Array()

func _ready() -> void:
	super._ready()
	set_profile(2)
	_update_glow_rects()

func set_profile(value: int) -> void:
	profile=clampi(value,0,2)
	restore_base()
	# Keep the approved original light/air. Spatial separation is depth-based,
	# not the rejected short-range grey fog or another global color preset.
	world.atmosphere41.set_stage(profile)
	_apply_frame_tint(profile>0)
	world._title35()

func _apply_frame_tint(value: bool) -> void:
	var ids := {}
	for tree in world.atmosphere41.frame_trees: ids[tree.visual.get_instance_id()]=true
	for piece in world.root_pieces:
		if not ids.has(piece.sprite.get_instance_id()): continue
		var tint := Vector3(.72,.83,.79) if value else Vector3.ONE
		piece.sprite.material_override.set_shader_parameter("tint",tint)
		piece.node.material_override.set_shader_parameter("tint",tint)

func _screen_rect(sprite: Sprite3D,pixels: Rect2) -> Vector4:
	var lo := Vector2(100000.,100000.)
	var hi := Vector2(-100000.,-100000.)
	for pixel in [pixels.position,Vector2(pixels.end.x,pixels.position.y),pixels.end,Vector2(pixels.position.x,pixels.end.y)]:
		var position: Vector3=world._pixel_world(sprite,pixel)
		if world.camera.is_position_behind(position): return Vector4(-5.,-5.,.001,.001)
		var screen: Vector2=world.camera.unproject_position(position)/world.get_viewport().get_visible_rect().size
		lo=lo.min(screen); hi=hi.max(screen)
	var center := (lo+hi)*.5
	var radius := (hi-lo)*.5
	return Vector4(center.x,center.y,maxf(radius.x,.001),maxf(radius.y,.001))

func _update_glow_rects() -> void:
	glow_rects.clear()
	# Authored glass locations, not every bright yellow/white pixel in the scene.
	if world.house_variant==0:
		for rect in [Rect2(623,420,82,84),Rect2(366,822,95,80),Rect2(855,822,95,80)]:
			glow_rects.append(_screen_rect(world.house_art,rect))
	else:
		for i in 3: glow_rects.append(Vector4(-5.,-5.,.001,.001))
	var life: Node3D=world.woodland_life
	if life.lantern_enabled:
		glow_rects.append(_screen_rect(life.lantern_root.get_child(0),Rect2(658,621,157,173)))
	else: glow_rects.append(Vector4(-5.,-5.,.001,.001))
	world.atmosphere41.focus_material.set_shader_parameter("glow_lights",glow_rects)

func _process(_delta: float) -> void:
	if profile==2 and world.atmosphere41.enabled: _update_glow_rects()
