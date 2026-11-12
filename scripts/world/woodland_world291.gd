extends "res://scripts/world/woodland_world290.gd"
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_boss291.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 291 · 弹珠团团 / 跳跃与表情关键帧")
func _ready() -> void:
 await super._ready()
 hint288.text="291 弹珠团团动作　F9直接Boss / F10旧种族外形\nF11单图290与新关键帧对照 / F7重试 / F8普通战\nQ手电主动 / C装配；睡姿、蓄力、跳跃、落地、受击、晕脸"
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed and ready264 and event.physical_keycode==KEY_F11 and not combat_paused:
  boss247.rich291=not boss247.rich291
  if boss247.resting265:boss247._process(0.)
  else:boss247.render247()
  notice219("新关键帧" if boss247.rich291 else "290单图变形对照");get_viewport().set_input_as_handled();return
 super._input(event)
