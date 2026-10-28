extends "res://scripts/world/woodland_world125.gd"
var shove_gates127 := {}
var shove_bursts127 := 0
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 127 · 呆萌生气 / 互拱飙汁")
func _enemy_script() -> Script: return preload("res://scripts/combat/tuantuan127.gd")
func start_combat(reposition := true) -> void:
 shove_gates127.clear();shove_bursts127=0
 super.start_combat(reposition)
func shove_juice127(a: CharacterBody3D,b: CharacterBody3D) -> void:
 if combat_paused or not active114 or not material_feedback or not is_instance_valid(jelly_fx): return
 if not is_instance_valid(a) or not is_instance_valid(b) or a.dead or b.dead: return
 var low := mini(a.get_instance_id(),b.get_instance_id());var high := maxi(a.get_instance_id(),b.get_instance_id())
 var pair := "%d:%d"%[low,high]
 if combat_clock33<float(shove_gates127.get(pair,-INF)): return
 shove_gates127[pair]=combat_clock33+.24
 var at := (a.global_position+b.global_position)*.5+Vector3.UP*.55
 var direction := (b.global_position-a.global_position).normalized()
 jelly_fx.burst(at,direction,false)
 jelly_fx._play(jelly_fx.hit_clip,at,-14.,1.03)
 shove_bursts127+=1
