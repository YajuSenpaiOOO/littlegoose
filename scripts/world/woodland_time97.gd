extends "res://scripts/world/woodland_time96.gd"
func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text=guide.text.replace("96：Ctrl+Alt+F2 林间小憩","97：Ctrl+Alt+F2 游园 · F3 秋千")
