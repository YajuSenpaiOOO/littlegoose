extends "res://scripts/world/world82.gd"
func _rail_script72() -> Script: return preload("res://scripts/art/rail_station83.gd")
func _station_kit_script81() -> Script: return preload("res://scripts/art/station_kit83.gd")
func _time_script() -> Script: return preload("res://scripts/world/world_time83.gd")
func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 车站83 · 石阶收边 / 后移候车厅 / 静谧花栏")
func stair_cuts80() -> PackedVector4Array:
	var cuts := super.stair_cuts80()
	cuts[1]=Vector4(3.101,-47.599,11.049,-44.251)
	return cuts
