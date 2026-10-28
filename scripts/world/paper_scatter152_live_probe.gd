extends "res://scripts/world/paper_scatter152_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial152.new();s.memory_save116="user://scatter152_live_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.trial152=true;s.paper_trial129=false;s.start_combat();s.hero.controls_enabled=true
 var next: int=s.memory_kit116.next_event119;var gel: int=s.memory_kit116.gel119
 var reports: Array=[]
 for mode in [true,false]:
  s.scatter152=mode;s.build152=0;s.apply_paper_build129()
  for frame in 660:
   if frame<480 and frame%72==0:
    var center := Vector3.ZERO;var count := 0
    for enemy in s.enemies:
     if is_instance_valid(enemy) and not enemy.dead: center+=enemy.global_position;count+=1
    if count>0:
     center/=float(count);center.y=s.floor_height(Vector2(center.x,center.z))+.05;s.fire_at(center)
   await settle72(1)
   if frame==300: await capture152("live_random" if mode else "live_assisted")
  reports.append({"random":mode,"damage":s.damage152,"hits":s.hits152,"kills":s.kills152})
  verify(s.hits152>0,"random nine-shot pattern lands hits with native Tuantuan AI active" if mode else "assisted six-shot pattern lands hits with native Tuantuan AI active")
 verify(s.memory_kit116.next_event119==next and s.memory_kit116.gel119==gel,"live practice does not grant materials or advance event progression")
 var report := {"checks":checks,"failures":failures,"live_encounter":reports,"note":"Sequential smoke test in one live encounter, not matched balance samples; player is invulnerable for observation."}
 FileAccess.open("res://docs/paper-scatter152-live-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("PAPER_SCATTER152_LIVE_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
