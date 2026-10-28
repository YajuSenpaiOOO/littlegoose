extends RefCounted
## A stable screen window, shared by foreground crowns. Physical roots stay solid.
var world: Node3D
var local_enabled := true
var entries: Dictionary={}
var material_cache: Dictionary={}
var center_pixels := Vector2.ZERO
var radius_pixels := Vector2.ONE
var lead_pixels := Vector2.ZERO
var scan_left := 0.
var active_count := 0
var candidate_count := 0
var previous_hero := Vector3.INF

func reset_fades() -> void:
	for tree in world.trees: tree.visual.material_override.set_shader_parameter("fade",1.)
	for piece in world.root_pieces: piece.node.material_override.set_shader_parameter("fade",1.)
	entries.clear()
	material_cache.clear()
	scan_left=0.
	lead_pixels=Vector2.ZERO
	previous_hero=Vector3.INF

func set_local(enabled: bool) -> void:
	local_enabled=enabled
	reset_fades()

func screen_bounds(sprite: Sprite3D) -> Rect2:
	var size := Vector2(sprite.texture.get_size())
	var minimum := Vector2.INF
	var maximum := -Vector2.INF
	for uv in [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN]:
		var pixel: Vector2=(uv-Vector2(.5,.5))*size+sprite.offset
		var point: Vector3=sprite.to_global(Vector3(pixel.x,pixel.y,0)*sprite.pixel_size)
		if world.camera.is_position_behind(point): continue
		var screen: Vector2=world.camera.unproject_position(point)
		minimum=minimum.min(screen)
		maximum=maximum.max(screen)
	if not minimum.is_finite(): return Rect2()
	return Rect2(minimum,maximum-minimum)

func overlaps_window(rect: Rect2,margin: float) -> bool:
	if not rect.has_area(): return false
	var nearest := center_pixels.clamp(rect.position,rect.end)
	return ((nearest-center_pixels)/(radius_pixels+Vector2.ONE*margin)).length_squared()<1.

func in_front(sprite: Sprite3D,body: Vector3) -> bool:
	var camera_at: Vector3=world.camera.global_position
	var direction := (body-camera_at).normalized()
	var plane := Plane(sprite.global_basis.z,sprite.global_position)
	var hit: Variant=plane.intersects_ray(camera_at,direction)
	return hit!=null and camera_at.distance_squared_to(hit)<camera_at.distance_squared_to(body)-.04

func _scan() -> void:
	candidate_count=0
	var body: Vector3=world.hero.global_position+Vector3.UP*.8
	var scale_ui: float=world.get_viewport().get_visible_rect().size.y/1000.
	for tree in world.trees:
		var sprite: Sprite3D=tree.visual
		var key := sprite.get_instance_id()
		if not entries.has(key): entries[key]={"sprite":sprite,"strength":0.,"held":0.,"target":false}
		var entry: Dictionary=entries[key]
		var margin: float=(36. if entry.target else 10.)*scale_ui
		var blocked := false
		if world.fade_enabled and sprite.is_visible_in_tree() and sprite.global_position.distance_squared_to(world.hero.global_position)<45.*45. and in_front(sprite,body):
			blocked=overlaps_window(screen_bounds(sprite),margin)
		entry.target=blocked
		if blocked:
			entry.held=.35
			candidate_count+=1

func update(delta: float) -> void:
	var hero_at: Vector3=world.hero.global_position
	var jumped: bool=not previous_hero.is_finite() or hero_at.distance_to(previous_hero)>3.
	previous_hero=hero_at
	var foot: Vector2=world.camera.unproject_position(hero_at+Vector3.UP*.10)
	var head: Vector2=world.camera.unproject_position(hero_at+Vector3.UP*1.45)
	var desired := Vector2.ZERO
	var motion := Vector3(world.hero.velocity.x,0,world.hero.velocity.z)
	if motion.length()>.15:
		desired=world.camera.unproject_position(hero_at+motion.normalized()*.9)-world.camera.unproject_position(hero_at)
	lead_pixels=desired if jumped else lead_pixels.lerp(desired,1.-exp(-delta*5.))
	center_pixels=(head+foot)*.5+lead_pixels*.65
	var ui_scale: float=world.get_viewport().get_visible_rect().size.y/1000.
	var body_pixels := head.distance_to(foot)
	radius_pixels=Vector2(maxf(68.*ui_scale,body_pixels*1.5),maxf(86.*ui_scale,body_pixels*1.7))
	if jumped:
		for entry in entries.values():
			entry.strength=0.; entry.target=false; entry.held=0.
		scan_left=0.
	scan_left-=delta
	if scan_left<=0.:
		_scan()
		scan_left=.07
	active_count=0
	for entry in entries.values():
		entry.held=maxf(0.,entry.held-delta)
		var reveal: bool=world.fade_enabled and (entry.target or entry.held>0.)
		entry.strength=move_toward(entry.strength,1. if reveal else 0.,delta*(4.5 if reveal else 1.6))
		if entry.strength>.001: active_count+=1

func sync_materials() -> void:
	var viewport_size: Vector2=world.get_viewport().get_visible_rect().size
	for piece in world.root_pieces:
		var sprite: Sprite3D=piece.sprite
		var key := sprite.get_instance_id()
		var wind: bool=world.woodland_life.tree_ids.has(key)
		var entry: Dictionary=entries.get(key,{})
		var strength: float=entry.get("strength",0.)
		var active: bool=strength>.001
		var base_shader: Shader=preload("res://scripts/art/forest_wind46.gdshader") if wind else preload("res://scripts/art/forest_cutout17.gdshader")
		var crown_shader: Shader=preload("res://scripts/art/canopy_window66.gdshader") if active else base_shader
		var state := (2 if wind else 0)+(4 if active else 0)
		var saved: Array=material_cache.get(key,[])
		if saved.size()!=3 or saved[0]!=state or saved[1]!=sprite.material_override.shader or saved[2]!=piece.node.material_override.shader:
			world.porch49.shade_material(sprite.material_override,crown_shader)
			world.porch49.shade_material(piece.node.material_override,base_shader)
			material_cache[key]=[state,sprite.material_override.shader,piece.node.material_override.shader]
		if active:
			var material: ShaderMaterial=sprite.material_override
			material.set_shader_parameter("window_center66",center_pixels/viewport_size)
			material.set_shader_parameter("window_radius66",radius_pixels/viewport_size)
			material.set_shader_parameter("window_strength66",strength)
