extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world249.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready247:await process_frame
 var b=w.boss247;w.auto114=false;w.invulnerability=10000.;w.hero.set_physics_process(false);b.set_physics_process(false)
 var progress={"next":w.memory_kit116.next_event119,"gel":w.memory_kit116.gel119}
 check(b.body_scale110==2.15,"larger independent body")
 check(w.safe_goal247(Vector2(b.position.x,b.position.z),Vector2(b.position.x,b.position.z)).is_finite(),"larger ground footprint safe-goal query")
 b.enter247("angry");var original=b.position;b._physics_process(.10)
 check(b.lift247>.1 and b.position.distance_to(original)<.05 and b.landings247.is_empty(),"impatient hops animate before attack")
 check(b.visual.texture==b.textures.shove124,"annoyed face reuses existing species art")
 await shot("boss249-angry")
 for i in 32:b._physics_process(1./60.)
 check(b.phase247=="squat","three impatient hops lead to charge")
 for i in 40:b._physics_process(1./60.)
 check(b.phase247=="flight" and b.total248==7,"charge starts seven-hit chain")
 var locked=b.goal247;w.hero.position+=Vector3(2.,0,0);b._physics_process(.08)
 check(b.goal247==locked,"flight stays committed")
 check(absf(b.hit_area.position.y-(.8*b.body_scale110+b.lift247))<.001,"enlarged airborne native target follows body")
 await shot("boss249-air")
 var clock=b.clock247;w.combat_paused=true;b._physics_process(.3)
 check(b.clock247==clock,"pause freezes attack")
 w.combat_paused=false;b.landings247.clear();b.flights247.clear();b.enter247("angry")
 for i in 370:b._physics_process(1./60.)
 check(b.landings247.size()==7,"seven actual landing events before flat recovery")
 check(b.phase247=="flat","full chain ends in punish window")
 check(b.flights247.size()==7 and b.flights247[0].duration<b.flights247[-1].duration and b.flights247[0].height>b.flights247[-1].height,"speed and energy decay across chain")
 b.enter247("angry");b.enter247("flight");b.from247=Vector2(b.position.x,b.position.z)-Vector2.RIGHT*2.;b.goal247=Vector2(b.position.x,b.position.z)
 b.hp=10000.;var old_total=b.total248;var old_parries=b.parried_count
 w.invulnerability=0.;w.hero.position=b.position;w.hero.parry_t=.15;w.hero.parried=false;w.hero.guarding109=false;w.hero.dodge_invulnerability=0.
 b.land247()
 check(b.phase247=="deflected" and b.parried_count==old_parries+1,"actual landing parry continues chain")
 check(b.forward247.dot(Vector2.LEFT)>.99,"parry reverses incoming momentum")
 check(b.total248==old_total+2 and b.jump247==1 and b.boost248==2,"parry adds two hits and boosts next two bounces")
 check(w.impact248==1 and w.impact_clock.events.any(func(e):return e.get("group","")=="boss248"),"parry schedules owned slow-motion feedback")
 var base_fov=w.camera.fov
 await create_timer(.18,true,false,true).timeout
 check(Engine.time_scale<.5,"real-time slow motion follows hitstop")
 check(w.camera.fov<base_fov,"parry camera punches closer")
 await shot("boss249-parry")
 await create_timer(.45,true,false,true).timeout
 check(is_equal_approx(Engine.time_scale,1.),"effect restores normal time")
 b._physics_process(.21)
 check(b.phase247=="flight" and b.reflected248,"reverse rebound resumes remaining chain")
 check(not b.reverse_pending249,"one reverse flight consumes pending reflection")
 var reverse_goal=b.goal247;w.hero.position+=Vector3(3.,0,2.);b._physics_process(.03)
 check(b.goal247==reverse_goal,"reversed flight stays locked after player moves")
 w.invulnerability=1000.;w.hero.parry_t=0.;b._physics_process(.40)
 check(not b.reflected248 and b.phase247=="rebound","reflection clears on that flight landing")
 var follow_from=Vector2(b.position.x,b.position.z);w._teleport15(follow_from+Vector2(2.,1.))
 b._physics_process(.30)
 check(b.phase247=="flight" and not b.reflected248 and (b.goal247-follow_from).dot(Vector2(2.,1.))>=0.,"next flight returns to player pursuit")
 check(not b.marker247.visible,"landing circle hidden by default")
 w._input(make_key248(KEY_F10))
 check(w.show_landing249 and b.marker247.visible,"debug circle toggle remains available")
 w._input(make_key248(KEY_F10))
 check(not b.marker247.visible and not w.show_landing249,"debug circle switches off cleanly")
 check(b.shadow.visible and is_equal_approx(b.shadow.mesh.size.x,1.44) and b.shadow.material_override.get_shader_parameter("opacity")>=.49,"actor-local soft shadow remains enabled with expected size and opacity")
 check(b.shadow.position.x==0. and b.shadow.position.z==0.,"shadow remains under current body, not future target")
 await shot("boss249-shadow")
 for i in 8:
  b.enter247("flight");b.deflect(w.hero.position+Vector3.UP*.6)
 check(b.total248==11 and b.extra248==4,"repeated parries cannot create infinite chain")
 w._input(make_key248(KEY_F6))
 check(w.combat_paused and w.impact_clock.events.is_empty() and is_equal_approx(Engine.time_scale,1.),"pause cancels delayed impact events")
 w._input(make_key248(KEY_F6));w.finish247(false)
 check(not w.active114 and not b.marker247.visible and is_equal_approx(Engine.time_scale,1.),"stop clears marker and time state")
 w.begin247();b=w.boss247;b.set_physics_process(false)
 check(w.enemies.size()==1 and b.body_scale110==2.15 and w.impact248==0,"restart clears actor and camera feedback")
 check(w.memory_kit116.next_event119==progress.next and w.memory_kit116.gel119==progress.gel,"formal progress unchanged")
 # Real native player projectiles against enlarged boss.
 b.enter247("rest");b.render247();w.build247=0;w.apply_paper_build129()
 for dir in [Vector2.LEFT,Vector2.RIGHT,Vector2.DOWN,Vector2.UP]:
  var spot=Vector2(b.position.x,b.position.z)+dir*3.5
  if w.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(spot.x,w.floor_height(spot)+.65,spot.y),b.hit_area.global_position,1|2,[w.hero.get_rid()])).is_empty():w._teleport15(spot);break
 await settle();var hp=b.hp
 for i in 8:
  w.cooldown=0.;w.fire_needs_release=false;w.fire_at(b.hit_area.global_position);await create_timer(.12).timeout
 await create_timer(.5).timeout
 check(b.hp<hp,"native projectiles damage enlarged boss")
 w._clear_combat_shots();w.hero.position=b.position;w.hero.parry_t=0.;w.hero.guarding109=false;w.invulnerability=0.;w.hero.dodge_invulnerability=0.
 hp=w.player_hp;b.enter247("flight");b.land247()
 check(w.player_hp<hp,"larger landing footprint still uses native damage")
 w.invulnerability=0.;w.hero.dodge_invulnerability=.3;hp=w.player_hp;b.enter247("flight");b.land247()
 check(w.player_hp==hp,"new chain respects dodge invulnerability")
 w.hero.dodge_invulnerability=0.;w.hero.guarding109=true;w.invulnerability=0.;hp=w.player_hp;b.enter247("flight");b.land247()
 check(w.player_hp<hp and hp-w.player_hp<18.,"new chain respects guard reduction")
 w.hero.cancel_guard109();b.receive_hit(10000.,Vector3.RIGHT);await create_timer(.2).timeout
 check(not w.active114 and b.dead and w.impact_clock.events.is_empty(),"defeat ends encounter and impact effects")
 var ok=checks.all(func(c):return c.pass)
 var file=FileAccess.open("res://docs/boss249-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));file.close()
 print("BOSS249_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
func make_key248(code: int) -> InputEventKey:
 var e=InputEventKey.new();e.pressed=true;e.physical_keycode=code;return e
