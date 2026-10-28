extends "res://scripts/world/woodland_time99.gd"
func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text=guide.text.replace("99：","100：")
