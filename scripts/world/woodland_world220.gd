extends "res://scripts/world/woodland_world216.gd"
var ready220 := false
var battle_phase220 := "fight"
var phase_age220 := 0.
var rig220: Node3D
var cat220: CharacterBody3D
var bats220: Array[CharacterBody3D]=[]
var pig220: Node3D
var cotton220: Node3D
var arena220 := Vector2.ZERO
var rig_at220 := Vector2.ZERO
var rig_from220 := Vector2.ZERO
var rig_height220 := 2.
var drop_goal220 := Vector2.ZERO
var delivery220 := false
var delivery_age220 := 0.
var drop_wait220 := 2.2
var pigs_enabled220 := true
var dropped220 := 0
var repairs220 := 0
var saved_hp220 := 100.
var saved_buffs220 := {}
var result220 := ""
var win_pending220 := false
var progress_before220 := {}
func _init() -> void:
 super._init();memory_save116="user://plush_boss220_preview.cfg"
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 220 · 肥猫滚动 / 姐姐投放猪猪 / 修补与蝙蝠")
func start_spider170() -> void:
 if ready220:begin220()
func _encounter_hud_script37() -> Script:
 return preload("res://scripts/combat/plush_hud220.gd")
func _enemy_script() -> Script:
 return preload("res://scripts/combat/fat_cat_boss220.gd") if ready220 and context202 else super._enemy_script()
func _ready() -> void:
 await super._ready()
 ready216=false;cat216.free();arena220=spawn216
 rig220=preload("res://scripts/art/sister_battle220.gd").new();rig220.world=self;rig220.start_at=arena220;rig220.end_at=arena220;add_child(rig220)
 cotton220=preload("res://scripts/combat/cotton_stream220.gd").new();cotton220.world=self;add_child(cotton220)
 ready220=true;begin220()
func _spawn_wave110(index: int) -> void:
 if not ready220 or not context202:super._spawn_wave110(index);return
 _clear_combat_shots();clear_standby119()
 for actor in enemies:
  if is_instance_valid(actor):
   actor.set_physics_process(false);actor.collision_layer=0;actor.hit_area.collision_layer=0;actor.queue_free()
 enemies.clear();reuse119.clear();bats220.clear();retired119.clear();round_index=0;between_left=0.;ending119=-1.;refill114=0.;packs114=1;total_enemies=3
 cat220=preload("res://scripts/combat/fat_cat_boss220.gd").new();cat220.battle=self;cat220.poses=combat_poses;cat220.textures=combat_textures;cat220.home=arena220
 cat220.name="FatCat220";cat220.position=Vector3(arena220.x,floor_height(arena220),arena220.y);add_child(cat220)
 cat220.max_hp110=120.;cat220.hp=120.;cat220.play119();enemies.append(cat220)
 for i in 2:
  var bat=preload("res://scripts/combat/bat_target220.gd").new();bat.battle=self;bat.poses=combat_poses;bat.textures=combat_textures;bat.home=arena220;bat.rig220=rig220;bat.index220=i;bat.name="BatTarget220_"+str(i);add_child(bat);bats220.append(bat);enemies.append(bat)
 rebuild_cells110();target114=null;aim_tick114=-1;call_deferred("_prune_actor_shadows")
func begin220() -> void:
 if active114:end220(false)
 saved_hp220=player_hp;saved_buffs220=buffs.levels.duplicate(true);win_pending220=false
 progress_before220={"next":memory_kit116.next_event119,"gel":memory_kit116.gel119,"reward":memory_kit116.last_reward119}
 context202=true;meadow.landmarks.grove=arena220;navigation=forest_navigation202
 trial152=true;paper_trial129=false;spider_trial170=true;spider_count170=1;hill_visited136=true;won119=false
 battle_phase220="fight";phase_age220=0.;result220="";drop_wait220=2.2;delivery220=false;dropped220=0;repairs220=0
 clear_pig220();cotton220.running=true;cotton220.enabled219=true
 rig220.lost220=-1
 for bat in rig220.bats:bat.scale=Vector3.ONE;bat.modulate=Color.WHITE
 rig_at220=arena220+Vector2(1.,-1.2);rig_height220=2.;rig220.place220(rig_at220,rig_height220,0.);rig220._process(0.)
 super.start_combat(false)
 cat220.max_hp110=120.;cat220.hp=120.
 _teleport15(arena220+Vector2(-3.1,1.))
 hero.controls_enabled=true;combat_paused=false
 announce152()
