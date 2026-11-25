extends "res://scripts/world/home_session408.gd"
func map_path406() -> String:return "res://scripts/world/woodland_world409.gd"
func room_path406() -> String:return "res://scripts/world/room_world409.gd"
func configure_map406() -> void:map406.set_mode405(2)
func door_point406() -> Vector2:return Vector2(-5.3,-6.3)
func _ready() -> void:
 await super._ready()
 hint406.text="409 · 小号3D外屋 / 轻收紧室内\n外屋68% · 左移0.6/后退1.5米\n门前E进屋 · F3进出 · 黑屏转场保留"
 DisplayServer.window_set_title("小白鹅 · 409 · 小号3D屋与轻收紧室内")
