extends "res://scripts/ground_lab_probe.gd"
const Tracks = preload("res://scripts/world/surface_tracks18.gd")

func drive(keys: Array) -> void:
	for key in [KEY_W,KEY_A,KEY_S,KEY_D]:
		var input := event(key)
		input.pressed = key in keys
		Input.parse_input_event(input)

func track_checks() -> void:
	var low := Tracks.new()
	var high := Tracks.new()
	var accept := func(_at: Vector2) -> bool: return true
	for pair in [[low,30],[high,144]]:
		pair[0].reset_position(Vector2.ZERO)
		for i in pair[1]*2: pair[0].advance(1./pair[1],Vector2(float(i+1)*8./(pair[1]*2.),0),true,accept)
	var same := low.cursor==high.cursor
	for i in low.cursor: same = same and Vector2(low.marks[i].x,low.marks[i].y).distance_to(Vector2(high.marks[i].x,high.marks[i].y))<.0001
	verify(same and low.active_count()>8,"footprint spacing and left/right placement are independent of frame rate")
	verify(low.marks[0].y*low.marks[1].y<0.,"left and right footprints alternate across the walking line")
	var before := low.revision
	low.advance(.2,Vector2(80,80),true,accept)
	verify(low.revision==before,"teleport does not draw a trail between positions")
	low.advance(5.,Vector2(80,80),true,accept)
	verify(low.active_count()==0 and low.revision==before,"standing still makes existing footprints expire without spawning more")
	low.clear()
	low.reset_position(Vector2.ZERO)
	for i in 300: low.advance(.02,Vector2((i+1)*.7,0),true,accept)
	verify(low.marks.size()==48 and low.cursor<48,"long walks reuse a fixed capacity rather than creating objects")
	var reject := Tracks.new()
	reject.reset_position(Vector2.ZERO)
	for i in 40: reject.advance(.1,Vector2((i+1)*.2,0),true,func(_at: Vector2) -> bool: return false)
	verify(reject.active_count()==0,"surface predicate prevents soil footprints on grass")
	reject.advance(.1,Vector2(8.8,0),false,accept)
	verify(reject.active_count()==0,"airborne movement does not stamp footprints")

func run() -> void:
	track_checks()
	var sample: Node3D = load("res://scenes/sandbox/living_path18.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	for i in 16: await physics_frame
	verify(sample.house_variant==0 and sample.hero.is_on_floor() and sample.surface_ready,"selected house and previous grounded scene remain intact")
	var at: Vector2 = sample.meadow.main_route[5]
	var lowered: float = sample.meadow.height_at(at.x,at.y,true)
	sample.meadow.profile.enabled = false
	var level: float = sample.meadow.height_at(at.x,at.y,true)
	sample.meadow.profile.enabled = true
	verify(is_equal_approx(level-lowered,.11),"path center is physically eleven centimetres below its previous level")
	verify(sample.meadow.profile.depression(1.1)==0. and sample.meadow.profile.depression(0.,0.)==0.,"grass shoulders and cottage entry remain at their original level")
	sample._teleport15(Vector2(-3.8,-2.175))
	sample.tracks.clear()
	for i in 8: await physics_frame
	sample.hero.controls_enabled = true
	drive([KEY_D])
	var stable := true
	for i in 43:
		await physics_frame
		stable = stable and sample.hero.is_on_floor()
	drive([])
	sample.hero.controls_enabled = false
	for i in 5: await physics_frame
	verify(stable and sample.hero.position.x> -1.3 and sample.tracks.active_count()>=3,"actual movement along the lowered road stays grounded and leaves footprints")
	var soil_only := true
	for mark in sample.tracks.marks:
		if sample.tracks.elapsed-mark.z<sample.tracks.lifetime: soil_only = soil_only and sample.meadow.contains_soil(Vector2(mark.x,mark.y))
	verify(soil_only,"actual emitted footprints stay inside the soil surface")
	# Freeze real gameplay to inspect the visible live footprints, then their fade.
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample._update_camera(0,true)
	sample._sync_tracks()
	var with_tracks: Image = await snapshot()
	with_tracks.save_png("res://docs/captures/world_restart/path18_tracks.png")
	for material in sample.ground_materials: material.set_shader_parameter("footprints_enabled",false)
	var no_tracks: Image = await snapshot()
	var full := Rect2i(Vector2i.ZERO,with_tracks.get_size())
	verify(changed(with_tracks,no_tracks,full)>15,"actual GPU image contains the emitted shoe-shaped prints")
	sample.tracks.elapsed += 5.
	sample._sync_tracks()
	var expired: Image = await snapshot()
	verify(changed(no_tracks,expired,full)==0,"expired GPU footprints disappear completely without residual decals")
	sample.set_spots(false)
	var plain: Image = await snapshot()
	sample.set_spots(true)
	var restored: Image = await snapshot()
	verify(changed(expired,plain,full)>1000 and changed(expired,restored,full)==0,"soil patch toggle changes the road and restores the same frame")
	# Walk across the shoulder using the actual physics collider.
	sample.hero.set_physics_process(true)
	sample.set_physics_process(true)
	sample._teleport15(Vector2(-2.2,-2.175))
	for i in 8: await physics_frame
	sample.hero.controls_enabled = true
	drive([KEY_S])
	var crossing := true
	for i in 26:
		await physics_frame
		crossing = crossing and sample.hero.is_on_floor()
	drive([])
	sample.hero.controls_enabled = false
	verify(crossing and sample.meadow.route_distance(Vector2(sample.hero.position.x,sample.hero.position.z))>1.2,"actor crosses the shallow turf shoulder without a blocking step or falling")
	sample._teleport15(Vector2(-2.2,-2.175))
	sample.set_road_relief(false)
	for i in 8: await physics_frame
	verify(sample.hero.is_on_floor() and not sample.meadow.profile.enabled,"relief comparison updates real floor collision and keeps actor grounded")
	sample.set_road_relief(true)
	for i in 8: await physics_frame
	verify(sample.hero.is_on_floor() and sample.meadow.profile.enabled,"restoring shallow relief also restores grounded traversal")
	print("LIVING18_PROBE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
