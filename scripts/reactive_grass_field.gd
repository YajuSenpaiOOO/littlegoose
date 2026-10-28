extends Node
## Sorted Sprite2Ds share one material; no per-tuft scripts, bodies or light projectors.
var scene: Node2D
var requested_count := 420
var tufts: Array[Sprite2D] = []
var shared_material: ShaderMaterial
var clock := 0.0
var trail := PackedVector4Array()
var last_stamp := Vector2(-10000,-10000)
var stamp_time := -100.0
var stamp_index := 0
var active := true
var rng := RandomNumberGenerator.new()
var centers_override: Array = []
var patch_radius := Vector2(65,43)
var placement_test := Callable()

func _ready() -> void:
	process_priority = 210
	rng.seed = 2026101704
	shared_material = ShaderMaterial.new()
	shared_material.shader = preload("res://scripts/art/reactive_grass.gdshader")
	for i in 8: trail.append(Vector4(0,0,-100,0))
	shared_material.set_shader_parameter("trail",trail)
	var textures: Array[Texture2D] = []
	for i in 4:
		var texture := AtlasTexture.new()
		texture.atlas = preload("res://assets/tiles/exterior.png")
		texture.region = Rect2(64+16*i,880,16,16)
		texture.filter_clip = true
		textures.append(texture)
	var centers := [Vector2(955,1275),Vector2(1010,1320),Vector2(1185,1295),Vector2(1250,1315),Vector2(1225,1170),Vector2(1240,1075),Vector2(1170,1040),Vector2(1350,1120),Vector2(1280,970)]
	if not centers_override.is_empty(): centers = centers_override
	var obstacles: Array[Rect2] = []
	for prop in scene.world.get_children():
		if prop.has_method("effective_footprint") and prop.effective_footprint()!=Vector2.ZERO:
			var size: Vector2 = prop.effective_footprint()*prop.size_factor
			obstacles.append(Rect2(prop.position+prop.effective_offset()*prop.size_factor-size/2,size).grow(5))
	var attempts := 0
	while tufts.size()<requested_count and attempts<requested_count*18:
		attempts += 1
		var center: Vector2 = centers[attempts%centers.size()]*scene.layout_scale
		var a := rng.randf()*TAU
		var r := sqrt(rng.randf())
		var at := center+Vector2(cos(a)*patch_radius.x,sin(a)*patch_radius.y)*r
		if not _allowed(at,obstacles): continue
		var tuft := Sprite2D.new()
		tuft.name = "InteractiveGrass%04d" % tufts.size()
		tuft.texture = textures[tufts.size()%4]
		tuft.offset = Vector2(0,-tuft.texture.get_height()/2)
		tuft.position = at
		tuft.scale = Vector2(rng.randf_range(1.0,1.55),rng.randf_range(0.95,1.35))
		tuft.modulate = Color(rng.randf_range(0.88,1.0),rng.randf_range(0.92,1.0),rng.randf_range(0.78,0.92))
		tuft.material = shared_material
		tuft.light_mask = 2
		tuft.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		scene.world.add_child(tuft)
		tufts.append(tuft)
	update_interaction(0)

func _allowed(at: Vector2,obstacles: Array[Rect2]) -> bool:
	if placement_test.is_valid(): return placement_test.call(at)
	# Keep the same stands for both ground styles and preserve the paving apron.
	if Rect2(Vector2(995,1142)*scene.layout_scale,Vector2(200,105)*scene.layout_scale).has_point(at): return false
	for obstacle in obstacles:
		if obstacle.has_point(at): return false
	for i in scene.routes.size():
		var path: PackedVector2Array = scene.routes[i]
		for j in path.size()-1:
			var distance := at.distance_to(Geometry2D.get_closest_point_to_segment(at,path[j],path[j+1]))
			if distance<float(scene.plan.routes[i].width)*scene.layout_scale*0.5-4: return false
	return true

func set_active(value: bool) -> void:
	active = value
	for tuft in tufts: tuft.visible = value
	set_process(value)
	if value:
		clear_trail()
		update_interaction(0)

func clear_trail() -> void:
	for i in 8: trail[i] = Vector4(0,0,-100,0)
	last_stamp = Vector2(-10000,-10000)
	stamp_time = -100
	shared_material.set_shader_parameter("trail",trail)

func update_interaction(delta: float) -> void:
	clock += delta
	var at: Vector2 = scene.hero.global_position
	if at.distance_to(last_stamp)>200: clear_trail()
	if clock-stamp_time>0.07 and at.distance_to(last_stamp)>5:
		var direction := signf(at.x-last_stamp.x)
		if direction==0: direction = 1.0
		trail[stamp_index] = Vector4(at.x,at.y,clock,direction)
		stamp_index = (stamp_index+1)%8
		last_stamp = at
		stamp_time = clock
		shared_material.set_shader_parameter("trail",trail)
	shared_material.set_shader_parameter("walker",at)
	shared_material.set_shader_parameter("clock",clock)
	# Only this finite region runs contact/trail math in the vertex shader.
	# Eight fixed trail entries are considered, never a CPU scan of all plants.
	var low := at-Vector2(25,25)
	var high := at+Vector2(25,25)
	for point in trail:
		var age := clock-point.z
		if age>=0 and age<0.85:
			low = low.min(Vector2(point.x,point.y)-Vector2(23,23))
			high = high.max(Vector2(point.x,point.y)+Vector2(23,23))
	shared_material.set_shader_parameter("touch_bounds",Vector4(low.x,low.y,high.x,high.y))

func _process(delta: float) -> void:
	update_interaction(delta)
