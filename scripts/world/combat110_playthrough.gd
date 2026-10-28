extends "res://scripts/world/combat110_probe.gd"
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var sample := Battle110.new();root.add_child(sample)
 while not sample.woodland_ready110: await physics_frame
 sample.permit=true;sample.start_combat();sample.hero.controls_enabled=true;sample.shooting=true;sample.fire_needs_release=false
 var start := Time.get_ticks_msec();var frames := 0;var rewards := 0;var seen := {};var costs: Array[float]=[];var previous := Time.get_ticks_usec()
 while Time.get_ticks_msec()-start<240000 and not (sample.wave_state=="cleared" and rewards==6):
  var time := (Time.get_ticks_msec()-start)/1000.;var g: Vector2=sample.meadow.landmarks.grove
  var wanted := g+Vector2(cos(time*.35)*3.,sin(time*.35)*2.5)
  sample.hero.wish=(wanted-Vector2(sample.hero.position.x,sample.hero.position.z)).limit_length(1.)
  var aimed := false
  for enemy in sample.enemies:
   if is_instance_valid(enemy) and not enemy.dead:
    seen[enemy.rank110]=true
    if not aimed: root.warp_mouse(sample.camera.unproject_position(enemy.hit_area.global_position));aimed=true
  if sample.draft_open:
   var pick := 0
   for wanted_id in ["eye_exercise","music_class","forest_fireboy","distract","red_banner","paper_racer","cup_phone"]:
    var found := false
    for i in sample.draft_choices.size():
     if sample.draft_choices[i].id==wanted_id: pick=i;found=true;break
    if found: break
   sample.shooting=false
   if sample.choose_buff(pick): rewards+=1;print("PLAY110_REWARD ",rewards," kills=",sample.defeated_count)
   await settle72(2)
   sample.shooting=true
  await process_frame;var now := Time.get_ticks_usec();costs.append((now-previous)/1000.);previous=now;frames+=1
 costs.sort()
 var data := {"kills":sample.defeated_count,"rewards":rewards,"seen_ranks":seen.keys(),"fired":sample.fired_count,"landed_hits":sample.landed_hits,"seconds":(Time.get_ticks_msec()-start)/1000.,"frames":frames,"median_ms":costs[frames/2],"p95_ms":costs[int(frames*.95)],"state":sample.wave_state,"cards":sample.buffs.summary()}
 var success: bool=sample.wave_state=="cleared" and sample.defeated_count==34 and rewards==6 and seen.size()==3 and sample.landed_hits>0
 var file := FileAccess.open("res://docs/combat110-playthrough.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("PLAYTHROUGH110 ",JSON.stringify(data));quit(0 if success else 1)
