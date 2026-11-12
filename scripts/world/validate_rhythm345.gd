extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world345.gd"
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
 func load_test226() -> void:pass
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
 root.get_texture().get_image().save_png("res://docs/hud342-"+tag+".png")
func phase(w: Node,index: int,source: int=0) -> void:
 w.interrupt327();w.clear_patterns327()
 w.cannon_hp326.assign([16.,16.]);w.phase331=index;w.phase_age344=0.;w.pattern_started327=false
 w.pattern_left327=w.DURATIONS344[index];w.volley_left327=.45;w.cannon_index326=source;w.breath344=0.
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg"):config[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=Trial.new();root.add_child(w);current_scene=w
 var limit:=Time.get_ticks_msec()+180000
 while not is_instance_valid(w.combat_hud342) and Time.get_ticks_msec()<limit:await process_frame
 if not is_instance_valid(w.combat_hud342):quit(1);return
 w.set_process(false);w.set_physics_process(false);w.hero.set_physics_process(false)
 w.theatre314.set_process(false);w.theatre314.cancel();w.theatre314.sample(4.06);w.theatre314.finished=true
 w.waiting_intro314=false;w.core_phase326=true;w.fastener_hp321=144.;w.active114=true;w.combat_paused=false;w.entry_clock314=-1.;w.cameo_left327=100000.
 phase(w,1)
 w.tick_pattern327(.45)
 check(not w.sweep331.is_empty() and w.flights327.size()==3,"sweep queues exactly three supporting mortars")
 check(w.sweep331.source==0 and w.flights327.all(func(f):return f.source==1),"primary and supporting guns have separate roles")
 check(w.flights327.all(func(f):return not f.sprite.visible),"mortar markers stay hidden until each launch")
 var sweep_aim: Vector2=w.sweep331.aim
 var first: Dictionary=w.flights327[0]
 w.hero.global_position.x+=.5
 w.tick_flights327(.91)
 check(first.sprite.visible and first.get("locked336",false),"first supporting shot locks at actual launch")
 var lock: Vector2=first.at
 w.hero.global_position.x+=1.
 w.tick_flights327(.2)
 check(first.at==lock and w.sweep331.aim==sweep_aim,"airborne mortar lock and fixed sweep aim remain stable")
 w.tick_flights327(.66)
 check(w.flights327[1].sprite.visible and w.flights327[1].at.distance_to(lock)>.5,"second mortar reads new player position")
 w.interrupt327(1)
 check(not w.sweep331.is_empty() and not w.flights327.any(func(f):return not f.sprite.visible),"suppress support removes pending mortars but leaves sweep")
 phase(w,1);w.tick_pattern327(.45);w.interrupt327(0)
 check(w.sweep331.is_empty() and w.flights327.is_empty(),"suppress lead also breaks pending mortar cooperation")
 phase(w,1);w.cannon_hp326[1]=0.;w.tick_pattern327(.45)
 check(not w.sweep331.is_empty() and w.flights327.is_empty(),"one gun does not inherit both roles")
 phase(w,2);w.tick_pattern327(.45)
 check(w.paper_queue334.size()==21 and w.jobs344.size()==1 and w.heavies330.is_empty(),"one gap ring then delayed heavy, no immediate stacking")
 w.tick_pattern327(1.29)
 check(w.heavies330.is_empty(),"full stagger before heavy charging")
 w.tick_pattern327(.02)
 check(w.heavies330.size()==1 and w.heavies330[0].source==1 and w.heavies330[0].state=="charge","other gun charges heavy after ring release")
 phase(w,2);w.tick_pattern327(.45);w.interrupt327(1);w.tick_pattern327(2.)
 check(w.jobs344.is_empty() and w.heavies330.is_empty(),"support suppression cancels delayed heavy")
 phase(w,2);w.tick_pattern327(.45);w.interrupt327(0)
 check(w.jobs344.is_empty() and w.paper_queue334.is_empty(),"lead suppression cancels ring and follow-up")
 phase(w,4);w.tick_pattern327(.45)
 check(w.flights327.size()==4 and is_equal_approx(w.flights327[0].age-w.flights327[1].age,1.45),"meteor row remains spaced 1.45 seconds")
 phase(w,1);w.pattern_started327=true;w.pattern_left327=0.;w.order344=1
 w.tick_pattern327(.2)
 check(w.phase331==1,"recovery does not instantly advance")
 w.tick_pattern327(.26)
 check(w.phase331==2,"clear field plus .45 seconds advances to ring duet")
 # The scheduler must distinguish a live landing from harmless visual tail.
 phase(w,1);w.pattern_started327=true;w.pattern_left327=0.;w.order344=1
 var blast: Dictionary={"resolved333":false}
 w.blasts327.append(blast)
 check(not w.phase_clear344(),"unresolved impact blocks transition")
 w.tick_pattern327(.5)
 check(w.phase331==1 and w.breath344==0.,"danger cannot be skipped by recovery timer")
 blast.resolved333=true
 check(w.phase_clear344(),"consumed explosion tail no longer blocks")
 w.tick_pattern327(.46)
 check(w.phase331==2 and w.blasts327.size()==1,"next windup can coexist with harmless tail")
 w.blasts327.clear()
 phase(w,1);w.pattern_started327=true;w.pattern_left327=0.
 w.jobs344.append({"source":1,"lead":0,"left":10.})
 check(not w.phase_clear344(),"pending paired work still blocks")
 w.jobs344.clear()
 w.add_flight327(Vector2(w.hero.position.x,w.hero.position.z),0.,1.65,0,false)
 check(not w.phase_clear344(),"airborne attack still blocks")
 w.clear_patterns327()
 # Full native effect/physics cycle, fixed hero and no survival measurement.
 phase(w,0);w.order344=0;w.events344.clear();w.cameo_left327=100000.
 var timeline: Array[Dictionary]=[]
 var prior: int=-1
 for tick in 3600:
  w.boss_step314(1./60.)
  if w.phase331!=prior:
   prior=w.phase331;timeline.append({"time":float(tick)/60.,"phase":prior})
  if tick%60==0:await process_frame
 check(timeline.size()>=5,"full sixty-second simulation cycles without deadlock")
 check(w.events344.any(func(e):return e.kind=="paired_mortar") and w.events344.any(func(e):return e.kind=="ring_follow_heavy"),"both duets execute in full simulation")
 check(w.fastener_hp321==144.,"castle durability unchanged")
 w.restart301()
 check(w.jobs344.is_empty() and w.events344.is_empty() and w.phase331==0,"restart resets rhythm and scheduled work")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"config unchanged "+file)
 FileAccess.open("res://docs/rhythm345-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures,"timeline":timeline},"\t"))
 print("RHYTHM345_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
