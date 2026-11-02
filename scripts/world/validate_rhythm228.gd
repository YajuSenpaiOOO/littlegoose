extends "res://scripts/world/validate_plush220.gd"
class TestWorld:
 extends "res://scripts/world/woodland_world228.gd"
 func _init() -> void:
  super._init();memory_save116="user://rhythm228_validation_preview.cfg"
 func export_stats226() -> Error:return OK
var old_config: PackedByteArray
var old_exists := false
func run() -> void:
 old_exists=FileAccess.file_exists("user://boss_balance226.cfg")
 if old_exists:old_config=FileAccess.get_file_as_bytes("user://boss_balance226.cfg")
 w=TestWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 check(w.test_config_path226()=="user://boss_balance228.cfg","228 config is isolated from 226/227 experiments")
 check(w.cat_health226==100. and w.bat_health226==80.,"fresh preview starts with cat100 bat80 rhythm trial")
 var old=preload("res://scripts/combat/fat_cat_boss221.gd").new()
 check(old.followup_allowed221() and old.recovery_time221()==1.1,"legacy cat keeps follow-up and original recovery");old.free()
 w.levels226={};w.start_battle225(false);w.auto114=false;w.invulnerability=10000.;w.pigs_enabled220=false;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 check(w.cat220.get_script()==preload("res://scripts/combat/fat_cat_boss228.gd") and not w.cat220.followup_allowed221(),"first round uses new single-roll cat")
 w.cat220.enter220("windup")
 check(is_equal_approx(w.cat220.windup_time221,.65) and w.choose_drop220()==Vector2.INF,"first round preparation is readable and rejects pig overlap")
 check(w.cat220.recovery_time221()==1.6,"first recovery grants a longer output opening")
 w.cat220.receive_hit(1000.,Vector3.ZERO);await create_timer(1.5).timeout
 check(w.battle_phase220=="repair" and w.repairs220==1 and not w.called227,"first repair remains quiet with no support spawning")
 check(w.bats220.all(func(b):return b.enabled220) and w.window226.size()>0,"quiet repair remains an attackable measured six-second window")
 w.phase_age220=6.1;await settle(3);w.phase_age220=1.3;await settle(3)
 check(w.battle_phase220=="fight" and w.repairs220==1 and not w.called227 and w.fight_clock228<.5,"second round starts with a grace period")
 check(w.drop_wait220>3.5 and w.cat220.followup_allowed221(),"second round permits follow-up while pig delivery waits")
 w.fight_clock228=2.1;w.cat220.enter220("chase");await settle(3)
 check(w.called227 and is_instance_valid(w.support227),"spider joins the second cat round instead of the second repair")
 var spider=w.support227;spider.set_physics_process(false)
 w.cat220.enter220("roll");spider.prepare170(Vector2(w.hero.position.x,w.hero.position.z))
 check(spider.state170=="watch" and w.pads172.is_empty(),"spider waits instead of weaving during a committed roll")
 w.cat220.enter220("chase");w.delivery220=true;spider.prepare170(Vector2.ZERO)
 check(spider.state170=="watch","spider waits during pig delivery")
 w.delivery220=false;spider.prepare170(Vector2.ZERO)
 check(spider.state170=="weave" and not w.cat_can_roll227(Vector2(w.cat220.position.x,w.cat220.position.z),Vector2(w.hero.position.x,w.hero.position.z)),"weaving reserves its own beat and suppresses a new roll")
 check(w.choose_drop220()==Vector2.INF,"pig cannot start while spider is weaving")
 spider.set_physics_process(true);await create_timer(1.95).timeout
 check(not w.pads172.is_empty() and w.pads172[0].live172,"support completes a real native web")
 var bat_hp=w.bats220[0].hp
 w.cat220.receive_hit(1000.,Vector3.ZERO);await settle(3)
 check(w.pads172.is_empty() and not spider.is_physics_processing() and spider not in w.enemies and spider.hit_area.collision_layer==0,"cat defeat clears webs and pauses/removes spider from aim targets")
 check(spider.visual.texture==spider.textures.idle and is_zero_approx(spider.visual.rotation.z),"quiet support changes from weaving/happy art to grounded idle")
 await create_timer(1.5).timeout
 check(w.battle_phase220=="repair" and w.bats220[0].hp==bat_hp,"bat damage persists and quiet second repair opens")
 var paused_clock=w.phase_age220;w.combat_paused=true;await create_timer(.15).timeout
 check(w.phase_age220==paused_clock,"pause freezes repair and rhythm state");w.combat_paused=false
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/rhythm228-repair.png")
 var report=w.report_stats226()
 check(report.has("rhythm228") and report.rhythm228.events.any(func(e):return e.event=="web_start"),"existing recorder exports phase and support events")
 w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 check(not w.called227 and not is_instance_valid(w.support227) and w.rig220.visible and w.bats220.all(func(b):return b.hp==80.),"restart cleans helpers and restores rig and independent bat HP")
 # Fully prepared active burst is allowed to finish in the first repair.
 w.levels226={"three_player":1,"eye_exercise":1,"hero_moment":1};w.apply_levels226();w.cat220.receive_hit(1000.,Vector3.ZERO);await create_timer(1.5).timeout
 # Controlled burst fixture: acquire a clear nearby bat before starting its window.
 var center=w.bats220[0].hit_area.global_position;var at=Vector2(center.x-3.,center.z)
 if w.open_drop225(at):w._teleport15(at)
 await settle(10)
 w.phase_age220=0.;w.cooldown=0.;w.fire_needs_release=false;w.target114=null;w.aim_tick114=-1
 var activated=w.moment161.request161();w.auto114=true
 var deadline=Time.get_ticks_msec()+15000
 while w.active114 and Time.get_ticks_msec()<deadline:await process_frame
 metrics.burst={"activated":activated,"result":w.stats226.result,"phase":w.battle_phase220,"repairs":w.repairs220,"windows":w.stats226.windows.duplicate(true),"remaining_bat_hp":[w.bats220[0].hp,w.bats220[1].hp]}
 check(not w.active114 and w.stats226.result=="胜利" and w.repairs220==1,"native stage burst can win first repair without a forced phase lock")
 if "--targeted" not in OS.get_cmdline_user_args():
  for build in [{"three_player":1,"eye_exercise":1},{"three_player":1,"eye_exercise":1,"flashlight":1}]:
   await natural228(build)
 w.stop225()
 check(FileAccess.file_exists("user://boss_balance226.cfg")==old_exists and (not old_exists or FileAccess.get_file_as_bytes("user://boss_balance226.cfg")==old_config),"old user loadout/HP file remains byte-identical")
 finish()
func natural228(build: Dictionary) -> void:
 w.levels226=build.duplicate();w.start_battle225(false);w.cat220.set_physics_process(false);w.hero.set_physics_process(false);w.pigs_enabled220=false;w.invulnerability=10000.;w.auto114=true
 var deadline=Time.get_ticks_msec()+95000
 while w.active114 and Time.get_ticks_msec()<deadline:await process_frame
 metrics[str(build)]={"seconds":w.stats226.seconds,"rounds":w.stats226.rounds.duplicate(true),"windows":w.stats226.windows.duplicate(true),"events":w.events228.duplicate(true),"result":w.stats226.result}
 check(not w.active114 and w.stats226.result=="胜利" and w.repairs220>=2,"native sustained build experiences a second round: "+str(build))
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/rhythm228-targeted.json" if "--targeted" in OS.get_cmdline_user_args() else "res://docs/rhythm228-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics},"\t"))
 print("RHYTHM228_DONE checks=",checks.size()," failures=",failures.size());quit(0 if failures.is_empty() else 1)
