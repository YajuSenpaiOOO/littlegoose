extends "res://scripts/world/validate_plush220.gd"
class TestWorld:
 extends "res://scripts/world/woodland_world232.gd"
 func _init() -> void:
  super._init();memory_save116="user://rain232_validation_preview.cfg"
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
var perf_rows232: Array=[]
func sample_perf232(tag: String,seconds: float) -> void:
 var start=Time.get_ticks_usec();var previous=start;var gaps: Array[float]=[]
 while Time.get_ticks_usec()-start<seconds*1000000.:
  await process_frame
  var now=Time.get_ticks_usec();gaps.append(float(now-previous)/1000.);previous=now
 gaps.sort()
 var row={"tag":tag,"fps":gaps.size()*1000000./(Time.get_ticks_usec()-start),"median_ms":gaps[gaps.size()/2],"p95_ms":gaps[int(gaps.size()*.95)],"draws":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"sword_nodes":w.swords153.get_child_count(),"landed":w.swords153.resting153.size(),"flying":w.swords153.flying153.size(),"shadows":w.actor_shadows.size()}
 perf_rows232.append(row)
 FileAccess.open("res://docs/rain232-final-perf.json",FileAccess.WRITE).store_string(JSON.stringify({"samples":perf_rows232,"conditions":"latest distribution+jitter, actual live cat/pig/spider, fixed invulnerable hero, 100000 cat HP, warmed by functional checks"},"\t"))
 print("RAIN232_FINAL_PERF ",row)
