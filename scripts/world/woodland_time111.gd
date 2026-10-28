extends "res://scripts/world/woodland_time110.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("110：","111：")+"\nF5 重新开始：清空本局记忆"
