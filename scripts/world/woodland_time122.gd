extends "res://scripts/world/woodland_time121.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("121 · 自然散场与团团蹦跳","122 · 团团退场与闲逛狠话")
