extends SceneTree
class ProfileWorld:
	extends "res://scripts/world/world83.gd"
	var timing84: Dictionary={}
	func record84(tag: String,start: int) -> void:
		var seconds := (Time.get_ticks_usec()-start)/1000000.
		timing84[tag]=float(timing84.get(tag,0.))+seconds
		print("STARTUP84 ",tag," ",seconds)
	func _build_lab_floor() -> void:
		var t := Time.get_ticks_usec();super._build_lab_floor();record84("surface_init",t)
	func _rebuild_terrain() -> void:
		var t := Time.get_ticks_usec();super._rebuild_terrain();record84("terrain",t)
	func _build_lab_grass() -> void:
		var t := Time.get_ticks_usec();super._build_lab_grass();record84("grass",t)
	func _build_woodland() -> void:
		var t := Time.get_ticks_usec();super._build_woodland();record84("trees",t)
	func _rebuild_root_pieces() -> void:
		var t := Time.get_ticks_usec();super._rebuild_root_pieces();record84("root_geometry",t)
	func _bake_root_shade() -> void:
		var t := Time.get_ticks_usec();super._bake_root_shade();record84("root_mask",t)
	func _cache_floor() -> void:
		var t := Time.get_ticks_usec();super._cache_floor();record84("floor_lookup",t)
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var start := Time.get_ticks_usec()
	var world := ProfileWorld.new();root.add_child(world)
	while not is_instance_valid(world.station81): await physics_frame
	for i in 12: await physics_frame
	var result := {"total_seconds":(Time.get_ticks_usec()-start)/1000000.,"stages":world.timing84}
	var file := FileAccess.open("res://docs/startup84-baseline.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"\t"))
	print("STARTUP84_BASELINE ",JSON.stringify(result));quit()
