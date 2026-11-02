extends "res://scripts/world/validate_pressure221.gd"
## Regression: continue ticking after parry, including persistent physical contact.
func advance221(cat: CharacterBody3D,seconds: float) -> void:
 for i in int(seconds*60.):
  w.hero.parry_t=maxf(0.,w.hero.parry_t-1./60.)
  cat._physics_process(1./60.)
  await physics_frame
func run() -> void:
 w=FixtureWorld.new();root.add_child(w);current_scene=w
 while not w.ready220:await process_frame
 w.auto114=false;w.pigs_enabled220=false
 var floor_body=StaticBody3D.new();floor_body.collision_layer=1
 var collider=CollisionShape3D.new();var shape=BoxShape3D.new();shape.size=Vector3(60,1,40);collider.shape=shape;floor_body.add_child(collider);w.add_child(floor_body);floor_body.position=Vector3(500,-.5,500)
 for i in 3:await physics_frame
 var cat=actor221("res://scripts/combat/fat_cat_boss220.gd",3.5)
 # Reproduce a successful native parry, then remain inside contact range.
 w.hero.position=Vector3(498.75,0,500);cat.roll_dir220=Vector2.LEFT;cat.enter220("roll")
 check(w.hero.request_parry(),"native right-click parry accepted")
 cat._physics_process(1./60.);await physics_frame
 check(cat.parried_count==1,"baseline roll successfully parried")
 await advance221(cat,.3)
 metrics.baseline_hp_after_parry=w.player_hp
 check(w.player_hp<100.,"reproduced old next-tick touch damage after successful parry")
 cat=actor221("res://scripts/combat/fat_cat_boss221.gd",3.5)
 check(not cat.show_lane221,"ground warning defaults off")
 w.hero.position=Vector3(498.75,0,500);cat.roll_dir220=Vector2.LEFT;cat.enter220("roll")
 w.hero.request_parry();cat._physics_process(1./60.);await physics_frame
 check(cat.parried_count==1 and cat.parry_separation221,"successful roll parry suppresses this cat's residual contact")
 await advance221(cat,1.25)
 metrics.fixed_hp_after_parry=w.player_hp
 check(w.player_hp==100. and cat.contact_count220==0,"remaining beside parried cat through recovery does not cost HP")
 w.hero.position=Vector3(496,0,500);cat._physics_process(1./60.)
 check(not cat.parry_separation221,"separating restores normal contact checks")
 cat.enter220("recover");w.hero.reset_actions();w.hero.position=cat.position+Vector3(-1.25,0,0);w.invulnerability=0.
 cat._physics_process(1./60.)
 check(w.player_hp<100.,"fresh unguarded body contact still deals damage")
 cat=actor221("res://scripts/combat/fat_cat_boss221.gd",4.)
 cat.enter220("roll");cat.planned_time221=1.
 var frames: Array[int]=[]
 for i in 12:
  cat.clock220=(float(i)+.5)/12.;cat._render_legacy(0.);frames.append(cat.roll_frame220())
  check(cat.visual.texture==cat.rolls220[i%6],"long roll actual sprite sample "+str(i))
 check(frames==[0,1,2,3,4,5,0,1,2,3,4,5],"long roll plays two complete equal-duration cycles")
 cat.planned_time221=.5
 frames.clear()
 for i in 6:cat.clock220=(float(i)+.5)/12.;frames.append(cat.roll_frame220())
 check(frames==[0,1,2,3,4,5],"short roll keeps one complete cycle")
 cat.enter220("windup");cat.clock220=.35;cat.lock221(Vector2(w.hero.position.x,w.hero.position.z));cat._render_legacy(0.)
 check(not cat.lane220.visible and is_equal_approx(cat.visual.scale.y,.9),"default invisible lane retains body windup")
 cat.show_lane221=true;cat._render_legacy(0.)
 check(cat.lane220.visible,"F8 comparison can still show lane")
 metrics.frames_long=[0,1,2,3,4,5,0,1,2,3,4,5]
 floor_body.queue_free();w.end220(false)
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/parry221-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics,"scope":"native parry + continued physical contact, visual cycle samples; no human motion approval"},"\t"))
 print("PARRY221_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
