extends "res://scripts/world/woodland_world246.gd"
var ready251 := false
var boss247: CharacterBody3D
var projection250: MeshInstance3D
var show_landing249 := false
var impact248 := 0
var result251 := ""
func _init() -> void:
 super._init();memory_save116="user://tuantuan_boss251_preview.cfg";levels226={};loadout_name226="普通射击";cat_health226=90.
func alternate_encounter251() -> bool:return ready251
func test_config_path226() -> String:return "user://boss_balance251.cfg"
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/boss_hud251.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 251 · 团团Boss / 246战斗基线")
func _ready() -> void:
 await super._ready()
 stop225();clear_support227();quiet_support228()
 rig220.hide();rig220.set_process(false);delivery225.hide();delivery225.set_process(false)
 ready251=true
 console226.queue_free();console226=preload("res://scripts/combat/boss_console251.gd").new();console226.world=self
 var layer=CanvasLayer.new();layer.layer=70;add_child(layer);layer.add_child(console226)
 begin251()
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226()
func clear251() -> void:
 _cancel_charge();_clear_combat_shots();clear_standby119();clear_support227();clear_pig220()
 for actor in enemies:
  if is_instance_valid(actor):
   actor.set_physics_process(false);actor.collision_layer=0;actor.hit_area.collision_layer=0;remove_child(actor);actor.queue_free()
 enemies.clear();bats220.clear();cat220=null;reuse119.clear();retired119.clear();_prune_actor_shadows();target114=null;aim_tick114=-1;refill114=0.;ending119=-1.
func begin251() -> void:
 clear251();reset_impact248();result251="";trial152=true;paper_trial129=false;spider_trial170=false;won119=false
 _travel_region("grove")
 active114=true;wave_state="fighting";stage225="battle";battle_phase220="fight";combat_paused=false;elapsed114=0.;defeated_count=0;total_enemies=1;reward_offered=true
 repairs220=0;pigs_enabled220=false;called227=true
 player_hp=max_player_health();invulnerability=.8;hero.knocked_down=false;hero.reset_actions();hero.cancel_guard109();hero.controls_enabled=true
 trial_ui114.menu.hide();_teleport15(meadow.landmarks.grove+Vector2(0.,3.));apply_levels226();reset_stats226(false)
 boss247=boss_script251().new();boss247.battle=self;boss247.poses=combat_poses;boss247.textures=combat_textures;boss247.home=meadow.landmarks.grove
 boss247.rank110=2;boss247.body_scale110=2.15;boss247.max_hp110=cat_health226;boss247.hp=cat_health226;boss247.touch110=2.5
 var at: Vector2=meadow.landmarks.grove+Vector2(0.,-2.)
 boss247.position=Vector3(at.x,floor_height(at)+.03,at.y);add_child(boss247);enemies.append(boss247);rebuild_cells110();boss247.reset_physics_interpolation()
 _add_actor_shadow(boss247,boss247.visual);projection250=actor_shadows[-1];time55.apply_look();encounter_hud.reset_round()
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_boss251.gd")
func safe_goal247(start: Vector2,wanted: Vector2) -> Vector2:
 var shape=CapsuleShape3D.new();shape.radius=.7925;shape.height=1.72
 var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1|2;query.exclude=[hero.get_rid()]
 if is_instance_valid(boss247):query.exclude.append(boss247.get_rid())
 var last=start;var steps=maxi(1,int(ceil(start.distance_to(wanted)/.2)))
 for i in range(1,steps+1):
  var at=start.lerp(wanted,float(i)/steps);var h=floor_height(at)
  if absf(h-floor_height(last))>.3:break
  query.transform.origin=Vector3(at.x,h+.90,at.y)
  if not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():break
  last=at
 return last
func start_combat(_reposition := true) -> void:pass
func start_battle225(keep_player: bool) -> void:
 if ready251:begin251()
 else:super.start_battle225(keep_player)
func enemy_defeated(actor: CharacterBody3D) -> void:
 if ready251 and actor==boss247:defeated_count=1;call_deferred("finish251",true)
