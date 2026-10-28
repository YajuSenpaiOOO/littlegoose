extends "res://scripts/world/woodland_time101.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("101：","102：")
