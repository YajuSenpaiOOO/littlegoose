extends "res://scripts/world/combat111_probe.gd"
func measure110(sample: Node3D,tag: String,frames := 600) -> Dictionary:
 var start := Time.get_ticks_usec();var previous := start;var times: Array[float]=[];var slow := 0;var peak := 0;var peak_fx := 0
 var fires: int=sample.fired_count;var reuses: int=sample.pool110.reused;var births: int=sample.pool110.births
 for i in frames:
  var g: Vector2=sample.meadow.landmarks.grove
  var target := g+Vector2(sin(i*.012)*3.,2.+cos(i*.012)*1.4)
  sample.hero.wish=(target-Vector2(sample.hero.position.x,sample.hero.position.z)).limit_length(1.)
  if tag=="held_guard": sample.hero.button=true
  if tag=="charged_water_jet" and i%120==0: sample._release_charged(sample.hero.position+Vector3(0,.8,-6),1.)
  var aim: Vector3=sample.hero.position+Vector3(0,.8,-8.)
  for enemy in sample.enemies:
   if is_instance_valid(enemy) and not enemy.dead: aim=enemy.position+Vector3.UP*.8;break
  root.warp_mouse(sample.camera.unproject_position(aim));await process_frame
  var now := Time.get_ticks_usec();var ms := (now-previous)/1000.;previous=now;times.append(ms)
  if ms>33.333: slow+=1
  peak=maxi(peak,sample.shots.size());peak_fx=maxi(peak_fx,sample.jelly_fx.bits.size())
 sample.hero.wish=Vector2.ZERO;sample.hero.button=false;times.sort()
 var data := {"frames":frames,"seconds":(Time.get_ticks_usec()-start)/1000000.,"median_ms":times[frames/2],"p95_ms":times[int(frames*.95)],"p99_ms":times[int(frames*.99)],"max_ms":times[-1],"over33":slow,"fired":sample.fired_count-fires,"peak_shots":peak,"peak_bits":peak_fx,"projectile_new":sample.pool110.births-births,"projectile_reuses":sample.pool110.reused-reuses,"idle_pool":sample.pool110.nodes.size(),"grid_skipped":sample.grid111.skipped,"grid_native":sample.grid111.native,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
 print("PROFILE111 ",tag," ",JSON.stringify(data));return data
func build110(sample: Node3D,cards: Array) -> void:
 sample._clear_combat_shots();sample.buffs.levels.clear()
 for id in cards: sample.buffs.apply(id)
 sample._apply_owned_buffs();sample.hero.button=false;sample.hero.reset_actions()
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var sample := Battle111.new();root.add_child(sample)
 while not sample.woodland_ready111: await physics_frame
 sample.permit=true;sample.start_combat()
 for enemy in sample.enemies:
  if is_instance_valid(enemy): sample.remove_child(enemy);enemy.queue_free()
 sample.enemies.clear();sample._spawn_wave110(5)
 for enemy in sample.enemies: enemy.max_hp110=1000000.;enemy.hp=1000000.
 sample.hero.controls_enabled=true;sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look();sample._teleport15(sample.meadow.landmarks.grove+Vector2(0,3));await settle72(80)
 var data := {"resolution":str(root.size),"enemies":sample.enemies.size(),"ordinary_elite_king":true}
 sample.shooting=true;data.normal=await measure110(sample,"normal")
 build110(sample,["paper_racer"]);data.guard=await measure110(sample,"held_guard",400)
 build110(sample,["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","snack","snack","music_class","music_class","music_class"])
 data.notes_split_swarm=await measure110(sample,"four_geese_three_lanes_split_notes")
 build110(sample,["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","flashlight"])
 data.continuous_water=await measure110(sample,"four_geese_three_lanes_water")
 sample.buffs.apply("slingshot");sample._apply_owned_buffs();sample.shooting=false
 data.charged_water=await measure110(sample,"charged_water_jet")
 sample.label.get_parent().hide();sample.frames66.panel.hide();sample.time55.guide.hide()
 sample._release_charged(sample.hero.position+Vector3(0,.8,-7),1.);await settle72(30)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/combat111_water_swarm.png")
 var file := FileAccess.open("res://docs/combat111-profile.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("PROFILE111_DONE");quit()
