extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world291.gd"
 func export_stats226() -> Error:return OK
func shot291(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/boss291-"+tag+".png")
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.transform288):await process_frame
 w.auto114=false;w.set_process(false);w.set_physics_process(false);w.hero.set_physics_process(false)
 var b=w.boss247;b.set_process(false);b._process(0.)
 check(b.pose291=="sleep" and b.visual.texture==b.ART291.sleep,"sleep uses new closed eyelids and glass body")
 check(is_equal_approx(b.visual.pixel_size*float(b.layout291.sleep.span[0]),3.),"sleep keeps existing three meter footprint")
 check(b.collision_layer==18 and is_instance_valid(w.cushion265),"sleep retains cushion and solid footprint")
 await shot291("sleep")
 w.boss_unlocked264=true;w.boss264();w.set_physics_process(false)
 b=w.boss247;b.set_physics_process(false);b.set_process(false)
 var native=b.visual;var collider=b.hit_area.get_child(0).shape;var hp=b.hp
 for state in [["rest",.2,"idle"],["angry",.2,"charge"],["squat",.3,"charge"],["flight",.2,"airborne"],["rebound",.02,"landing"],["flat",.04,"landing"],["flat",.4,"dizzy"],["flat",2.3,"idle"],["bumper",.1,"dizzy"],["deflected",.05,"hit"]]:
  b.enter247(state[0]);b.clock247=state[1];b.hit_left=0.;b.landing_left=0.;b.lift247=1.2 if state[0]=="flight" else 0.;b.render247()
  check(b.pose291==state[2],"phase %s %.2f selects %s"%[state[0],state[1],state[2]])
  var texture=b.GLASS290 if state[2]=="idle" else b.ART291[state[2]]
  check(b.visual.texture==texture and b.soft_ink.get_shader_parameter("art")==texture,"sprite and shader agree: "+str(state[2]))
  var foot=b.FOOT290.y if state[2]=="idle" else float(b.layout291[state[2]].foot[1])
  check(is_equal_approx(b.visual.offset.y+b.visual.texture.get_height()*.5,foot) and is_equal_approx(b.soft_ink.get_shader_parameter("foot_y"),foot/b.visual.texture.get_height()),"sprite/shader foot pivot agrees: "+str(state[2]))
  check(b.visual==native and b.hit_area.get_child(0).shape==collider and b.hp==hp,"native visual/collider/HP preserved: "+str(state[2]))
  if state[2] in ["charge","airborne","landing","dizzy","hit"]:await shot291(str(state[2]))
 b.rich291=false;b.enter247("flight");b.render247();check(b.visual.texture==b.GLASS290,"F11 comparison restores 290 single skin")
 b.rich291=true;b.glass290=false;b.render247();check(b.visual.texture!=b.ART291.airborne and b.visual.texture!=b.GLASS290,"F10 comparison restores old species art")
 b.glass290=true;b.enter247("rest");b.receive_hit(1.,Vector3.RIGHT);check(b.hp<hp and b.pose291=="hit","native damage chooses authored recoil")
 b.dead=true;b.defeat_age=.2;b._render_legacy(0.);check(b.pose291=="dizzy","defeat uses exhausted body without reverting to old art");b.dead=false
 b.enter247("rest");b.hit_left=0.;b.landing_left=0.;w.invulnerability=100.
 var seen={}
 for i in 600:
  seen[b.phase247]=true;b._physics_process(1./60.)
 check(seen.has("angry") and seen.has("flight") and seen.has("flat"),"native ten second bounce cycle remains live")
 check(is_instance_valid(w.projection250),"shared native ground shadow retained")
 FileAccess.open("res://docs/boss291-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks},"  "))
 quit(0 if checks.all(func(c):return c.pass) else 1)
