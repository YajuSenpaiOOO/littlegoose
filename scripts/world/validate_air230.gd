extends "res://scripts/world/benchmark_air230.gd"
var checks230: Array=[]
func check(ok: bool,message: String) -> void:
 super.check(ok,message);checks230.append({"name":message,"pass":ok});print("AIR230 ",ok," ",message)
func run() -> void:
 var configs := {}
 for n in [226,228,229,230]:
  var p="user://boss_balance%d.cfg"%n;configs[p]=FileAccess.get_file_as_bytes(p) if FileAccess.file_exists(p) else null
 w=BenchWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 w.levels226={"paper_plane":1,"balloon_sword":1,"three_player":1,"eye_exercise":1};w.start_battle225(false)
 w.auto114=false;w.invulnerability=10000.;w.pigs_enabled220=false;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 check(w.cat220.get_script().resource_path.ends_with("fat_cat_boss230.gd"),"new cat controller selected")
 # Import's transparent-border RGB repair can change invisible edge texels
 # across atlas cells; compare actual source pixels rather than imported mips.
 var old=Image.new();old.load_png_from_buffer(FileAccess.get_file_as_bytes("res://assets/fat_cat220/roll_sheet.png"))
 var revised=Image.new();revised.load_png_from_buffer(FileAccess.get_file_as_bytes("res://assets/fat_cat230/roll_sheet.png"))
 for i in 6:
  var rect: Array=w.cat220.roll_data220.frames[i].region;var region=Rect2i(rect[0],rect[1],rect[2],rect[3])
  var equal=old.get_region(region).get_data()==revised.get_region(region).get_data()
  check(equal if i!=3 else not equal,"only fourth roll/down frame replaced: "+str(i+1))
 var anchor: Array=w.cat220.roll_data220.frames[3].anchor
 check(Vector2(anchor[0],anchor[1])==Vector2(273.,418.),"down frame retains foot anchor")
 check(w.buffs.rate()==1.25 and w.flashlight_rate_gain110()==1.,"229 balance retained")
 w.cat220.receive_hit(100000.,Vector3.ZERO);await create_timer(1.5).timeout
 w.measuring=true;w.bench_phase="bat";w.phase_age220=0.
 check(w.bats220.all(func(b):return b.enabled220),"both low repair bats targetable")
 check(place_player(w.bats220[0].hit_area.global_position),"clear repair shooting fixture")
 w.rebuild_cells110();await settle()
 var centre: Vector3=w.bats220[0].hit_area.global_position
 var packet: Dictionary=w.snapshot_packet146(centre,false,0.)
 var spec: Dictionary=packet.specs[0]
 var air=packet.duplicate(true);air.air150=true;air.specs=[spec.duplicate(true)]
 air.specs[0].angle=.2
 var origin=centre+Vector3.UP*3.
 for native in [true,false]:
  w._clear_combat_shots();w.use_native113=native
  w.emit_packet146(air,origin,centre,.25)
  check(w.shots.size()==1,"one original spec emits one payload native="+str(native))
  var shot: Dictionary=w.shots[0];var velocity: Vector3=shot.velocity
  check(absf(velocity.x)+absf(velocity.z)<.00001 and velocity.y<0.,"parallel downward velocity native="+str(native))
  check(is_equal_approx(w.damage_for_shot(shot),float(spec.damage)*.25),"packet damage budget preserved native="+str(native))
  check(shot.sword153 and shot.goose_source168==spec.get("goose_source168",0),"sword/goose payload tags preserved native="+str(native))
  w._step_shots(.04)
  check(w.shots.size()==1 and shot.velocity.is_equal_approx(velocity) and w.buffs.level("eye_exercise")==1,"no midair bending and global eye restored native="+str(native))
 w.use_native113=true;w._clear_combat_shots()
 var manager=w.paper_memories146
 w.bats220[1].set_enabled220(false)
 var sample=centre+Vector3(2.3,0.,0.)
 var local_packet=packet.duplicate(true)
 for s in local_packet.specs:s.tracking=0
 var f={"packet":local_packet,"mark":Vector3(centre.x,w.floor_height(Vector2(centre.x,centre.z))+.05,centre.z),"used151":{}}
 check(manager.choose_local230(f,sample,centre.y+4.)==null,"no eye cannot pull a distant sample")
 for s in local_packet.specs:s.tracking=1
 check(manager.choose_local230(f,sample,centre.y+4.)==w.bats220[0],"eye improves only nearby pre-release correction")
 check(manager.choose_local230(f,centre+Vector3(2.4,0.,0.),centre.y+4.)==null,"far sector remains a real miss")
 check(manager.choose_local230(f,centre,centre.y-.2)==null,"cannot rain upward at a higher target")
 w.bats220[1].set_enabled220(true)
 manager.flight_rng146.seed=23001
 manager.launch146(packet,w.projectile_origin(),centre)
 var count=manager.planes149.size();var flight: Dictionary=manager.planes149[0]
 check(count==3 and flight.coverage151.size()==6,"three geese still carry six sector drops each")
 check(is_equal_approx(manager.marker_radius150(),2.4),"original area radius retained")
 var drops=manager.deliveries146
 for i in 6:manager.drop150(flight,i)
 check(manager.deliveries146-drops==6,"no extra delivery count")
 check(manager.history149.slice(-6).all(func(h):return Vector2(h.origin.x-h.aim.x,h.origin.z-h.aim.z).length()<.00001),"release points vertically above resolved landings")
 check(flight.release<1.5 and is_equal_approx(manager.FLIGHT_SPEED230,1.5),"aircraft arrives sooner without changing attack cooldown")
 w._clear_combat_shots();w.levels226={"paper_plane":1,"flashlight":1,"eye_exercise":1};w.apply_levels226()
 var beam: Dictionary=w.snapshot_packet146(centre,false,0.);beam.air150=true
 manager.send146(beam,origin,centre,.2)
 var fixed: Dictionary=manager.bursts146[-1]
 check(not fixed.has("flight150") and not fixed.has("target151"),"beam burst has fixed release rather than a moving plane/target")
 manager.step146(.04)
 check(fixed.origin==origin and fixed.target==centre and w.shots.all(func(s):return absf(s.velocity.x)+absf(s.velocity.z)<.00001),"all beam pulses stay in parallel rain lanes")
 w._clear_combat_shots();w.levels226={"eye_exercise":1};w.apply_levels226()
 for native in [true,false]:
  w._clear_combat_shots();w.use_native113=native
  var straight: Dictionary=w.data_shot110(centre+Vector3(3.,0.,0.),Vector3(-5.,0.,.8),1.)
  var before: Vector3=straight.velocity
  w._step_shots(.05)
  check(not straight.velocity.is_equal_approx(before) and w.buffs.level("eye_exercise")==1,"ordinary direct shots retain tracking native="+str(native))
 w.use_native113=true;w.levels226={"paper_plane":1,"balloon_sword":1,"three_player":1,"eye_exercise":1};w.apply_levels226()
 w._clear_combat_shots();w.auto114=true;w.phase_age220=0.;w.target114=null;w.aim_tick114=-1
 await create_timer(3.7).timeout;w.auto114=false
 check(w.stats226.bat_damage[0]+w.stats226.bat_damage[1]>0.,"actual native drops damage repair bats")
 w.combat_paused=true
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/air230-repair.png")
 var total=w.paper_memories146.deliveries146
 await create_timer(.15).timeout
 check(total==w.paper_memories146.deliveries146,"pause stops new drops")
 w.combat_paused=false;w.measuring=false;w.start_battle225(false);w.auto114=false
 check(w.paper_memories146.planes149.is_empty() and w.paper_memories146.bursts146.is_empty(),"restart clears aircraft and fixed beam releases")
 check(w.rig220.visible and w.player_hp==14.,"restart preserves sister and full determination")
 w.stop225()
 for p in configs:
  check(configs[p]==(FileAccess.get_file_as_bytes(p) if FileAccess.file_exists(p) else null),"user configuration untouched: "+p)
 FileAccess.open("res://docs/air230-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks230,"failed":failures.size()},"\t"))
 print("AIR230_DONE ",checks230.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
