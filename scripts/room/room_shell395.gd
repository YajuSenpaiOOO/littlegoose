extends "res://scripts/room/room_shell394.gd"
var desk_model395: Node3D
var use_desk395:=true
func build_furniture() -> void:
 super.build_furniture()
 desk_model395=preload("res://scripts/room/desk_model395.gd").new()
 item356("desk").root.add_child(desk_model395)
 set_desk395(true)
func set_desk395(value: bool) -> void:
 use_desk395=value
 desk_model395.visible=value
 var row: Dictionary=furniture394[0]
 row.sprite.visible=not value
 for c in row.originals:c.visible=false
 for c in row.shadows:c.visible=not value;c.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
 lamp_light394.position=desk_model395.lamp_anchor395 if value else new_light394
func set_window393(value: bool) -> void:
 super.set_window393(value)
 if is_instance_valid(desk_model395) and use_desk395:lamp_light394.position=desk_model395.lamp_anchor395
