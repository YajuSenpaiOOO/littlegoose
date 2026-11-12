extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world349.gd"
 var injury347:=0.
 func hurt_player(damage: float,_from: Vector2) -> void:injury347+=damage
 func load_test226() -> void:pass
 func ordinary_record_folder347() -> String:return "res://.paper349-record-validation"
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
 root.get_texture().get_image().save_png("res://docs/paper349-"+tag+".png")
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
 w.restart301()
 var arrival=w.spawn347("normal")
 arrival.set_physics_process(false)
 var start: Vector3=arrival.global_position
 var screen: Vector2=w.camera.unproject_position(start)
 check(screen.y< -200. and arrival.hit_area.collision_layer==0 and arrival.collision_layer==0,"paper begins wholly beyond upper camera edge and cannot attack/block")
 arrival._physics_process(.85)
 check(arrival.global_position.distance_to(start)>.5 and arrival.global_position.distance_to(arrival.destination349)>.2,"paper travels continuously through an entry arc")
 await capture("arrival")
 w.combat_paused=true
 var frozen: Vector3=arrival.global_position
 arrival._physics_process(.3)
 check(arrival.global_position==frozen,"pause freezes arrival")
 w.combat_paused=false
 for i in 20:arrival._physics_process(.1)
 check(arrival.entry347==0. and arrival.active_ai and arrival.hit_area.collision_layer==8 and arrival.collision_layer!=0,"arrival restores normal targeting and physical collision")
 check(arrival.global_position.distance_to(arrival.destination349)<2. and arrival.gust_wait130<1.1,"first attack becomes ready shortly after arrival")
 arrival.paper_state129="gust";arrival.paper_clock129=arrival.gust_duration131-.01
 arrival._physics_process(.02)
 check(arrival.paper_state129=="coast" and arrival.gust_wait130<=2.05,"repeat dive recovers in 1.6 to 2.04 seconds")
 w.restart301()
 check(w.total347()==50 and w.total_enemies==50,"forty-five papers and five elites")
 for i in 120:w.director347(.1)
 check(w.live347().size()==10 and w.batch347==0 and w.jobs347.is_empty(),"unopposed normal wave grows to ten, never timer-escalates")
 check(w.live347().all(func(p):return p.hp==3.),"crowd papers remain low health")
 var entries: Array=w.events347.filter(func(e):return e.kind=="entry")
 check(entries[3].time-entries[2].time>1.,"small clusters have visible spacing")
 for actor in w.live347():actor.health_time=2.
 await capture("crowd")
 # Force ten attack-ready papers close enough to exercise the actual AI gate.
 var normals: Array=w.live347()
 for i in normals.size():
  var actor=normals[i]
  var at: Vector3=w.hero.position+Vector3(cos(float(i)*TAU/10.)*2.8,0.,sin(float(i)*TAU/10.)*2.8)
  actor.position=at;actor.position.y=w.floor_height(Vector2(at.x,at.z))+.04
  actor.entry347=0.;actor.play119();actor.gust_wait130=0.;actor._physics_process(1./60.)
 var warnings: Array=w.live347().filter(func(p):return p.paper_state129 in ["warning","gust"])
 check(warnings.size()==3,"actual paper AI admits only three concurrent dives")
 w.spawn347("dinosaur")
 w.tickets348.clear()
 for actor in w.live347():actor.paper_state129="drift";actor.gust_wait130=0.
 for actor in w.live347():actor._physics_process(1./60.)
 warnings=w.live347().filter(func(p):return p.paper_state129 in ["warning","gust"])
 check(warnings.size()==2,"elite presence limits new dive admissions to two")
 # Death must release the attack budget instead of leaving a permanent ticket.
 for actor in warnings:kill(actor)
 var follower=w.live347().filter(func(p):return p.paper_state129=="drift")[0]
 follower.gust_wait130=0.;follower._physics_process(1./60.)
 check(follower.paper_state129=="warning","defeated attacker releases dive reservation")
 check(w.normal_cap347(0)==10 and w.normal_cap347(1)==6,"normal caps adapt to elite presence")
 w.restart301();w.jobs347.clear();w.batch347=4
 check(w.normal_cap347(2)==4 and w.elite_gate347()==4,"double elite finale retains four normal cap")
 w.restart301()
 var seen: Array=[]
 var max_normal:=0
 var max_elite:=0
 for tick in 2000:
  if not w.active114:break
  w.director347(.1)
  max_normal=maxi(max_normal,w.live347().size());max_elite=maxi(max_elite,w.live347(true).size())
  check(w.live347().size()<=10 and w.live347(true).size()<=(2 if w.batch347==4 else 1),"population cap "+str(tick))
  if tick%18==0:
   for actor in w.live347():kill(actor)
  if tick%70==0:
   for actor in w.live347(true):kill(actor)
  if tick%25==0:await process_frame
 check(not w.active114 and w.kills347==50 and w.elite_kills347==5,"all fifty enemies clear across five stages")
 for event in w.events347:
  if event.kind=="entry" and event.data.type!="normal":seen.append(event.data.type)
 check(seen==["dinosaur","knight","monster","dinosaur","knight"],"elite order unchanged")
 w.restart301();w.set_process(true);w.set_physics_process(true)
 var peak_dives:=0
 var peak_population:=0
 for tick in 540:
  await physics_frame
  peak_dives=maxi(peak_dives,w.live347().filter(func(p):return p.paper_state129 in ["warning","gust"]).size())
  peak_population=maxi(peak_population,w.live347().size())
 w.set_process(false);w.set_physics_process(false)
 check(peak_population>=8 and peak_population<=10 and peak_dives<=3,"nine-second real AI run maintains crowd and dive limits")
 await capture("live")
 w.restart301();w.console226.draft={"exercise":1};w.console226.determination257.value=2;w.console226.record226()
 check(w.recording226.active,"C recording works in crowd encounter")
 w.finish251(true)
 var path: String=w.recording226.folder+"/"+w.recording226.id+".json"
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
 check(data.runtime_preview==349 and data.crowd348.normal_total==45 and data.has("ordinary347"),"record includes crowd configuration and ordinary events")
 w.recording226.final_report.clear();w.restart301()
 check(w.tickets348.is_empty() and w.cluster_points348.is_empty(),"restart clears attack tickets and cluster anchors")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"user config unchanged "+file)
 var records:=ProjectSettings.globalize_path("res://.paper349-record-validation")
 for file in DirAccess.get_files_at(records):DirAccess.remove_absolute(records+"/"+file)
 DirAccess.remove_absolute(records)
 FileAccess.open("res://docs/paper349-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures,"normal_total":45,"elite_total":5,"peak_real_population":peak_population,"peak_real_dives":peak_dives,"elite_entries":seen},"\t"))
 print("PAPER349_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