func finish251(victory: bool) -> void:
 active114=false;stage225="waiting";wave_state="waiting";combat_paused=false;hero.controls_enabled=true;hero.cancel_guard109();_cancel_charge();_clear_combat_shots()
 reset_impact248();target114=null;refill114=0.;ending119=-1.;result251="团团认输啦" if victory else "试演结束"
 if is_instance_valid(boss247):boss247.marker247.hide();boss247.lift247=0.;boss247.velocity=Vector3.ZERO
 stats226.result="胜利" if victory else "结束";recording226.finish(self,stats226.result)
func finish114() -> void:
 if ready251:finish251(false)
 else:super.finish114()
func end220(victory: bool) -> void:
 if ready251:finish251(victory)
 else:super.end220(victory)
func record_enemy_damage226(actor: Node,damage: float) -> void:
 if ready251 and actor==boss247 and damage>0.:
  stats226.cat_damage+=damage;round_damage226+=damage;recording226.hit(true,false)
 else:super.record_enemy_damage226(actor,damage)
func export_stats226() -> Error:
 var file=FileAccess.open("user://boss_balance251_last.json",FileAccess.WRITE)
 if file==null:return FileAccess.get_open_error()
 file.store_string(JSON.stringify(report_stats226(),"  "));return recording226.save(self)
func summary_stats226() -> String:
 if not ready251:return super.summary_stats226()
 return "团团Boss · %s\n决心上限 %.0f · %d / 6槽\n有效战斗 %.1f秒 · 累计伤害 %.1f\nDPS %.2f · 受伤%d次"%[stats226.get("result","待开战"),max_player_health(),balance_profile226().cost(levels226),stats226.get("seconds",0.),stats226.get("cat_damage",0.),float(stats226.get("cat_damage",0.))/maxf(.001,float(stats226.get("seconds",0.))),stats226.get("injuries",[]).size()]
func reset_impact248() -> void:
 impact248=0;impact_clock.clear();stop_until=0.;stop_gate=0.;stop_duration=0.;punch=0.;dodge_zoom=0.;closeup_started=-1.;closeup_weight=0.;trauma=0.
func boss_impact248(_contact: Vector3) -> void:
 impact248+=1;impact_clock.cancel_pending("parry");impact_clock.cancel_pending("boss251");hitstop(.11,true);impact_clock.add(.28,.30,.11,"boss251");punch=maxf(punch,1.05);trauma=minf(1.,trauma+.25)
func toggle_console226() -> void:
 reset_impact248();super.toggle_console226()
func close_console226() -> void:
 super.close_console226();stamp236=Time.get_ticks_usec()
func _input(event: InputEvent) -> void:
 if ready251 and (not is_instance_valid(console226) or not console226.visible) and event is InputEventKey and event.pressed and not event.echo:
  match event.physical_keycode:
   KEY_F7,KEY_F8:begin251()
   KEY_F6:reset_impact248();combat_paused=not combat_paused;hero.controls_enabled=not combat_paused
   KEY_F4:auto114=not auto114;target114=null
   KEY_F2:finish251(false)
   KEY_F3:finish251(false);clear251();home116()
   KEY_F10:
    show_landing249=not show_landing249
    if is_instance_valid(boss247):
     boss247.marker247.visible=show_landing249 and boss247.phase247 in ["flight","pounce"]
     if boss247.marker247.visible:boss247.draw_marker247()
   KEY_F5,KEY_F9,KEY_F11,KEY_E:return
   _:super._input(event);return
  get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if ready251 and event is InputEventKey and event.physical_keycode in [KEY_F2,KEY_F3,KEY_F4,KEY_F5,KEY_F6,KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_E]:return
 super._unhandled_input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if not ready251:return
 if active114 and not combat_paused:
  stats226.seconds+=delta;fight_age226+=delta;recording226.step(self,delta,"fight")
 var state="待开战"
 if is_instance_valid(boss247):state="Boss %d / %d · 第%d / %d砸"%[maxf(0.,boss247.hp),boss247.max_hp110,mini(boss247.jump247+1,boss247.total248),boss247.total248]
 guide206.text="251 团团Boss · 246战斗基线\n"+state+"\nC 装配与统计 · 决心 %.0f · %d / 6槽\nF7重开 / F6暂停 / F4瞄准 / F10落地圈 / F3回院\n"%[max_player_health(),balance_profile226().cost(levels226)]+result251
