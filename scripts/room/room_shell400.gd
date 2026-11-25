extends "res://scripts/room/room_shell399.gd"
var vines400: Node3D
func build_shell() -> void:
 super.build_shell()
 vines400=preload("res://scripts/room/vines400.gd").new();add_child(vines400)
func set_vines400(value: bool) -> void:vines400.visible=value
