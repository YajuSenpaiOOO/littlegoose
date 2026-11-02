extends "res://scripts/world/validate_plush220.gd"
const P=preload("res://scripts/combat/balance_profile226.gd")
func shot(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/balance226-"+tag+".png")
func click_control226(control: Control) -> void:
 var at=control.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new();motion.position=at;motion.global_position=at;root.push_input(motion,true)
 await process_frame
 metrics.gui={"at":at,"rect":control.get_global_rect(),"hover":str(root.gui_get_hovered_control()),"disabled":control.disabled}
 var press=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=at;press.global_position=at;root.push_input(press,true)
 await process_frame
 var release=press.duplicate();release.pressed=false;root.push_input(release,true)
 await process_frame
func run() -> void:
 w=load("res://scenes/world/world226.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready226:await process_frame
 var cfg_path="user://boss_balance226.cfg";var cfg_exists=FileAccess.file_exists(cfg_path);var cfg_backup=FileAccess.get_file_as_bytes(cfg_path) if cfg_exists else PackedByteArray()
 var previous_progress=[w.memory_kit116.next_event119,w.memory_kit116.last_reward119,w.memory_kit116.gel119]
 w.levels226=P.PRESETS[0].levels.duplicate(true);w.apply_levels226()
 check(w.stage225=="waiting" and w.player_hp==14. and w.max_player_health()==14.,"starts at cottage with real fourteen health")
 for preset in P.PRESETS:check(P.error(preset.levels)=="","six-slot preset valid: "+preset.name)
 check(P.error({"boarding_school":1})!="" and P.error({"music_class":1})!="" and P.error({"paper_racer":1})!="","second region and unfinished redesigns blocked")
 check(P.error({"hero_moment":1,"homework":1})!="" and P.error({"flashlight":1,"balloon_sword":1})!="","active and weapon conflicts validated")
 check(P.error({"three_player":1,"hero_moment":1,"eye_exercise":1,"pillow_hut":1})!="","over six slots rejected")
 check(P.error({"paper_plane":2})!="","ineffective duplicate levels rejected")
 await key(KEY_C);var intro_clock=w.age225;await create_timer(.15).timeout
 check(w.console226.visible and w.combat_paused and not w.hero.controls_enabled and w.age225==intro_clock,"C opens paused console at door")
 await shot("console")
 await click_control226(w.console226.rows.three_player.minus)
 check(w.console226.draft.get("three_player",0)==0,"actual GUI mouse click edits draft through paused overlay")
 w.console226.preset226(0)
 var before=w.levels226.duplicate(true);w.console226.clear226();await key(KEY_ESCAPE)
 check(w.levels226==before and not w.combat_paused and w.hero.controls_enabled,"Escape cancels draft and restores controls")
 w.levels226=P.PRESETS[0].levels.duplicate(true);w.cat_health226=P.CAT_HP;w.bat_health226=P.BAT_HP
 await key(KEY_F8)
 check(not w.auto114 and not w.fire_input_held(),"new fight defaults to manual fire without held mouse")
 w.auto114=false;w.pigs_enabled220=false;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 check(w.player_hp==14. and w.cat220.hp==P.CAT_HP and w.bats220.all(func(b):return b.hp==P.BAT_HP),"battle uses profile health for player cat and bats")
 check(w.buffs.levels==w.levels226 and w.skills110.geese110.size()==2,"native startup retains chosen two extra geese")
 await create_timer(.5).timeout
 check(w.encounter_hud.gems.gem_count==14 and w.encounter_hud.gems.max_value==14. and "14" in w.encounter_hud.health_text.text,"HUD shows fourteen separate one-point gems")
 await shot("health")
 w.hero.dodge_invulnerability=0.;w.invulnerability=0.;w.hurt_player_from(22.,Vector2.ZERO,"roll")
 check(w.player_hp==10. and w.stats226.injuries[-1].source=="roll" and w.stats226.injuries[-1].loss==4.,"roll applies four actual health and records source")
 check("4" in w.encounter_hud.feedback_text.text and not "29" in w.encounter_hud.feedback_text.text,"hurt feedback uses actual gem loss rather than hundred-point shake scale")
 w.hurt_player_from(12.,Vector2.ZERO,"touch")
 check(w.player_hp==10.,"same invulnerability window prevents followup contact damage")
 w.invulnerability=0.;w.hurt_player_from(12.,Vector2.ZERO,"touch")
 check(w.player_hp==8.,"ordinary touch applies two health")
 w.invulnerability=0.;w.cotton220.pig=w.rig220;w.cotton220.contact219()
 check(w.player_hp==7. and w.stats226.injuries[-1].source=="cotton","native cotton contact applies one health")
 w.cotton220.pig=null
 w.hero.dodge_invulnerability=.2;w.invulnerability=0.;w.hurt_player_from(22.,Vector2.ZERO,"roll")
 check(w.player_hp==7.,"dodge still prevents scaled attack")
 w.hero.dodge_invulnerability=0.;w.hero.guarding109=true;w.hurt_player_from(22.,Vector2.ZERO,"roll")
 check(is_equal_approx(w.player_hp,4.6),"guard retains forty percent damage reduction")
 w.hero.cancel_guard109();w.player_hp=14.;w.invulnerability=10.;w.stop_until=0.;Engine.time_scale=1.
 check(is_equal_approx(w.health_fraction(),1.),"full fourteen health is full ratio")
 w.buffs.levels={"flashlight":1};w._apply_owned_buffs()
 var full=w.snapshot_packet146(w.cat220.position,false,0.);w.player_hp=7.
 var half=w.snapshot_packet146(w.cat220.position,false,0.)
 check(is_equal_approx(w.health_fraction(),.5) and is_equal_approx(full.pulse_interval/half.pulse_interval,1.3),"real half health drives packet low-health rate without hundred-point assumption")
 w.player_hp=14.;w.apply_levels226()
 w.combat_paused=true;w.hero.controls_enabled=false;await key(KEY_C);await key(KEY_C)
 check(w.combat_paused and not w.hero.controls_enabled,"console preserves existing manual pause")
 w.combat_paused=false;w.hero.controls_enabled=true
 var position=w.hero.position;var hp=w.player_hp;var cat_hp=w.cat220.hp;var stage=w.battle_phase220
 await key(KEY_C);var before_seconds=w.stats226.seconds;var cat_phase_clock=w.cat220.clock220;await create_timer(.2).timeout
 check(w.stats226.seconds==before_seconds and w.cat220.clock220==cat_phase_clock,"console freezes combat clocks and statistics")
 w.console226.preset226(2)
 var error=w.commit_console226(w.console226.draft,w.cat_health226,w.bat_health226,false)
 check(error=="" and w.hero.position==position and w.player_hp==hp and w.cat220.hp==cat_hp and w.battle_phase220==stage,"apply changes equipment in place without healing teleport or phase reset")
 check(w.stats226.partial and w.buffs.level("pillow_hut")==1 and w.buffs.level("eye_exercise")==0,"in-place change starts labeled statistics segment and drops prior effects")
 check(w.buffs.levels==w.levels226,"applied fragment effects match selected loadout")
 await key(KEY_C);var previous=w.levels226.duplicate(true)
 error=w.commit_console226({"boarding_school":1},600.,200.,false)
 check(error!="" and w.levels226==previous and w.console226.visible,"invalid apply leaves console and old configuration intact")
 w.console226.preset226(0);error=w.commit_console226(w.console226.draft,P.CAT_HP,P.BAT_HP,true)
 check(error=="" and w.active114 and w.player_hp==14. and not w.stats226.partial and not w.console226.visible,"restart applies draft restores fourteen health and fresh statistics")
 w.auto114=false;w.pigs_enabled220=false;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 # Real native automatic fire against a stationary physical target: a calibration only.
 w.cat220.hp=100000.;w.cat220.max_hp110=100000.;w.invulnerability=100.;w.auto114=true;w.target114=null;w.aim_tick114=-1
 var plane_target=w.paper_aim146()
 check(Vector2(plane_target.x,plane_target.z).distance_to(Vector2(w.cat220.position.x,w.cat220.position.z))<.2,"aircraft ground mark follows native autoaim rather than idle cursor")
 var initial=w.cat220.hp;var start=w.stats226.seconds
 await create_timer(8.).timeout
 metrics.stationary_cat={"seconds":w.stats226.seconds-start,"damage":initial-w.cat220.hp,"dps":(initial-w.cat220.hp)/maxf(.01,w.stats226.seconds-start)}
 check(metrics.stationary_cat.damage>0. and w.stats226.cat_damage>0.,"native aircraft loadout damages physical cat and accumulates actual capped damage")
 metrics.aircraft_details={"shots":w.fired_count,"hits":w.landed_hits,"planes":w.paper_memories146.planes_launched146,"deliveries":w.paper_memories146.deliveries146,"interval":w.attack_cooldown()}
 w.auto114=false;w._clear_combat_shots();w.buffs.levels.erase("paper_plane");w._apply_owned_buffs();w.auto114=true
 initial=w.cat220.hp;start=w.stats226.seconds
 await create_timer(8.).timeout
 metrics.direct_comparison={"seconds":w.stats226.seconds-start,"damage":initial-w.cat220.hp,"dps":(initial-w.cat220.hp)/maxf(.01,w.stats226.seconds-start)}
 w.auto114=false;w._clear_combat_shots();w.apply_levels226()
 w.auto114=false;await key(KEY_F9);await create_timer(1.5).timeout
 check(w.battle_phase220=="repair" and not w.window226.is_empty(),"cat defeat opens measured six-second repair window")
 w.bats220[0].hp=100000.;w.bats220[0].max_hp110=100000.;w.bats220[1].hp=100000.;w.bats220[1].max_hp110=100000.
 var bat_initial=w.bats220[0].hp+w.bats220[1].hp;var bat_start=w.stats226.seconds;w.auto114=true;w.target114=null;w.aim_tick114=-1
 await create_timer(3.5).timeout
 metrics.stationary_bats={"seconds":w.stats226.seconds-bat_start,"damage":bat_initial-w.bats220[0].hp-w.bats220[1].hp,"first_hit":w.window226.get("first_hit",-1.)}
 check(metrics.stationary_bats.damage>0. and w.window226.first_hit>=0.,"native autoaim damages exposed bats and records first hit delay")
 await key(KEY_C);await shot("statistics");await key(KEY_C)
 w.auto114=false;w.phase_age220=6.1;await create_timer(.15).timeout
 check(not w.stats226.windows.is_empty() and w.stats226.windows[-1].damage[0]+w.stats226.windows[-1].damage[1]>0.,"repair exit archives actual per-bat damage")
 check(w.stats226.debug,"debug F9 sample marked and excluded as clean balance sample")
 check(w.export_stats226()==OK and FileAccess.file_exists("user://boss_balance226_last.json"),"statistics export written outside inventory save")
 await key(KEY_F7)
 check(w.stage225=="waiting" and not w.context202 and w.player_hp<=14.,"reset restores doorway and forest context without hundred-health leak")
 check(w.stats226.result=="中止","F7 archives interrupted sample before returning to door")
 await key(KEY_F8);w.auto114=false;w.pigs_enabled220=false
 w.hero.dodge_invulnerability=0.;w.invulnerability=0.;w.hurt_player_from(999.,Vector2.ZERO,"other")
 await create_timer(.8).timeout
 check(not w.active114 and w.stats226.result=="失败" and not w.context202,"lethal damage records failure and cleans trial context")
 await key(KEY_F7);w._teleport15(w.wait_at225);await key(KEY_E)
 check(w.stage225=="knock","fourteen-health preview still enters through cottage knock")
 await key(KEY_C);var entry_age=w.age225;await create_timer(.15).timeout;await key(KEY_C)
 check(w.age225==entry_age and not w.hero.controls_enabled and not w.combat_paused,"console pauses intro and resumes original disabled movement state")
 var intro_deadline=Time.get_ticks_msec()+25000
 while w.stage225!="battle" and Time.get_ticks_msec()<intro_deadline:await process_frame
 w.auto114=false
 check(w.stage225=="battle" and w.player_hp==14. and w.cat220.max_hp110==P.CAT_HP,"natural nine-stage introduction hands off to new health profile")
 await key(KEY_F9);await create_timer(1.5).timeout;await key(KEY_F10);await create_timer(1.).timeout
 check(not w.active114 and w.stats226.result=="胜利" and w.rig220.fall224 and w.stats226.debug,"native repair and collapse victory preserve marked statistics")
 w.stop225();w.levels226={"paper_plane":1,"balloon_sword":1,"pillow_hut":1,"exercise":1};w.start_battle225(false)
 w.auto114=false;w.pigs_enabled220=false;w.invulnerability=100000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 var launches=w.paper_memories146.planes_launched146
 await create_timer(.5).timeout
 check(w.paper_memories146.planes_launched146==launches,"aircraft does not self-launch when battle starts")
 var at=w.camera.unproject_position(w.cat220.hit_area.global_position)*Vector2(root.size)/root.get_visible_rect().size
 var motion=InputEventMouseMotion.new();motion.position=at;motion.global_position=at;Input.parse_input_event(motion)
 var mouse=InputEventMouseButton.new();mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=true;mouse.position=at;mouse.global_position=at;Input.parse_input_event(mouse)
 await create_timer(6.).timeout
 check(w.paper_memories146.planes_launched146>launches and w.swords153.landed153>0,"held real mouse launches manual aircraft and attaches swords")
 var births=w.swords153.births226;var reused=w.swords153.reuses226
 await create_timer(4.).timeout
 check(w.swords153.reuses226>reused and w.swords153.births226<=births+8,"continuous volleys reuse bounded sword pad and shadow objects")
 check(w.cat220.hp<100000. and w.swords153.layers153.get(w.cat220.get_instance_id(),[]).size()<=5,"pooled swords retain damage and five-layer slow cap")
 mouse=mouse.duplicate();mouse.pressed=false;Input.parse_input_event(mouse);await create_timer(.2).timeout
 launches=w.paper_memories146.planes_launched146;await create_timer(1.5).timeout
 check(w.paper_memories146.planes_launched146==launches,"releasing mouse stops new aircraft launches")
 w._clear_combat_shots();await process_frame
 check(w.swords153.resting153.is_empty() and w.swords153.flying153.is_empty() and w.swords153.blades226.all(func(n):return not n.visible) and w.swords153.pads226.all(func(n):return not n.visible),"reset hides all pooled blades pads and clears live attachment records")
 await key(KEY_F4);await key(KEY_F8)
 check(w.auto114,"explicit F4 auto mode survives restart")
 await key(KEY_F4);await key(KEY_F8)
 check(not w.auto114,"manual mode survives restart")
 w.stop225()
 check([w.memory_kit116.next_event119,w.memory_kit116.last_reward119,w.memory_kit116.gel119]==previous_progress,"testing and loadout changes grant no formal progress or rewards")
 var old=load("res://scripts/world/world21.gd").new();old.player_hp=50.
 check(old.max_player_health()==100. and is_equal_approx(old.health_fraction(),.5),"legacy world keeps original hundred-point health defaults");old.free()
 if cfg_exists:FileAccess.open(cfg_path,FileAccess.WRITE).store_buffer(cfg_backup)
 else:DirAccess.remove_absolute(ProjectSettings.globalize_path(cfg_path))
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/balance226-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics},"\t"))
 print("BALANCE226_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
