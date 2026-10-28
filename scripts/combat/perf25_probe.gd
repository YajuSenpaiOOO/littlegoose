extends SceneTree
class Sample:
	extends "res://scripts/world/world24.gd"
	var allow_stop := true
	func hitstop(duration: float,force := false) -> void:
		if allow_stop: super.hitstop(duration,force)
class Updated:
	extends "res://scripts/world/world25.gd"
	var allow_stop := true
	func hitstop(duration: float,force := false) -> void:
		if allow_stop: super.hitstop(duration,force)
class Current:
	extends "res://scripts/world/world26.gd"
	var allow_stop := true
	func hitstop(duration: float,force := false) -> void:
		if allow_stop: super.hitstop(duration,force)
class Guided:
	extends "res://scripts/world/world28.gd"
	var allow_stop := true
	func hitstop(duration: float,force := false) -> void:
		if allow_stop: super.hitstop(duration,force)
class Telephone:
	extends "res://scripts/world/world29.gd"
	var allow_stop := true
	func hitstop(duration: float,force := false) -> void:
		if allow_stop: super.hitstop(duration,force)
class Feel:
	extends "res://scripts/world/world30.gd"
	var allow_stop := true
	func hitstop(duration: float,force := false) -> void:
		if allow_stop: super.hitstop(duration,force)
class MaterialFeel:
	extends "res://scripts/world/world31.gd"
	var allow_stop := true
	func hitstop(duration: float,force := false) -> void:
		if allow_stop: super.hitstop(duration,force)
class ElasticFeel:
	extends "res://scripts/world/world32.gd"
	var allow_stop := true
	func hitstop(duration: float,force := false) -> void:
		if allow_stop: super.hitstop(duration,force)
class EncounterFeel:
	extends "res://scripts/world/world33.gd"
	var allow_stop := true
	func hitstop(duration: float,force := false) -> void:
		if allow_stop: super.hitstop(duration,force)

var sample: Node3D
var report: Dictionary = {}
func _initialize() -> void: run.call_deferred()
func phase(label: String,shoot: bool,stops: bool) -> void:
	sample.allow_stop = stops
	sample._reset_impact_state()
	var enemy: CharacterBody3D = sample.enemies[0]
	enemy.hp = 100000.
	var ticks := PackedFloat32Array()
	var deadline := Time.get_ticks_msec()+3500
	var previous := Time.get_ticks_usec()
	var next_fire := 0
	var start_hits: int = sample.landed_hits
	while Time.get_ticks_msec()<deadline:
		if shoot and Time.get_ticks_msec()>=next_fire:
			next_fire = Time.get_ticks_msec()+140
			var target: Vector3 = enemy.position+Vector3.UP*.8 if label.contains("hit") else sample.hero.position+Vector3(8,.85,-1)
			sample.fire_at(target)
		await process_frame
		var now := Time.get_ticks_usec()
		ticks.append(float(now-previous)/1000.)
		previous=now
	ticks.sort()
	var total := 0.
	for t in ticks: total+=t
	var item := {"mean_ms":total/maxi(1,ticks.size()),"p50_ms":ticks[int(ticks.size()*.5)],"p95_ms":ticks[int(ticks.size()*.95)],"fps":1000.*ticks.size()/total,"process_ms":Performance.get_monitor(Performance.TIME_PROCESS)*1000.,"physics_ms":Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"anchors":sample.anchors.size(),"hits":sample.landed_hits-start_hits}
	report[label] = item
	print("PERF25 ",label," ",JSON.stringify(item))
	sample._clear_combat_shots()
func run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var updated := "--updated" in OS.get_cmdline_user_args()
	var current := "--current" in OS.get_cmdline_user_args()
	var guided := "--guided" in OS.get_cmdline_user_args()
	var telephone := "--telephone" in OS.get_cmdline_user_args()
	var feel := "--feel" in OS.get_cmdline_user_args()
	var material := "--material" in OS.get_cmdline_user_args()
	var elastic := "--elastic" in OS.get_cmdline_user_args()
	var encounter := "--encounter" in OS.get_cmdline_user_args()
	sample = EncounterFeel.new() if encounter else ElasticFeel.new() if elastic else MaterialFeel.new() if material else Feel.new() if feel else Telephone.new() if telephone else Guided.new() if guided else Current.new() if current else Updated.new() if updated else Sample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.fx_layer): await physics_frame
	if material:
		while not sample.material_ready: await physics_frame
	if elastic:
		while not sample.elastic_ready: await physics_frame
	if encounter:
		while not sample.encounter_ready: await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for enemy in sample.enemies: enemy.set_physics_process(false)
	var center: Vector2 = sample.meadow.landmarks.grove
	sample.enemies[0].position = Vector3(center.x,sample.meadow.walk_height(center,true)+.04,center.y+1.)
	for i in 40: await physics_frame
	await phase("idle",false,false)
	await phase("miss",true,false)
	await phase("hit",true,true)
	await phase("hit_no_stop",true,false)
	var path := "res://docs/perf33.json" if encounter else "res://docs/perf32.json" if elastic else "res://docs/perf31.json" if material else "res://docs/perf30.json" if feel else "res://docs/perf29.json" if telephone else "res://docs/perf28.json" if guided else "res://docs/perf26.json" if current else "res://docs/perf25-after.json" if updated else "res://docs/perf25-before.json"
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	sample._reset_impact_state()
	quit()
