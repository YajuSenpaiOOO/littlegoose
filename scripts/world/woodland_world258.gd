extends "res://scripts/world/woodland_world257.gd"
var parry_grace258 := 0.
var blocked_hits258 := 0
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_boss258.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 258 · 团团Boss / 弹反保护修正")
func begin251() -> void:
 parry_grace258=0.;blocked_hits258=0;super.begin251()
func finish251(victory: bool) -> void:
 parry_grace258=0.;super.finish251(victory)
func parry_success(contact: Vector3,outward: Vector3) -> void:
 var before=parry_count
 super.parry_success(contact,outward)
 if parry_count>before:parry_grace258=maxf(parry_grace258,.35)
func hurt_player(damage: float,from: Vector2) -> void:
 if parry_grace258>0. and active114:
  blocked_hits258+=1;return
 super.hurt_player(damage,from)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not combat_paused:parry_grace258=maxf(0.,parry_grace258-delta)
func _process(delta: float) -> void:
 super._process(delta)
 if ready251:guide206.text=guide206.text.replace("257 团团Boss · 初始决心 / 贴身判定","258 团团Boss · 弹反保护修正")
