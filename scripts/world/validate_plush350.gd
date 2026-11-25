extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world350.gd"
 var injury347:=0.
 func hurt_player(damage: float,_from: Vector2) -> void:injury347+=damage
 func load_test226() -> void:pass
 func ordinary_record_folder347() -> String:return "res://.plush350-record-validation"
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
 root.get_texture().get_image().save_png("res://docs/plush350-"+tag+".png")
func kill(actor: Node) -> void:
 if not actor.get_meta("elite347",false):actor.entry350=0.;actor.play119()
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
 spider.entry350=0.;spider.play119()
 check(spider.max_hp110==4. and absf(spider.visual.rotation.x)<.001,"upright four HP spider")
 check(pig.max_hp110==12. and pig.visual==pig.model350.visual,"pig is targetable actor with existing painted prop")
 var direction: Vector2=pig.model350.direction219
 pig._physics_process(1.12);pig._physics_process(.35)
 check(pig.cotton350.counts219().x>0,"pig emits cotton through native pooled stream")
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
 check(report.runtime_preview==350 and report.plush350.spiders==23 and not report.has("paper_theatre337"),"ordinary sister report")
 w.finish251(false)
 check(w.silk171.is_empty() and w.pads172.is_empty(),"ending clears silk and web hazards")
 w.restart301()
 check(w.kills347==0 and w.batch347==0,"retry resets encounter")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"user config unchanged "+file)
 FileAccess.open("res://docs/plush350-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures,"max_spiders":max_normal},"\t"))
 print("PLUSH350_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
