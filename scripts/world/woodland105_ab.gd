extends "res://scripts/world/woodland104_ab.gd"
class Cost105:
 extends "res://scripts/world/woodland_world105.gd"
 var timing := false
 var totals: Dictionary={}
 var rate_scale := 1.
 var shooting := false
 var allow_battle := false
 func _hero_script() -> Script: return LivingActor
 func start_combat(reposition := true) -> void:
  if allow_battle: super.start_combat(reposition)
 func fire_input_held() -> bool: return shooting
 func attack_cooldown() -> float: return super.attack_cooldown()/rate_scale
 func projectile_damage() -> float: return .001
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at);player_hp=100.
 func sum105(key: String,start: int) -> void:
  var value: Vector3=totals.get(key,Vector3.ZERO);var elapsed := Time.get_ticks_usec()-start
  totals[key]=Vector3(value.x+elapsed,value.y+1,maxf(value.z,elapsed))
 func _process(delta: float) -> void:
  var t := Time.get_ticks_usec()
  super._process(delta)
  if timing: sum105("_process",t)
 func _physics_process(delta: float) -> void:
  var t := Time.get_ticks_usec()
  super._physics_process(delta)
  if timing: sum105("_physics_process",t)
 func _step_shots(delta: float) -> void:
  var t := Time.get_ticks_usec()
  super._step_shots(delta)
  if timing: sum105("_step_shots",t)
 func _update_forest_occlusion(delta: float) -> void:
  var t := Time.get_ticks_usec()
  super._update_forest_occlusion(delta)
  if timing: sum105("_update_forest_occlusion",t)
 func floor_height(at: Vector2) -> float:
  var t := Time.get_ticks_usec()
  var result: float=super.floor_height(at)
  if timing: sum105("floor_height",t)
  return result
 func aim_at_screen(point: Vector2) -> Vector3:
  var t := Time.get_ticks_usec()
  var result: Vector3=super.aim_at_screen(point)
  if timing: sum105("aim_at_screen",t)
  return result
 func fire_at(target: Vector3) -> void:
  var t := Time.get_ticks_usec()
  super.fire_at(target)
  if timing: sum105("fire_at",t)
 func legacy_trace(start: Vector3,end: Vector3) -> Dictionary:
  var t := Time.get_ticks_usec()
  var result: Dictionary=super.legacy_trace(start,end)
  if timing: sum105("legacy_trace",t)
  return result
 func _fit_contact(mark: Node3D,at: Vector3,lift: float) -> void:
  var t := Time.get_ticks_usec()
  super._fit_contact(mark,at,lift)
  if timing: sum105("_fit_contact",t)
 func legacy_contact_art(at: Vector3,direction: Vector3,juice: bool,finishing := false) -> void:
  var t := Time.get_ticks_usec()
  super.legacy_contact_art(at,direction,juice,finishing)
  if timing: sum105("legacy_contact_art",t)

func take105(sample: Node3D,tag: String,shoot := false,rate := 1.,frames := 600) -> Dictionary:
 sample.shooting=shoot;sample.rate_scale=rate;sample.totals.clear();sample.timing=true
 var previous := Time.get_ticks_usec();var times: Array[float]=[];var max_shots := 0;var max_anchors := 0;var initial: int=sample.fired_count
 for i in frames:
  var g: Vector2=sample.meadow.landmarks.grove
  var target := g+Vector2(sin(i*.012)*4.,4.+cos(i*.012)*2.)
  sample.hero.wish=(target-Vector2(sample.hero.position.x,sample.hero.position.z)).limit_length(1.)
  var aim: Vector3=sample.hero.position+Vector3(0,1.,-6.)
  for enemy in sample.enemies:
   if is_instance_valid(enemy) and not enemy.dead: aim=enemy.position+Vector3.UP*.75;break
  root.warp_mouse(sample.camera.unproject_position(aim))
  await process_frame
  var now := Time.get_ticks_usec();times.append((now-previous)/1000.);previous=now
  max_shots=maxi(max_shots,sample.shots.size());max_anchors=maxi(max_anchors,sample.anchors.size())
 sample.hero.wish=Vector2.ZERO;sample.timing=false;sample.shooting=false;times.sort()
 var methods := {}
 for key in sample.totals:
  var v: Vector3=sample.totals[key];methods[key]={"total_ms":v.x/1000.,"calls":v.y,"ms_per_call":v.x/maxf(1.,v.y)/1000.,"max_ms":v.z/1000.}
 var data := {"median_ms":times[frames/2],"p95_ms":times[int(frames*.95)],"p99_ms":times[int(frames*.99)],"max_ms":times[-1],"fired":sample.fired_count-initial,"peak_shots":max_shots,"peak_anchors":max_anchors,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"methods":methods}
 print("REAL105 ",tag," ",JSON.stringify(data));return data
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var sample := Cost105.new();root.add_child(sample)
 while not sample.woodland_ready104: await physics_frame
 await settle72(30);sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample.allow_battle=true;sample.start_combat(true);sample.round_index=1;sample._spawn_next_round()
 for enemy in sample.enemies:
  if is_instance_valid(enemy): enemy.hp=12.
 sample.hero.controls_enabled=true;await settle72(80)
 var data := {}
 for state in [false,true]:
  sample.combat_budget105=state;await settle72(15)
  var tag := "new" if state else "old"
  data[tag+"_ai"]=await take105(sample,tag+"_ai",false,1.,300)
  data[tag+"_fire"]=await take105(sample,tag+"_fire",true,1.,300)
  data[tag+"_rate8"]=await take105(sample,tag+"_rate8",true,8.,300)
 var file := FileAccess.open("res://docs/woodland105-ab.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("REAL105_DONE");quit()
