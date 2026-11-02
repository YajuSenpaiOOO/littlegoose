extends "res://scripts/world/validate_plush220.gd"
class TestWorld:
 extends "res://scripts/world/woodland_world233.gd"
 func _init() -> void:
  super._init();memory_save116="user://motion233_validation_preview.cfg"
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
 func floor_height(at: Vector2) -> float:
  if at.x>400.:return 0.
  return super.floor_height(at)
func capture233(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/motion233-"+tag+".png")
func roll233(cat: CharacterBody3D,scale: float) -> Dictionary:
 cat.position=Vector3(500,0,500);cat.velocity=Vector3.ZERO;cat.set_meta("locomotion_scale153",scale)
 cat.roll_dir220=Vector2.RIGHT;cat.planned_time221=.8;cat.enter220("roll");cat.parry_separation221=false
 w.hero.position=Vector3(530,0,500);w.hero.reset_actions()
 var seconds=0.;var start=cat.position;var speed=0.
 while cat.phase220=="roll" and seconds<3.:
  cat._physics_process(1./120.);seconds+=1./120.
  speed=maxf(speed,cat.velocity.length())
 return {"seconds":seconds,"distance":cat.position.distance_to(start),"speed":speed}
func run() -> void:
 var configs={}
 for p in ["user://boss_balance232.cfg","user://boss_balance233.cfg"]:configs[p]=FileAccess.get_file_as_bytes(p) if FileAccess.file_exists(p) else null
 w=TestWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 w.levels226={"paper_plane":1,"balloon_sword":1,"three_player":1,"eye_exercise":1};w.start_battle225(false)
 w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.hero.set_physics_process(false);w.cat220.set_physics_process(false)
 check(w.cat220.get_script().resource_path.ends_with("fat_cat_boss233.gd"),"233 uses roll-control cat")
 check(w.swords153.get_script().resource_path.ends_with("balloon_sword232.gd"),"batched sword renderer retained")
 # Compare the old and new flight managers with the same payload, RNG and
 # actual bat colliders. No physics step occurs between their paired drops.
 w.combat_paused=false;w.battle_phase220="repair";w.cat220.dead=true
 w.rig_at220=w.repair_spot220();w.rig_height220=.1;w.rig220.place220(w.rig_at220,.1,0.);w.rig220._process(0.)
 for bat in w.bats220:bat.set_enabled220(true);bat._physics_process(0.)
 var target: Vector3=w.bats220[0].hit_area.global_position
 var packet: Dictionary=w.snapshot_packet146(target,false,0.)
 check(not packet.is_empty(),"comparison captures a real unpaused attack packet")
 if packet.is_empty():quit(1);return
 w.combat_paused=true
 var old=preload("res://scripts/combat/paper_rain232.gd").new();old.battle=w;w.add_child(old);old.set_process(false)
 var current=w.paper_memories146
 old.flight_rng146.seed=233001;current.flight_rng146.seed=233001
 old.launch146(packet,w.projectile_origin(),target);current.launch146(packet,w.projectile_origin(),target)
 check(old.planes149.size()==3 and current.planes149.size()==3,"same three aircraft payload groups")
 if old.planes149.size()!=3 or current.planes149.size()!=3:quit(1);return
 for source in 3:
  var a: Dictionary=old.planes149[source];var b: Dictionary=current.planes149[source]
  check(a.packet==b.packet and a.gain==b.gain and a.release==b.release and a.spacing==b.spacing and a.coverage151==b.coverage151,"payload and delivery schedule unchanged source "+str(source))
  var speed_ok=true;var heights_ok=true
  for age in [.01,.10,.24,.25,.30,.50,.75,.85,1.,1.20]:
   var velocity=(current.point150(b,age+.001)-current.point150(b,age))/.001
   speed_ok=speed_ok and absf(velocity.length()-8.)<.02 and absf(velocity.y)<.001
  for index in 6:
   var when=old.drop_time150(a,index)
   heights_ok=heights_ok and is_equal_approx(old.point150(a,when).y,current.point150(b,when).y)
   old.drop150(a,index);current.drop150(b,index)
  check(speed_ok,"constant level speed through approach/drop/exit source "+str(source))
  check(heights_ok,"every drop retains old fall height source "+str(source))
 check(old.history149.size()==18 and current.history149.size()==18,"same eighteen deliveries")
 check(current.history149.any(func(h):return h.target_id!=0),"paired delivery test acquires actual low bat targets")
 check(range(18).all(func(i):return old.history149[i].aim.is_equal_approx(current.history149[i].aim) and old.history149[i].origin.is_equal_approx(current.history149[i].origin) and old.history149[i].target_id==current.history149[i].target_id),"all actual delivery origins aims and targets identical")
 metrics["air_speed"]=8.;old.queue_free();w._clear_combat_shots()
 w.combat_paused=false;w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.cat220.set_physics_process(false)
 var cat=w.cat220;w.repairs220=0
 var floor_body=StaticBody3D.new();floor_body.collision_layer=1
 var collision=CollisionShape3D.new();var box=BoxShape3D.new();box.size=Vector3(80,1,40);collision.shape=box;floor_body.add_child(collision);w.add_child(floor_body);floor_body.position=Vector3(510,-.5,500)
 cat.position=Vector3(500,0,500);w.hero.position=Vector3(530,0,500)
 await settle(3)
 var plain=roll233(cat,1.);var full=roll233(cat,.6)
 metrics["roll_normal"]=plain;metrics["roll_five_layers"]=full
 check(absf(plain.speed-9.5)<.01 and absf(full.speed-5.7)<.01,"five stacks reduce real rolling velocity by forty percent")
 check(absf(full.distance-plain.distance)<.1 and full.seconds>plain.seconds*1.6,"same roll distance takes longer under slow")
 cat.enter220("windup")
 check(is_equal_approx(cat.windup_time221,.65),"first-round preparation unchanged")
 w.swords153.reset153();cat.position=Vector3(500,0,500);cat.enter220("roll");cat.planned_time221=.8;cat.roll_dir220=Vector2.RIGHT
 for i in 5:w.swords153.attach153(cat,cat.visual.global_position,Vector3.LEFT,1.,{})
 check(cat.roll_speed_scale221()==.6,"real adhesive layers feed rolling control")
 cat._physics_process(.2)
 check(absf(cat.clock220-.12)<.0001 and cat.roll_frame220()==1,"roll animation advances with slowed movement")
 w.swords153.step153(3.01)
 check(cat.roll_speed_scale221()==1.,"expired adhesive restores full rolling speed")
 var legacy=preload("res://scripts/combat/fat_cat_boss231.gd").new();legacy.set_meta("locomotion_scale153",.6)
 check(legacy.roll_speed_scale221()==1.,"old previews retain original roll behavior");legacy.free()
 cat.position=Vector3(500,0,500);cat.set_meta("locomotion_scale153",.6);cat.roll_dir220=Vector2.LEFT;cat.planned_time221=1.;cat.enter220("roll")
 w.hero.position=Vector3(498.75,0,500);w.hero.reset_actions();w.player_hp=14.;w.invulnerability=0.
 check(w.hero.request_parry(),"parry request accepted during slow-roll fixture")
 cat._physics_process(1./60.)
 check(cat.parried_count>0 and cat.phase220=="recover" and w.player_hp==14.,"slowed roll retains parry and residual-contact protection")
 w.invulnerability=10000.;floor_body.queue_free();w._clear_combat_shots();w.start_battle225(false);w.auto114=false;w.player_hp=14.;w.invulnerability=10000.;w.pigs_enabled220=false
 w._update_camera(0.,true);w.auto114=true
 await create_timer(3.5).timeout
 w.combat_paused=true;await capture233("live")
 check(w.paper_memories146.history149.size()>0 and w.cat220.hp<100.,"actual battle aircraft and sword damage remain active")
 w.combat_paused=false;w.auto114=false;w.stop225()
 for p in configs:check(configs[p]==(FileAccess.get_file_as_bytes(p) if FileAccess.file_exists(p) else null),"user config unchanged: "+p)
 var failed=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/motion233-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failed.size(),"metrics":metrics},"\t"))
 print("MOTION233_DONE checks=",checks.size()," failures=",failed.size());quit(0 if failed.is_empty() else 1)
