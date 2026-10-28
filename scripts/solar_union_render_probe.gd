extends SceneTree
var failures := 0
var checks := 0

func _initialize() -> void: call_deferred("_run")

func verify(value: bool,message: String) -> void:
	checks += 1
	if value: print("PASS ",message)
	else:
		failures += 1
		push_error(message)

func frame() -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

func _run() -> void:
	var stage := Node2D.new()
	root.add_child(stage)
	var floor := ColorRect.new()
	floor.size = root.get_visible_rect().size
	floor.color = Color(0.6,0.7,0.5)
	floor.z_index = -7
	stage.add_child(floor)
	var rig: Node2D = load("res://scripts/art/world_lighting.gd").new()
	rig.auto_update_projections = false
	stage.add_child(rig)
	var profile: Resource = load("res://scripts/art/world_light_profile.gd").new()
	profile.sky_color = Color.WHITE
	profile.direct_energy = 0.18
	profile.shadow_opacity = 0.3
	profile.shadow_azimuth_degrees = 0
	profile.elevation_degrees = 45
	rig.set_profile(profile,true)
	var actors: Array[Node2D] = []
	var projections: Array[Node2D] = []
	for i in 2:
		var actor := Node2D.new()
		stage.add_child(actor)
		actors.append(actor)
		var projection: Node2D = rig.project_plane(actor,Rect2(180,180,120,90),PackedVector2Array([Vector2(180,180),Vector2(300,180),Vector2(300,270),Vector2(180,270)]),0,100)
		projection.update_shadow(0,true)
		projections.append(projection)
	var union: Node2D = load("res://scripts/art/solar_union.gd").new()
	union.rig = rig
	stage.add_child(union)
	for projection in projections: union.register(projection)
	union.sync(true)
	await frame()
	var both := root.get_texture().get_image()
	var overlap := both.get_pixel(230,220)
	var clear := both.get_pixel(120,220)
	verify(overlap.r<clear.r-0.03,"merged mask actually darkens covered ground")
	actors[1].hide()
	projections[1].update_shadow(0,true)
	union.sync(true)
	await frame()
	var one := root.get_texture().get_image().get_pixel(230,220)
	verify(absf(one.r-overlap.r)<0.008 and absf(one.g-overlap.g)<0.008 and absf(one.b-overlap.b)<0.008,"two overlapping sun shadows have the same darkness as one")
	union.sync(false)
	await frame()
	var off := root.get_texture().get_image().get_pixel(230,220)
	verify(absf(off.r-clear.r)<0.008,"disabling merged sunlight restores the unshadowed surface")
	print("SOLAR_UNION_RENDER_PROBE ",checks-failures,"/",checks," passed; one=",one," both=",overlap," clear=",clear)
	stage.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
