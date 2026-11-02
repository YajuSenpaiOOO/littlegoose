extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world225.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready225:await process_frame
 w.start_battle225(false);w.combat_paused=true;w.auto114=false
 w.hero.set_physics_process(false);w.cat220.set_physics_process(false)
 var cat=w.cat220
 var side=w.camera.global_basis.x;side.y=0.;side=side.normalized()
 for sign_value in [1.,-1.]:
  var right=sign_value>0.
  cat.phase220="chase";cat.velocity=side*sign_value;cat._render_legacy(0.)
  check(cat.visual.flip_h==right,"moving cat faces screen "+("right" if right else "left"))
  w.hero.position=cat.position+side*sign_value*4.
  cat.enter220("windup");cat.velocity=Vector3.ZERO;cat._render_legacy(0.)
  check(cat.visual.flip_h==right,"stationary windup faces player on "+("right" if right else "left"))
  cat.lock221(Vector2(w.hero.position.x,w.hero.position.z));cat.enter220("roll");cat._render_legacy(0.)
  check(cat.visual.flip_h==right,"roll first frame retains intended direction before velocity update")
  cat.enter220("recover");cat.velocity=Vector3.ZERO;cat._render_legacy(0.)
  check(cat.visual.flip_h==right,"stopped recovery retains last roll direction")
  cat.enter220("down");cat._render_legacy(0.)
  check(cat.visual.flip_h==right,"defeated cat retains facing with zero velocity")
 cat.phase220="windup";cat.roll_dir220=Vector2(-side.x,-side.z);cat._render_legacy(0.)
 cat.roll_dir220=Vector2(side.x,side.z);cat._render_legacy(0.)
 check(cat.visual.flip_h,"preparation can follow player crossing to the right")
 cat.enter220("recover");cat.velocity=Vector3.ZERO;cat._render_legacy(0.)
 var offset=cat.visual.offset
 for i in 12:cat._render_legacy(0.)
 check(cat.visual.offset.is_equal_approx(offset),"mirrored anchor does not accumulate across renders")
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/facing225-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size()},"\t"))
 print("FACING225_RESULT ",checks.size()," checks ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
