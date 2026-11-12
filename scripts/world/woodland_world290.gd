extends "res://scripts/world/woodland_world288.gd"
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_boss290.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 290 · 玻璃弹珠大团团 / 动作适配")
func _ready() -> void:
 await super._ready()
 hint288.text="290 玻璃弹珠大团团　F9直接试Boss / F10新旧外形\nQ手电主动 / C装配 / F7重试 / F8普通战\n睡姿暂沿用旧稿；战斗数值与288相同"
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed and ready264:
  if event.physical_keycode==KEY_F9 and not combat_paused:
   boss_unlocked264=true;boss264();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F10 and is_instance_valid(boss247) and not combat_paused:
   boss247.glass290=not boss247.glass290
   if not boss247.resting265:boss247.render247()
   notice219("玻璃弹珠外形" if boss247.glass290 else "旧版外形对照")
   get_viewport().set_input_as_handled();return
 super._input(event)
