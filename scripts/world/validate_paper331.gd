extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world331.gd"
 func export_stats226() -> Error: return OK
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures += 1
func capture(w: Node, tag: String) -> void:
 w._process(.016)
 for i in 3: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/castle-candidates/331-"+tag+".png")
func run() -> void:
 var w = Trial.new()
 root.add_child(w)
 current_scene = w
 var deadline := Time.get_ticks_msec()+180000
 while not is_instance_valid(w.boss_bar326) and Time.get_ticks_msec()<deadline: await process_frame
 if not is_instance_valid(w.boss_bar326):
  check(false,"ready")
  quit(1)
  return
 w.set_physics_process(false)
 w.set_process(false)
 w.hero.set_physics_process(false)
 var stage = w.theatre314
 stage.set_process(false)
 stage.cancel()
 stage.sample(4.06)
 stage.finished = true
 w.boss_step314(.01)
 await physics_frame
 await process_frame
 await physics_frame
 await process_frame
 w.clear_patterns327()
 w.phase331=1
 w.start_sweep331(0)
 var aim: Vector2 = w.sweep331.aim
 w.tick_sweep331(.4)
 check(w.cannon_shots326.is_empty() and stage.sweep_mesh331.visible,"windup before first round")
 await capture(w,"cue")
 w.hero.position.x+=1.
 w.tick_sweep331(.41)
 check(w.cannon_shots326.size()==1 and w.sweep331.aim==aim,"first round after .8 seconds fixed aim")
 var first: Dictionary = w.cannon_shots326[0]
 w.tick_cannon_shots326(.016)
 check(w.cannon_shots326.size()==1,"round clears own cannon body")
 var first_angle: float = aim.angle_to(first.direction)
 for i in 100:
  w.tick_sweep331(.016)
  w.tick_cannon_shots326(.016)
 check(w.cannon_shots326.size()>4,"continuous visible bullet train")
 await capture(w,"stream")
 # Finish emission without retiring shots to inspect angular order.
 w.clear_cannon_shots326()
 w.cancel_sweep331()
 w.start_sweep331(1)
 var side: float = w.sweep331.side
 w.tick_sweep331(.81)
 for i in 24: w.tick_sweep331(.16)
 check(w.sweep331.is_empty() and w.cannon_shots326.size()==24,"exactly 24 rounds then stop")
 var angle0: float = Vector2(w.cannon_shots326[0].direction).angle_to(w.cannon_shots326[23].direction)
 check(side<0. and angle0<-.9,"next burst reverses fixed sweep direction")
 var ordered := true
 for i in 23:
  if Vector2(w.cannon_shots326[i].direction).angle_to(w.cannon_shots326[i+1].direction)>=0.: ordered=false
 check(ordered,"adjacent shots follow angular order")
 w.clear_cannon_shots326()
 # Native dash and parry remain available against the new continuous shot path.
 w.invulnerability=0.
 w.hero.reset_actions()
 w.hero.controls_enabled=true
 check(w.hero.request_parry(),"native parry request")
 var near: Vector3 = w.hero.global_position+Vector3(0.,.85,-.4)
 var sprite: Sprite3D = stage.shell331(near,Vector2.DOWN)
 w.cannon_shots326.append({"sprite":sprite,"at":near,"direction":Vector2.DOWN,"life":1.,"speed":6.,"source":0,"aa331":true,"height":.85})
 var count: int = w.parry_count
 w.tick_cannon_shots326(.016)
 check(w.parry_count==count+1 and w.cannon_shots326.is_empty(),"new rounds support native parry")
 w.hero.reset_actions()
 w.invulnerability=0.
 w.hero.dodge_invulnerability=.2
 w.hero.dash_eligible=true
 sprite=stage.shell331(near,Vector2.DOWN)
 w.cannon_shots326.append({"sprite":sprite,"at":near,"direction":Vector2.DOWN,"life":1.,"speed":6.,"source":0,"aa331":true,"height":.85})
 var dodges: int = w.perfect_dodges
 w.tick_cannon_shots326(.016)
 check(w.perfect_dodges==dodges+1,"new rounds support perfect dodge")
 w.start_sweep331(0)
 var hp: float = w.fastener_hp321
 w.hurt_cannon326(0,5.)
 check(w.cannon_hp326[0]==0. and w.repair_left331[0]==7. and w.sweep331.is_empty(),"disable cannon interrupts sweep and starts repair")
 check(w.fastener_hp321==hp-3.,"first suppression damages castle three")
 w.hurt_cannon326(0,20.)
 check(w.fastener_hp321==hp-3.,"disabled cannon cannot farm castle damage")
 await physics_frame
 await process_frame
 check(stage.cannon_areas326[0].collision_layer==0,"disabled target not attackable")
 await capture(w,"disabled")
 w.tick_repairs331(6.2)
 stage._process(0.)
 check(w.cannon_hp326[0]==0. and stage.cannons326[0].texture==stage.cannon_frames326[0],"last second visibly refolds before firing")
 w.tick_repairs331(.8)
 await physics_frame
 await process_frame
 check(w.cannon_hp326[0]==5. and stage.cannon_areas326[0].collision_layer==8 and w.volley_left327>=.9,"repair restores target with firing grace")
 hp=w.fastener_hp321
 w.hurt_cannon326(0,5.)
 check(w.fastener_hp321==hp,"repeat suppression grants quiet not repeat damage")
 w.hurt_cannon326(1,5.)
 check(w.live_device327()<0,"both guns can be temporarily suppressed")
 w.tick_repairs331(7.1)
 check(w.live_device327()>=0 and w.cannon_hp326==[5.,5.],"both guns return instead of permanent helpless castle")
 w.clear_patterns327()
 w.clear_cannon_shots326()
 w.pattern_left327=0.
 w.phase331=4
 w.tick_pattern327(.016)
 check(w.phase331==0,"five phase loop wraps")
 w.start_sweep331(0)
 w.finish251(true)
 check(w.sweep331.is_empty() and w.repair_left331==[0.,0.] and w.cannon_hp326==[0.,0.],"victory cancels sweep and repairs")
 stage.collapse314(1.2)
 check(stage.cannons326.all(func(c): return c.visible and c.texture==stage.cannon_frames326[1]),"castle collapse destroys both guns together")
 await capture(w,"finale")
 w.restart301()
 check(not w.finale_cannons331 and w.phase331==0 and not w.disabled_once331[0] and w.cannon_hp326==[5.,5.] and not stage.finale_burst331,"restart restores full encounter")
 print("RESULT failures=",failures)
 quit(failures)
