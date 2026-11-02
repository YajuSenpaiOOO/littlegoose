extends "res://scripts/world/validate_plush220.gd"
class TestWorld:
 extends "res://scripts/world/woodland_world229.gd"
 func _init() -> void:
  super._init();memory_save116="user://balance229_validation_preview.cfg"
 func export_stats226() -> Error:return OK
var configs229 := {}
func run() -> void:
 for path in ["user://boss_balance226.cfg","user://boss_balance228.cfg","user://boss_balance229.cfg"]:
  configs229[path]=FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
 var book=preload("res://scripts/combat/buff_book229.gd").new();book.levels={"eye_exercise":1}
 check(is_equal_approx(book.rate(),1.25),"one eye gives twenty-five percent rate")
 book.levels.eye_exercise=2;check(is_equal_approx(book.rate(),1.5),"two eyes give fifty percent total rate")
 book.moment_rate161=2.;check(is_equal_approx(book.rate(),3.),"stage multiplier still composes with reduced eye")
 var legacy=preload("res://scripts/combat/buff_book168.gd").new();legacy.levels={"eye_exercise":1}
 check(legacy.rate()==1.5,"old preview keeps fifty percent eye for comparison")
 w=TestWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 check(w.test_config_path226()=="user://boss_balance229.cfg" and w.cat_health226==100. and w.bat_health226==80.,"229 isolates settings and retains rhythm HP")
 check("25%" in w.memory_kit116.effect118("eye_exercise",1) and "35%" in w.memory_kit116.effect118("flashlight",1),"equipment descriptions match new effects")
 w.levels226={"flashlight":1,"three_player":1,"eye_exercise":1};w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 for health in [14.,7.,5.,14./3.,4.,1.,0.]:
  w.player_hp=health
  var expected=1.35 if health>0. and health<14./3. else 1.
  check(is_equal_approx(w.flashlight_damage_gain110(),expected) and w.flashlight_rate_gain110()==1.,"threshold damage only at HP="+str(health))
 w.player_hp=14.;w.levels226={"flashlight":1,"paper_plane":1,"eye_exercise":1};w.apply_levels226()
 var full=w.snapshot_packet146(w.cat220.hit_area.global_position,false,0.)
 w.player_hp=4.;var red=w.snapshot_packet146(w.cat220.hit_area.global_position,false,0.)
 check(not full.is_empty() and is_equal_approx(full.pulse_interval,red.pulse_interval),"aircraft/notes beam packet gains no low-health firing frequency")
 check(is_equal_approx(float(red.specs[0].damage)/float(full.specs[0].damage),1.35),"beam packet snapshots fixed red damage once")
 w.player_hp=1.;var critical=w.snapshot_packet146(w.cat220.hit_area.global_position,false,0.)
 check(is_equal_approx(float(critical.specs[0].damage),float(red.specs[0].damage)),"lower HP does not further increase packet damage")
 w.levels226={"flashlight":1,"three_player":1,"eye_exercise":1};w.apply_levels226()
 for health in [14.,4.,1.]:await sample229(health)
 var ratio=metrics["4"].dps/metrics["14"].dps
 check(absf(ratio-1.35)<.07,"native direct beam DPS scales by fixed thirty-five percent")
 check(absf(metrics["1"].dps/metrics["4"].dps-1.)<.05,"native one-HP beam equals four-HP beam")
 w.player_hp=4.;await settle(3)
 check(w.encounter_hud.timer229.visible,"red lamp appears below one third")
 var age=w.encounter_hud.timer229.age229;w.combat_paused=true;await create_timer(.2).timeout
 check(w.encounter_hud.timer229.age229==age,"red lamp pulse freezes while paused")
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/balance229-red-lamp.png")
 w.combat_paused=false;w.player_hp=5.;await process_frame;await process_frame
 check(not w.encounter_hud.timer229.visible,"red lamp clears above threshold")
 w.player_hp=4.;w.levels226={};w.apply_levels226();await process_frame;await process_frame
 check(not w.encounter_hud.timer229.visible and w.flashlight_damage_gain110()==1.,"unequipping flashlight removes red lamp and benefit")
 w.start_battle225(false);w.auto114=false;await settle(3)
 check(w.player_hp==14. and not w.encounter_hud.timer229.visible,"restart restores normal-health lamp state")
 check(w.report_stats226().balance229.eye_rate_level1==1.25,"recording carries balance version and exact parameters")
 w.levels226={"flashlight":1};w.apply_levels226();w.cat220.set_physics_process(false);w.cat220.receive_hit(1000000.,Vector3.ZERO);await create_timer(1.5).timeout
 check(w.window226.has("start_hp") and w.window226.has("stage_seconds"),"repair records HP and stage coverage fields")
 w.player_hp=4.;await create_timer(.25).timeout
 check(w.window226.red_seconds>0. and w.red_seconds229>0.,"repair records actual red-lamp coverage")
 w.stop225()
 var old=preload("res://scripts/world/woodland_world226.gd").new();old.player_hp=7.
 check(is_equal_approx(old.flashlight_damage_gain110(),1.3) and is_equal_approx(old.flashlight_rate_gain110(),1.3),"legacy flashlight hooks retain original continuous gain");old.free()
 for path in configs229:
  var current=FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
  check(current==configs229[path],"user config unchanged: "+path)
 finish()
func sample229(health: float) -> void:
 w.auto114=false;w._clear_combat_shots();w.player_hp=health;w.cooldown=0.;w.fire_needs_release=false;w.skills110.beam_tick110=0.;w.target114=null;w.aim_tick114=-1
 var before=w.cat220.hp;var elapsed=w.stats226.seconds;w.auto114=true
 await create_timer(6.).timeout;w.auto114=false
 var seconds=w.stats226.seconds-elapsed;metrics[String.num(health,0)]={"seconds":seconds,"damage":before-w.cat220.hp,"dps":(before-w.cat220.hp)/seconds}
func finish() -> void:
 var failed=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/balance229-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failed.size(),"metrics":metrics},"\t"))
 print("BALANCE229_DONE checks=",checks.size()," failures=",failed.size()," metrics=",metrics);quit(0 if failed.is_empty() else 1)
