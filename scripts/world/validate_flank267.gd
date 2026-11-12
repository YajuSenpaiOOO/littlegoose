extends "res://scripts/world/validate_plush220.gd"
class Walker:
 extends "res://scripts/combat/hero192.gd"
 var input267 := Vector2.ZERO
 func movement_input() -> Vector2:return input267 if controls_enabled else Vector2.ZERO
 func dash_key_down() -> bool:return false
class Harness:
 extends "res://scripts/world/woodland_world267.gd"
 var contacts267 := 0
 func _init() -> void:
  super._init();memory_save116="user://flank267-validation-preview.cfg"
 func test_config_path226() -> String:return "user://flank267-validation.cfg"
 func export_stats226() -> Error:return OK
 func _hero_script() -> Script:return Walker
 func hurt_player(_damage: float,_from: Vector2) -> void:contacts267+=1
func simulate267(enabled: bool) -> Dictionary:
 w.tactics_enabled267=enabled;w.yard264();w.auto114=false;w.ordinary264();w.contacts267=0
 var centre: Vector2=w.meadow.landmarks.grove
 w.hero.position=Vector3(centre.x+4.,w.floor_height(centre)+.1,centre.y);w.hero.reset_physics_interpolation()
 var killed_at=Time.get_ticks_msec();var deadline=killed_at+65000;var max_live=0;var max_flank=0;var max_attacks=0;var early=true;var damage=true;var snapshot=false
 while w.mode264=="ordinary" and Time.get_ticks_msec()<deadline:
  await physics_frame
  var live=w.live_minions260();max_live=maxi(max_live,live.size())
  var flankers=live.filter(func(m):return m.flanking267());max_flank=maxi(max_flank,flankers.size())
  max_attacks=maxi(max_attacks,live.filter(func(m):return m.attack_phase in ["windup","lunge"]).size())
  if w.roster264.spawned<7 and not flankers.is_empty():early=false
  for m in live:
   if m.max_hp110!=6. or m.touch110!=1. or m.speed110!=1.:damage=false
  var radial=Vector2(w.hero.position.x,w.hero.position.z)-centre
  w.hero.input267=(radial.orthogonal().normalized()+(4.-radial.length())*radial.normalized()*.8).normalized()
  var now=Time.get_ticks_msec()
  if now-killed_at>=2200:
   var targets=live.filter(func(m):return m.targetable260())
   if not targets.is_empty():targets[0].receive_hit(100.,Vector3.RIGHT);killed_at=now
  if enabled and not snapshot and flankers.size()>0:
   w.combat_paused=true;await shot("flank267-side");w.combat_paused=false;snapshot=true;killed_at=Time.get_ticks_msec()
 w.hero.input267=Vector2.ZERO
 return {"enabled":enabled,"finished":w.mode264=="ready","kills":w.roster264.defeated,"max_live":max_live,"max_flankers":max_flank,"max_attacks":max_attacks,"early_unchanged":early,"stats_unchanged":damage,"contact_checks":w.contacts267,"tactics":w.tactics267.duplicate(true),"seconds":w.roster264.seconds}
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false
 check(w.hero.collision_mask==3 and w.boss247.collision_layer==18,"hero and rest collision remain the tested 266 setup")
 metrics.trials=[]
 metrics.trials.append(await simulate267(false));metrics.trials.append(await simulate267(true))
 var old=metrics.trials[0];var current=metrics.trials[1]
 check(old.finished and current.finished and old.kills==15 and current.kills==15,"both fixed-circle fixtures complete all fifteen members")
 check(current.early_unchanged and old.tactics.assignments==0,"first two batches and disabled baseline have no flank assignments")
 check(current.stats_unchanged and current.max_live<=5,"six health, one damage, original hop speed and population caps retained")
 check(current.tactics.assignments>0 and current.tactics.front_entries>0,"real moving encounter performs flanks and forward entries")
 check(current.max_flankers<=2 and current.max_attacks<=1,"at most two flankers and one attacking actor")
 check(current.tactics.intercepts>0,"front-side approach converts into interception rather than only travelling to a waypoint")
 check(current.tactics.arrived+current.tactics.timeouts+current.tactics.hit_breaks+current.tactics.intercepts>0,"flanking resolves rather than trapping actors in permanent detours")
 w.tactics_enabled267=true;w.yard264();w.ordinary264();w.roster264.wave=2;w.roster264.spawned=7
 var m=w.live_minions260()[0];var player=Vector2(w.hero.position.x,w.hero.position.z)
 m.assign_flank267(player+Vector2(2.,2.),"front");var goal=m.flank_goal267
 w.heading267=Vector2.LEFT;w.flank_plan267()
 check(m.flank_goal267==goal,"committed flank target does not swivel when player reverses")
 var clock=m.flank_left267;w.combat_paused=true;await create_timer(.2).timeout
 check(m.flank_left267==clock,"pause freezes tactical commitments")
 w.combat_paused=false;m.receive_hit(.1,Vector3.RIGHT)
 check(m.flank_left267==0. and m.flank_cooldown267>2.,"actual hit cancels a flank and grants a reroute cooldown")
 m.assign_flank267(player+Vector2(2.,2.),"front")
 check(not w.reserve_attack(m),"flanker cannot start an attack before leaving repositioning")
 m.stop_flank267("test");w.attack_gate260=0.
 for other in w.live_minions260():other.attack_phase="approach"
 check(w.reserve_attack(m) and is_equal_approx(w.attack_gate260,.95),"third batch uses a bounded stagger rather than simultaneous attacks")
 var report=w.report_stats226()
 check(report.has("tactics267") and report.tactics267.has("assignments"),"player captures include tactical counters")
 w.boss_unlocked264=true;w.boss264();w.boss247.set_physics_process(false)
 var boss_minion=w.spawn_minion260()
 check(not w.late267() and boss_minion!=null and boss_minion.flank_left267==0. and w.minion_cap261()==3,"Boss companions retain original behaviour and cap")
 w.finish251(false);w.cancel_dialog264();w.yard264()
 check(w.live_minions260().size()==3 and not w.active114,"replay restores three harmless playground actors")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/flank267-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("FLANK267_VALIDATION ",ok," metrics=",metrics);quit(0 if ok else 1)
