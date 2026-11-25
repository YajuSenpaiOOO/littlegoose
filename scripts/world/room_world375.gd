extends "res://scripts/world/room_world374.gd"
func companion_script373() -> Script:return preload("res://scripts/combat/goose_follow375.gd")
func room_script355() -> Script:return preload("res://scripts/room/room_shell375.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 375 · 睡眠层序与行走节奏")
 help367=help367.replace("374 · 盖被收发与侧面摆臂","375 · 睡眠层序与行走节奏")+"\nI 人物在枕前/旧深度对照"
 refresh367()
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_I:
  room.layer375=not room.layer375;get_viewport().set_input_as_handled();return
 super._input(event)

func _process(delta: float) -> void:
 super._process(delta)
 if sleeping362 and not legacy_sleep368:prompt.text="E 起床 · 被子＞人物＞枕头 · Q 掀被"
