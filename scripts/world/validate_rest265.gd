extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world265.gd"
 func _init() -> void:
  super._init();memory_save116="user://rest265-validation-preview.cfg"
 func test_config_path226() -> String:return "user://rest265-validation.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func press265(code: int) -> void:
 var event=InputEventKey.new();event.pressed=true;event.physical_keycode=code;w._input(event)
func pointer_error265() -> float:
 var bubble=w.speech112.live
 return (bubble.position+bubble.pointer265*bubble.scale.x).distance_to(bubble.speaker_screen265)
func run() -> void:
 var model=preload("res://scripts/combat/encounter_roster265.gd").new()
 check(model.spawned==3 and not model.needs_entry(3),"three actors open without timed reinforcements")
 model.defeated=1;check(model.needs_entry(2) and model.target==6 and model.wave==1,"first low-count gate queues three rather than one replacement")
 check(not model.needs_entry(4),"early wave stops admitting at four live actors")
 for i in 3:model.entered()
 model.incoming=1;check(not model.needs_entry(2) and model.wave==1,"next batch waits for all prior arrivals to land")
 model.incoming=0;model.retry_left=0.;check(model.needs_entry(2) and model.target==10 and model.wave==2,"second batch grows to four")
 for i in 4:model.entered()
 model.retry_left=0.;check(model.needs_entry(2) and model.target==15 and model.live_cap()==5,"final batch grows to five with bounded climax cap")
 var announced=0
 for i in 5:
  if model.entered():announced+=1
 model.cancelled();model.entered();check(announced==1 and model.spawned==15 and not model.complete(),"replacement never repeats final announcement or counts as a defeat")
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false;w.hero.set_physics_process(false);w.hero.controls_enabled=false
 check(w.live_minions260().size()==3 and w.mode264=="ambient","scene opens with three harmless playing actors")
 check(w.boss247.resting265 and w.boss247.sleeping265 and w.rest_at265.distance_to(w.meadow.landmarks.grove)>=6.5,"sleeping boss waits outside ordinary combat field")
 check(w.boss247.visual.texture.resource_path.ends_with("tuantuan_rest265/sleep.png") and w.boss247.hit_area.collision_layer==0,"new sleep artwork is displayed and cannot be damaged")
 check(w.cushion265.visual.shaded and w.cushion265.visual.billboard==BaseMaterial3D.BILLBOARD_ENABLED and not w.boss247.shadow.visible,"cushion receives light and boss keeps only shared silhouette shadow")
 var path=w.entry_navigation261.path(w.meadow.landmarks.grove,w.rest_at265)
 check(not path.is_empty() and path[-1].distance_to(w.rest_at265)<.8,"rest spot is reachable from the field")
 # Test the low footprint with real physics, from two sides, separately from image outline.
 var collisions=[]
 for direction in [Vector3.RIGHT,Vector3.BACK]:
  var body=CharacterBody3D.new();var hit=CollisionShape3D.new();var shape=CapsuleShape3D.new();shape.radius=.2;shape.height=.9;hit.shape=shape;body.add_child(hit);body.collision_layer=0;body.collision_mask=16;w.add_child(body)
  body.position=w.boss247.position+direction*2.+Vector3.UP*.45
  await physics_frame
  var contact=body.move_and_collide(-direction*2.)
  collisions.append(contact!=null and contact.get_collider()==w.boss247)
  w.remove_child(body);body.queue_free()
 check(collisions.all(func(v):return v),"resting boss physical footprint blocks real bodies from two sides")
 w.hero.position=w.boss247.position+Vector3(2.3,0,0);press265(KEY_E)
 check(not w.dialog264.visible and not w.boss_unlocked264,"sleeping boss cannot be challenged early")
 w.say264("最后几个也跑过来了！");await create_timer(.9).timeout
 check(w.speech112.live.body.text=="最后几个也跑过来了！","speech contains no speaker-name prefix")
 check(pointer_error265()<.01,"bubble tail tip lands on the interpolated goose head")
 w.combat_paused=true;await shot("rest265-sleep");w.combat_paused=false
 w.time55.preview_at(22.);await create_timer(.6).timeout;w.combat_paused=true;await shot("rest265-night");w.combat_paused=false;w.time55.preview_at(12.)
 w.set_physics_process(false)
 var old=w.speech112.live.speaker_screen265;w.goose.position+=Vector3(.7,0,0);w.goose.reset_physics_interpolation();w.goose.visual.reset_physics_interpolation();await settle(2);w.speech112.live._process(0.)
 check(pointer_error265()<.01 and old.distance_to(w.speech112.live.speaker_screen265)>5.,"tail follows speaker motion without fixed-corner lag")
 w.set_physics_process(true)
 w.hero.position=Vector3(w.meadow.landmarks.grove.x,w.floor_height(w.meadow.landmarks.grove)+.03,w.meadow.landmarks.grove.y+3.);press265(KEY_E)
 check(w.mode264=="ordinary" and w.roster264.spawned==3 and w.enemies.size()==3,"ordinary encounter starts with all three original actors")
 var waiting=w.live_minions260();waiting[0].receive_hit(100.,Vector3.RIGHT)
 var deadline=Time.get_ticks_msec()+7000
 while w.live_minions260().size()<4 and Time.get_ticks_msec()<deadline:await process_frame
 check(w.live_minions260().size()==4 and w.roster264.spawned<6,"first batch can hold four live actors without dumping entire queue")
 var max_alive=w.live_minions260().size();var pictured=false;var defeat_wait=0.;deadline=Time.get_ticks_msec()+80000
 while w.mode264=="ordinary" and Time.get_ticks_msec()<deadline:
  await physics_frame;max_alive=maxi(max_alive,w.live_minions260().size());defeat_wait+=1./60.
  if w.roster264.final_called and not pictured:
   await create_timer(2.2).timeout;max_alive=maxi(max_alive,w.live_minions260().size());w.combat_paused=true;await shot("rest265-final-wave");w.combat_paused=false;pictured=true
  var grounded=w.live_minions260().filter(func(m):return m.state260=="ground")
  if not grounded.is_empty() and defeat_wait>.7:grounded[0].receive_hit(100.,Vector3.RIGHT);defeat_wait=0.
 check(w.mode264=="ready" and w.roster264.defeated==15 and max_alive==5,"all fifteen finish across four batches with maximum five live")
 check(w.awake265 and not w.boss247.sleeping265 and w.boss247.position.distance_to(Vector3(w.rest_at265.x,w.floor_height(w.rest_at265)+.03,w.rest_at265.y))<.01,"clear wakes boss at its cushion rather than moving it into the field")
 metrics.ordinary=w.last_ordinary264;metrics.max_alive=max_alive;metrics.rest_at=[w.rest_at265.x,w.rest_at265.y]
 w.hero.position=w.boss247.position+Vector3(2.3,0,0);press265(KEY_E)
 check(not w.dialog264.visible,"waking animation finishes before challenge dialogue is available")
 await create_timer(1.).timeout;press265(KEY_E)
 check(w.dialog264.visible and not w.active114 and w.boss247.visual.texture.resource_path.ends_with("idle_front_v1.png"),"awake boss offers independent dialogue with normal species appearance")
 w.cancel_dialog264();w.combat_paused=true;await shot("rest265-awake");w.combat_paused=false
 press265(KEY_E);w.confirm264()
 check(w.mode264=="boss" and not w.boss247.resting265 and w.boss247.is_physics_processing() and w.boss247.hp==90.,"challenge reconstructs unchanged combat boss in its arena")
 w.boss247.set_physics_process(false);w.finish251(false)
 check(w.boss247.resting265 and not w.boss247.sleeping265 and w.boss_unlocked264,"boss failure returns NPC to cushion and preserves retry qualification")
 w.cancel_dialog264();press265(KEY_F8)
 check(w.live_minions260().size()==3 and w.boss247.resting265 and w.boss_unlocked264,"ordinary replay keeps boss away from the combat field")
 check(w.get_children().filter(func(n):return n is CharacterBody3D and n.get_script()==w.boss_script251()).size()==1 and w.get_children().filter(func(n):return n.get_script()==preload("res://scripts/art/rest_cushion265.gd")).size()==1,"replays retain exactly one boss and one cushion")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/rest265-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("REST265_VALIDATION ",ok," checks=",checks.size()," metrics=",metrics);quit(0 if ok else 1)
