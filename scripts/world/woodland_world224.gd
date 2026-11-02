extends "res://scripts/world/woodland_world223.gd"
func _init() -> void:
 super._init();memory_save116="user://plush_boss224_preview.cfg"
func _sister_script220() -> Script:
 return preload("res://scripts/art/sister_fall224.gd")
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 224 · 姐姐B姿势软落地")
func begin220() -> void:
 if is_instance_valid(rig220):rig220.reset_fall224()
 super.begin220()
func end220(victory: bool) -> void:
 super.end220(victory)
 if is_instance_valid(rig220):
  if victory:rig220.start_fall224()
  else:rig220.reset_fall224()
func _process(delta: float) -> void:
 super._process(delta)
 if ready220:
  guide206.text=guide206.text.replace("223 蝙蝠表情","224 姐姐软落地")+"\nF9进入修补 → F10预览落床 · F6可暂停收尾"
  if rig220.fall224:result220="姐姐在地上缓一缓 · F7重开"
func _input(event: InputEvent) -> void:
 if ready220 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  if event.physical_keycode==KEY_F10:
   if active114 and not combat_paused and battle_phase220=="repair":bats220[0].receive_hit(bats220[0].hp,Vector3.ZERO)
   get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F6 and rig220.fall224:
   combat_paused=not combat_paused;hero.controls_enabled=not combat_paused
   get_viewport().set_input_as_handled();return
 super._input(event)
