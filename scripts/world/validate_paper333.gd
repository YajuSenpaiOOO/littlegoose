extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world333.gd"
 func export_stats226() -> Error: return OK
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func reset_hit(w: Node) -> void:
 w.invulnerability=0.
 w.parry_grace258=0.
 w.hero.reset_actions()
 w.player_hp=12.
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
 w.hero.set_physics_process(false)
 var stage=w.theatre314
 stage.set_process(false)
 stage.cancel()
 stage.sample(4.06)
 stage.finished=true
 w.boss_step314(.01)
 w.set_process(false)
 var feet:=Vector2(w.hero.global_position.x,w.hero.global_position.z)
 for meteor in [false,true]:
  reset_hit(w)
  var ground:=feet+Vector2(1.3,0.)
  w.add_flight327(ground,0.,1.,0,meteor)
  w.tick_flights327(.99)
  check(w.player_hp==12.,"no damage before impact meteor=%s"%meteor)
  w.tick_flights327(.02)
  check(w.player_hp==10.5 and w.hero.pending_lift332>0.,"full radius evaluated at actual landing meteor=%s"%meteor)
  reset_hit(w)
  for i in 5: w.tick_blasts327(.1)
  check(w.player_hp==12. and w.hero.pending_lift332==0.,"lingering expanding art never hits again meteor=%s"%meteor)
  w.clear_patterns327()
 reset_hit(w)
 var target:=feet+Vector2(3.,0.)
 w.add_flight327(target,0.,1.,0,false)
 w.tick_flights327(1.)
 check(w.player_hp==12.,"outside radius at landing is safe")
 w.hero.global_position=Vector3(target.x,w.floor_height(target),target.y)
 for i in 5: w.tick_blasts327(.1)
 check(w.player_hp==12. and w.hero.pending_lift332==0.,"entering BOOM later stays safe")
 w.clear_patterns327()
 reset_hit(w)
 w.hero.dodge_invulnerability=.2
 w.hero.dash_eligible=true
 var count: int=w.perfect_dodges
 w.add_flight327(target,0.,1.,0,true)
 w.tick_flights327(1.)
 check(w.perfect_dodges==count+1 and w.hero.pending_lift332==0.,"landing still grants perfect dodge")
 w.clear_patterns327()
 w.mortar327(0)
 check(is_equal_approx(w.flights327[1].age,-.85) and w.flights327[0].duration==1.65,"mortar queue denser with unchanged readable flight")
 w.clear_patterns327()
 w.meteor_row327(0)
 check(is_equal_approx(w.flights327[1].age,-1.45) and w.flights327[0].duration==1.4,"meteor queue ordered with unchanged flight")
 w.clear_patterns327()
 w.phase331=1
 w.pattern_left327=0.
 w.tick_pattern327(.01)
 w.tick_pattern327(.46)
 check(w.phase331==2 and is_equal_approx(w.volley_left327,1.25),"scatter faster and phase gap .45 seconds")
 w.restart301()
 check(w.pattern_left327==4.8 and w.volley_left327==.45 and w.blasts327.is_empty(),"restart uses shorter opening and clears blasts")
 print("RESULT failures=",failures)
 quit(failures)
