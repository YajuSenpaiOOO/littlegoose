extends "res://scripts/world/woodland108_probe.gd"
class Lean105:
 extends "res://scripts/world/woodland_world108.gd"
 var shooting := false
 var allow_battle := false
 var rate_scale := 1.
 var extra_impacts := false
 var extra_clock := 0.
 var physics_ticks105 := 0
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return shooting
 func attack_cooldown() -> float: return super.attack_cooldown()/rate_scale
 func projectile_damage() -> float: return .001
 func start_combat(reposition := true) -> void:
  if allow_battle: super.start_combat(reposition)
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at);player_hp=100.
 func _physics_process(delta: float) -> void:
  super._physics_process(delta);physics_ticks105+=1
 func _process(delta: float) -> void:
  super._process(delta)
  if not extra_impacts or not woodland_ready105: return
  extra_clock+=delta
  if extra_clock>=.1:
   extra_clock=0.
   var at := hero.position+Vector3(1.,.65,-1.)
   jelly_fx.burst(at,Vector3.RIGHT,false);jelly_fx.break_sugar(at,Vector3.RIGHT)
func measure105(sample: Node3D,tag: String,frames := 900) -> Dictionary:
 var previous := Time.get_ticks_usec();var started := previous;var times: Array[float]=[]
 var initial: int=sample.fired_count;var hits: int=sample.landed_hits;var physics: int=sample.physics_ticks105
 var cache_hits: int=sample.floor_hits105;var cache_misses: int=sample.floor_misses105
 var peaks := Vector4i.ZERO;var slow := 0
 for i in frames:
  var g: Vector2=sample.meadow.landmarks.grove;var target: Vector2=g+sample.PARK99.BENCH+Vector2(sin(i*.012)*1.4,2.3+cos(i*.012)*.9)
  sample.hero.wish=(target-Vector2(sample.hero.position.x,sample.hero.position.z)).limit_length(1.)
  var aim: Vector3=sample.hero.position+Vector3(0,1.,-6.)
  for enemy in sample.enemies:
   if is_instance_valid(enemy) and not enemy.dead: aim=enemy.position+Vector3.UP*.75;break
  root.warp_mouse(sample.camera.unproject_position(aim));await process_frame
  var now := Time.get_ticks_usec();var ms := (now-previous)/1000.;times.append(ms);previous=now
  if ms>33.333: slow+=1
  peaks.x=maxi(peaks.x,sample.shots.size());peaks.y=maxi(peaks.y,sample.jelly_fx.bits.size());peaks.z=maxi(peaks.z,sample.jelly_fx.drops.size());peaks.w=maxi(peaks.w,sample.anchors.size())
 times.sort();sample.hero.wish=Vector2.ZERO
 var data := {"frames":frames,"seconds":(Time.get_ticks_usec()-started)/1000000.,"median_ms":times[frames/2],"p95_ms":times[int(frames*.95)],"p99_ms":times[int(frames*.99)],"max_ms":times[-1],"over33":slow,"fired":sample.fired_count-initial,"hits":sample.landed_hits-hits,"physics_ticks":sample.physics_ticks105-physics,"peak_shots_bits_drops_anchors":str(peaks),"cache_hits":sample.floor_hits105-cache_hits,"cache_misses":sample.floor_misses105-cache_misses,"cache_size":sample.floor_recent105.size()+sample.floor_previous105.size(),"gpu_ms":RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid()),"active_lamp_shadows":sample.lamps106.active_shadows108,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
 print("STRESS105 ",tag," ",JSON.stringify(data));return data
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 var sample := Lean105.new();root.add_child(sample)
 while not sample.woodland_ready108: await physics_frame
 await settle72(30);sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample.allow_battle=true;sample.start_combat(true);sample.round_index=1;sample._spawn_next_round();sample.hero.controls_enabled=true;await settle72(80)
 var data := {"backend":ProjectSettings.get_setting("physics/3d/physics_engine"),"resolution":str(root.size),"enemy_count":sample.enemies.size()}
 sample.shooting=true
 sample._teleport15(sample.meadow.landmarks.grove+sample.PARK99.BENCH+Vector2(-1,2.8));sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 for enabled in [false,true,true,false]:
  sample.lamps106.shadows_enabled108=enabled;sample.lamps106.update106();sample.hero.controls_enabled=true;await settle72(60)
  var tag := "night_shadow_"+str(enabled)+"_"+str(data.size())
  # Move around the lamp, not across the central clearing.
  data[tag]=await measure105(sample,tag,600)
 sample.lamps106.shadows_enabled108=true;sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 data.noon=await measure105(sample,"noon_continuous_fire",600)
 var file := FileAccess.open("res://docs/woodland108-profile.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("PROFILE108_DONE");quit()
