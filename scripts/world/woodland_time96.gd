extends "res://scripts/world/woodland_time95.gd"
func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text=guide.text.replace("95：Ctrl+Alt+F2 林隙花海","96：Ctrl+Alt+F2 林间小憩")
