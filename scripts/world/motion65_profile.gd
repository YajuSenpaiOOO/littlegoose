extends "res://scripts/world/air52_performance_probe.gd"
class Baseline:
	extends "res://scripts/world/world64.gd"
	var contact_us := 0
	var contact_calls := 0
	var blending_us := 0
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func _update_prop_contacts() -> void:
		var start := Time.get_ticks_usec()
		super._update_prop_contacts()
		contact_us+=Time.get_ticks_usec()-start
		contact_calls+=1
	func _update_tree_blending() -> void:
		var start := Time.get_ticks_usec()
		super._update_tree_blending()
		blending_us+=Time.get_ticks_usec()-start

func run() -> void:
	var sample := Baseline.new()
	root.add_child(sample)
	while not is_instance_valid(sample.landmark62) or not sample.landmark62.is_node_ready(): await physics_frame
	sample.label.get_parent().hide()
	sample._travel_region("home")
	for i in 45: await physics_frame
	sample.contact_us=0; sample.contact_calls=0; sample.blending_us=0
	sample.hero.controls_enabled=true
	var result := await record(sample,360,true)
	result.contact_total_ms=sample.contact_us/1000.
	result.contact_calls=sample.contact_calls
	result.tree_blending_total_ms=sample.blending_us/1000.
	var file := FileAccess.open("res://docs/motion65-baseline.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"\t"))
	print("MOTION65_BASELINE ",JSON.stringify(result))
	quit()
