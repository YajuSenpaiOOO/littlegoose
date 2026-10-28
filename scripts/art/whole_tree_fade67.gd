extends "res://scripts/art/canopy_occlusion66.gd"
## Reuse geometry helpers, never the rejected window shader or its material path.
var improved := true
var masks67: Dictionary={}
var changed67: Array[int]=[]
var shader_dirty67 := true

func prepare() -> void:
	reset_fades()
	for tree in world.trees: _mask(tree.visual.texture)

func set_improved(value: bool) -> void:
	improved=value
	reset_fades()
	shader_dirty67=true

func _mask(texture: Texture2D) -> BitMap:
	var key := texture.get_instance_id()
	if not masks67.has(key):
		var image := texture.get_image()
		if image.is_compressed(): image.decompress()
		var bitmap := BitMap.new()
		bitmap.create_from_image_alpha(image,.32)
		masks67[key]=bitmap
	return masks67[key]

func painted_at(sprite: Sprite3D,screen: Vector2) -> bool:
	var origin: Vector3=world.camera.project_ray_origin(screen)
	var ray: Vector3=world.camera.project_ray_normal(screen)
	var plane := Plane(sprite.global_basis.z,sprite.global_position)
	var hit: Variant=plane.intersects_ray(origin,ray)
	if hit==null: return false
	var local: Vector3=sprite.to_local(hit)/sprite.pixel_size
	var size := Vector2(sprite.texture.get_size())
	var uv := Vector2(.5+(local.x-sprite.offset.x)/size.x,.5-(local.y-sprite.offset.y)/size.y)
	if uv.x<0. or uv.y<0. or uv.x>=1. or uv.y>=1.: return false
	return _mask(sprite.texture).get_bitv(Vector2i(uv*size))

func _scan() -> void:
	var body: Vector3=world.hero.global_position+Vector3.UP*.8
	candidate_count=0
	for tree in world.trees:
		var sprite: Sprite3D=tree.visual
		var key := sprite.get_instance_id()
		if not entries.has(key): entries[key]={"sprite":sprite,"opacity":1.,"held":0.,"target":false}
		var entry: Dictionary=entries[key]
		var blocked := false
		if world.fade_enabled and sprite.is_visible_in_tree() and sprite.global_position.distance_squared_to(world.hero.global_position)<45.*45. and in_front(sprite,body):
			var pad: float=1.45 if entry.target else 1.
			if overlaps_window(screen_bounds(sprite),20. if entry.target else 0.):
				for offset in [Vector2.ZERO,Vector2(0,-.7),Vector2(0,.65),Vector2(-.7,-.35),Vector2(.7,-.35),Vector2(-.7,.35),Vector2(.7,.35)]:
					if painted_at(sprite,center_pixels+offset*radius_pixels*pad):
						blocked=true
						break
		entry.target=blocked
		if blocked: entry.held=.4; candidate_count+=1

func update(delta: float) -> void:
	changed67.clear()
	var at: Vector3=world.hero.global_position
	var jumped: bool=not previous_hero.is_finite() or at.distance_to(previous_hero)>3.
	previous_hero=at
	var head: Vector2=world.camera.unproject_position(at+Vector3.UP*1.45)
	var foot: Vector2=world.camera.unproject_position(at+Vector3.UP*.12)
	var motion := Vector3(world.hero.velocity.x,0,world.hero.velocity.z)
	var lead := Vector2.ZERO
	if motion.length()>.15: lead=world.camera.unproject_position(at+motion.normalized()*.55)-world.camera.unproject_position(at)
	lead_pixels=lead if jumped else lead_pixels.lerp(lead,1.-exp(-delta*5.))
	center_pixels=(head+foot)*.5+lead_pixels*.5
	var scale_ui: float=world.get_viewport().get_visible_rect().size.y/1000.
	var body_height := head.distance_to(foot)
	radius_pixels=Vector2(maxf(22.*scale_ui,body_height*.42),maxf(34.*scale_ui,body_height*.68))
	if jumped:
		for key in entries:
			var entry: Dictionary=entries[key]
			entry.opacity=1.; entry.held=0.; entry.target=false
			entry.sprite.material_override.set_shader_parameter("fade",1.)
			changed67.append(key)
		shader_dirty67=true
		scan_left=0.
	scan_left-=delta
	if scan_left<=0.: _scan(); scan_left=.07
	active_count=0
	for key in entries:
		var entry: Dictionary=entries[key]
		entry.held=maxf(0.,entry.held-delta)
		var hide_tree: bool=world.fade_enabled and (entry.target or entry.held>0.)
		var previous: float=entry.opacity
		entry.opacity=move_toward(previous,0. if hide_tree else 1.,delta*(5. if hide_tree else 1.65))
		if entry.opacity<1.: active_count+=1
		if previous==entry.opacity: continue
		# The old material squares fade. Drive actual opacity with a smooth curve.
		var alpha: float=smoothstep(0.,1.,entry.opacity)
		var fade := sqrt(alpha)
		if (sqrt(smoothstep(0.,1.,previous))<.999)!=(fade<.999): shader_dirty67=true
		entry.sprite.material_override.set_shader_parameter("fade",fade)
		changed67.append(key)
