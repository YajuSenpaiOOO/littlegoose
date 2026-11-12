extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world334.gd"
 func export_stats226() -> Error: return OK
var failures:=0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func capture(w: Node, tag: String) -> void:
 w._process(.016)
 for i in 3: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/castle-candidates/334-"+tag+".png")
func run() -> void:
 var w=Trial.new()
 root.add_child(w)
 current_scene=w
 var deadline:=Time.get_ticks_msec()+180000
 while not is_instance_valid(w.boss_bar326) and Time.get_ticks_msec()<deadline: await process_frame
 if not is_instance_valid(w.boss_bar326):
  quit(1)
  return
 w.set_physics_process(false)
 w.set_process(false)
 w.hero.set_physics_process(false)
 var stage=w.theatre314
 stage.set_process(false)
 stage.cancel()
 stage.sample(4.06)
 stage.finished=true
 w.boss_step314(.01)
 check(w.fastener_hp321==144. and w.cannon_hp326==[16.,16.],"new durability baseline")
 w.hurt_cannon326(0,5.)
 check(w.cannon_hp326[0]==11.,"five normal hits no longer disable")
 w.hurt_cannon326(0,11.)
 w.hurt_cannon326(1,16.)
 w.tick_repairs331(.01)
 check(w.rebuild_index334==0 and w.rebuild_queue334==[1],"two repairs serialize")
 stage.sample_rebuild334(0,.7)
 check(stage.courier334.visible and stage.cannons326[0].visible,"courier descends toward wreck")
 stage.sample_rebuild334(0,1.4)
 check(stage.cannons326[0].position.y>stage.homes334[0].y+1. and stage.rope334.visible,"wreck lifts with attached rope")
 await capture(w,"recovery")
 stage.sample_rebuild334(0,2.1)
 check(not stage.cannons326[0].visible and not stage.courier334.visible,"wreck removed before new folding")
 stage.sample_rebuild334(0,3.1)
 check(stage.courier334.visible and stage.courier334.position.y>stage.girl.position.y+2.,"catcher visibly descends before paper throw")
 stage.sample_rebuild334(0,3.9)
 check(stage.parcel334.visible and stage.courier334.visible,"new folded parcel thrown and caught")
 await capture(w,"parcel")
 stage.sample_rebuild334(0,5.6)
 check(stage.cannons326[0].visible and stage.rope334.visible and stage.cannons326[0].texture==stage.cannon_frames326[0],"fresh cannon transported toward home")
 await capture(w,"delivery")
 w.tick_repairs331(7.)
 check(w.cannon_hp326[0]==16. and w.cannon_hp326[1]==0. and w.rebuild_index334<0,"first restoration full health second still queued")
 w.tick_repairs331(.1)
 check(w.rebuild_index334==1,"second rebuild starts next")
 w.tick_repairs331(7.)
 check(w.cannon_hp326==[16.,16.] and stage.cannons326[0].position==stage.homes334[0],"both restore at original anchors")
 w.salvo334=1
 w.scatter327(0)
 check(w.paper_queue334.size()==3 and is_equal_approx(w.paper_queue334[2].delay,.24),"locked three round burst queue")
 w.tick_paper_queue334(.13)
 check(w.paper_queue334.size()==1,"burst emits in chronological slots")
 w.paper_queue334.clear()
 w.salvo334=2
 w.scatter327(0)
 check(w.paper_queue334.size()==8 and w.paper_queue334.filter(func(s): return s.delay>0.).size()==4,"double fans offset half beat")
 w.interrupt327(0)
 check(w.paper_queue334.all(func(s): return s.source==1),"disable cancels only associated queued shots")
 w.phase331=2
 w.pattern_left327=2.
 w.volley_left327=1.25
 w.boss_step314(.01)
 check(w.volley_left327<=.75,"ordinary phase higher cadence")
 w.hurt_cannon326(0,16.)
 w.tick_repairs331(1.)
 w.finish251(true)
 check(w.rebuild_index334<0 and w.rebuild_queue334.is_empty() and not stage.courier334.visible,"victory cancels transportation")
 w.restart301()
 check(w.fastener_hp321==144. and w.cannon_hp326==[16.,16.] and w.paper_queue334.is_empty(),"restart restores all custom state")
 print("RESULT failures=",failures)
 quit(failures)
