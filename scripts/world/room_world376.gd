extends "res://scripts/world/room_world375.gd"
func companion_script373() -> Script:return preload("res://scripts/combat/goose_follow376.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 376 · 小黑鹅呼吸与弹步")
 help367=help367.replace("375 · 睡眠层序与行走节奏","376 · 小黑鹅呼吸与弹步")+"\nO 呼吸弹步开关 · N 双人近看"
 refresh367()
func _input(event: InputEvent) -> void:
 if ready355 and is_instance_valid(companion373) and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_O:
  companion373.motion376=not companion373.motion376;get_viewport().set_input_as_handled();return
 super._input(event)
