extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world352.gd"
 var injury347:=0.
 var weave_attempts352:=0
 func place_pad172(actor: CharacterBody3D) -> CharacterBody3D:
  weave_attempts352+=1
  return super.place_pad172(actor)
 func hurt_player(damage: float,_from: Vector2) -> void:injury347+=damage
 func load_test226() -> void:pass
 func ordinary_record_folder347() -> String:return "res://.pressure352-record-validation"
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
 root.get_texture().get_image().save_png("res://docs/pressure352-"+tag+".png")
func kill(actor: Node) -> void:
 if not actor.get_meta("elite347",false):actor.entry350=0.;actor.travel351="";actor.play119()
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
 check(w.total347()==26,"twenty-three spiders and three pigs")
 w.jobs347.clear()
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
 var direction: Vector2=pig.model350.direction219
 pig._physics_process(1.12);pig._physics_process(.35)
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
 check(w.kills347==26 and w.elite_kills347==3 and not w.active114,"full sister ordinary encounter clears without rewards")
 for event in w.events347:
  if event.kind=="entry" and event.data.type=="pig":types.append(event.data.type)
 check(types.size()==3,"three fixed pig encounters")
 w.restart301();w.jobs347.clear();w.spawn347("normal");w.spawn347("normal");w.spawn347("pig")
 w.set_process(true);w.set_physics_process(true)
 for tick in 360:await physics_frame
 w.set_process(false);w.set_physics_process(false)
 await capture("live")
 check(w.active114 and w.context202 and not w.theatre314.visible,"six-second real AI run stays in ordinary forest encounter")
 var report: Dictionary=w.report_stats226()
 check(report.runtime_preview==352 and report.plush350.spiders==23 and not report.has("paper_theatre337"),"ordinary sister report")
 w.finish251(false)
 check(w.silk171.is_empty() and w.pads172.is_empty() and w.atmosphere351.is_empty(),"ending clears silk and web hazards")
 w.restart301()
 check(w.kills347==0 and w.batch347==0,"retry resets encounter")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"user config unchanged "+file)
 FileAccess.open("res://docs/pressure352-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures,"max_spiders":max_normal},"\t"))
 print("PRESSURE352_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
