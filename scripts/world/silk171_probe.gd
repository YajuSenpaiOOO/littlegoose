extends "res://scripts/world/spider170_probe.gd"
func capture171(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/silk171_"+tag+".png")
func freeze171(s: Node3D) -> void:
 for actor in s.enemies: actor.set_physics_process(false)
 for ball in s.silk171: ball.set_physics_process(false)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := preload("res://scripts/world/woodland_world171.gd").new()
 s.memory_save116="user://silk171_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.arc_shadows167): await physics_frame
 s.start_spider170();await settle(10)
 var stock: int=s.memory_kit116.gel119;var event: int=s.memory_kit116.next_event119
 verify(s.enemies.size()==3 and s.skills110.geese110.size()==2,"three silk spiders and three geese")
 var states := {};var peak := 0;var lunges := 0;var high_jumps := 0;var first_hp: float=s.player_hp;var releases := 0
 for i in 720:
  var preparing := 0
  for actor in s.enemies:
   states[actor.state170]=true
   if actor.state170 in ["winding","push"]: preparing+=1
   if actor.attack_phase=="lunge": lunges+=1
   if actor.lift170>.33: high_jumps+=1
   releases=maxi(releases,actor.throws171)
  peak=maxi(peak,preparing)
  await physics_frame
 verify(states.has("winding") and states.has("push") and states.has("sit"),"natural AI winds, pushes and sits")
 verify(states.has("hop") and states.has("crouch"),"small-hop movement retained")
 verify(lunges==0 and high_jumps==0,"no body lunge or large jump")
 verify(peak<=1 and releases>=1,"staggered preparation releases actual balls")
 verify(s.player_hp<first_hp,"rolling balls use real player hurt flow")
 verify(s.enemies.size()==3,"balls do not enter enemy targeting or encounter counts")
 freeze171(s);s.set_physics_process(false);s.hero.set_physics_process(false);s.hero.controls_enabled=false
 s.build170=8;s.apply_paper_build129()
 var e: CharacterBody3D=s.enemies[0];var g: Vector2=s.meadow.landmarks.grove
 for actor in s.enemies: actor.enter170("watch");actor.impulse=Vector2.ZERO;actor._render_legacy(0.)
 e.position=Vector3(g.x,s.floor_height(g)+.06,g.y);s._teleport15(g+Vector2(0.,3.))
 e.prepare170(g+Vector2(0.,3.));e._physics_process(.5)
 var locked: Vector2=e.attack_direction;var at: Vector3=e.position
 s._teleport15(g+Vector2(2.,3.));e._physics_process(.3)
 verify(e.attack_direction==locked and e.position.distance_to(at)<.02,"winding locks direction and stays still")
 await capture171("winding")
 e._physics_process(.36);e._physics_process(.09)
 verify(e.throws171>=1 and s.silk171.size()==1,"push spawns one independent ball")
 var b: CharacterBody3D=s.silk171[0];b.set_physics_process(false)
 verify(b.direction171==locked and b.hit_area.collision_layer==8,"released ball has fixed direction and real shootable hit area")
 verify(e.attack_phase!="lunge" and e.lift170==0.,"push remains on ground without body attack")
 await capture171("push")
 var ball_clock: float=b.clock171;var clock: float=e.clock170;var ball_at: Vector3=b.position
 s.combat_paused=true;e._physics_process(.5);b._physics_process(.5)
 verify(b.clock171==ball_clock and e.clock170==clock and b.position==ball_at,"pause freezes winding and balls")
 s.combat_paused=false;e._physics_process(.22);e._physics_process(.7)
 verify(e.state170=="sit" and e.attack_phase=="recover","sit gives a stable punish window")
 await capture171("sit")
 e._physics_process(.66);verify(e.state170=="watch" and e.relocate171,"spider schedules small-hop reposition after recovery")
 # Put the same real projectile target on a clear line, away from the spiders.
 for actor in s.enemies: actor.position=Vector3(g.x-4.-actor.role110,s.floor_height(g)+.06,g.y-3.)
 b.position=Vector3(g.x,s.floor_height(g)+.06,g.y);s._teleport15(g+Vector2(0.,3.));b._render_legacy(0.)
 await settle(3)
 var defeated: int=s.defeated_count;var kills: int=s.kills152;var cleared: int=s.silk_clears171
 s.fire_at(b.position+Vector3.UP*.4)
 for i in 60: s._step_shots(1./60.)
 verify(b.retired171 and b.reason171=="shot","ordinary native projectile destroys ball")
 verify(s.defeated_count==defeated and s.kills152==kills and s.silk_clears171==cleared+1,"clearing ball does not count as spider kill")
 verify(s.memory_kit116.gel119==stock and s.memory_kit116.next_event119==event,"ball destruction gives no material or progress")
 b._physics_process(.2);await capture171("unravel")
 b._physics_process(.26);verify(not s.silk171.has(b),"unravel removes retired ball")
 s.release_silk171(e,Vector2.RIGHT);b=s.silk171[-1];b.set_physics_process(false)
 b.clock171=4.5;b._physics_process(.11)
 verify(b.retired171 and b.reason171=="timeout","ball expires without leaving a web")
 s.clear_silk171()
 for i in 10: s.release_silk171(e,Vector2.RIGHT)
 verify(s.silk171.size()==8,"live ball budget is bounded")
 s.build170=3;s.apply_paper_build129();verify(s.silk171.is_empty(),"changing build clears hostile balls")
 s.fire_at(e.position+Vector3.UP*.65)
 verify(s.paper_memories146.planes149.size()==3,"sword aircraft still launch from all three geese")
 s._clear_combat_shots()
 await key(KEY_F6);verify(s.spider_trial170 and s.enemies.size()==1 and s.silk171.is_empty(),"F6 switches to one spider and clears balls")
 await key(KEY_F5);verify(not s.spider_trial170 and not s.paper_trial129,"F5 native tuantuan remains available")
 await key(KEY_F4);verify(not s.spider_trial170 and s.paper_trial129,"F4 native paper remains available")
 await key(KEY_F7);freeze171(s);verify(s.spider_trial170,"F7 returns to silk trial")
 e=s.enemies[0];e.prepare170(Vector2(s.hero.position.x,s.hero.position.z));e.receive_hit(999.,Vector3.RIGHT);e._physics_process(2.)
 verify(s.silk171.is_empty(),"defeated spider cannot complete an unfinished ball")
 s._step_outing119(1.)
 verify(s.won119 and s.memory_kit116.gel119==stock and s.memory_kit116.next_event119==event,"finite trial finishes without rewards or progress")
 s.home116();verify(not s.spider_trial170 and s.silk171.is_empty(),"home removes all balls and exits spider trial")
 var report := {"checks":checks,"failures":failures,"note":"Silk toy attack, native shooting, real player damage, finite lifecycle, fixed aim, pause, budget, presets and input. No map changes."}
 FileAccess.open("res://docs/silk171-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://silk171_probe_tmp.cfg"))
 print("SILK171_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
