extends "res://scripts/world/woodland_time105.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("105：","106：")+"\nCtrl+Alt+F7 树下暖灯对照"
