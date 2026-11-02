extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world258.gd"
 var legacy258 := false
 func _init() -> void:
  super._init();memory_save116="user://boss258-validation-preview.cfg"
 func test_config_path226() -> String:return "user://boss258-validation.cfg"
 func export_stats226() -> Error:return OK
 func boss_script251() -> Script:
  return load("res://scripts/combat/tuantuan_boss257.gd") if legacy258 else super.boss_script251()
func prepare258(legacy: bool) -> CharacterBody3D:
 w.legacy258=legacy;w.begin251();var b=w.boss247
 b.set_physics_process(false);w.hero.set_physics_process(false);w.auto114=false;w.player_hp=12.;w.invulnerability=0.
 w.hero.cancel_guard109();w.hero.dodge_invulnerability=0.;w.hero.parry_t=.15;w.hero.parried=false
 b.hp=1000.;b.enter247("angry");b.enter247("flight");b.jump247=6
 b.position=w.hero.position+Vector3(.2,0,0);b.from247=Vector2(b.position.x,b.position.z)-Vector2.RIGHT;b.goal247=Vector2(b.position.x,b.position.z)
 return b
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready251 or not w.console226.has_method("draft_level257"):await process_frame
 w.set_physics_process(false)
 var b=prepare258(true);var hp=w.player_hp;b.strike257(2.,Vector2(b.position.x,b.position.z),"tuantuan_sweep")
 check(b.phase247=="deflected" and w.hero.parried,"reproduce real body-contact parry")
 w.reset_impact248();w.parry_grace258=0.;b._physics_process(.21);b._physics_process(.02)
 metrics.legacy_loss=hp-w.player_hp
 check(w.player_hp<hp,"257 outbound reflected jump reproduces immediate damage after successful parry")
 b=prepare258(false);hp=w.player_hp;var count=w.parry_count
 b.strike257(2.,Vector2(b.position.x,b.position.z),"tuantuan_sweep")
 check(w.parry_count==count+1 and b.phase247=="deflected" and b.attack_connected,"successful parry consumes current attack even after state transition")
 check(w.parry_grace258>=.349 and w.invulnerability==0.,"brief parry grace does not alter normal invulnerability or block future parry inputs")
 var phase=b.phase247;var jumps=b.jump247;b.land247()
 check(b.phase247==phase and b.jump247==jumps and w.player_hp==hp,"stale landing callback cannot resolve a parried flight")
 w.reset_impact248();w.parry_grace258=0.;b._physics_process(.21)
 check(b.reflected248 and b.attack_connected and b.total248==9,"returned bounce remains harmless while preserving add-two continuation")
 b._physics_process(.02)
 check(w.player_hp==hp,"outbound overlap is harmless even with grace forced off")
 b.position=w.hero.position+Vector3(.3,0,0);b.land247()
 check(w.player_hp==hp and b.phase247=="rebound","reflected landing cannot hit player either")
 w.hero.position.z+=4.
 b._physics_process(.05)
 check(b.phase247=="flight" and not b.reflected248 and not b.attack_connected,"next normal pursuit restores live attack checks")
 b.position=w.hero.position;b.lift247=0.;b.land247()
 check(w.player_hp==hp-3.,"later normal landing still deals expected damage")
 b=prepare258(false);b.strike257(2.,Vector2(b.position.x,b.position.z),"tuantuan_sweep");w.reset_impact248();hp=w.player_hp
 b.position.x+=5.
 w.emit_echoes256(Vector2(w.hero.position.x,w.hero.position.z),Vector2.DOWN)
 var ball=w.echoes256[0];ball.set_physics_process(false);ball.position=w.hero.position+Vector3.UP*.2;ball.direction=Vector2.ZERO;ball._physics_process(.001)
 metrics.echo={"hp":w.player_hp,"before":hp,"grace":w.parry_grace258,"queued":ball.is_queued_for_deletion(),"at":str(ball.position),"hero":str(w.hero.position)}
 check(w.player_hp==hp and ball.is_queued_for_deletion(),"echo ball cannot punish successful parry in the same moment")
 var grace=w.parry_grace258;w.combat_paused=true;w._physics_process(.2)
 check(w.parry_grace258==grace,"pause freezes parry grace")
 w.combat_paused=false;w._physics_process(.36);w.hero.dodge_invulnerability=0.;w.invulnerability=0.;w.hurt_player(1.,Vector2(w.hero.position.x,w.hero.position.z))
 check(w.parry_grace258==0. and w.player_hp==hp-1.,"damage returns after finite grace")
 w.clear_echoes256();b=prepare258(false);b.enter247("pounce");hp=w.player_hp;b.strike257(2.,Vector2(b.position.x,b.position.z),"tuantuan_sweep")
 check(b.phase247=="flat" and w.player_hp==hp,"pounce parry still goes directly to clean recovery")
 w.reset_impact248();w.begin251();b=w.boss247;b.set_physics_process(false)
 check(w.parry_grace258==0. and w.player_hp==12. and w.capacity257()==4,"restart clears protection and preserves initial progression")
 w.hero.parry_t=.15;w.hero.parried=false;w.invulnerability=0.;w.combat_paused=true;count=w.parry_count
 w.parry_success(w.hero.position,Vector3.RIGHT)
 check(w.parry_count==count and w.parry_grace258==0.,"rejected paused parry does not grant protection")
 w.combat_paused=false;w.parry_grace258=.3;w.finish251(false)
 check(w.parry_grace258==0. and w.echoes256.is_empty(),"end cleans protection and projectiles")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/parry258-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("PARRY258_VALIDATION ",ok," checks=",checks.size()," metrics=",metrics);quit(0 if ok else 1)
