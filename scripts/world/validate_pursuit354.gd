extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world354.gd"
 var injury347:=0.
 var weave_attempts352:=0
 func place_pad172(actor: CharacterBody3D) -> CharacterBody3D:
  weave_attempts352+=1
  return super.place_pad172(actor)
 func hurt_player(damage: float,_from: Vector2) -> void:injury347+=damage
 func load_test226() -> void:pass
 func ordinary_record_folder347() -> String:return "res://.pursuit354-record-validation"
 func commit_progress257(levels: Dictionary,_cat: float,_bat: float,_restart: bool,level: int) -> String:
  var error:=loadout_error257(levels,level)
  if error!="":return error
  if recording226.active:recording226.finish(self,"loadout_change_abort")
  determination_level257=level;levels226=levels.duplicate(true);apply_levels226();close_console226();restart301()
  return ""
 func export_stats226() -> Error:return OK
var failures: Array[String]=[]
var config: Dictionary={}
func _initialize() -> void:call_deferred("run")
func check(ok: bool, label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 current_scene.encounter_hud.set_process(false)
 current_scene._process(.016)
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/pursuit354-"+tag+".png")
func kill(actor: Node) -> void:
 if not actor.get_meta("elite347",false) or actor.get_meta("kind347","")=="bomber":actor.entry350=0.;actor.travel351="";actor.play119()
 actor.receive_hit(9999.,Vector3.BACK)
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg"):config[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=Trial.new();root.add_child(w);current_scene=w
 var limit:=Time.get_ticks_msec()+180000
 while not w.ready350 and Time.get_ticks_msec()<limit:await process_frame
 if not w.ready350:quit(1);return
 w.set_process(false);w.set_physics_process(false);w.hero.set_physics_process(false)
 w.restart301()
 check(w.context202 and w.navigation==w.forest_navigation202 and w.spider_trial170,"forest navigation and silk gameplay active")
 check(w.centre301.distance_to(w.arena220)<15. and not w.theatre314.visible,"sister forest arena without castle")
 check(w.total347()==27,"twenty-three spiders, two pigs and two bombers")
 w.jobs347.clear()
 var bomber=w.spawn347("bomber");bomber.set_physics_process(false)
 bomber._physics_process(1.81);bomber._physics_process(.02)
 check(bomber.max_hp110==22. and bomber.global_position.y>bomber.ground353.y+1. and bomber.hit_area.collision_layer==8,"airborne elite is vulnerable at actual swing height")
 w.auto114=false;w.aim_tick114=-1
 var cursor: Vector2=w.camera.unproject_position(bomber.hit_area.global_position)
 w._refresh_aim114(cursor)
 check(w.target114==bomber and w.aim114.y>bomber.ground353.y+1.,"mouse assistance locks actual airborne hit region")
 await capture("aim")
 for i in 2:await physics_frame
 var origin: Vector3=w.projectile_origin()
 var bullet: Dictionary=w.data_shot110(origin,(bomber.hit_area.global_position-origin).normalized()*12.,1.5)
 bullet.fixed_damage110=1.;bullet.tracking146=0
 for i in 24:
  w._step_shots(.025)
  await physics_frame
 check(bomber.hp<22.,"real native player projectile hits suspended elite")
 w._clear_combat_shots()
 var tracked: Dictionary=w.data_shot110(origin,(bomber.hit_area.global_position-origin).normalized()*12.,1.5)
 tracked.tracking146=1
 w._steer_shot(tracked,.1)
 check(tracked.has("air353") and tracked.velocity.y>.1,"eye exercise preserves the airborne vertical trajectory")
 w._clear_combat_shots()
 var held: Vector3=bomber.global_position+Vector3.UP*1.5
 var bomb=w.drop_bomb353(bomber,held);bomb.set_physics_process(false)
 var locked: Vector3=bomb.goal353
 w.hero.position.x+=2.
 bomb._physics_process(.55)
 check(bomb.goal353==locked and bomb.global_position.y>locked.y+.5 and bomb.hit_area.global_position.distance_to(bomb.global_position)<.01,"large bomb descends toward fixed release-time target with matching hit area")
 bomb.reset_physics_interpolation()
 await capture("fall")
 var damage_before: float=w.injury347
 bomb._physics_process(.61)
 check(bomb.resolved353 and w.injury347==damage_before,"walking out avoids the one-time landing hit")
 w.hero.global_position=locked-Vector3.UP*.58
 bomb._physics_process(.15)
 check(w.injury347==damage_before,"unravelling visual does not deal delayed contact damage")
 w.remove_silk171(bomb)
 bomb=w.drop_bomb353(bomber,held);bomb.set_physics_process(false)
 w.hero.dodge_invulnerability=0.;w.hero.cancel_guard109()
 damage_before=w.injury347
 bomb._physics_process(1.16);bomb._physics_process(.1)
 check(w.injury347==damage_before+1. and bomb.hit_area.collision_layer==0,"standing in landing area takes exactly one hit")
 w.remove_silk171(bomb)
 bomb=w.drop_bomb353(bomber,held);bomb.set_physics_process(false)
 var impacts_before: int=w.impacts353
 bomb.receive_hit(1.,Vector3.UP);bomb._physics_process(.2)
 check(bomb.retired171 and not bomb.resolved353 and w.impacts353==impacts_before,"shooting falling bomb unravels it without impact")
 w.remove_silk171(bomb)
 bomb=w.drop_bomb353(bomber,held);bomb.set_physics_process(false)
 w.hero.dodge_invulnerability=.2;w.hero.dash_eligible=false
 damage_before=w.injury347;bomb._physics_process(1.16)
 check(w.injury347==damage_before,"invulnerable dodge avoids landing damage")
 w.hero.dodge_invulnerability=0.;w.remove_silk171(bomb)
 bomber.phase353="swing";bomber.phase_age353=0.;bomber.volley353=0;bomber.thrown353=0
 var got_rest:=false
 for i in 240:
  bomber._physics_process(.05)
  if bomber.phase353=="rest":got_rest=true;break
 check(bomber.thrown353==2 and got_rest,"two real throws lead to low resting window")
 bomber.reset_physics_interpolation()
 await capture("rest")
 bomber.receive_hit(999.,Vector3.BACK)
 check(bomber.dead and bomber.travel351=="exit" and not bomber.held353.visible,"defeated bomber stops firing and escapes on silk")
 # Chase a moved player by casting to new fixed anchors without teleporting the body.
 bomber=w.spawn347("bomber");bomber.set_physics_process(false)
 bomber._physics_process(1.81);bomber._physics_process(.02)
 var old_anchor: Vector3=bomber.anchor353
 var old_at: Vector3=bomber.global_position
 var goal: Vector2=w.centre301+Vector2(3.,2.)
 var safe: Vector2=w.navigation.origin+Vector2(w.navigation.nearest(goal))*w.navigation.CELL
 w.hero.global_position=Vector3(safe.x,w.floor_height(safe),safe.y)
 var first_distance: float=Vector2(old_at.x-safe.x,old_at.z-safe.y).length()
 var max_step:=0.
 var min_distance:=first_distance
 var saw_cast:=false
 for i in 200:
  var before: Vector3=bomber.global_position
  bomber._physics_process(.05)
  max_step=maxf(max_step,before.distance_to(bomber.global_position))
  min_distance=minf(min_distance,Vector2(bomber.position.x-safe.x,bomber.position.z-safe.y).length())
  if bomber.casting354>=0.:saw_cast=true
 check(bomber.transfers354>=1 and bomber.anchor353.distance_to(old_anchor)>1. and saw_cast,"mobile bomber casts and changes fixed silk anchors")
 check(max_step<.65 and min_distance<first_distance-.5,"pursuit gains ground through continuous swings rather than teleporting")
 var pause_position: Vector3=bomber.global_position
 w.combat_paused=true;bomber._physics_process(.5);w.combat_paused=false
 check(bomber.global_position==pause_position,"grapple chase freezes while paused")
 bomber.reset_physics_interpolation();await capture("chase")
 w.restart301();w.jobs347.clear()
 var spider=w.spawn347("normal")
 var pig=w.spawn347("pig")
 spider.set_physics_process(false)
 check(spider.travel351=="entry" and spider.hit_area.collision_layer==0 and spider.global_position.y>spider.destination351.y+8.,"spider starts high on silk without combat collision")
 spider._physics_process(.9)
 check(spider.global_position.y>spider.destination351.y and spider.silk351.visible,"continuous silk descent")
 await capture("entry")
 spider._physics_process(.91)
 check(spider.travel351=="" and spider.active_ai and spider.hit_area.collision_layer==8 and not spider.silk351.visible,"landing enables combat and releases silk")
 check(spider.max_hp110==10. and absf(spider.visual.rotation.x)<.001,"upright ten HP spider")
 check(pig.max_hp110==12. and pig.visual==pig.model350.visual,"pig is targetable actor with existing painted prop")
 # Force a real single actor attack sequence; it must rewind and reacquire before its second ball.
 var player:=Vector2(w.hero.position.x,w.hero.position.z)
 spider.prepare170(player)
 var first_direction: Vector2=spider.attack_direction
 var switched:=false
 for i in 55:
  w.age347+=.05
  spider._physics_process(.05)
  if spider.throws171==1 and not switched:
   w.hero.position.x+=1.5;switched=true
 check(spider.throws171==2 and not spider.second352,"readable double throw emits two balls")
 check(spider.attack_direction.distance_to(first_direction)>.05,"second throw reacquires player during its own windup")
 check(w.silk171.size()>=2 and w.silk171[-1].get_script().resource_path.ends_with("silk_ball352.gd"),"double throw uses faster dodgeable shootable silk")
 var web_before: int=w.weave_attempts352
 for i in 8:
  spider.prepare170(Vector2(w.hero.position.x,w.hero.position.z))
 check(w.weave_attempts352-web_before==2,"webs are one in four actions rather than every other action")
 w.clear_pads350();w.clear_silk171()
 var second=w.spawn347("normal");second.set_physics_process(false);second.travel351="";second.entry350=0.;second.play119()
 var third=w.spawn347("normal");third.set_physics_process(false);third.travel351="";third.entry350=0.;third.play119()
 spider.enter170("winding");second.enter170("winding");w.next_throw352=0.
 check(not w.reserve_spider170(third),"third attack waits while two spiders wind up")
 second.enter170("sit")
 check(w.reserve_spider170(third) and not w.reserve_spider170(second),"two attack slots retain shared start spacing")
 for extra in [second,third]:
  w.enemies.erase(extra);w.actors347.erase(extra);extra.queue_free()
 spider.enter170("watch")
 var close=w.spawn_closeup352();close.set_physics_process(false)
 var width: float=w.get_viewport().get_visible_rect().size.x
 var from: Vector2=w.camera.unproject_position(close.global_position)
 check(from.x>width and close.collision_layer==0 and close.hit_area.collision_layer==0 and not w.enemies.has(close),"closeup begins outside right edge without combat registration")
 close.clock351=1.6;close.closeup_pose352(.5)
 await capture("closeup")
 var middle: Vector2=w.camera.unproject_position(close.global_position)
 check(absf(middle.x-width*.5)<3. and absf(middle.y-w.get_viewport().get_visible_rect().size.y*.43)<3. and close.visual.scale.x>1.,"large closeup crosses upper frame on silk")
 close.closeup_pose352(1.)
 check(w.camera.unproject_position(close.global_position).x<0.,"closeup exits through opposite side")
 close._physics_process(2.)
 check(close.is_queued_for_deletion(),"foreground swing frees itself")
 close=w.spawn_closeup352();close.set_physics_process(false)
 check(w.camera.unproject_position(close.global_position).x<0.,"next closeup reverses direction")
 close.queue_free()
 var placed_distance: float=Vector2(pig.position.x-w.hero.position.x,pig.position.z-w.hero.position.z).length()
 check(placed_distance>=2.4 and placed_distance<=4.2,"pig is placed within a usable clear lane near player routes")
 pig._physics_process(1.12)
 var direction: Vector2=pig.model350.direction219
 pig._physics_process(.35)
 check(pig.cotton350.counts219().x>0,"pig emits cotton through native pooled stream")
 var stream=pig.cotton350
 stream._process(0.)
 check(stream.is_set_as_top_level() and stream.global_position.length()<.001,"cotton pool does not inherit pig offset")
 var record: Dictionary=stream.records[stream.active[0]]
 var uploaded: Vector3=stream.batches[record.type].global_transform*stream.batches[record.type].multimesh.get_instance_transform(0).origin
 check(uploaded.distance_to(record.pos)<.01 and uploaded.distance_to(pig.global_position)<3.,"rendered cotton is physically at the nozzle rather than double-offset")
 await capture("cotton")
 spider.receive_hit(99.,Vector3.BACK)
 check(spider.dead and spider.travel351=="exit" and spider.is_physics_processing(),"defeated spider starts silk escape rather than static rest")
 var departure: Vector3=spider.departure351
 spider._physics_process(.8)
 check(spider.global_position.y>departure.y+1. and spider.hit_area.collision_layer==0,"defeated spider rises without target collision")
 await capture("escape")
 spider._physics_process(.8)
 check(spider.is_queued_for_deletion(),"defeated spider is removed after escape")
 spider=w.spawn347("normal");spider.travel351="";spider.entry350=0.;spider.play119()
 w.tick_atmosphere351(8.)
 check(w.atmosphere351.size()==1 and not w.enemies.has(w.atmosphere351[0]) and w.atmosphere351[0].collision_layer==0,"background swing has no target collision or encounter quota")
 var ambient=w.atmosphere351[0]
 ambient._physics_process(2.5)
 await capture("background")
 var before_damage: float=w.injury347
 w.hero.dodge_invulnerability=0.;w.hero.cancel_guard109()
 stream.clear219()
 stream.emit219(w.hero.global_position+Vector3.UP*.5,Vector2.RIGHT,0)
 stream.advance219(.001)
 check(w.injury347==before_damage+1.,"visible cotton contact applies exactly one ordinary hit")
 w.hero.position.x+=1.
 pig._physics_process(.4)
 check(pig.model350.direction219==direction,"pig lane remains fixed while player moves")
 var model=pig.model350
 model.advance219(1.6)
 var old_cycles: int=model.cycles354
 w.hero.position.x-=3.
 model.advance219(1.05)
 check(model.cycles354==old_cycles+1 and model.direction219.distance_to(direction)>.05,"next warning reselects a new lane rather than firing the old placement direction forever")
 check(model.warning.visible and model.warning.mesh.get_surface_count()>0,"fan sweep has visible committed warning geometry")
 model.advance219(1.05);pig.cotton350.clear219();model.advance219(.28)
 var record_ok:=false
 for slot in pig.cotton350.active:
  var tuft: Dictionary=pig.cotton350.records[slot]
  if tuft.danger and tuft.age<.05:
   record_ok=tuft.vel.length()>4. and tuft.life==2.2 and tuft.has("clearance354")
 check(record_ok,"new cotton has six-metre effective reach and terrain clearance")
 w.release_silk171(spider,Vector2.RIGHT)
 check(not w.silk171.is_empty() and w.silk171[-1].touch110==1.,"spider silk enabled with ordinary damage")
 pig.receive_hit(99.,Vector3.BACK)
 check(pig.dead and not pig.model350.running219 and w.hold347==2.,"destroying pig stops emission and pauses reinforcement")
 w.restart301()
 var types: Array=[]
 var max_normal:=0
 for tick in 1300:
  if not w.active114:break
  w.director347(.1)
  max_normal=maxi(max_normal,w.live347().size())
  check(w.live347().size()<=4 and w.live347(true).size()<=1,"population limits "+str(tick))
  if tick%16==0:
   for actor in w.live347():kill(actor)
  if tick%50==0:
   for actor in w.live347(true):kill(actor)
  if tick%25==0:await process_frame
 check(w.kills347==27 and w.elite_kills347==4 and not w.active114,"full sister ordinary encounter clears without rewards")
 for event in w.events347:
  if event.kind=="entry" and event.data.type=="pig":types.append(event.data.type)
 check(types.size()==2,"two fixed pig encounters")
 w.restart301();w.jobs347.clear();w.spawn347("normal");w.spawn347("normal");w.spawn347("bomber")
 w.set_process(true);w.set_physics_process(true)
 for tick in 360:await physics_frame
 w.set_process(false);w.set_physics_process(false)
 await capture("live")
 check(w.active114 and w.context202 and not w.theatre314.visible,"six-second real AI run stays in ordinary forest encounter")
 # An actual placed pig must threaten a stationary player at normal encounter distance.
 w.restart301();w.jobs347.clear()
 for i in 2:await physics_frame
 var threat=w.spawn347("pig");threat.set_physics_process(false)
 w.hero.dodge_invulnerability=0.;w.hero.cancel_guard109()
 var initial_damage: float=w.injury347
 for i in 140:
  threat._physics_process(.05)
  if i==43:await capture("sweep")
  if i%15==0:await physics_frame
 check(w.injury347>initial_damage,"real placed pig spray reaches and hits a stationary player at encounter distance")
 threat.receive_hit(99.,Vector3.BACK);w.finish251(true)
 threat._physics_process(2.5)
 check(threat.is_queued_for_deletion(),"defeated pig finishes disappearing even after encounter completion")
 w.restart301();w.jobs347.clear()
 var report: Dictionary=w.report_stats226()
 check(report.runtime_preview==354 and report.plush350.spiders==23 and not report.has("paper_theatre337"),"ordinary sister report")
 w.finish251(false)
 check(w.silk171.is_empty() and w.pads172.is_empty() and w.atmosphere351.is_empty(),"ending clears silk and web hazards")
 w.restart301()
 check(w.kills347==0 and w.batch347==0,"retry resets encounter")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"user config unchanged "+file)
 FileAccess.open("res://docs/pursuit354-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures,"max_spiders":max_normal},"\t"))
 print("PURSUIT354_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
