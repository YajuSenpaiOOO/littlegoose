extends "res://scripts/world/woodland_world127.gd"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 128 · 错峰扑击 / 弹弓蓄力取舍")
func _enemy_script() -> Script: return preload("res://scripts/combat/tuantuan128.gd")
func _hero_script() -> Script: return preload("res://scripts/combat/hero128.gd")
func charge_time() -> float:
 return 1.10/buffs.rate()*(.85 if buffs.level("slingshot")>=2 else 1.)
func on_dash_started() -> void:
 _cancel_charge()
 super.on_dash_started()
func _step_fire_input(delta: float) -> void:
 if is_instance_valid(hero) and hero.dash_left>0. and buffs.level("slingshot")>0:
  _cancel_charge();return
 super._step_fire_input(delta)
