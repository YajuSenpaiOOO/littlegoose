extends "res://scripts/world/woodland_time100.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("100：","101：")+"\nCtrl+Alt+A 环境音开关"
