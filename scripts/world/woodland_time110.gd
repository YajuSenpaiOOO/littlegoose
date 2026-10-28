extends "res://scripts/world/woodland_time109.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("109：","110：")+"\nF11 切换演练档 · 六幕含精英与大王"
