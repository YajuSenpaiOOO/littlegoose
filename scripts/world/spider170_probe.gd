extends SceneTree
var checks := 0
var failures: Array[String]=[]
func _initialize() -> void: call_deferred("run")
func verify(ok: bool,label: String) -> void:
 checks+=1
 if not ok: failures.append(label);push_error(label)
 else: print("PASS ",label)
func settle(frames := 3) -> void:
 for i in frames: await physics_frame
func capture(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/spider170_"+tag+".png")
func key(code: Key) -> void:
 var event := InputEventKey.new();event.physical_keycode=code;event.pressed=true;Input.parse_input_event(event);await process_frame
 event=InputEventKey.new();event.physical_keycode=code;event.pressed=false;Input.parse_input_event(event);await process_frame
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := preload("res://scripts/world/woodland_world170.gd").new()
 s.memory_save116="user://spider170_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.arc_shadows167): await physics_frame
 s.start_spider170();await settle(10)
 verify(s.enemies.size()==3 and s.total_enemies==3,"three spiders, finite encounter")
 verify(s.enemies.all(func(e): return e.has_method("prepare170")),"correct spider script injected")
 verify(s.skills110.geese110.size()==2,"default three-goose preset")
 var gel: int=s.memory_kit116.gel119;var event: int=s.memory_kit116.next_event119
 var states := {};var maximum := 0;var start_hp: float=s.player_hp
 for i in 540:
  var simultaneous := 0
  for e in s.enemies:
   states[e.state170]=true
   if e.state170 in ["prepare","pounce"]: simultaneous+=1
  maximum=maxi(maximum,simultaneous)
  await physics_frame
 verify(states.has("prepare") and states.has("pounce") and states.has("recover"),"native AI completes prepare, jump and recovery")
 verify(states.has("hop") and states.has("crouch"),"native AI uses crouch and small-hop locomotion")
 verify(maximum<=1,"at most one committed attacker")
 verify(s.player_hp<start_hp,"real spider attack uses player hurt flow")
 for actor in s.enemies:
  actor.set_physics_process(false);actor.enter170("watch");actor._render_legacy(0.)
 s.set_physics_process(false);s.hero.set_physics_process(false);s.hero.controls_enabled=false
 var e: CharacterBody3D=s.enemies[0]
 var g: Vector2=s.meadow.landmarks.grove
 s._teleport15(g+Vector2(0.,2.));e.position=Vector3(g.x,s.floor_height(g)+.06,g.y);e.impulse=Vector2.ZERO
 e.prepare170(g+Vector2(0.,2.));var locked: Vector2=e.target170
 s._teleport15(g+Vector2(2.,2.));e._physics_process(.25)
 verify(e.target170==locked,"landing point locks at beginning of warning")
 await capture("warning")
 verify(s.encounter_hud.header.text.contains("小蜘蛛B") and s.encounter_hud.footer.text.contains("F7"),"spider HUD shows correct encounter and controls")
 var age: float=e.clock170;var at: Vector3=e.position
 s.combat_paused=true;e._physics_process(.5)
 verify(e.clock170==age and e.position==at,"pause freezes clock and movement")
 s.combat_paused=false;e.enter170("pounce");e._physics_process(.25)
 verify(e.lift170>.8 and e.hit_area.position.y>1.3,"airborne visual and hit capsule share lift")
 await capture("airborne")
 e.enter170("recover");e._physics_process(.7)
 verify(e.state170=="recover" and e.attack_phase=="recover","recovery remains punishable after 0.7 seconds")
 await capture("landing")
 e._physics_process(.56);verify(e.state170=="watch","recovery ends after full window")
 var distances: Array[float]=[]
 for scale in [1.,.6]:
  e.position=Vector3(g.x,s.floor_height(g)+.06,g.y);e.impulse=Vector2.ZERO;e.hop170=Vector2.RIGHT;e.enter170("hop");e.set_meta("locomotion_scale153",scale)
  var before: float=e.position.x;e._physics_process(.1);distances.append(e.position.x-before)
 verify(absf(distances[1]/maxf(.0001,distances[0])-.6)<.05,"sword slows small hops")
 distances.clear()
 for scale in [1.,.6]:
  e.position=Vector3(g.x,s.floor_height(g)+.06,g.y);e.impulse=Vector2.ZERO;e.jump_from170=g;e.target170=g+Vector2(2.,0.);e.enter170("pounce");e.attack_connected=true;e.set_meta("locomotion_scale153",scale)
  var before: float=e.position.x;e._physics_process(.1);distances.append(e.position.x-before)
 verify(absf(distances[0]-distances[1])<.01,"sword does not slow committed attack")
 e.set_meta("locomotion_scale153",1.);e.position=Vector3(g.x,s.floor_height(g)+.06,g.y);e.enter170("watch");e._render_legacy(0.)
 s.build170=8;s.apply_paper_build129();s._teleport15(g+Vector2(0.,3.));s.fire_needs_release=false
 var hp: float=e.hp;s.fire_at(e.position+Vector3.UP*.65)
 for i in 80: s._step_shots(1./60.)
 verify(e.hp<hp,"real native projectile can damage spider")
 s._clear_combat_shots();s.build170=3;s.apply_paper_build129();s.fire_at(e.position+Vector3.UP*.65)
 verify(s.paper_memories146.planes149.size()==3,"three-goose sword aircraft launch in spider trial")
 s._clear_combat_shots()
 for i in BUILDS_COUNT():
  s.build170=i;s.apply_paper_build129()
  var cost := 0
  for id in s.buffs.levels: cost+=int(s.memory_kit116.COSTS.get(id,0))*int(s.buffs.levels[id])
  verify(cost<=4,"preset fits four slots "+str(i+1))
 await key(KEY_F6);verify(s.spider_trial170 and s.enemies.size()==1,"F6 restarts one-spider trial")
 await key(KEY_F4);verify(not s.spider_trial170 and s.paper_trial129,"F4 retains native paper trial")
 await key(KEY_F7);verify(s.spider_trial170 and not s.paper_trial129,"F7 returns to spider trial")
 for actor in s.enemies: actor.receive_hit(999.,Vector3.RIGHT)
 verify(s.defeated_count==s.spider_count170 and s.ending119>0.,"all defeated spiders schedule finite ending")
 s._step_outing119(1.)
 verify(s.won119 and s.memory_kit116.gel119==gel and s.memory_kit116.next_event119==event,"trial finishes without materials or event progression")
 s.home116()
 verify(not s.spider_trial170 and s.enemies.all(func(actor): return not actor.has_method("prepare170")),"returning home restores ambient tuantuan")
 var report := {"checks":checks,"failures":failures,"note":"Targeted spider AI, real native hit/hurt flow, slots, pause, input and trial lifecycle. No terrain changes."}
 FileAccess.open("res://docs/spider170-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://spider170_probe_tmp.cfg"))
 print("SPIDER170_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
func BUILDS_COUNT() -> int: return 9
