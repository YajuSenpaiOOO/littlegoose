extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world336.gd"
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
 w.clear_patterns327()
 w.mortar327(0)
 check(w.flights327.map(func(f): return f.source)==[0,1,0],"mortar alternates available cannons")
 var original: Vector2=w.centre301+Vector2(0.,5.)
 w.hero.global_position=Vector3(original.x,w.floor_height(original),original.y)
 w.tick_flights327(.01)
 check(w.attack_sources336==[1,0],"only actual first launch counted")
 var first: Dictionary=w.flights327[0]
 check(first.at.distance_to(original)<.001 and first.get("locked336",false),"first shell locks actual launch position")
 var moved: Vector2=w.centre301+Vector2(2.,6.)
 w.hero.global_position=Vector3(moved.x,w.floor_height(moved),moved.y)
 w.tick_flights327(.85)
 check(w.attack_sources336==[1,1],"second launch credited to right cannon")
 var second: Dictionary=w.flights327[1]
 check(second.at.distance_to(moved)<.001,"second shell independently targets later position")
 check(first.at.distance_to(original)<.001,"airborne first shell never retargets")
 var third_at: Vector2=w.centre301+Vector2(-2.,7.)
 w.hero.global_position=Vector3(third_at.x,w.floor_height(third_at),third_at.y)
 w.tick_flights327(.85)
 var third: Dictionary=w.flights327.back()
 check(third.at.distance_to(third_at)<.001,"third shell independently targets third position")
 w.clear_patterns327()
 w.attack_sources336.fill(0)
 w.cannon_index326=0
 for phase in [0,1,4,0,1,4]:
  w.phase331=phase
  w.pattern_left327=3.
  w.pattern_started327=false
  w.volley_left327=0.
  w.tick_pattern327(.01)
  w.clear_patterns327()
 check(w.attack_sources336==[3,3],"special attacks share primary duty evenly")
 w.cannon_hp326[0]=0.
 w.phase331=0
 w.pattern_started327=false
 w.volley_left327=0.
 w.tick_pattern327(.01)
 check(w.heavies330[0].source==1,"disabled cannon falls back to live peer")
 w.clear_patterns327()
 w.heavy_bag336.assign([3,4])
 w.last_heavy_phase336=0
 w.phase331=0
 var last_heavy:=0
 var alternates:=true
 var no_repeat:=true
 var collected: Array[int]=[]
 w.phase_rng336.seed=42
 for i in 18:
  var previous: int=w.phase331
  w.phase331=w.next_phase336()
  if (previous in [0,3,4])==(w.phase331 in [0,3,4]): alternates=false
  if w.phase331 in [0,3,4]:
   if last_heavy==w.phase331: no_repeat=false
   last_heavy=w.phase331
   collected.append(w.phase331)
 check(alternates,"normal phases separate all heavy attacks")
 check(no_repeat and collected.has(0) and collected.has(3) and collected.has(4),"shuffle bag covers heavy types without immediate repeat")
 w.restart301()
 check(w.attack_sources336==[0,0] and w.heavy_bag336==[3,4] and w.cannon_hp326==[16.,16.],"restart clears schedule and counters")
 print("RESULT failures=",failures)
 quit(failures)
