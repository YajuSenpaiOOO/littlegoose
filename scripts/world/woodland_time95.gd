extends "res://scripts/world/woodland_time94.gd"
func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text=guide.text.replace("94：Ctrl+Alt+F2 林隙花丛","95：Ctrl+Alt+F2 林隙花海")
