extends "res://scripts/world/validate_plush220.gd"
class Walker:
 extends "res://scripts/combat/hero192.gd"
 var input266 := Vector2.ZERO
 func movement_input() -> Vector2:return input266 if controls_enabled else Vector2.ZERO
 func dash_key_down() -> bool:return false
class Harness:
 extends "res://scripts/world/woodland_world266.gd"
 var legacy266 := false
 func _init() -> void:
  super._init();memory_save116="user://rest266-validation-preview.cfg"
 func test_config_path226() -> String:return "user://rest266-validation.cfg"
 func export_stats226() -> Error:return OK
 func _hero_script() -> Script:return Walker
 func roster_script264() -> Script:
  return preload("res://scripts/combat/encounter_roster265.gd") if legacy266 else super.roster_script264()
 func minion_script260() -> Script:
  return preload("res://scripts/combat/tuantuan_minion264.gd") if legacy266 else super.minion_script260()
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func place_hero266(offset: Vector2) -> void:
 w.hero.input266=Vector2.ZERO;w.hero.reset_actions();w.hero.controls_enabled=true
 var at=w.rest_at265+offset;w.hero.position=Vector3(at.x,w.floor_height(w.rest_at265)+.26,at.y);w.hero.velocity=Vector3.ZERO;w.hero.locomotion=Vector2.ZERO;w.hero.combat_impulse=Vector2.ZERO;w.hero.reset_physics_interpolation()
func drive266(offset: Vector2,dash: bool) -> Dictionary:
 place_hero266(offset);await settle(2)
 var direction=-offset.normalized();var collided=false;var support=false;var start=w.hero.position
 if dash:w.hero.request_dash(direction)
 else:w.hero.input266=direction
 var deadline=Time.get_ticks_msec()+850
 while Time.get_ticks_msec()<deadline:
  await physics_frame
  for i in w.hero.get_slide_collision_count():
   if w.hero.get_slide_collision(i).get_collider()==w.boss247:collided=true
   if w.hero.get_slide_collision(i).get_collider()==w.cushion265.support266:support=true
 w.hero.input266=Vector2.ZERO
 return {"dash":dash,"blocked_by_boss":collided,"blocked_by_support":support,"remaining_distance":Vector2(w.hero.position.x,w.hero.position.z).distance_to(w.rest_at265),"travel":w.hero.position.distance_to(start),"mask":w.hero.collision_mask}
