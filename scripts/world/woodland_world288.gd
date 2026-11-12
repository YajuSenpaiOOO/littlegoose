extends "res://scripts/world/woodland_world276.gd"
var transform288: Node3D
var shade288: ColorRect
var hint288: Label
var saved_pause288 := false
var saved_controls288 := true
var visual_saved288 := true
var intro288 := false
var auto288 := 0.
var pixel288 := 0.
var camera_size288 := 0.
var camera_fov288 := 0.
var beacon_suspended288 := false
var beacon_process288 := true
var state_hud288: Control
const COOLDOWN288 := 30.
const NORMAL_GAIN288 := 1.2
const RED_GAIN288 := 1.9
var cooldown288 := 0.
var skill288 := false
var ended288 := false
var activations288 := 0
var beam_damage288 := 0.
func _init() -> void:
 super._init();memory_save116="user://flashlight288-preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit288.gd").new()
func balance_profile226() -> Script:return preload("res://scripts/combat/balance_profile288.gd")
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/encounter_hud288.gd")
func _skills_script110() -> Script:return preload("res://scripts/combat/battle_skills288.gd")
func test_config_path226() -> String:return "user://boss_balance288.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226();return
 levels226={"flashlight":1,"bouncy_ball":1,"exercise":1};loadout_name226="光能弹力";determination_level257=1;cat_health226=90.
func card_catalog273() -> Array:
 var cards=super.card_catalog273().duplicate(true)
 for card in cards:
  if card.id=="flashlight":card.fx=preload("res://scripts/combat/memory_kit288.gd").FLASH288
 return cards
func beam_active288() -> bool:
 return skill288 and is_instance_valid(transform288) and transform288.playing and transform288.age>=transform288.INTRO and transform288.age<transform288.END_BEGIN and int(levels226.get("flashlight",0))>0 and active114 and player_hp>0.
func sync_weapon288() -> void:
 if not is_instance_valid(buffs):return
 if beam_active288():buffs.levels["flashlight"]=int(levels226.flashlight)
 else:buffs.levels.erase("flashlight")
func apply_levels226() -> void:
 if is_instance_valid(transform288) and transform288.playing:cancel288()
 buffs.levels=levels226.duplicate(true);sync_weapon288();_apply_owned_buffs();aim_tick114=-1;target114=null
func flashlight_red229() -> bool:return beam_active288() and transform288.is_red()
func flashlight_damage_gain110() -> float:return RED_GAIN288 if flashlight_red229() else NORMAL_GAIN288
func flashlight_rate_gain110() -> float:return 1.
func red_pulse263() -> float:return transform288.pulse() if is_instance_valid(transform288) else 0.
func consume288() -> void:
 if ended288:return
 ended288=true;cooldown288=COOLDOWN288;stop_beam288()
func stop_beam288() -> void:
 beam_left110=0.
 for i in range(shots.size()-1,-1,-1):
  if shots[i].get("stream110",false):pool110.retire(shots[i]);shots.remove_at(i)
 pending_splits110=pending_splits110.filter(func(split):return not split.get("payload234",{}).get("stream",false))
 if is_instance_valid(skills110):skills110.beam_tick110=0.;skills110.chains110.clear();skills110.ribbon110.queue_redraw()
func _physics_process(delta: float) -> void:
 var started_cd=false
 if is_instance_valid(transform288) and transform288.playing:
  if skill288 and (not active114 or result_open or player_hp<=0. or hero.knocked_down or hero.story_knocked):cancel288()
  elif intro288 or not combat_paused:
   if skill288 and not ended288 and transform288.age+delta>=transform288.END_BEGIN:consume288();started_cd=true
   transform288.advance(delta)
 if not combat_paused and not started_cd:cooldown288=maxf(0.,cooldown288-delta)
 sync_weapon288();super._physics_process(delta)
func _step_fire_input(delta: float) -> void:
 if intro288:return
 if beam_active288():
  var allowed=not combat_paused and not result_open and wave_state=="fighting" and between_left<=0. and hero.controls_enabled and hero.dash_left<=0. and not hero.guarding109 and not hero.knocked_down
  beam_left110=.12 if allowed and fire_input_held() and not fire_needs_release else 0.
  if not fire_input_held():fire_needs_release=false
  return
 super._step_fire_input(delta)
