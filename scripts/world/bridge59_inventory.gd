extends "res://scripts/world/woodland46_probe.gd"
class InventorySample:
	extends "res://scripts/world/world58.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
func run() -> void:
	var sample: Node3D=InventorySample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.time55) or not sample.time55.is_node_ready(): await physics_frame
	sample.label.get_parent().hide()
	var rect: Rect2=sample.meadow.bridge_rect
	sample.hero.controls_enabled=false
	sample._teleport15(rect.get_center())
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	for i in 35: await physics_frame
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/bridge59_before.png")
	print("BRIDGE59_INVENTORY rect=",rect," camera=",sample.camera.global_transform," water=",sample.meadow.water," island=",sample.meadow.island)
	quit()
