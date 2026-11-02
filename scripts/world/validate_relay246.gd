extends "res://scripts/world/validate_plush220.gd"
class World:
 extends "res://scripts/world/woodland_world246.gd"
 var aim236 := Vector3.ZERO
 func paper_aim146() -> Vector3:return aim236
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
func tap245() -> void:
 var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;w._input(event)
func run() -> void:
 w=World.new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.relay245):await process_frame
 w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=100000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 w.aim236=w.cat220.hit_area.global_position
 var found=false
 for dir in [Vector2.LEFT,Vector2.RIGHT,Vector2.DOWN,Vector2.UP]:
  var at=Vector2(w.aim236.x,w.aim236.z)+dir*3.
  if not w.open_drop225(at):continue
  var start=Vector3(at.x,w.floor_height(at)+.55,at.y)
  if w.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start,w.aim236,1|2,[w.hero.get_rid()])).is_empty():w._teleport15(at);found=true;break
 check(found,"clear real physics line to cat")

 check(found,"clear native line for relay fixture")
 w.levels226={"red_banner":1,"music_class":1};w.apply_levels226();w.hero.reset_actions();w.fire_needs_release=false
 w.on_dash_started()
 check(w.relay245.phase=="drop" and w.relay245.pending.is_empty(),"dash creates one descending flag")
 await create_timer(.08).timeout
 check(w.relay245.global_position.y>w.relay245.ground.y+1.,"visible fall above actual ground")
 await shot("relay246-drop")
 w.rhythm236.reset();w.fire_needs_release=false
 w.stamp236=Time.get_ticks_usec();w.rhythm236.time=w.rhythm236.period237();tap245()

 check(w.relay245.pending.get("specs",[]).size()==1,"next actual music attack captured once")
 var captured=float(w.relay245.pending.get("specs",[{"damage":0.}])[0].damage)
 check(captured>0. and abs(captured-w.rhythm_damage236)<.00001,"relay stores final Perfect damage budget")
 var age=w.relay245.age;w.combat_paused=true;await create_timer(.15).timeout
 check(w.relay245.age==age,"flag animation pauses with combat")
 w.combat_paused=false
 var deadline=Time.get_ticks_msec()+4000
 while w.relay245.phase!="fire" and Time.get_ticks_msec()<deadline:await process_frame
 var emitted=w.echoes245
 check(emitted==1,"one native echo emitted after landing and puff")
 await shot("relay246-fire")
 await create_timer(.8).timeout
 check(w.relay245.phase=="gone" and w.echoes245==emitted,"roll-away cleanup and no recursive relay")
 check(w.cat220.hp<100000.,"native projectiles damage actual cat")
 check(w.relay245.history.has("settle") and w.relay245.history.has("puff") and w.relay245.history.has("roll"),"animation phases connected")
 # New flag replaces old one; a whole goose squad must never be copied.
 w._clear_combat_shots();w.levels226={"red_banner":1,"three_player":1};w.apply_levels226();w.on_dash_started();w.fire_at(w.aim236)
 check(w.shots.size()==3 and w.relay245.pending.specs.size()==1,"three geese retain only main source for echo")
 var planted=w.relay245.planted;var at_saved=w.relay245.ground;w.on_dash_started()
 check(w.relay245.planted==planted and not w.relay245.pending.is_empty() and w.relay245.ground==at_saved,"repeated dash preserves flag and captured attack")
 await create_timer(1.3).timeout
 w.on_dash_started();await create_timer(.5).timeout
 check(w.relay245.phase=="ready","next dash after completion plants a new ready flag")
 var ready_at=w.relay245.ground;var count_before=w.relay245.planted
 w.relay245.lifetime=100.;w.relay245._process(.02);w.on_dash_started()
 check(w.relay245.phase=="ready" and w.relay245.ground==ready_at and w.relay245.planted==count_before,"ready flag persists indefinitely and repeated dodges do not replace it")
 var packet={"specs":[{"damage":1.}],"plane":false}
 var centre=w.relay245.global_position
 w.relay245.offer245(packet,centre-w.camera.global_basis.x*3.);w.relay245.render245()
 check(w.relay245.inks[0].get_shader_parameter("flip245")==1. and w.relay245.inks[1].get_shader_parameter("flip245")==1. and w.relay245.inks[2].get_shader_parameter("flip245")==-1.,"left shot flips only goose, never pencil or cloth")
 var left_mouth=w.relay245.mouth245();w.relay245.flip=1.;w.relay245.render245();var right_mouth=w.relay245.mouth245()
 check(left_mouth.distance_to(right_mouth)>.2 and absf((left_mouth-right_mouth).dot(w.camera.global_basis.y))<.001,"muzzle follows goose direction around fixed body centre")
 w.relay245.pending.clear();w.relay245.enter245("ready")
 await shot("relay246-ready")
 # Remove old red-banner combo boost.
 w.combo=50;var shot=w.shots[0] if not w.shots.is_empty() else w.data_shot110(w.projectile_origin(),Vector3.RIGHT,1.)
 var high=w.damage_for_shot(shot);w.combo=0
 check(abs(high-w.damage_for_shot(shot))<.00001,"old combo +40 percent removed")
 # Native music sword / airplane echoes retain a single source and no recursion.
 for levels in [{"red_banner":1,"music_class":1,"balloon_sword":1},{"red_banner":1,"music_class":1,"paper_plane":1}]:
  w._clear_combat_shots();w.levels226=levels;w.apply_levels226();w.hero.reset_actions();w.fire_needs_release=false
  w.on_dash_started();w.stamp236=Time.get_ticks_usec();w.rhythm236.time=w.rhythm236.period237();tap245()
  check(w.relay245.pending.get("specs",[]).size()==1,"combo payload captured / "+str(levels))
  var expected_plane=levels.has("paper_plane")
  check(bool(w.relay245.pending.get("plane",false))==expected_plane,"delivery identity preserved")
  if levels.has("balloon_sword"):check(w.relay245.pending.specs[0].sword153,"sword identity preserved")
  await create_timer(1.8).timeout
  check(w.echoes245==1 and w.relay245.phase=="gone","combo echoes exactly once / "+str(levels))
 # Same game camera, registered foot and independent contact shadow, day/night.
 var at=w.hero.global_position+w.camera.global_basis.x*1.15
 w.relay245.plant245(at);w.relay245.phase="ready";w.relay245.age=0.;w.relay245.set_process(false);w.relay245.render245()
 check(w.relay245.get_children().all(func(n):return not n is CollisionObject3D),"flag is nonblocking visual support, no bitmap-shaped collision")
 await shot("relay246-day")
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();await shot("relay246-night")
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 w.relay245.set_process(true)
 # Ground palettes are independent, no baked terrain card.
 for kind in ["soil_grass","stone","wood_indoor"]:
  w.relay245.plant245(w.hero.global_position,kind);w.relay245.burst245()
  check(w.relay245.chips.size()==6 and w.relay245.kind==kind,"material particles / "+kind)
 w._clear_combat_shots()
 check(w.relay245.phase=="gone" and w.relay245.chips.is_empty(),"clear removes particles and contact shadow")
 metrics={"checks":checks,"captures":w.captures245,"echoes":w.echoes245,"test_gain":w.relay_gain245}
 FileAccess.open("res://docs/relay246-validation.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t"))
 print("RELAY246_VALIDATION ",JSON.stringify(metrics));w.stop225();quit(1 if checks.any(func(c):return not c["pass"]) else 0)
