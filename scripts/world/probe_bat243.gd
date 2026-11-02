extends "res://scripts/world/validate_plush220.gd"
class World:
 extends "res://scripts/world/woodland_world243.gd"
 var locked243: Node3D
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
 func _refresh_aim114(cursor: Vector2) -> void:
  if is_instance_valid(locked243):target114=locked243;aim114=locked243.hit_area.global_position;return
  super._refresh_aim114(cursor)
func run() -> void:
 w=World.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.
 w.cat220.set_physics_process(false);w.cat220.dead=true
 w.battle_phase220="repair";w.phase_age220=0.
 var bat=w.bats220[0];bat.set_enabled220(true);bat.hp=bat.max_hp110*.2
 w.locked243=bat
 await create_timer(.25).timeout
 w.rhythm236.time=.15;w.last_kind237="perfect";w.last_offset237=0.;w.candy117.hit236(1,true)
 await shot("music243-bat")
 w.stop225();quit()
