extends "res://scripts/world/woodland_world275.gd"
func elastic_visual_script275() -> Script:return preload("res://scripts/art/elastic_visual276.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 276 · 彩色弹力球 / 同色反弹")
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:guide206.text=guide206.text.replace("275 林间空地","276 林间空地").replace("275 大团团挑战","276 大团团挑战")
