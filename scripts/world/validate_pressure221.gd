extends SceneTree
class FixtureWorld:
 extends "res://scripts/world/woodland_world221.gd"
 func floor_height(at: Vector2) -> float:
  if at.x>400.:return 0.
  return super.floor_height(at)
var w: Node3D
var checks: Array[Dictionary]=[]
var metrics := {}
func _initialize() -> void:call_deferred("run")
func check(ok: bool,label: String) -> void:
 checks.append({"name":label,"pass":ok});print("221 ",ok," ",label)
func actor221(script: String,distance: float) -> CharacterBody3D:
 var old=w.cat220
 old.set_physics_process(false);old.collision_layer=0;old.hit_area.collision_layer=0;old.queue_free()
 var cat=load(script).new();cat.battle=w;cat.poses=w.combat_poses;cat.textures=w.combat_textures;cat.home=Vector2(500,500);cat.position=Vector3(500,0,500)
 w.add_child(cat);cat.set_physics_process(false);cat.play119();cat.hp=120.;cat.max_hp110=120.
 w.cat220=cat;w.enemies[0]=cat
 w.hero.set_physics_process(false);w.hero.position=Vector3(500.-distance,0.,500.);w.hero.reset_actions();w.hero.controls_enabled=true
 w.player_hp=100.;w.invulnerability=0.;w.active114=true;w.combat_paused=false;w.battle_phase220="fight";w._clear_combat_shots();w.auto114=false;w.pigs_enabled220=false
 cat.enter220("windup")
 return cat
func scenario221(script: String,distance: float,mode: String,seconds: float) -> Dictionary:
 var cat=actor221(script,distance)
 var dt=1./60.;var tracked=true;var committed=Vector2.INF;var parry_requested=false
 for i in int(seconds/dt):
  var move=Vector2.ZERO
  if mode=="retreat":move=Vector2.LEFT*4.1
  if mode=="sidestep" and cat.get("locked221"):move=Vector2.DOWN*4.1
  if mode=="parry" and cat.phase220=="roll" and cat.position.distance_to(w.hero.position)<2.4 and not parry_requested:
   parry_requested=w.hero.request_parry()
  w.hero.move_and_collide(Vector3(move.x,0.,move.y)*dt)
  w.hero.parry_t=maxf(0.,w.hero.parry_t-dt)
  w.hero.parry_cd=maxf(0.,w.hero.parry_cd-dt)
  cat._physics_process(dt)
  if cat.phase220=="roll":
   if committed==Vector2.INF:committed=cat.roll_dir220
   elif not committed.is_equal_approx(cat.roll_dir220):tracked=false
  else:committed=Vector2.INF
  await physics_frame
  if mode in ["sidestep","parry"] and cat.phase220=="recover":break
 return {"rolls":cat.roll_count220,"roll_hits":cat.rolled_hits220,"contacts":cat.contact_count220,"hp":w.player_hp,"parries":cat.parried_count,"committed_direction_unchanged":tracked,"walls":cat.get("walls221")}
func shot(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/pressure221-"+tag+".png")
func run() -> void:
 w=FixtureWorld.new();root.add_child(w);current_scene=w
 var deadline=Time.get_ticks_msec()+180000
 while not w.ready220 and Time.get_ticks_msec()<deadline:await process_frame
 if not w.ready220:check(false,"init");finish();return
 w.auto114=false;w.pigs_enabled220=false
 var floor_body=StaticBody3D.new();floor_body.collision_layer=1
 var collider=CollisionShape3D.new();var shape=BoxShape3D.new();shape.size=Vector3(60,1,40);collider.shape=shape;floor_body.add_child(collider);w.add_child(floor_body);floor_body.position=Vector3(500,-.5,500)
 for i in 3:await physics_frame
 metrics.old_retreat=await scenario221("res://scripts/combat/fat_cat_boss220.gd",3.5,"retreat",3.)
 metrics.new_retreat=await scenario221("res://scripts/combat/fat_cat_boss221.gd",3.5,"retreat",3.)
 check(metrics.old_retreat.roll_hits==0,"220 baseline misses ordinary straight retreat in open physical fixture")
 check(metrics.new_retreat.roll_hits>0,"221 roll reaches ordinary straight retreat without removing cues")
 metrics.far_retreat=await scenario221("res://scripts/combat/fat_cat_boss221.gd",8.,"retreat",3.2)
 check(metrics.far_retreat.rolls==2 and metrics.far_retreat.roll_hits>0,"bounded follow-up closes far retreat")
 check(metrics.new_retreat.rolls<=2 and metrics.far_retreat.rolls<=2,"at most two rolls in one burst")
 metrics.sidestep=await scenario221("res://scripts/combat/fat_cat_boss221.gd",3.5,"sidestep",2.)
 check(metrics.sidestep.roll_hits==0,"moving sideways after commitment can avoid first roll")
 check(metrics.sidestep.committed_direction_unchanged,"actual roll never homes after commitment")
 metrics.parry=await scenario221("res://scripts/combat/fat_cat_boss221.gd",3.5,"parry",2.)
 check(metrics.parry.parries>0,"native parry still interrupts faster roll")
 var cat=actor221("res://scripts/combat/fat_cat_boss221.gd",4.)
 cat._physics_process(.2);var early=cat.locked220
 w.hero.move_and_collide(Vector3(0,0,.5));cat._physics_process(.15)
 check(cat.locked221 and cat.locked220!=early,"aim updates during preparation then commits late")
 var locked: Vector2=cat.locked220
 w.hero.move_and_collide(Vector3(0,0,.5));cat._physics_process(.05)
 check(cat.locked220==locked,"last .18 seconds preserve committed target")
 cat.show_lane221=false;cat._render_legacy(0.)
 check(not cat.lane220.visible and cat.phase220=="windup","floor cue can hide while body windup remains")
 cat.show_lane221=true;cat._render_legacy(0.)
 check(cat.lane220.visible,"floor cue toggles independently of attack timing")
 floor_body.queue_free()
 w.end220(false);w.build170=0;w.begin220();w.auto114=true;w.pigs_enabled220=true;w.hero.set_physics_process(true)
 var samples: Array[float]=[];var last=Time.get_ticks_usec();var begin=last
 var shots=0;var cotton=0
 while Time.get_ticks_usec()-begin<6500000 and w.active114:
  await process_frame
  var now=Time.get_ticks_usec()
  if now-begin>500000:samples.append(float(now-last)/1000.)
  last=now;shots=maxi(shots,w.shots.size());cotton=maxi(cotton,w.cotton220.active.size())
 var total=0.
 for value in samples:total+=value
 metrics.map={"frame_mean_ms":total/maxi(1,samples.size()),"peak_player_shots":shots,"peak_cotton":cotton,"rolls":w.cat220.roll_count220,"walls":w.cat220.walls221,"terrain_stops":w.cat220.terrain_stops221,"hp":w.player_hp,"cat_hp":w.cat220.hp}
 check(w.cat220.roll_count220>0 and shots>0,"real map runs revised rolls with native automatic player fire")
 await shot("map")
 w.combat_paused=true;var clock: float=w.cat220.clock220;await create_timer(.2).timeout
 check(w.cat220.clock220==clock,"pause still freezes revised attack")
 w.combat_paused=false;w.end220(false)
 check(not w.context202 and w.navigation==w.original_navigation202,"exit restores original forest navigation")
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/pressure221-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics,"scope":"controlled physical fixture comparisons + short real-map combined run; not a human difficulty verdict"},"\t"))
 print("221_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
