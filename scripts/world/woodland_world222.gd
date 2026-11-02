extends "res://scripts/world/woodland_world221.gd"
func _init() -> void:
 super._init();memory_save116="user://plush_boss222_preview.cfg"
func _sister_script220() -> Script:
 return preload("res://scripts/art/sister_repair222.gd")
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 222 · 姐姐低空修补动作")
func repair_spot220() -> Vector2:
 # Mend from behind the cat, with a small lateral offset to keep her face visible.
 return Vector2(cat220.position.x,cat220.position.z)+Vector2(1.65,-.75)
func _process(delta: float) -> void:
 super._process(delta)
 if ready220:
  guide206.text=guide206.text.replace("221 肥猫追滚","222 姐姐修补")+"\nF9 跳至修补预览 · 六秒内可攻击蝙蝠"
func _input(event: InputEvent) -> void:
 if ready220 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and event.physical_keycode==KEY_F9:
  if active114 and not combat_paused and battle_phase220=="fight":cat220.receive_hit(cat220.hp,Vector3.ZERO)
  get_viewport().set_input_as_handled();return
 super._input(event)
