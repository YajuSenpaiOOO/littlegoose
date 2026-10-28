extends "res://scripts/world/woodland_time92.gd"
func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text+="\n94：Ctrl+Alt+F2 林隙花丛"
