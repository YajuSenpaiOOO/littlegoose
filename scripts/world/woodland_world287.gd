extends "res://scripts/world/woodland_world276.gd"
var transform287: Node3D
var shade287: ColorRect
var hint287: Label
var saved_pause287 := false
var saved_controls287 := true
var visual_saved287 := true
var intro287 := false
var auto287 := .65
var pixel287 := 0.
var camera_size287 := 0.
var camera_fov287 := 0.
var beacon_suspended287 := false
var beacon_process287 := true
var state_hud287: Control
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 287 · 手电变身 / 光能状态与原创音效")
func _ready() -> void:
 await super._ready()
 var layer=CanvasLayer.new();layer.layer=45;add_child(layer)
 shade287=ColorRect.new();shade287.color=Color(0.,0.,0.,0.);shade287.mouse_filter=Control.MOUSE_FILTER_IGNORE;shade287.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);layer.add_child(shade287)
 transform287=preload("res://scripts/art/flashlight_transform287.gd").new();add_child(transform287)
 transform287.revealed.connect(release287);transform287.finished.connect(finish287)
 state_hud287=preload("res://scripts/art/transform_hud287.gd").new();state_hud287.fx=transform287;layer.add_child(state_hud287)
 hint287=Label.new();hint287.position=Vector2(24,24);hint287.add_theme_font_size_override("font_size",23);layer.add_child(hint287)
 hint287.text="287 光能状态与原创合成音效　F2重播 / M静音 / Esc结束\n显形后8秒，最后2秒红灯；移动可见少量光点\n本轮为状态演出预览，手电限时主动攻击尚未接入。"
func start287() -> void:
 if not is_instance_valid(transform287) or intro287:return
 if combat_paused or (is_instance_valid(console226) and console226.visible):return
 saved_pause287=combat_paused;saved_controls287=hero.controls_enabled;visual_saved287=hero.visual.visible
 if not beacon_suspended287:
  beacon_process287=red_beacon263.is_processing();beacon_suspended287=true;red_beacon263.set_process(false);red_beacon263.hide()
 hero.cancel_guard109();hero.reset_actions();_cancel_charge();_clear_combat_shots()
 # Obtain neutral idle geometry; do not resize or tilt the native hero.
 hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.facing="down";hero.render_pose()
 pixel287=hero.visual.pixel_size
 var atlas=AtlasTexture.new();atlas.atlas=preload("res://assets/hero_pixel/walk_source.png");atlas.region=Rect2(633,0,600,800)
 transform287.idle_texture=atlas;transform287.idle_offset=Vector2(0.,400.-749.);transform287.pixel=pixel287
 transform287.glow.set_shader_parameter("tint",hero.visual.modulate)
 combat_paused=true;hero.controls_enabled=false;intro287=true;hero.visual.hide()
 camera_size287=camera.size;camera_fov287=camera.fov;project287();transform287.start()
func release287() -> void:
 if not intro287:return
 intro287=false;combat_paused=saved_pause287;hero.controls_enabled=saved_controls287;hero.visual.visible=visual_saved287
 restore_camera287()
func restore_camera287() -> void:
 if camera_size287>0.:camera.size=camera_size287
 if camera_fov287>0.:camera.fov=camera_fov287
func finish287() -> void:
 release287();shade287.color.a=0.
 if beacon_suspended287 and is_instance_valid(red_beacon263):red_beacon263.set_process(beacon_process287);beacon_suspended287=false
func cancel287() -> void:
 if not is_instance_valid(transform287):return
 transform287.cancel();finish287()
func project287() -> void:
 # Same native world transform and upright display plane as the hero, no Canvas portrait.
 transform287.global_transform=hero.visual.global_transform
 transform287.motion_target=hero.velocity
 transform287.bind_native(hero.visual);transform287.badge_allowed=hero.facing!="up"
func lighting287() -> void:
 var t=transform287.age
 var dim=smoothstep(0.,.45,t)*(1.-smoothstep(1.9,2.75,t))
 shade287.color=Color(.045,.035,.08,.18*dim)
 if camera_size287>0. and intro287:
  var push=smoothstep(.15,.7,t)*(1.-smoothstep(2.1,3.15,t))
  camera.size=camera_size287*lerpf(1.,.84,push)
  camera.fov=rad_to_deg(2.*atan(tan(deg_to_rad(camera_fov287*.5))*lerpf(1.,.84,push)))
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(transform287):return
 if auto287>0.:
  auto287-=delta
  if auto287<=0.:start287()
 if transform287.playing:
  project287();transform287.advance(delta);lighting287()
  if intro287:hero.visual.hide()
func _input(event: InputEvent) -> void:
 if is_instance_valid(transform287) and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F2:start287();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_M:
   transform287.audio.set_enabled(not transform287.audio.enabled)
   if transform287.audio.enabled and transform287.age>=transform287.INTRO and transform287.remaining()>0. and transform287.playing:transform287.audio.cue("hum")
   get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_ESCAPE and transform287.playing:cancel287();get_viewport().set_input_as_handled();return
 if intro287:
  get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if intro287:return
 super._unhandled_input(event)
func _exit_tree() -> void:
 if is_instance_valid(transform287):transform287.cancel()
 if is_instance_valid(hero):finish287()
 super._exit_tree()
