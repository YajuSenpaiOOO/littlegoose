extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world264.gd"
 var protect264 := true
 func _init() -> void:
  super._init();memory_save116="user://encounter264-validation-preview.cfg"
 func test_config_path226() -> String:return "user://encounter264-validation.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(damage: float,from: Vector2) -> void:
  if not protect264:super.hurt_player(damage,from)
func press264(code: int) -> void:
 var event=InputEventKey.new();event.pressed=true;event.physical_keycode=code;w._input(event)
func run() -> void:
 var model=preload("res://scripts/combat/encounter_roster264.gd").new()
 check(not model.complete() and not model.needs_entry(2),"fixed six-member roster begins with only two field actors")
 model.defeated=1;check(model.needs_entry(1) and not model.needs_entry(3),"first defeat enables entries without exceeding live cap")
 model.entered();model.cancelled();check(model.spawned==2 and not model.complete(),"cancelled arrival remains queued rather than counting as a defeat")
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false;w.hero.set_physics_process(false);w.hero.controls_enabled=false
 var gel=w.memory_kit116.gel119
 check(w.mode264=="ambient" and not w.active114 and w.live_minions260().size()==2 and not w.boss_unlocked264,"preview opens with two playing tuantuans and a locked passive boss")
 check(w.boss247 not in w.enemies and w.boss247.hit_area.collision_layer==0 and not w.boss247.is_physics_processing(),"passive boss cannot be attacked or attack during ordinary encounter")
 var actors=w.live_minions260();var positions=actors.map(func(m):return m.position)
 await create_timer(1.5).timeout
 check(actors[0].position.distance_to(positions[0])>.02 or actors[1].position.distance_to(positions[1])>.02,"ambient actors actually hop and play before combat")
 check(actors.all(func(m):return not m.targetable260() and m.hit_area.collision_layer==0),"playing actors remain harmless and untargetable")
 w.combat_paused=true;await shot("encounter264-playing");w.combat_paused=false
 # Locked boss interaction cannot start boss or skip the ordinary battle.
 w.hero.position=w.boss247.position+Vector3(0,0,1.);press264(KEY_E)
 check(w.mode264=="ambient" and not w.dialog264.visible and not w.boss_unlocked264,"locked boss interaction cannot bypass qualification")
 w.hero.position=Vector3(w.meadow.landmarks.grove.x,w.floor_height(w.meadow.landmarks.grove)+.03,w.meadow.landmarks.grove.y+3.)
 var before_positions=actors.map(func(m):return m.position)
 press264(KEY_E)
 check(w.mode264=="ordinary" and w.active114 and w.enemies.size()==2,"E starts ordinary fight with the existing two actors")
 check(actors[0].position==before_positions[0] and actors[1].position==before_positions[1],"starting combat does not replace or teleport ambient tuantuans")
 w.finish_ordinary264(true);check(w.mode264=="ordinary" and not w.boss_unlocked264,"incomplete roster cannot falsely clear or unlock boss")
 w.set_physics_process(false);w.combat_paused=true
 var seconds=w.roster264.seconds;var time=w.speech112.live.age
 await create_timer(.2).timeout
 check(w.roster264.seconds==seconds and w.speech112.live.age==time,"pause freezes ordinary pacing and the goose speech bubble")
 w.combat_paused=false;w.set_physics_process(true)
 # Kill via native receive_hit; actual route physics admits all reinforcements.
 var first=actors[0];first.receive_hit(100.,Vector3.RIGHT)
 check(w.roster264.defeated==1 and w.mode264=="ordinary","one real defeat advances roster but does not clear encounter")
 var deadline=Time.get_ticks_msec()+6000
 while w.roster264.spawned<3 and Time.get_ticks_msec()<deadline:await process_frame
 var entering=w.live_minions260().filter(func(m):return m.state260 in ["rustle","arrive"])
 check(not entering.is_empty(),"first reinforcements use the real perimeter arrival states")
 if not entering.is_empty():
  var spawned=w.roster264.spawned;w.cancel_entry261(entering[0]);check(w.roster264.spawned==spawned-1 and not w.boss_unlocked264,"blocked entrance is replaced without granting free progression")
 var max_alive=0;var routes=0;var final_bubble=false;var pictured=false;var shoot_wait=0.;deadline=Time.get_ticks_msec()+40000
 while w.mode264=="ordinary" and Time.get_ticks_msec()<deadline:
  await physics_frame
  max_alive=maxi(max_alive,w.live_minions260().size())
  final_bubble=final_bubble or w.speech112.history.any(func(h):return h.text=="最后几个也跑过来了！" and h.anchor==w.goose.get_instance_id())
  if not pictured and final_bubble and is_instance_valid(w.speech112.live) and w.speech112.live.words=="最后几个也跑过来了！":
   await create_timer(1.05).timeout;w.combat_paused=true;await shot("encounter264-last-entry");w.combat_paused=false;pictured=true
  var grounded=w.live_minions260().filter(func(m):return m.state260=="ground")
  shoot_wait+=1./60.
  if not grounded.is_empty() and shoot_wait>.75:
   var target=grounded[0];target.receive_hit(100.,Vector3.RIGHT);shoot_wait=0.
  routes=w.telemetry260.data.events.filter(func(e):return e.kind=="entry_complete").size()
 check(w.mode264=="ready" and w.roster264.defeated==6 and w.boss_unlocked264,"all six native defeats finish ordinary encounter and unlock boss")
 check(max_alive<=3 and routes>=4,"live cap holds while all four reinforcements traverse actual routes")
 check(final_bubble and w.roster264.final_called,"last reinforcement announcement is spoken by the main black goose")
 check(not w.active114 and w.enemies.is_empty() and w.live_minions260().is_empty() and w.player_hp==12.,"clear leaves breathing room, restores determination and does not auto-start boss")
 check(w.memory_kit116.gel119==gel,"preview clear does not accidentally issue old formal material rewards")
 metrics.ordinary=w.last_ordinary264.duplicate(true);metrics.max_alive=max_alive;metrics.entry_completions=routes
 await create_timer(1.2).timeout
 w.combat_paused=true;await shot("encounter264-clear");w.combat_paused=false
 # Challenge can be postponed, then confirmed independently.
 w.hero.position=w.boss247.position+Vector3(0,0,1.);press264(KEY_E)
 check(w.dialog264.visible and w.combat_paused and w.mode264=="ready","nearby E opens boss challenge dialogue without immediately fighting")
 await shot("encounter264-dialogue")
 w.cancel_dialog264();check(not w.active114 and w.boss_unlocked264 and not w.combat_paused,"declining preserves qualification and free movement")
 press264(KEY_E);w.confirm264()
 check(w.mode264=="boss" and w.active114 and w.boss247 in w.enemies and w.boss247.is_physics_processing() and w.player_hp==12.,"confirm starts unchanged boss fight with full determination")
 var b=w.boss247;b.set_physics_process(false)
 w.finish251(false)
 check(w.mode264=="boss_failed" and w.boss_unlocked264 and w.dialog264.visible,"boss failure retains qualification and offers direct retry")
 w.confirm264();check(w.mode264=="boss" and w.active114 and w.live_minions260().is_empty(),"boss retry skips ordinary encounter and preserves solo boss opening")
 check(w.get_children().filter(func(n):return n is CharacterBody3D and n.get_script()==w.boss_script251()).size()==1,"passive NPC is reclaimed before each boss retry")
 w.boss247.set_physics_process(false);w.finish251(true)
 check(w.mode264=="won" and w.boss_unlocked264 and not w.active114,"boss victory leaves independent replay interaction")
 press264(KEY_F8);check(w.mode264=="ambient" and w.live_minions260().size()==2 and w.boss_unlocked264,"F8 returns to playing opening while keeping earned qualification")
 check(w.get_children().filter(func(n):return n is CharacterBody3D and n.get_script()==w.boss_script251()).size()==1,"returning to ambient opening leaves exactly one boss actor")
 w.ordinary264();w.finish251(false)
 check(w.mode264=="ordinary_failed" and w.dialog264.visible,"ordinary failure offers its own retry")
 w.confirm264();check(w.mode264=="ordinary" and w.roster264.defeated==0 and w.roster264.spawned==2,"ordinary retry resets six-member roster cleanly")
 # A fresh unqualified attempt must never unlock on death.
 w.boss_unlocked264=false;w.protect264=false;w.invulnerability=0.;w.parry_grace258=0.;w.hero.reset_actions()
 w.hurt_player(100.,Vector2(w.hero.position.x,w.hero.position.z))
 await settle(3)
 check(w.mode264=="ordinary_failed" and not w.boss_unlocked264,"actual player defeat cannot unlock boss")
 w.cancel_dialog264();check(w.mode264=="ambient" and w.player_hp==12. and not w.dialog264.visible,"rest after failed ordinary fight restores the safe opening")
 var report=w.report_stats226();check(report.has("encounter264") and report.encounter264.progress_scope=="current preview session","record distinguishes ordinary progression from formal save progress")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/encounter264-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("ENCOUNTER264_VALIDATION ",ok," checks=",checks.size()," metrics=",metrics);quit(0 if ok else 1)
