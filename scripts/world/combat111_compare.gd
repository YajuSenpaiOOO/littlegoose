extends "res://scripts/world/combat111_probe.gd"
func setup(sample: Node3D,ready_key: String) -> void:
 root.add_child(sample)
 while not sample.get(ready_key): await physics_frame
 sample.permit=true;sample.start_combat()
 for enemy in sample.enemies:
  if is_instance_valid(enemy): sample.remove_child(enemy);enemy.queue_free()
 sample.enemies.clear();sample._spawn_wave110(5)
 for enemy in sample.enemies: enemy.max_hp110=1000000.;enemy.hp=1000000.
 sample.weapon_rng.seed=111111;sample.hero.controls_enabled=true;sample._teleport15(sample.meadow.landmarks.grove+Vector2(0,2));await settle72(40)
func build(sample: Node3D,cards: Array) -> void:
 sample._clear_combat_shots();sample.buffs.levels.clear()
 for id in cards: sample.buffs.apply(id)
 sample._apply_owned_buffs();sample.shooting=true;sample.fire_needs_release=false
func compare_measure111(sample: Node3D,tag: String) -> Dictionary:
 var times: Array[float]=[];var previous := Time.get_ticks_usec();var fired: int=sample.fired_count;var peak := 0
 for i in 600:
  var g: Vector2=sample.meadow.landmarks.grove;var wanted := g+Vector2(sin(i*.012)*2.,2.+cos(i*.012))
  sample.hero.wish=(wanted-Vector2(sample.hero.position.x,sample.hero.position.z)).limit_length(1.)
  var target: Vector3=sample.hero.position+Vector3(0,.8,-4.)
  var best := INF
  for enemy in sample.enemies:
   if not is_instance_valid(enemy) or enemy.dead: continue
   var at: Vector3=enemy.hit_area.global_position
   if sample.camera.is_position_in_frustum(at):
    var distance: float=sample.camera.unproject_position(at).distance_squared_to(root.size*.5)
    if distance<best: best=distance;target=at
  root.warp_mouse(sample.camera.unproject_position(target));await process_frame
  var now := Time.get_ticks_usec();times.append((now-previous)/1000.);previous=now;peak=maxi(peak,sample.shots.size())
 times.sort();var result := {"median_ms":times[300],"p95_ms":times[570],"max_ms":times[599],"fired":sample.fired_count-fired,"peak_shots":peak,"frames":600}
 print("COMPARE111 ",tag," ",JSON.stringify(result));return result
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var six := ["forest_fireboy","three_player","eye_exercise","eye_exercise","snack","snack"]
 var data := {}
 var old := Battle110.new();await setup(old,"woodland_ready110");build(old,six);data.old_six=await compare_measure111(old,"110_six_cards");root.remove_child(old);old.queue_free();await settle72(3)
 var sample := Battle111.new();await setup(sample,"woodland_ready111");build(sample,six);data.new_six=await compare_measure111(sample,"111_six_cards")
 build(sample,["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","snack","snack","music_class","music_class","music_class"])
 data.new_max_split=await compare_measure111(sample,"111_all_split_notes")
 build(sample,["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","flashlight"])
 data.new_max_water=await compare_measure111(sample,"111_all_water")
 var file := FileAccess.open("res://docs/combat111-comparison.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("COMPARE111_DONE");quit()