func announce152() -> void:
 if not ready220:super.announce152();return
 if is_instance_valid(encounter_hud):encounter_hud.announce("肥猫与玩偶小剧场","慢追 / 接触伤害 / 预告滚动 · 打软肥猫后攻击低空蝙蝠",3.)
func _step_outing119(delta: float) -> void:
 if not ready220:super._step_outing119(delta)
func enemy_defeated(actor: CharacterBody3D) -> void:
 if not ready220:super.enemy_defeated(actor)
func notice219(value: String) -> void:
 if is_instance_valid(encounter_hud):encounter_hud.announce(value,"",1.2)
func cat_down220(_cat: CharacterBody3D) -> void:
 if battle_phase220!="fight":return
 battle_phase220="lower";phase_age220=0.;rig_from220=rig_at220;delivery220=false;clear_pig220();target114=null;aim_tick114=-1;rebuild_cells110()
 notice219("肥猫软掉了！姐姐降下来缝补")
func bat_down220(index: int) -> void:
 if battle_phase220!="repair" or win_pending220:return
 win_pending220=true;rig220.lost220=index
 for bat in bats220:bat.set_enabled220(false)
 call_deferred("end220",true)
func clear_pig220() -> void:
 if is_instance_valid(cotton220):cotton220.clear219()
 if is_instance_valid(pig220):pig220.queue_free()
 pig220=null
func choose_drop220() -> Vector2:
 var player=Vector2(hero.position.x,hero.position.z)
 var wanted=player-Vector2(-1.,.4).normalized()*2.3
 return _spawn_spot110(wanted,[],.45)
func release_pig220() -> void:
 clear_pig220()
 pig220=preload("res://scripts/art/pig_drop220.gd").new();pig220.world=self
 pig220.position=Vector3(drop_goal220.x,floor_height(drop_goal220),drop_goal220.y)
 rig220._process(0.);pig220.source220=rig220.seated.global_position+camera.global_basis.y*.25
 add_child(pig220);pig220.stream=cotton220;cotton220.pig=pig220;cotton220.running=true;dropped220+=1
