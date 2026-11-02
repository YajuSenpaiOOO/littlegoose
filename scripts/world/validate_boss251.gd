extends "res://scripts/world/validate_plush220.gd"
func tap251(code: int) -> void:
 var e=InputEventKey.new();e.pressed=true;e.physical_keycode=code;w._input(e)
func run() -> void:
 w=load("res://scenes/world/world251.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready251 or not is_instance_valid(w.projection250):await process_frame
 var b=w.boss247;w.auto114=false;w.invulnerability=1000.;b.set_physics_process(false);w.hero.set_physics_process(false)
 check(w.get_script().get_base_script().resource_path.ends_with("woodland_world246.gd"),"actual world parent is latest246 combat")
 check(w.alternate_encounter251() and w.enemies.size()==1 and not is_instance_valid(w.cat220) and w.bats220.is_empty(),"only tuantuan encounter active, no sister actors")
 check(w.player_hp==w.max_player_health() and w.player_hp==14.,"native 14-determination baseline restored")
 check(w.encounter_hud.get_script().resource_path.ends_with("boss_hud251.gd") and w.encounter_hud.gems!=null,"latest determination HUD restored")
 check(is_instance_valid(w.console226) and not w.console226.visible,"native C console installed")
 check(w.memory_kit116.get_script().resource_path.ends_with("memory_kit246.gd") and w.balance_profile226().CAPACITY==6,"latest catalog and slot profile restored")
 check(is_instance_valid(w.relay245) and w.relay245.get_script().resource_path.ends_with("relay_flag246.gd"),"latest relay implementation available")
 check(w.hero.get_script().resource_path.ends_with("hero192.gd"),"current approved hero retained")
 tap251(KEY_C);await process_frame
 check(w.console226.visible and w.combat_paused and not w.hero.controls_enabled,"C opens native console and pauses fight")
 check(not w.console226.rows.has("distract") and w.console226.rows.has("music_class"),"current fragment choices match246")
 check(w.console226.cat_hp.visible and not w.console226.bat_hp.visible,"console exposes boss HP without obsolete bat input")
 await shot("boss251-console")
 var result=w.commit_console226({"red_banner":1},90.,80.,false)
 check(result=="" and w.buffs.level("red_banner")==1 and not w.console226.visible and not w.combat_paused,"console applies current fragments in place")
 w.on_dash_started()
 check(w.relay245.phase=="drop","real dash hook plants latest relay flag")
 w._clear_combat_shots()
 # Dynamic latest profile also gates the music mode correctly.
 result=w.commit_console226({"music_class":1},90.,80.,false)
 check(result=="" and w.music_running236(),"latest music system runs for tuantuan encounter")
 result=w.commit_console226({},90.,80.,false)
 w.auto114=false;w.invulnerability=1000.;b.enter247("angry");b.enter247("flight");b.jump247=5;b.boost248=0
 w.hero.position=b.position+Vector3(4.,0,0);w.hero.velocity=Vector3(4.1,0,0);b.lock247()
 var last: Dictionary=b.flights247[-1]
 check(last.get("lead",Vector2.ZERO).x>0. and last.get("lead",Vector2.ZERO).length()<=1.6001,"takeoff uses bounded movement prediction")
 check(last.get("speed",0.)>=6.6,"late-chain horizontal speed has pursuit floor")
 var t=b.duration248();var effective=float(last.speed)*t/(t+.07+float(b.jump247)*.012)
 check(effective>w.hero.movement_speed(),"late-chain average pursuit exceeds ordinary walking speed")
 var locked=b.goal247;w.hero.position+=Vector3(0.,0,2.);b._physics_process(.1)
 check(b.goal247==locked,"prediction does not become midair homing")
 b.enter247("flight");b.from247=Vector2(b.position.x,b.position.z)-Vector2.RIGHT;b.goal247=Vector2(b.position.x,b.position.z)
 w.invulnerability=0.;w.hero.position=b.position;w.hero.parry_t=.15;w.hero.parried=false;w.hero.dodge_invulnerability=0.;b.land247()
 check(b.phase247=="deflected" and b.reverse_pending249,"single reflected bounce preserved on latest combat")
 w.reset_impact248();w.hero.cancel_guard109();w.invulnerability=1000.;b.enter247("rest");b.render247()
 # Native projectiles hit boss through the latest hit/payload/stat chain.
 for dir in [Vector2.LEFT,Vector2.RIGHT,Vector2.DOWN,Vector2.UP]:
  var at=Vector2(b.position.x,b.position.z)+dir*3.5
  if w.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(at.x,w.floor_height(at)+.65,at.y),b.hit_area.global_position,1|2,[w.hero.get_rid()])).is_empty():w._teleport15(at);break
 w.hero.velocity=Vector3.ZERO;await settle();var hp=b.hp
 for i in 8:
  w.cooldown=0.;w.fire_needs_release=false;w.fire_at(b.hit_area.global_position);await create_timer(.12).timeout
 await create_timer(.5).timeout
 check(b.hp<hp,"latest native projectiles damage boss")
 check(w.stats226.cat_damage>0.,"C statistics record tuantuan damage")
 await shot("boss251-hud")
 w._clear_combat_shots();w.invulnerability=0.;var health=w.player_hp;w.hurt_player(2.5,Vector2(b.position.x,b.position.z))
 check(w.player_hp<health and w.player_hp>0.,"damage scaled for determination baseline instead of old 100HP")
 var count=w.actor_shadows.size();tap251(KEY_F7);b=w.boss247;b.set_physics_process(false);await process_frame
 check(w.enemies.size()==1 and w.player_hp==14. and w.actor_shadows.size()==count,"restart preserves latest health and clean shadow registration")
 check(w.projection250.visible and not b.shadow.visible and not b.marker247.visible,"world silhouette and default circle-off retained")
 b.receive_hit(10000.,Vector3.RIGHT);await create_timer(.3).timeout
 check(not w.active114 and w.result251!="" and is_equal_approx(Engine.time_scale,1.),"defeat ends latest encounter without auto restart")
 var first=w;w=null;root.remove_child(first);first.queue_free();await process_frame;await process_frame
 # Sequential regression of246 with default-false hooks; no second simultaneous game.
 w=load("res://scenes/world/world246.tscn").instantiate();root.add_child(w);current_scene=w
 while not is_instance_valid(w.relay245):await process_frame
 check(not w.alternate_encounter251(),"246 retains default sister encounter path")
 w.start_battle225(false)
 check(is_instance_valid(w.cat220) and w.bats220.size()==2 and w.stage225=="battle","246 original sister encounter still spawns normally")
 await create_timer(.2).timeout
 check(w.active114 and w.cat220.hp>0. and w.stats226.seconds>0.,"246 original state machine and stats still run")
 var ok=checks.all(func(c):return c.pass)
 var file=FileAccess.open("res://docs/boss251-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));file.close()
 print("BOSS251_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
