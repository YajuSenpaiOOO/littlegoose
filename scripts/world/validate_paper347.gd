extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world347.gd"
 var injury347:=0.
 func hurt_player(damage: float,_from: Vector2) -> void:injury347+=damage
 func load_test226() -> void:pass
 func ordinary_record_folder347() -> String:return "res://.paper347-record-validation"
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
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper347-"+tag+".png")
func kill(actor: Node) -> void:
 if actor.get_meta("elite347",false):actor.enter301("rest")
 else:actor.entry347=0.;actor.play119()
 actor.receive_hit(9999.,Vector3.BACK)
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg"):config[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=Trial.new();root.add_child(w);current_scene=w
 var limit:=Time.get_ticks_msec()+180000
 while not w.ready347 and Time.get_ticks_msec()<limit:await process_frame
 if not w.ready347:quit(1);return
 w.set_process(false);w.set_physics_process(false);w.hero.set_physics_process(false)
 check(w.mode264=="paper347" and not w.theatre314.visible and not w.core_phase326,"independent ordinary mode hides castle")
 check(w.theatre314.castle_target327.collision_layer==0 and w.theatre314.cannon_areas326[0].collision_layer==0,"hidden castle and guns are not targets")
 w.restart301()
 w.director347(.01)
 check(w.live347().size()==1 and w.live347(true).is_empty(),"first squad starts with ordinary paper")
 var normal=w.live347()[0]
 check(normal.max_hp110==3. and absf(normal.visual.rotation.x)<.001 and normal.hit_area.collision_layer==0,"ordinary paper health upright display and safe entry")
 normal.paper_contact131(Vector2.ZERO)
 check(w.injury347==1.,"ordinary gust uses one damage not legacy ten")
 for i in 25:w.director347(.1)
 check(w.live347().size()==4 and w.batch347==0,"four ordinary maximum and no timer-only escalation")
 kill(w.live347()[0]);kill(w.live347()[0])
 for i in 40:w.director347(.1)
 check(w.batch347==1 and w.live347().size()<=4,"half-cleared squad permits continuous next batch")
 # Controlled clearing drives every batch; caps are checked every scheduler step.
 var max_normal:=0
 var max_elite:=0
 var snapshots: Array[Dictionary]=[]
 var shown:=false
 for tick in 1000:
  if not w.active114:break
  w.director347(.1)
  max_normal=maxi(max_normal,w.live347().size());max_elite=maxi(max_elite,w.live347(true).size())
  check(w.live347().size()<=(2 if w.batch347==4 else 4) and w.live347(true).size()<=(2 if w.batch347==4 else 1),"population cap tick "+str(tick))
  if not shown and not w.live347(true).is_empty():
   shown=true
   for actor in w.live347()+w.live347(true):actor.health_time=2.
   await capture("mixed")
  # Defeat normal papers in bursts, not a one-for-one spawn loop.
  if tick%12==0:
   for actor in w.live347():kill(actor)
  if tick%45==0:
   for actor in w.live347(true):kill(actor)
  if tick%20==0:await process_frame
 check(w.batch347==4 and not w.active114 and w.kills347==20 and w.elite_kills347==5,"all five batches finish exactly twenty enemies without rewards")
 var types: Array=[]
 var final_times: Array[float]=[]
 for event in w.events347:
  if event.kind=="entry" and event.data.type!="normal":
   types.append(event.data.type)
   if event.batch==4:final_times.append(event.time)
 check(types==["dinosaur","knight","monster","dinosaur","knight"],"elite order and final pair")
 check(final_times.size()==2 and final_times[1]-final_times[0]>=2.4,"final elite entries are staggered")
 # Explicit final pair overlap; the cap is not tested only via single elites.
 w.restart301();w.jobs347.clear();w.batch347=4;w.batch_age347=0.
 w.jobs347.assign([{"type":"dinosaur","due":0.},{"type":"knight","due":2.5}])
 w.director347(.01)
 w.director347(2.4)
 check(w.live347(true).size()==1,"second final elite waits for stagger")
 w.director347(.11)
 check(w.live347(true).size()==2,"final pair can coexist")
 max_elite=maxi(max_elite,w.live347(true).size())
 w.restart301();w.jobs347.clear();w.batch347=4;w.batch_age347=10.
 w.jobs347.assign([{"type":"dinosaur","due":0.},{"type":"knight","due":2.5}])
 w.director347(.01);w.director347(.01)
 check(w.live347(true).size()==1,"overdue elite queue still respects actual entry stagger")
 w.director347(2.5)
 check(w.live347(true).size()==2,"delayed second elite arrives after actual gap")
 w.restart301();w.jobs347.clear();w.batch347=1
 var elite=w.spawn347("dinosaur")
 kill(elite)
 w.jobs347.append({"type":"normal","due":0.})
 w.director347(1.9)
 check(w.jobs347.size()==1,"elite defeat pauses reinforcement for two seconds")
 w.director347(.11)
 check(w.jobs347.is_empty(),"reinforcements resume after breather")
 w.restart301();w.jobs347.clear();w.batch347=3
 var monster=w.spawn347("monster");monster.enter301("rest");w.meteor_left347=0.
 w.director347(.01)
 check(w.flights327.size()==1 and w.flights327[0].sprite.get_parent()==w,"monster sends one visible diagonal meteor outside hidden stage")
 w.tick_flights327(1.9)
 check(not w.blasts327.is_empty() and w.blasts327[0].resolved333 and is_equal_approx(w.blasts327[0].radius,1.35),"ordinary meteor impact has reduced radius and one-time damage")
 var hp: float=w.injury347
 w.tick_blasts327(.1)
 check(w.injury347==hp,"remaining explosion art does not damage twice")
 # Run actual C record entry with a no-disk-config commit stub.
 w.restart301();w.console226.draft={"exercise":1};w.console226.determination257.value=2
 w.console226.record226()
 check(w.recording226.active and w.recording226.folder=="res://.paper347-record-validation","actual C recording enters ordinary folder")
 w.director347(.1)
 w.finish251(true)
 var saved_path: String=w.recording226.folder+"/"+w.recording226.id+".json"
 var saved: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(saved_path))
 check(saved.has("ordinary347") and not saved.has("paper_theatre337"),"saved file uses ordinary telemetry")
 w.recording226.final_report.clear()
 var report: Dictionary=w.report_stats226()
 check(report.runtime_preview==347 and report.has("ordinary347") and not report.has("paper_theatre337"),"ordinary report is separate from castle telemetry")
 w.finish251(false);w.restart301()
 w.set_process(true);w.set_physics_process(true)
 # Brief real physics/AI run, unlike the accelerated roster assertions above.
 for tick in 240:await physics_frame
 w.set_process(false);w.set_physics_process(false)
 w._process(.016)
 check(w.mode264=="paper347" and not w.theatre314.visible and w.core_phase326==false,"real physics stays in ordinary encounter")
 await capture("live")
 w.restart301()
 check(w.batch347==0 and w.kills347==0 and w.flights327.is_empty(),"retry clears ordinary actors hazards and counters")
 check(w.balance_profile226().COSTS.forest_fireboy==2 and w.balance_profile226().COSTS.three_player==4,"current goose costs retained")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"user config unchanged "+file)
 var record_folder:=ProjectSettings.globalize_path("res://.paper347-record-validation")
 for file in DirAccess.get_files_at(record_folder):DirAccess.remove_absolute(record_folder+"/"+file)
 DirAccess.remove_absolute(record_folder)
 FileAccess.open("res://docs/paper347-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures,"max_normal":max_normal,"max_elite":max_elite,"elite_entries":types},"\t"))
 print("PAPER347_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
