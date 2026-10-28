extends "res://scripts/world/combat114_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var s := Trial.new();root.add_child(s)
 while not s.woodland_ready114: await physics_frame
 s.begin114(true);var started := Time.get_ticks_msec();var frames: Array[float]=[];var previous := Time.get_ticks_usec();var peak := 0
 while s.active114 and Time.get_ticks_msec()-started<65000:
  var t: float=s.elapsed114;var g: Vector2=s.meadow.landmarks.grove
  var wanted := g+Vector2(sin(t*.6)*2.2,2.+cos(t*.6)*1.1)
  s.hero.wish=(wanted-Vector2(s.hero.position.x,s.hero.position.z)).limit_length(1.)
  await process_frame
  var now := Time.get_ticks_usec();frames.append((now-previous)/1000.);previous=now;peak=maxi(peak,s.shots.size())
 verify(not s.active114 and s.trial_ui114.menu.visible,"live enemy trial finishes normally within its time limit")
 verify(s.packs114>=2 and s.defeated_count>=3 and s.landed_hits>=12,"automatic firing defeats actual moving enemies and refills the pack")
 verify(s.buffs.levels.is_empty() and not s.draft_open,"live trial never introduces cards")
 frames.sort();var data := {"checks":checks,"failures":failures,"packs":s.packs114,"kills":s.defeated_count,"hits":s.landed_hits,"shots":s.fired_count,"hurt":s.hurt_count,"seconds":s.elapsed114,"median_ms":frames[frames.size()/2],"p95_ms":frames[int(frames.size()*.95)],"max_ms":frames[-1],"peak_shots":peak,"spawn_max_ms":s.spawn_max_us114/1000.}
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/trial114_live_results.png")
 var file := FileAccess.open("res://docs/combat114-live-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("TRIAL114_LIVE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