func capture232(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/rain232-"+tag+".png")
func run() -> void:
 var configs={}
 for path in ["user://boss_balance231.cfg","user://boss_balance232.cfg"]:configs[path]=FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
 w=TestWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 w.levels226={"paper_plane":1,"balloon_sword":1,"three_player":1,"eye_exercise":1};w.start_battle225(false)
 w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 var m=w.swords153;var air=w.paper_memories146
 check(m.get_child_count()==4 and m.bodies232.multimesh.instance_count==768,"four bounded batch submissions replace per-sword nodes")
 check(w.cat220.get_script().resource_path.ends_with("fat_cat_boss231.gd"),"approved cat art retained")
 check(w.buffs.rate()==1.25 and w.player_hp==14.,"229 eye and player health retained")
 check("25%" in w.memory_kit116.effect118("paper_plane",1),"console explains trial aircraft payload benefit")
 var target: Vector3=w.cat220.hit_area.global_position
 var packet: Dictionary=w.snapshot_packet146(target,false,0.)
 var budget=0.
 for spec in packet.specs:budget+=float(spec.damage)
 air.launch146(packet,w.projectile_origin(),target)
 var carried=0.
 for f in air.planes149:
  for spec in f.packet.specs:carried+=float(spec.damage)*float(f.gain)
  check(f.spacing==.09 and air.drop_time150(f,0)<.4,"source starts early and spreads six drops across .45 seconds")
 check(is_equal_approx(carried,budget*1.25),"total payload bonus exactly twenty-five percent, no goose duplication")
 check(air.planes149.size()==3 and air.delivery_count150()==6 and air.marker_radius150()==2.4,"three aircraft preserve six drops each and original area")
 for build in [{"paper_plane":1,"slingshot":1,"eye_exercise":1},{"paper_plane":1,"flashlight":1,"eye_exercise":1},{"paper_plane":1,"snack":1,"eye_exercise":1}]:
  w._clear_combat_shots();w.levels226=build;w.apply_levels226()
  var charged: bool=build.has("slingshot")
  var payload: Dictionary=w.snapshot_packet146(target,charged,1. if charged else 0.)
  air.launch146(payload,w.projectile_origin(),target)
  var f: Dictionary=air.planes149[0]
  check(is_equal_approx(float(f.gain),1.25) and f.packet.specs==payload.specs,"rain retains complete payload: "+str(build))
  # Legacy charged tracing keys off charged itself; piercing110 is the beam flag.
  if charged:check(payload.specs.all(func(s):return s.charged),"charged rain retains native charged tracing flag")
  if build.has("flashlight"):check(payload.stream and payload.pulse_interval>0.,"beam rain retains burst cadence")
  if build.has("snack"):check(payload.specs.all(func(s):return s.snack==1),"splitting rain retains split level")
 w._clear_combat_shots();w.levels226={"balloon_sword":1,"three_player":1,"eye_exercise":1};w.apply_levels226()
 # Place the visual fixture on the camera side, rather than inside the card.
 var at: Vector3=w.cat220.visual.global_position+w.camera.global_basis.y*.9+w.camera.global_basis.z*.22
 for i in 7:m.attach153(w.cat220,at,Vector3.LEFT,1.,{})
 m.step153(0.)
 check(m.layers153[w.cat220.get_instance_id()].size()==5 and is_equal_approx(w.cat220.get_meta("locomotion_scale153"),.6),"native five-layer forty-percent slow cap preserved")
 check(m.resting153.size()==5 and m.get_child_count()==4,"excess layers expire without allocating nodes")
 w.combat_paused=true;m.contact158.reset158()
 await capture232("direct-gel-day")
 var rendered=root.get_texture().get_image()
 var screen: Vector2=w.camera.unproject_position(at)
 var box=Rect2i(Vector2i(screen)-Vector2i(160,140),Vector2i(320,280)).intersection(Rect2i(Vector2i.ZERO,rendered.get_size()))
 var cyan=0
 for y in range(box.position.y,box.end.y):
  for x in range(box.position.x,box.end.x):
   var color=rendered.get_pixel(x,y)
   if color.b>.6 and color.g>.6 and color.r<.55:cyan+=1
 metrics["attached_blade_cyan_pixels"]=cyan
 check(cyan>15,"GPU renders cyan attached blade without impact accents")
 check(m.bodies232.multimesh.visible_instance_count==5 and m.pads232.multimesh.visible_instance_count==5,"attached swords retain individual bodies and gel pads")
 check(m.body_shadows232.visible and m.pad_shadows232.visible and m.body_shadows232.multimesh.visible_instance_count==5,"blade and gel silhouette shadows retained")
 var before: Vector3=m.anchor154(m.resting153[0]);w.cat220.position.x+=.2
 check(m.anchor154(m.resting153[0]).distance_to(before)>.1,"attachment follows moving actor")
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();await capture232("direct-gel-night")
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 w.combat_paused=false;m.step153(3.01)
 check(m.resting153.is_empty() and is_equal_approx(w.cat220.get_meta("locomotion_scale153"),1.),"lifetime expiry restores full movement and clears layers")
 var ground=Vector3(w.cat220.position.x+1.,w.cat220.position.y+.05,w.cat220.position.z+1.)
 for i in 200:m.attach153(null,ground+Vector3(i%10,0.,i/10)*.025,Vector3.DOWN,1.,{})
 check(m.resting153.size()==160 and m.get_child_count()==4,"ground residue capped without node growth")
 m.reset153();await process_frame;await process_frame
 check(m.layers153.is_empty() and m.resting153.is_empty() and m.bodies232.multimesh.visible_instance_count==0 and m.pads232.multimesh.visible_instance_count==0,"reset removes bodies pads shadows and slow layers")
 w.levels226={"paper_plane":1,"balloon_sword":1,"three_player":1,"eye_exercise":1};w.apply_levels226()
 w._teleport15(w.arena220+Vector2(-2.8,0.));w.target114=null;w.aim_tick114=-1;w.rebuild_cells110();w.auto114=true
 var hp=w.cat220.hp;await create_timer(3.).timeout
 check(w.cat220.hp<hp,"actual native sword rain damages fat cat")
 w.combat_paused=true;await capture232("rain-day")
 var count=m.bodies232.multimesh.visible_instance_count
 check(count>0 and count<=768,"native flying and landed swords reach bounded visible batches")
 check(m.get_child_count()==4 and m.blades226.is_empty() and m.pads226.is_empty(),"continuous rain creates no hidden per-sword pool")
 var source=RenderingServer.shader_get_code(m.bodies232.material_override.shader.get_rid())
 check("INSTANCE_CUSTOM" in source,"visible blades use instanced deformation data")
 var age: float=air.planes149[0].age if not air.planes149.is_empty() else -1.
 await create_timer(.2).timeout
 check(age<0. or air.planes149[0].age==age,"pause freezes aircraft schedule")
 w.combat_paused=false;w.auto114=false;w._clear_combat_shots();await process_frame;await process_frame
 check(m.bodies232.multimesh.visible_instance_count==0 and m.body_shadows232.multimesh.visible_instance_count==0,"weapon clear leaves no batched ghost swords")
 w.start_battle225(false);w.auto114=false
 check(w.rig220.visible and w.player_hp==14. and w.paper_memories146.planes149.is_empty(),"restart restores clean visible encounter")
 if "--perf-live232" in OS.get_cmdline_user_args():
  w.start_battle225(false);w.hero.set_physics_process(false);w.invulnerability=10000.;w.cat220.hp=100000.;w.cat220.max_hp110=100000.;w.pigs_enabled220=true;w.repairs220=1;w.auto114=true
  await sample_perf232("live_early",8.)
  await create_timer(17.).timeout;await sample_perf232("live_mid",8.)
  await create_timer(19.).timeout;await sample_perf232("live_late",8.)
 w.stop225()
 for path in configs:check(configs[path]==(FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null),"user config unchanged: "+path)
 var failed=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/rain232-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failed.size(),"metrics":metrics},"\t"))
 print("RAIN232_DONE checks=",checks.size()," failures=",failed.size());quit(0 if failed.is_empty() else 1)
