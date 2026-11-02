extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world263.gd"
 var held263 := false
 func _init() -> void:
  super._init();memory_save116="user://beam263-capture-preview.cfg"
 func test_config_path226() -> String:return "user://beam263-capture.cfg"
 func export_stats226() -> Error:return OK
 func fire_input_held() -> bool:return held263
 func aim_at_screen(point: Vector2) -> Vector3:
  if is_instance_valid(boss247):return boss247.hit_area.global_position
  return super.aim_at_screen(point)
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.red_beacon263):await process_frame
 w.hero.set_physics_process(false);w.hero.controls_enabled=false;w.boss247.set_physics_process(false);w.auto114=false
 w.levels226={"flashlight":1,"eye_exercise":1};w.apply_levels226();w.held263=true;w.fire_needs_release=false
 await create_timer(2.).timeout
 var normal_hp=w.boss247.hp
 check(normal_hp<90. and not w.shots.is_empty(),"native held-fire loop hits actual boss with the new renderer")
 w.combat_paused=true;await shot("beam263-native-normal");w.combat_paused=false
 w.player_hp=3.;await create_timer(2.).timeout
 check(w.red_beacon263.visible and w.encounter_hud.timer229.visible and w.boss247.hp<normal_hp,"native red firing displays beacon HUD and keeps damaging")
 var core=w.red_beacon263.core263.global_position;var before=w.hero.position
 w.hero.position+=Vector3(.5,0,.2);w.red_beacon263._process(0.)
 check((w.red_beacon263.core263.global_position-core).distance_to(w.hero.position-before)<.001,"world-space chest light follows actor movement")
 w.hero.position=before;w.combat_paused=true;await shot("beam263-native-red");w.combat_paused=false
 w.buffs.levels.erase("flashlight");w._process(0.);w.red_beacon263._process(0.);w.encounter_hud.timer229._process(0.)
 check(not w.red_beacon263.visible and not w.encounter_hud.timer229.visible,"unequipping flashlight clears low-health effects")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/beam263-native-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));f.close()
 print("BEAM263_NATIVE ",ok);quit(0 if ok else 1)
