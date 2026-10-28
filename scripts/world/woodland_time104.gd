extends "res://scripts/world/woodland_time103.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide):
  guide.text=guide.text.replace("103：","104：")+"\nCtrl+Alt+Q 阴影质量 · Ctrl+Alt+B 色层对照"
