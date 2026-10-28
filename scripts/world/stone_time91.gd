extends "res://scripts/world/terrace_time90.gd"
func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text+="\n91：Ctrl+Alt+K 净草地/独立岩面 对照"
