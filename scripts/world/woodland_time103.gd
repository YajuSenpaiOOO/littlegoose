extends "res://scripts/world/woodland_time102.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("102：","103：")+"\nCtrl+Alt+F6 林缘入口"
