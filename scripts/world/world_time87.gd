extends "res://scripts/world/world_time86.gd"
func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text+="\n87：3 林地 · Ctrl+7 西侧苔岩\nCtrl+Alt+G 林地小景对照"