func _process(delta: float) -> void:
 super._process(delta)
 if not ready220:return
 var bat_hp=""
 for bat in bats220:
  if is_instance_valid(bat):bat_hp+=str(ceili(bat.hp))+" "
 guide206.text="220 肥猫小剧场 · "+{"fight":"肥猫追逐与滚动","lower":"姐姐下降修补","repair":"锁定低空蝙蝠！","rise":"修好肥猫，再次升空","landing":"蝙蝠撑不住了，吊床落地","ended":result220}[battle_phase220]+"\n肥猫 "+str(ceili(cat220.hp) if is_instance_valid(cat220) else 0)+"/120 · 蝙蝠 "+bat_hp+"\n自动攻击 / WASD / Shift闪避 / 右键防御弹反 · 1—9既有组合\nF4自动/鼠标瞄准 · F5猪猪 "+("开" if pigs_enabled220 else "关")+" · F6暂停 · F7重开\nF2结束试演 · F3回院 · 猪猪不可攻击，短时喷射后退场"+("\n【暂停】" if combat_paused else "")
 if battle_phase220=="repair":guide206.text+="\n修补进度 "+str(int(clampf(phase_age220/6.,0.,1.)*100.))+"%"
 if combat_paused:return
 phase_age220+=delta
 if battle_phase220=="fight" and active114:
  if is_instance_valid(pig220) and pig220.phase219=="gone" and cotton220.active.is_empty():clear_pig220()
  if pigs_enabled220:
   drop_wait220-=delta
   if not delivery220 and drop_wait220<=0. and not is_instance_valid(pig220):
    drop_goal220=choose_drop220();delivery220=true;delivery_age220=0.;rig_from220=rig_at220
   if delivery220:
    delivery_age220+=delta;rig_at220=rig_from220.lerp(drop_goal220,smoothstep(0.,.8,delivery_age220))
    if delivery_age220>=1.:
     delivery220=false;release_pig220();drop_wait220=7.5
  rig_height220=2.
 elif battle_phase220=="lower":
  var at=Vector2(cat220.position.x,cat220.position.z)+Vector2(1.,.9)
  var t=smoothstep(0.,1.3,phase_age220);rig_at220=rig_from220.lerp(at,t);rig_height220=lerpf(2.,.10,t)
  if phase_age220>=1.3:
   battle_phase220="repair";phase_age220=0.;repairs220+=1
   for bat in bats220:bat.set_enabled220(true)
   rebuild_cells110();target114=null;aim_tick114=-1
 elif battle_phase220=="repair":
  rig_height220=.10
  if phase_age220>=6.:
   battle_phase220="rise";phase_age220=0.
   for bat in bats220:bat.set_enabled220(false)
   rebuild_cells110();target114=null;aim_tick114=-1
 elif battle_phase220=="rise":
  rig_height220=lerpf(.1,2.,smoothstep(0.,1.2,phase_age220))
  if phase_age220>=1.2:
   cat220.repair220();battle_phase220="fight";phase_age220=0.;drop_wait220=2.
 elif battle_phase220=="landing":
  rig_height220=lerpf(.1,0.,smoothstep(0.,1.5,phase_age220))
  if phase_age220>=1.5:battle_phase220="ended";result220="试演完成 · F7再来一场"
 rig220.place220(rig_at220,rig_height220,delta)
func restore_context220() -> void:
 meadow.landmarks.grove=original_grove202;navigation=original_navigation202;context202=false;spider_trial170=false;trial152=false;won119=false
 buffs.levels=saved_buffs220.duplicate(true);_apply_owned_buffs();player_hp=saved_hp220;hero.knocked_down=false;hero.cancel_guard109();hero.controls_enabled=true
 Engine.time_scale=1.;stop_until=0.;ending119=-1.;refill114=0.;target114=null;aim_tick114=-1
func end220(victory: bool) -> void:
 active114=false;combat_paused=false;wave_state="waiting";_clear_combat_shots();clear_pig220();delivery220=false
 for bat in bats220:
  if is_instance_valid(bat):bat.set_enabled220(false)
 if is_instance_valid(cat220):cat220.dead=true;cat220.hit_area.collision_layer=0;cat220.enter220("down");cat220.velocity=Vector3.ZERO
 restore_context220()
 battle_phase220="landing" if victory else "ended";phase_age220=0.;result220="试演结束 · F7重开"
func finish114() -> void:
 if ready220:end220(false)
 else:super.finish114()
func _input(event: InputEvent) -> void:
 if ready220 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  match event.physical_keycode:
   KEY_F7:begin220()
   KEY_F6:
    if active114:combat_paused=not combat_paused;hero.controls_enabled=not combat_paused
   KEY_F5:
    pigs_enabled220=not pigs_enabled220
    if not pigs_enabled220:clear_pig220();delivery220=false
   KEY_F4:auto114=not auto114;target114=null;aim_tick114=-1
   KEY_F2:end220(false)
   KEY_F3:
    end220(false);super._input(event);return
   KEY_E,KEY_V,KEY_F8,KEY_F9:return
   _:
    if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9 and active114:
     build170=event.physical_keycode-KEY_1;apply_paper_build129();return
    super._input(event);return
  get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if ready220 and event is InputEventKey and event.pressed and event.physical_keycode in [KEY_F2,KEY_F4,KEY_F5,KEY_F6,KEY_F7,KEY_F8,KEY_F9]:return
 super._unhandled_input(event)
