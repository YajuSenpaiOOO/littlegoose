extends "res://scripts/world/woodland_world169.gd"
## Standalone no-reward prototype on the original woodland clearing.
const BUILDS247=[{}, {"slingshot":1}, {"snack":1}, {"eye_exercise":1}, {"balloon_sword":1}]
var ready247 := false
var boss247: CharacterBody3D
var guide247: Label
var build247 := 0
var result247 := ""
func _init() -> void:
 super._init();memory_save116="user://tuantuan_boss247_preview.cfg"
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/boss_hud247.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 247 · 团团Boss / 弹力三连跳原型")
func _ready() -> void:
 await super._ready()
 while not hill_ready146 or not is_instance_valid(arc_shadows167):await get_tree().physics_frame
 var layer=CanvasLayer.new();layer.layer=50;add_child(layer)
 guide247=Label.new();guide247.position=Vector2(18,80);guide247.add_theme_font_size_override("font_size",20);layer.add_child(guide247)
 ready247=true;begin247()
func clear247() -> void:
 _cancel_charge();_clear_combat_shots();clear_standby119()
 for actor in enemies:
  if is_instance_valid(actor):
   actor.set_physics_process(false);actor.collision_layer=0;actor.hit_area.collision_layer=0;remove_child(actor);actor.queue_free()
 enemies.clear();reuse119.clear();retired119.clear();refill114=0.;ending119=-1.;target114=null;aim_tick114=-1
 _prune_actor_shadows()
func begin247() -> void:
 clear247();result247="";trial152=true;paper_trial129=false;won119=false
 _travel_region("grove")
 active114=true;wave_state="fighting";combat_paused=false;elapsed114=0.;defeated_count=0;total_enemies=1;reward_offered=true
 player_hp=max_player_health();invulnerability=1.;Engine.time_scale=1.;stop_until=0.
 hero.knocked_down=false;hero.reset_actions();hero.cancel_guard109();hero.controls_enabled=true
 trial_ui114.menu.hide();_teleport15(meadow.landmarks.grove+Vector2(0.,3.))
 auto114=false;apply_paper_build129()
 boss247=boss_script247().new()
 boss247.battle=self;boss247.poses=combat_poses;boss247.textures=combat_textures;boss247.home=meadow.landmarks.grove
 boss247.rank110=2;boss247.body_scale110=boss_size247();boss247.max_hp110=90.;boss247.hp=90.;boss247.touch110=18.
 var at: Vector2=meadow.landmarks.grove+Vector2(0.,-2.)
 boss247.position=Vector3(at.x,floor_height(at)+.03,at.y);add_child(boss247);enemies.append(boss247)
 rebuild_cells110();boss247.reset_physics_interpolation()
func boss_script247() -> Script:return preload("res://scripts/combat/tuantuan_boss247.gd")
func boss_size247() -> float:return 1.65
func safe_goal247(start: Vector2,wanted: Vector2) -> Vector2:
 # Keep a full boss footprint clear; do not teleport through trees or rock walls.
 var shape=CapsuleShape3D.new();shape.radius=maxf(.62,boss_size247()*.35+.04);shape.height=maxf(1.32,boss_size247()*.8)
 var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1|2
 query.exclude=[hero.get_rid()]
 if is_instance_valid(boss247):query.exclude.append(boss247.get_rid())
 var last=start
 var steps=maxi(1,int(ceil(start.distance_to(wanted)/.2)))
 for i in range(1,steps+1):
  var at=start.lerp(wanted,float(i)/steps)
  var h=floor_height(at)
  if absf(h-floor_height(last))>.3:break
  query.transform.origin=Vector3(at.x,h+shape.height*.5+.04,at.y)
  if not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():break
  last=at
 return last
func apply_paper_build129() -> void:
 if not ready247:return
 _cancel_charge();_clear_combat_shots();buffs.levels=BUILDS247[build247].duplicate();_apply_owned_buffs()
func _step_outing119(_delta: float) -> void:pass
func enemy_defeated(actor: CharacterBody3D) -> void:
 if ready247 and actor==boss247:
  defeated_count=1;call_deferred("finish247",true)
func finish247(victory: bool) -> void:
 active114=false;wave_state="waiting";combat_paused=false;hero.controls_enabled=true;hero.cancel_guard109()
 _cancel_charge();_clear_combat_shots();target114=null;refill114=0.;ending119=-1.;Engine.time_scale=1.;stop_until=0.
 if is_instance_valid(boss247):boss247.marker247.hide();boss247.lift247=0.;boss247.velocity=Vector3.ZERO
 result247="团团躺平认输啦" if victory else "试演结束"
func finish114() -> void:
 if ready247:finish247(false)
 else:super.finish114()
func start_combat(_reposition := true) -> void:
 # Legacy world21 calls this automatically near the grove every waiting frame.
 # Only explicit F7 / begin247 may start this independent encounter.
 pass
func _process(delta: float) -> void:
 super._process(delta)
 if not ready247:return
 var state=""
 if is_instance_valid(boss247):
  var labels={"rest":"准备中","squat":"蓄力压扁","flight":"弹力跳 · 第%d次"%(boss247.jump247+1),"rebound":"借力回弹","flat":"摊平休息","pounce_wait":"准备短扑","pounce":"短扑"}
  state="血量 %d / 90 · %s"%[maxf(0.,boss247.hp),labels.get(boss247.phase247,"休息")]
 guide247.visible=active114 or result247!=""
 guide247.text="247 团团Boss · 弹力三连跳原型\n"+state+"\nWASD移动 / 左键射击 / Shift闪避 / 右键防御弹反\nF4自动瞄准开关 / F6暂停 / F7重开 / F2结束 / F3回院\n1普通 2弹弓 3分裂 4追踪 5气球剑 · 无正式奖励\n"+result247
 if combat_paused:guide247.text+=" · 暂停"
func _input(event: InputEvent) -> void:
 if ready247 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  match event.physical_keycode:
   KEY_F7:begin247()
   KEY_F6:
    if active114:combat_paused=not combat_paused;hero.controls_enabled=not combat_paused
   KEY_F4:auto114=not auto114
   KEY_F2:finish247(false)
   KEY_F3:finish247(false);clear247();home116()
   KEY_F5,KEY_F8,KEY_F9,KEY_F11,KEY_F,KEY_E,KEY_ESCAPE:return
   _:
    if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_5:
     build247=event.physical_keycode-KEY_1;apply_paper_build129()
    else:super._input(event);return
  get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if ready247 and event is InputEventKey and event.physical_keycode in [KEY_F2,KEY_F3,KEY_F4,KEY_F5,KEY_F6,KEY_F7,KEY_F8,KEY_F9,KEY_F11,KEY_ESCAPE]:return
 super._unhandled_input(event)
