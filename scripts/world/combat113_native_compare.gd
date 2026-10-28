extends "res://scripts/world/combat113_compare.gd"
func measure113(sample: Node3D,tag: String) -> Dictionary:
 var times: Array[float]=[];var previous := Time.get_ticks_usec();var fired: int=sample.fired_count;var peak := 0
 for i in 300:
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
 times.sort();var result := {"median_ms":times[150],"p95_ms":times[285],"max_ms":times[299],"fired":sample.fired_count-fired,"peak_shots":peak,"frames":300}
 print("COMPARE111 ",tag," ",JSON.stringify(result));return result
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var s := Battle113.new();await setup(s,"woodland_ready113");var data := {}
 build(s,["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","snack","snack","music_class","music_class","music_class"])
 for i in 4:
  s.use_native113=i==1 or i==2
  data[str(i)]=await measure113(s,"native="+str(s.use_native113))
 var file := FileAccess.open("res://docs/combat113-native-abba.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));quit()