func trial266(legacy: bool) -> Dictionary:
 w.legacy266=legacy;w.yard264();w.hero.set_physics_process(false);w.hero.controls_enabled=false;w.auto114=false;w.ordinary264()
 var last_kill=Time.get_ticks_msec();var gap_start=-1;var max_gap=0;var total_gap=0;var max_live=0;var exposed=false;var actual_ray=false;var pictured=false
 var deadline=Time.get_ticks_msec()+70000
 while w.mode264=="ordinary" and Time.get_ticks_msec()<deadline:
  await physics_frame
  var now=Time.get_ticks_msec();var live=w.live_minions260();max_live=maxi(max_live,live.size())
  var targets=live.filter(func(m):return m.targetable260())
  var incoming=targets.filter(func(m):return m.state260=="arrive")
  if not legacy and not incoming.is_empty():
   exposed=true
   if not actual_ray:
    var enemy=incoming[0];var point=enemy.hit_area.global_position
    var query=PhysicsRayQueryParameters3D.create(point+Vector3.UP*2.,point-Vector3.UP*.1,8,[w.hero.get_rid()]);query.collide_with_areas=true;query.collide_with_bodies=false
    var hit=w.get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty() and hit.collider==enemy.hit_area:
     var before=enemy.hp;var shot_data=w.data_shot110(point+Vector3.UP*2.,Vector3.DOWN*20.,1.);shot_data.fixed_damage110=1.
     w._apply_shot_hit(shot_data,hit);actual_ray=enemy.hp<before;w._clear_combat_shots()
  if w.roster264.defeated>0 and w.roster264.defeated<15 and targets.is_empty():
   if gap_start<0:gap_start=now
  elif gap_start>=0:
   var duration=now-gap_start;max_gap=maxi(max_gap,duration);total_gap+=duration;gap_start=-1
  if not legacy and not pictured and exposed and w.roster264.defeated>=5:
   w.combat_paused=true;await shot("rest266-reinforcements");w.combat_paused=false;pictured=true;last_kill=Time.get_ticks_msec()
  if now-last_kill>=550 and not targets.is_empty():
   targets[0].receive_hit(100.,Vector3.RIGHT);last_kill=now
 var result={"legacy":legacy,"finished":w.mode264=="ready","kills":w.roster264.defeated,"max_live":max_live,"longest_no_target_ms":max_gap,"total_no_target_ms":total_gap,"incoming_targetable":exposed,"incoming_native_ray_hit":actual_ray,"seconds":w.roster264.seconds}
 return result
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false
 check(w.rest_at265.distance_to(w.meadow.landmarks.grove+Vector2(0,-12))<.01,"rest bay uses authored ridge-front position beyond shrubs")
 check((w.hero.collision_mask&w.boss247.collision_layer)!=0 and w.hero.collision_mask==3,"rest footprint intersects real hero mask without changing hero collision policy")
 check(w.cushion265.support266.collision_layer==2 and w.boss247.hit_area.collision_layer==0,"mattress has support collision while sleeping boss is not an attack target")
 check(w.boss247.position.distance_to(w.cushion265.position)<.001 and absf(w.boss247.visual.position.y-.22)<.001,"body contact anchor and mattress top share the same centre and height")
 metrics.hero=[]
 metrics.hero.append(await drive266(Vector2(2.5,0),false));metrics.hero.append(await drive266(Vector2(-2.5,0),false));metrics.hero.append(await drive266(Vector2(0,2.8),true))
 check(metrics.hero.all(func(m):return (m.blocked_by_boss or m.blocked_by_support) and m.remaining_distance>1.2),"native hero ground approaches and dash stop at the physical rest footprint")
 metrics.body=[]
 metrics.body.append(await drive266(Vector2(1.8,0),false));metrics.body.append(await drive266(Vector2(-1.8,0),false));metrics.body.append(await drive266(Vector2(0,1.2),true))
 check(metrics.body.all(func(m):return m.blocked_by_boss and m.remaining_distance>1.1),"native hero already on mattress cannot walk or dash through boss body")
 w.hero.set_physics_process(false);place_hero266(Vector2(2.5,2.1));w.hero.controls_enabled=false
 w.combat_paused=true;await shot("rest266-sleep-front");w.combat_paused=false
 place_hero266(Vector2(-2.5,-.3));w.hero.controls_enabled=false;w.combat_paused=true;await shot("rest266-sleep-back");w.combat_paused=false
 w.time55.preview_at(22.);await create_timer(.4).timeout;w.combat_paused=true;await shot("rest266-night");w.combat_paused=false;w.time55.preview_at(12.)
 metrics.trials=[]
 metrics.trials.append(await trial266(true));metrics.trials.append(await trial266(false))
 var old=metrics.trials[0];var current=metrics.trials[1]
 check(old.finished and current.finished and old.kills==15 and current.kills==15,"both identical kill-cadence comparisons finish the fixed fifteen-member encounter")
 check(current.max_live<=5 and current.incoming_targetable and current.incoming_native_ray_hit,"early visible arrivals are real damage targets while total population remains bounded")
 check(current.longest_no_target_ms<1000 and current.longest_no_target_ms<old.longest_no_target_ms,"new pipeline removes multi-second untargetable gaps at the same kill cadence")
 check(current.total_no_target_ms<old.total_no_target_ms,"total no-target waiting time decreases rather than moving to another wave")
 await create_timer(1.).timeout
 check(w.awake265 and not w.boss247.sleeping265 and w.boss247.resting265,"clear still wakes boss at the new rest bay")
 w.hero.position=w.boss247.position+Vector3(2.4,.25,0);w.interact264()
 check(w.dialog264.visible and not w.active114,"awake boss dialogue remains a separate challenge trigger")
 w.cancel_dialog264();w.combat_paused=true;await shot("rest266-awake");w.combat_paused=false
 w.interact264();w.confirm264();w.boss247.set_physics_process(false)
 check(w.mode264=="boss" and w.boss247.collision_layer==16 and w.minion_cap261()==3,"combat boss restores original collision and three-minion limit")
 w.finish251(false);w.cancel_dialog264();w.yard264()
 check(w.get_children().filter(func(n):return n is CharacterBody3D and n.get_script()==w.boss_script251()).size()==1,"replays retain exactly one rest or combat boss")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/rest266-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("REST266_VALIDATION ",ok," checks=",checks.size()," metrics=",metrics);quit(0 if ok else 1)
