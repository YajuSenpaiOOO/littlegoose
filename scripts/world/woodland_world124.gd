extends "res://scripts/world/woodland_world123.gd"
var pressure124 := false
func _enemy_script() -> Script: return preload("res://scripts/combat/tuantuan124.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 124 · 生气互拱 / 柔和退场")
func reserve_attack(enemy: CharacterBody3D) -> bool:
 if not pressure124: return super.reserve_attack(enemy)
 if combat_paused or wave_state!="fighting" or between_left>0. or combat_clock33<next_attack33: return false
 var busy := 0
 for other in enemies:
  if is_instance_valid(other) and other!=enemy and not other.dead and other.attack_phase in ["windup","lunge"]: busy+=1
 if busy>=2: return false
 last_attacker=weakref(enemy);next_attack33=combat_clock33+.65;return true
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F6 and not event.ctrl_pressed and not event.alt_pressed:
  pressure124=not pressure124
  encounter_hud.announce("包夹压力对照" if pressure124 else "原有轻松节奏","最多两位同时准备扑击 · 间隔0.65秒" if pressure124 else "最多一位准备扑击 · 间隔1秒",2.5)
  return
 super._unhandled_input(event)