func emit_stream110(target: Vector3) -> void:
 if not beam_active288():return
 var before=shots.size();super.emit_stream110(target)
 for i in range(before,shots.size()):shots[i].flashlight288=true
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var enemy: Variant=hit.collider.get_meta("enemy") if is_instance_valid(hit.get("collider")) and hit.collider.has_meta("enemy") else null
 var before=float(enemy.hp) if is_instance_valid(enemy) else 0.
 super._apply_shot_hit(shot,hit)
 if shot.get("stream110",false) and is_instance_valid(enemy):beam_damage288+=maxf(0.,before-maxf(0.,float(enemy.hp)))
func reset_skill288() -> void:
 if is_instance_valid(transform288) and transform288.playing:cancel288()
 cooldown288=0.;skill288=false;ended288=false;sync_weapon288()
func begin251() -> void:
 reset_skill288();super.begin251()
func yard264() -> void:
 reset_skill288();super.yard264()
func boss264() -> void:
 reset_skill288();super.boss264()
func finish251(victory: bool) -> void:
 if is_instance_valid(transform288) and transform288.playing:cancel288()
 super.finish251(victory)
func finish_ordinary264(victory: bool) -> void:
 if is_instance_valid(transform288) and transform288.playing:cancel288()
 super.finish_ordinary264(victory)
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 report.balance229.flashlight_damage_gain=RED_GAIN288/NORMAL_GAIN288
 report.balance229.flashlight_threshold="active_remaining <= 3 seconds"
 report.balance262.flashlight_normal=NORMAL_GAIN288;report.balance262.flashlight_red=RED_GAIN288
 report.balance262.red_relative=RED_GAIN288/NORMAL_GAIN288;report.balance262.red_threshold="active_remaining <= 3 seconds"
 report["flashlight288"]={"active_seconds":8.,"red_seconds":3.,"cooldown_after_end":COOLDOWN288,"gain_normal":NORMAL_GAIN288,"gain_red":RED_GAIN288,"activations":activations288,"damage":beam_damage288,"red_uses_hp":false}
 return report
func reset_stats226(partial: bool) -> void:
 super.reset_stats226(partial);activations288=0;beam_damage288=0.
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 288 · 手电变身 / 光能状态与原创音效")
func _ready() -> void:
 await super._ready()
 var layer=CanvasLayer.new();layer.layer=45;add_child(layer)
 shade288=ColorRect.new();shade288.color=Color(0.,0.,0.,0.);shade288.mouse_filter=Control.MOUSE_FILTER_IGNORE;shade288.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);layer.add_child(shade288)
 transform288=preload("res://scripts/art/flashlight_transform288.gd").new();add_child(transform288)
 transform288.revealed.connect(release288);transform288.finished.connect(finish288)
 state_hud288=preload("res://scripts/art/transform_hud288.gd").new();state_hud288.fx=transform288;state_hud288.battle=self;layer.add_child(state_hud288)
 hint288=Label.new();hint288.position=Vector2(24,24);hint288.add_theme_font_size_override("font_size",23);layer.add_child(hint288)
 hint288.text="288 手电主动技能　Q变身 / C装配 / M静音\n持续8秒，最后3秒红灯；按住左键照射，结束后冷却30秒\nF2仅看演出 / Shift+F2测试冷却归零 / Esc取消"
