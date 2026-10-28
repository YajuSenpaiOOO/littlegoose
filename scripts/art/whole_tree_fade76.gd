extends "res://scripts/art/whole_tree_fade67.gd"
var near_candidates76 := 0

func screen_bounds(sprite: Sprite3D) -> Rect2:
	# Clip the quad at the camera near plane. Discarding rear corners can
	# reduce a near crown to a line even while it fills the screen.
	var size := Vector2(sprite.texture.get_size())
	var quad: Array[Vector3]=[]
	for uv in [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN]:
		var pixel: Vector2=(uv-Vector2(.5,.5))*size+sprite.offset
		quad.append(sprite.to_global(Vector3(pixel.x,pixel.y,0)*sprite.pixel_size))
	var clipped: Array[Vector3]=[]
	var near_depth: float=maxf(world.camera.near,.04)+.001
	for i in quad.size():
		var a: Vector3=quad[i];var b: Vector3=quad[(i+1)%quad.size()]
		var da: float=-world.camera.to_local(a).z
		var db: float=-world.camera.to_local(b).z
		if da>=near_depth: clipped.append(a)
		if (da>=near_depth)!=(db>=near_depth): clipped.append(a.lerp(b,(near_depth-da)/(db-da)))
	if clipped.size()<3: return Rect2()
	var lo := Vector2.INF;var hi := -Vector2.INF
	for point in clipped:
		var screen: Vector2=world.camera.unproject_position(point)
		lo=lo.min(screen);hi=hi.max(screen)
	return Rect2(lo,hi-lo)

func near_view_blocks76(sprite: Sprite3D,rect: Rect2,held: bool) -> bool:
	var viewport: Rect2=world.get_viewport().get_visible_rect()
	var visible := rect.intersection(viewport)
	if visible.get_area()<viewport.get_area()*(.20 if held else .28): return false
	# Alpha samples keep large transparent margins from hiding distant trees.
	var hits := 0
	for y in [.22,.42,.62,.82]:
		for x in [.2,.35,.5,.65,.8]:
			if painted_at(sprite,viewport.position+viewport.size*Vector2(x,y)): hits+=1
	return hits>=(4 if held else 6)

func _scan() -> void:
	candidate_count=0;near_candidates76=0
	var body: Vector3=world.hero.global_position+Vector3.UP*.8
	var reviewing: bool=world.review72 or (is_instance_valid(world.landmark62) and world.landmark62.review_view)
	for tree in world.trees:
		var sprite: Sprite3D=tree.visual
		var key := sprite.get_instance_id()
		if not entries.has(key): entries[key]={"sprite":sprite,"opacity":1.,"held":0.,"target":false,"near76":false}
		var entry: Dictionary=entries[key]
		var blocked := false;var near_block := false
		if world.fade_enabled and not reviewing and sprite.is_visible_in_tree() and sprite.global_position.distance_squared_to(world.hero.global_position)<55.*55. and in_front(sprite,body):
			var bounds := screen_bounds(sprite)
			var pad: float=1.45 if entry.target else 1.
			if overlaps_window(bounds,20. if entry.target else 0.):
				for offset in [Vector2.ZERO,Vector2(0,-.7),Vector2(0,.65),Vector2(-.7,-.35),Vector2(.7,-.35),Vector2(-.7,.35),Vector2(.7,.35)]:
					if painted_at(sprite,center_pixels+offset*radius_pixels*pad): blocked=true;break
			near_block=near_view_blocks76(sprite,bounds,entry.target)
		blocked=blocked or near_block
		entry.target=blocked;entry.near76=near_block
		if blocked: entry.held=.4;candidate_count+=1
		if near_block: near_candidates76+=1
