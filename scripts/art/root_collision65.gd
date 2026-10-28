extends "res://scripts/art/willow_clearing64.gd"
var root_body65: StaticBody3D
var root_shapes65 := 0

func _apply_tree(texture: Texture2D,profile: Dictionary) -> void:
	super._apply_tree(texture,profile)
	_rebuild_root_collision65(profile)

func set_old_tree(enabled: bool) -> void:
	super.set_old_tree(enabled)
	if enabled and is_instance_valid(root_body65): root_body65.collision_layer=0

func _rebuild_root_collision65(profile: Dictionary) -> void:
	if is_instance_valid(root_body65):
		root_body65.get_parent().remove_child(root_body65)
		root_body65.queue_free()
	root_body65=StaticBody3D.new()
	root_body65.name="PaintedRootFootprint65"
	root_body65.collision_layer=2
	root_body65.collision_mask=0
	tree.root.add_child(root_body65)
	root_shapes65=0
	var bitmap: Image=tree.visual.texture.get_image()
	if bitmap.is_compressed(): bitmap.decompress()
	var scale_px: float=tree.visual.pixel_size
	var foot := Vector2(profile.foot[0],profile.foot[1])
	var drop: float=root_piece.drop
	# Fold the actual opaque root pixels onto the same ground plane as the art.
	# Separate narrow convex strips retain the spaces between spreading roots.
	var y_begin := maxi(0,int(foot.y-(drop+.12)/scale_px))
	var y_end := mini(bitmap.get_height()-1,int(foot.y))
	var stride := maxi(8,int(.55/scale_px))
	for x_begin in range(0,bitmap.get_width(),stride):
		var pixels := PackedVector2Array()
		for x in range(x_begin,mini(x_begin+stride+1,bitmap.get_width()),3):
			for y in range(y_begin,y_end+1,3):
				if bitmap.get_pixel(x,y).a<.65: continue
				var h := (foot.y-float(y))*scale_px
				pixels.append(Vector2((float(x)-foot.x)*scale_px,maxf(0.,(drop-h)/tan(deg_to_rad(25.)))))
		if pixels.size()<4: continue
		var hull := Geometry2D.convex_hull(pixels)
		if hull.size()<4: continue
		var vertices := PackedVector3Array()
		var lowest := INF
		var highest := -INF
		for p in hull:
			var world_at: Vector3=tree.root.to_global(Vector3(p.x,0,p.y))
			var floor_y: float=world.floor_height(Vector2(world_at.x,world_at.z))-tree.root.global_position.y
			lowest=minf(lowest,floor_y-.12)
			highest=maxf(highest,floor_y+.85)
		for p in hull:
			vertices.append(Vector3(p.x,lowest,p.y))
			vertices.append(Vector3(p.x,highest,p.y))
		var shape := ConvexPolygonShape3D.new()
		shape.points=vertices
		var collider := CollisionShape3D.new()
		collider.shape=shape
		root_body65.add_child(collider)
		root_shapes65+=1
