extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world330.gd"
 func export_stats226() -> Error: return OK
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures += 1
func capture(w: Node, label: String) -> void:
 w._process(.016)
 for i in 3: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/castle-candidates/330-"+label+".png")
func close_ball(w: Node) -> void:
 w.charge_heavy330(0)
 var ball: Dictionary = w.heavies330.back()
 ball.state = "incoming"
 ball.height = .85
 ball.heading = Vector2(0.,1.)
 ball.at = w.hero.global_position+Vector3(0.,.85,-.8)
 ball.sprite.global_position = ball.at
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
 await physics_frame
 w.clear_patterns327()
 check(w.fastener_hp321==72.,"HP 72 preserved")
 check(stage.HEAVY330.get_image().get_pixel(0,0).a==0. and stage.MORTAR330.get_image().get_pixel(0,0).a==0.,"new sprites have genuine alpha")
 w.charge_heavy330(0)
 w.tick_heavy330(.58)
 check(w.heavies330[0].state=="charge" and w.heavies330[0].sprite.scale.x>.6,"visible growing windup")
 check(w.heavies330[0].sprite.global_position.distance_to(w.heavies330[0].at)<.03,"charge stays at muzzle in world coordinates")
 await capture(w,"charge")
 w.tick_heavy330(.58)
 w.tick_heavy330(.1)
 check(w.heavies330.size()==1 and w.heavies330[0].state=="incoming","heavy clears own cannon collision")
 var heading: Vector2 = w.heavies330[0].heading
 w.hero.position.x += 1.
 w.tick_heavy330(.1)
 check(w.heavies330.size()==1 and w.heavies330[0].heading==heading,"flight locks heading instead of homing")
 w.clear_heavy330()
 w.invulnerability=0.
 w.hero.reset_actions()
 w.hero.controls_enabled=true
 close_ball(w)
 check(w.hero.request_parry(),"native right click parry request accepted")
 var count: int = w.parry_count
 w.tick_heavy330(.01)
 check(w.heavies330.size()==1 and w.heavies330[0].state=="return" and w.parry_count==count+1,"native parry reflects rather than deletes")
 check(w.reflected330==1,"reflected count once")
 await capture(w,"return")
 var hp: float = w.fastener_hp321
 for i in 180: w.tick_heavy330(1./60.)
 check(w.fastener_hp321==hp-8. and w.heavies330.is_empty(),"return hits castle once for eight damage")
 w.invulnerability=0.
 w.parry_grace258=0.
 w.hero.reset_actions()
 w.hero.guarding109=true
 var health: float = w.player_hp
 close_ball(w)
 w.tick_heavy330(.01)
 check(w.player_hp<health and w.heavies330.is_empty() and w.reflected330==1,"holding guard takes reduced hit without reflection")
 w.invulnerability=0.
 w.parry_grace258=0.
 w.hero.reset_actions()
 w.hero.dodge_invulnerability=.2
 w.hero.dash_eligible=true
 var dodges: int = w.perfect_dodges
 health=w.player_hp
 close_ball(w)
 w.tick_heavy330(.01)
 check(w.perfect_dodges==dodges+1 and w.player_hp==health,"heavy supports perfect dodge")
 w.clear_patterns327()
 w.mortar327(1)
 check(w.flights327.size()==3 and w.flights327[0].duration==1.65 and w.flights327[1].age< -1.,"mortar slower ordered queue")
 check(w.flights327[0].sprite.texture==stage.MORTAR330 and w.flights327[0].sprite.pixel_size>.001,"mortar uses large dedicated body")
 w.tick_flights327(.55)
 check(w.flights327.filter(func(f): return f.sprite.visible).size()==1,"only first mortar launched before next slot")
 var first: Dictionary = w.flights327[0]
 check(first.sprite.global_position.y>first.ground.y+1.,"mortar has readable elevated arc")
 await capture(w,"mortar")
 var angle: float = first.sprite.rotation.z
 stage.pose_mortar330(first,.85)
 check(absf(angle-first.sprite.rotation.z)>.2,"mortar nose follows arc")
 w.tick_flights327(1.11)
 check(w.blasts327.size()==1,"mortar explodes once on landing")
 w.clear_patterns327()
 w.charge_heavy330(0)
 w.interrupt327(0)
 check(w.heavies330.is_empty(),"cannon interruption cancels charging heavy")
 w.charge_heavy330(1)
 w.finish251(true)
 check(w.heavies330.is_empty() and w.flights327.is_empty(),"victory clears new projectiles")
 w.restart301()
 check(w.heavies330.is_empty() and w.attack330==0 and w.reflected330==0 and w.fastener_hp321==72.,"restart resets phase projectiles and health")
 w.tick_pattern327(.7)
 check(w.heavies330.size()==1,"scheduled opening actually charges heavy")
 w.clear_patterns327()
 for phase in [1,2,3,0]:
  w.pattern_left327=0.
  w.tick_pattern327(.01)
  check(w.attack330==phase,"phase advances to %d" % phase)
  w.clear_patterns327()
 print("RESULT failures=",failures)
 quit(failures)
