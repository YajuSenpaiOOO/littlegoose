extends "res://scripts/world/woodland_world269.gd"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 270 · 花与团团整体滚动")
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:guide206.text=guide206.text.replace("269 滚滚花团团","270 整体滚动花团团")
