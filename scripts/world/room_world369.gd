extends "res://scripts/world/room_world368.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell369.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 369 · 同比例完整睡姿")
 help367="369 · 参考行走小人的完整睡姿\nE 床边睡下/起床 · F10 状态\nR 新睡姿/368旧睡姿 · B 旧2D床\nC 近看 · F12 跟随 · F11 床对照\nQ 掀被看全身 · G 搭毯\nF2 昼夜 · F4 占地 · F7 归位"
 refresh367()
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_R:
  room.set_old_pose369(not room.old_pose369)
  message355="睡姿："+("368旧长身对照" if room.old_pose369 else "369原小人比例");message_left355=4.
  get_viewport().set_input_as_handled();return
 super._input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if sleeping362 and not legacy_sleep368:prompt.text="E 起床 · "+("368旧睡姿" if room.old_pose369 else "369完整睡姿 · Q掀被")+(" · 右位预留" if room.mode362==2 else "")
