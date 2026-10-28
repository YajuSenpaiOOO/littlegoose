extends "res://scripts/world/woodland_time108.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("108：","109：")+"\n右键按住：原地蹲防 · 松开开始冷却"
