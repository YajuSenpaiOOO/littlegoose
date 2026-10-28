extends "res://scripts/world/woodland_time120.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("120 · 林间聚会与弹跳收藏品","121 · 自然散场与团团蹦跳")+"\n散场后自由探索，自己决定何时回小院"