func start288(preview := false) -> bool:
 if not is_instance_valid(transform288) or intro288 or transform288.playing:return false
 if combat_paused or (is_instance_valid(console226) and console226.visible):return false
 if not preview:
  if int(levels226.get("flashlight",0))<=0:notice219("按C装配手电筒主动");return false
  if cooldown288>0.:notice219("手电冷却还剩 %.1f 秒"%cooldown288);return false
  if not active114 or wave_state!="fighting" or result_open or player_hp<=0. or hero.knocked_down or hero.story_knocked or hero.dash_left>0. or hero.guarding109:return false
 skill288=not preview;ended288=false
 if skill288:activations288+=1
 saved_pause288=combat_paused;saved_controls288=hero.controls_enabled;visual_saved288=hero.visual.visible
 if not beacon_suspended288:
  beacon_process288=red_beacon263.is_processing();beacon_suspended288=true;red_beacon263.set_process(false);red_beacon263.hide()
 hero.cancel_guard109();hero.reset_actions();_cancel_charge();_clear_combat_shots()
 # Lock input before rendering: hero36 otherwise turns back toward held keys,
 # and stale `moving` chooses a walk frame with a different pixel density.
 hero.controls_enabled=false
 hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.facing="down";hero.moving=false;hero.phase=0.;hero.render_pose()
 hero.visual.reset_physics_interpolation()
 # The authored transformation poses were calibrated to FRONT IDLE, not to
 # whichever directional sprite happened to be displayed on the input tick.
 var front=hero.directions.down
 pixel288=1.6/float(front.idle_height)
 transform288.idle_texture=front.idle
 transform288.idle_offset=Vector2(front.idle.get_width()*.5-front.idle_anchor.x,front.idle.get_height()*.5-front.idle_anchor.y)
 transform288.pixel=pixel288
 transform288.glow.set_shader_parameter("tint",hero.visual.modulate)
 combat_paused=true;hero.controls_enabled=false;intro288=true;hero.visual.hide()
 camera_size288=camera.size;camera_fov288=camera.fov;project288();transform288.start();return true
func release288() -> void:
 if not intro288:return
 intro288=false;combat_paused=saved_pause288;hero.controls_enabled=saved_controls288;hero.visual.visible=visual_saved288
 if skill288:fire_needs_release=false
 sync_weapon288()
 restore_camera288()
func restore_camera288() -> void:
 if camera_size288>0.:camera.size=camera_size288
 if camera_fov288>0.:camera.fov=camera_fov288
func finish288() -> void:
 release288();shade288.color.a=0.;skill288=false
 sync_weapon288()
 if beacon_suspended288 and is_instance_valid(red_beacon263):red_beacon263.set_process(beacon_process288);beacon_suspended288=false
func cancel288() -> void:
 if not is_instance_valid(transform288):return
 if skill288 and not ended288:consume288()
 transform288.cancel();finish288()
func project288() -> void:
 # Same native world transform and upright display plane as the hero, no Canvas portrait.
 transform288.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 transform288.global_transform=hero.visual.get_global_transform_interpolated()
 transform288.motion_target=hero.velocity
 transform288.bind_native(hero.visual);transform288.badge_allowed=hero.facing!="up"
func lighting288() -> void:
 var t=transform288.age
 var dim=smoothstep(0.,.45,t)*(1.-smoothstep(1.9,2.75,t))
 shade288.color=Color(.045,.035,.08,.18*dim)
 if camera_size288>0. and intro288:
  var push=smoothstep(.15,.7,t)*(1.-smoothstep(2.1,3.15,t))
  camera.size=camera_size288*lerpf(1.,.84,push)
  camera.fov=rad_to_deg(2.*atan(tan(deg_to_rad(camera_fov288*.5))*lerpf(1.,.84,push)))
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:guide206.text=guide206.text.replace("红灯：手电伤害×2","红灯：最后3秒，手电伤害×1.58")
 if not is_instance_valid(transform288):return
 if auto288>0.:
  auto288-=delta
  if auto288<=0.:start288()
 if transform288.playing:
  project288();lighting288()
  if intro288:hero.visual.hide()
func _input(event: InputEvent) -> void:
 # Polling still sees LMB, but old airplane input must not queue a drop mid-beam.
 if beam_active288() and not combat_paused and event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  get_viewport().set_input_as_handled();return
 if is_instance_valid(transform288) and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F2:
   if event.shift_pressed:cooldown288=0.;notice219("测试：手电冷却归零")
   else:start288(true)
   get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_Q and int(levels226.get("flashlight",0))>0:
   start288();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_M:
   transform288.audio.set_enabled(not transform288.audio.enabled)
   if transform288.audio.enabled and transform288.age>=transform288.INTRO and transform288.remaining()>0. and transform288.playing:transform288.audio.cue("hum")
   get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_ESCAPE and transform288.playing:cancel288();get_viewport().set_input_as_handled();return
 if intro288:
  get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if intro288:return
 super._unhandled_input(event)
func _exit_tree() -> void:
 if is_instance_valid(transform288):transform288.cancel()
 if is_instance_valid(hero):finish288()
 super._exit_tree()
