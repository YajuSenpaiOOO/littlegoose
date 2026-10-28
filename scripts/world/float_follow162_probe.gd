extends "res://scripts/world/hero_moment161_probe.gd"
func run() -> void:
 var results := []
 for fps in [30,60,144]:
  var follow=preload("res://scripts/combat/float_follow162.gd").new()
  follow.advance(Vector3.ZERO,0.)
  for i in fps: follow.advance(Vector3.RIGHT,1./float(fps),10.)
  results.append(follow.position.x)
 verify(absf(results[0]-results[2])<.00001,"exact spring settles equally at thirty, sixty and one-forty-four FPS")
 var spring=preload("res://scripts/combat/float_follow162.gd").new();spring.advance(Vector3.ZERO,0.)
 var first: Vector3=spring.advance(Vector3.RIGHT,1./60.)
 verify(first.x>0. and first.x<.1 and spring.velocity.x>0.,"follow accelerates gradually instead of snapping")
 var paused: Vector3=spring.advance(Vector3(2,0,0),0.)
 verify(paused==first,"zero-delta pause preserves floating position")
 spring.advance(Vector3(40,0,0),.016)
 verify(spring.position.x==40. and spring.velocity==Vector3.ZERO,"large teleport resets inertia immediately")
 root.size=Vector2i(1600,1000)
 var s := Trial161.new();s.memory_save116="user://float162_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.moment161): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0.,4.));await settle72(8)
 for e in s.enemies: e.hide();e.hit_area.collision_layer=0
 s.set_physics_process(false);s.hero.set_physics_process(false)
 var book: Node3D=s.paper_memories146;var stage: Node=s.moment161
 book.set_process(false);stage.set_process(false)
 s.build161=5;s.apply_paper_build129();s.fire_at(s.projectile_origin()+Vector3.FORWARD*4.)
 book._process(.016)
 verify(book.book146.visible and book.book146.physics_interpolation_mode==Node.PHYSICS_INTERPOLATION_MODE_OFF,"real notebook uses render-driven visual follow without double interpolation")
 var at: Vector3=book.book146.global_position
 s.hero.position.x+=1.;s.hero.reset_physics_interpolation();book._process(1./144.)
 verify(book.book146.global_position.x>at.x and book.book146.global_position.x<at.x+.2,"real notebook lags behind a normal movement step")
 for i in 144: book._process(1./144.)
 verify(absf(book.book146.global_position.x-(s.hero.position.x+.62))<.08,"notebook catches up and settles near intended offset")
 var before_write: Vector3=book.book146.global_position
 verify(book.request146(),"original notebook action still starts")
 book._process(1./144.)
 verify(book.book146.global_position.distance_to(before_write)<.25,"switching to writing anchor blends instead of teleporting")
 s.combat_paused=true;var frozen: Vector3=book.book146.global_position;var clock: float=book.float_age162
 book._process(.5)
 verify(book.book146.global_position==frozen and book.float_age162==clock,"pause freezes notebook bob and inertia")
 s.combat_paused=false;book.reset146()
 verify(not book.book_follow162.initialized and not book.book146.visible,"notebook cleanup resets pose history")
 s.build161=0;s.apply_paper_build129();stage.request161();stage._process(.016)
 var star_at: Vector3=stage.stars162[0].position
 var age: float=stage.age161;var visual_age: float=stage.float_age162
 s.hero.position.x+=1.;s.hero.reset_physics_interpolation();stage._process(1./144.)
 verify(stage.stars162[0].position.x>star_at.x and stage.stars162[0].position.x<star_at.x+.15,"paper star has independent slow follow")
 verify(stage.age161==age and stage.float_age162>visual_age,"floating animation advances per render frame independently of combat ticks")
 for i in 144: stage._process(1./144.)
 verify(stage.stars162.size()==14 and stage.stars162[0].position!=stage.stars162[1].position,"bounded fourteen stars keep distinct float states")
 stage.age161=.2;stage._process(.016);await capture161("float_follow")
 s.hero.position.x+=20.;s.hero.reset_physics_interpolation()
 await process_frame;await process_frame
 stage._process(.016)
 verify(stage.stage_follow162.position.distance_to(s.hero.position+Vector3.UP*.8)<.001,"stage follows a teleport without long trailing flight")
 s.combat_paused=true;var star_frozen: Vector3=stage.stars162[0].position
 stage._process(.5);verify(stage.stars162[0].position==star_frozen,"pause freezes star inertia")
 s.combat_paused=false;stage.reset161()
 verify(not stage.stage_follow162.initialized and stage.stars162.all(func(x: RefCounted) -> bool: return not x.initialized),"stage cleanup resets every float history")
 var report := {"checks":checks,"failures":failures,"fps_settle":results,"note":"Targeted visual follow only; no combat stat or encounter changes."}
 FileAccess.open("res://docs/float-follow162-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("FLOAT162_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
