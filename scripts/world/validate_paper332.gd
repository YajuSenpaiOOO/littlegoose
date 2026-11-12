extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world332.gd"
 func export_stats226() -> Error: return OK
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures += 1
func reset_hit(w: Node) -> void:
 w.invulnerability=0.
 w.parry_grace258=0.
 w.hero.reset_actions()
 w.hero.velocity=Vector3.ZERO
 w.hero.combat_impulse=Vector2.ZERO
 w.player_hp=12.
func capture(w: Node, tag: String) -> void:
 w._process(.016)
 for i in 3: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/castle-candidates/332-"+tag+".png")
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
 stage.finished=true
 w.boss_step314(.01)
 await physics_frame
 await process_frame
 w.start_sweep331(0)
 var aim: Vector2 = w.sweep331.aim
 w.cancel_sweep331()
 w.hero.position.x+=3.
 w.start_sweep331(0)
 check(w.sweep331.aim==aim,"sector independent of player even before windup")
 w.tick_sweep331(.81)
 for i in 25: w.tick_sweep331(.16)
 check(w.cannon_shots326.size()==25 and w.sweep331.is_empty(),"25 ordinary scraps complete out and back")
 check(w.cannon_shots326[0].sprite.texture.resource_path.ends_with("folded_packet.png"),"sweep uses ordinary paper scraps")
 var first: Vector2 = w.cannon_shots326[0].direction
 var peak: Vector2 = w.cannon_shots326[12].direction
 var last: Vector2 = w.cannon_shots326[24].direction
 check(first.distance_to(last)<.001 and first.angle_to(peak)<-.9,"fixed arc returns to exact starting edge")
 var out_angle: float = Vector2(w.cannon_shots326[10].direction).angle_to(w.cannon_shots326[11].direction)
 var in_angle: float = Vector2(w.cannon_shots326[13].direction).angle_to(w.cannon_shots326[14].direction)
 check(out_angle*in_angle<0.,"sweep reverses within same burst")
 w.clear_cannon_shots326()
 w._teleport15(w.centre301+Vector2(0.,6.5))
 reset_hit(w)
 var feet := Vector2(w.hero.global_position.x,w.hero.global_position.z)
 w.hurt_player(1.,feet-Vector2.RIGHT)
 check(w.player_hp<12. and w.hero.pending_lift332==0.,"ordinary shots retain grounded light hit")
 reset_hit(w)
 w.charge_heavy330(0)
 var ball: Dictionary=w.heavies330[0]
 ball.state="incoming"
 ball.at=w.hero.global_position+Vector3(0.,.85,-.8)
 ball.height=.85
 ball.heading=Vector2.DOWN
 w.tick_heavy330(.016)
 check(w.last_heavy332=="heavy" and w.hero.pending_lift332==4.8,"real heavy collision queues short physical lift")
 check(w.hero.combat_impulse.length()<=7.01 and w.invulnerability>=1.1,"bounded push and landing protection")
 reset_hit(w)
 for meteor in [false,true]:
  var visual: Dictionary=stage.make_blast327(feet,3.2)
  w.blasts327.append({"at":feet,"age":0.,"hit":false,"radius":1.6,"meteor":meteor,"visual":visual})
  w.tick_blasts327(.01)
  check(w.hero.pending_lift332==(5.6 if meteor else 4.5),"blast kind routes correct lift meteor=%s"%meteor)
  w.clear_patterns327()
  reset_hit(w)
 w.hero.guarding109=true
 w.hazard_hurt332(1.5,feet-Vector2.DOWN,"meteor")
 check(w.player_hp<12. and w.hero.pending_lift332==0. and w.hero.combat_impulse.length()<=3.01,"guard braces rather than airborne launch")
 reset_hit(w)
 w.invulnerability=.5
 w.hazard_hurt332(1.5,feet,"mortar")
 check(w.player_hp==12. and w.hero.pending_lift332==0.,"invulnerability prevents damage and launch")
 reset_hit(w)
 w.hero.dodge_invulnerability=.2
 var dodges: int=w.perfect_dodges
 w.hero.dash_eligible=true
 var visual: Dictionary=stage.make_blast327(feet,3.2)
 w.blasts327.append({"at":feet,"age":0.,"hit":false,"radius":1.6,"meteor":true,"visual":visual})
 w.tick_blasts327(.01)
 check(w.perfect_dodges==dodges+1 and w.hero.pending_lift332==0.,"perfect dodge avoids lift and grants native reward")
 w.clear_patterns327()
 reset_hit(w)
 # Step the actual CharacterBody3D against terrain through apex and landing.
 for i in 3:
  await physics_frame
  w.hero._physics_process(1./60.)
 var origin: Vector3=w.hero.global_position
 feet=Vector2(origin.x,origin.z)
 w.hazard_hurt332(1.5,feet-Vector2.RIGHT,"meteor")
 var apex:=0.
 for i in 60:
  await physics_frame
  w.hero._physics_process(1./60.)
  apex=maxf(apex,w.hero.global_position.y-w.floor_height(Vector2(w.hero.global_position.x,w.hero.global_position.z)))
  if i==7: await capture(w,"airborne")
 check(apex>.3 and apex<1.2,"native launch visibly lifts less than 1.2 metres")
 check(not w.hero.blast_air332 and w.hero.is_on_floor(),"native gravity lands without custom trajectory")
 check(Vector2(w.hero.global_position.x-origin.x,w.hero.global_position.z-origin.z).length()<2.5,"bounded displacement under 2.5 metres")
 check(w.hero.controls_enabled,"movement remains enabled during blast")
 reset_hit(w)
 w.hazard_hurt332(1.5,feet,"mortar")
 check(w.hero.request_dash(Vector2.LEFT) and w.hero.pending_lift332==0.,"native dash can cancel launch feedback")
 w.restart301()
 check(w.hero.pending_lift332==0. and not w.hero.blast_air332 and w.landing_rings332.is_empty(),"restart clears lift and landing effects")
 w.hero.controls_enabled=true
 w.hero.request_parry()
 w.hero.pending_lift332=4.5
 var paused_at: Vector3=w.hero.global_position
 w.combat_paused=true
 w.hero._physics_process(1./60.)
 check(w.hero.global_position==paused_at and w.hero.pending_lift332==4.5 and not w.hero.guarding109,"pause defers lift and retains native guard cancellation")
 w.combat_paused=false
 w.restart301()
 print("RESULT failures=",failures)
 quit(failures)
