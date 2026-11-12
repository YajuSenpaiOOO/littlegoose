extends "res://scripts/world/woodland_world276.gd"
var transform286: Node3D
var shade286: ColorRect
var hint286: Label
var saved_pause286 := false
var saved_controls286 := true
var visual_saved286 := true
var intro286 := false
var auto286 := .65
var pixel286 := 0.
var camera_size286 := 0.
var camera_fov286 := 0.
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 286 · 手电变身 / 垂落光带 / 世界遮挡")
func _ready() -> void:
 await super._ready()
 var layer=CanvasLayer.new();layer.layer=45;add_child(layer)
 shade286=ColorRect.new();shade286.color=Color(0.,0.,0.,0.);shade286.mouse_filter=Control.MOUSE_FILTER_IGNORE;shade286.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);layer.add_child(shade286)
 transform286=preload("res://scripts/art/flashlight_transform286.gd").new();add_child(transform286)
 transform286.revealed.connect(release286);transform286.finished.connect(finish286)
 hint286=Label.new();hint286.position=Vector2(24,24);hint286.add_theme_font_size_override("font_size",23);layer.add_child(hint286)
 hint286.text="286 手电变身演出　F2 重播 / Esc 结束演出\n闭眼凝神 → 举灯 → 冲天爆发 → 高处回光 → 垂落光带 → 显形\n世界空间演出；静止垂落，移动飘起。F2重播，Esc取消。"
func start286() -> void:
 if not is_instance_valid(transform286) or intro286:return
 if combat_paused or (is_instance_valid(console226) and console226.visible):return
 saved_pause286=combat_paused;saved_controls286=hero.controls_enabled;visual_saved286=hero.visual.visible
 hero.cancel_guard109();hero.reset_actions();_cancel_charge();_clear_combat_shots()
 # Obtain neutral idle geometry; do not resize or tilt the native hero.
 hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.facing="down";hero.render_pose()
 pixel286=hero.visual.pixel_size
 var atlas=AtlasTexture.new();atlas.atlas=preload("res://assets/hero_pixel/walk_source.png");atlas.region=Rect2(633,0,600,800)
 transform286.idle_texture=atlas;transform286.idle_offset=Vector2(0.,400.-749.);transform286.pixel=pixel286
 transform286.glow.set_shader_parameter("tint",hero.visual.modulate)
 combat_paused=true;hero.controls_enabled=false;intro286=true;hero.visual.hide()
 camera_size286=camera.size;camera_fov286=camera.fov;project286();transform286.start()
func release286() -> void:
 if not intro286:return
 intro286=false;combat_paused=saved_pause286;hero.controls_enabled=saved_controls286;hero.visual.visible=visual_saved286
 restore_camera286()
func restore_camera286() -> void:
 if camera_size286>0.:camera.size=camera_size286
 if camera_fov286>0.:camera.fov=camera_fov286
func finish286() -> void:
 release286();shade286.color.a=0.
func cancel286() -> void:
 if not is_instance_valid(transform286):return
 transform286.cancel();finish286()
func project286() -> void:
 # Same native world transform and upright display plane as the hero, no Canvas portrait.
 transform286.global_transform=hero.visual.global_transform
 transform286.motion_target=hero.velocity
func lighting286() -> void:
 var t=transform286.age
 var dim=smoothstep(0.,.45,t)*(1.-smoothstep(1.9,2.75,t))
 shade286.color=Color(.045,.035,.08,.18*dim)
 if camera_size286>0. and intro286:
  var push=smoothstep(.15,.7,t)*(1.-smoothstep(2.1,3.15,t))
  camera.size=camera_size286*lerpf(1.,.84,push)
  camera.fov=rad_to_deg(2.*atan(tan(deg_to_rad(camera_fov286*.5))*lerpf(1.,.84,push)))
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(transform286):return
 if auto286>0.:
  auto286-=delta
  if auto286<=0.:start286()
 if transform286.playing:
  project286();transform286.advance(delta);lighting286()
  if intro286:hero.visual.hide()
func _input(event: InputEvent) -> void:
 if is_instance_valid(transform286) and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F2:start286();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_ESCAPE and transform286.playing:cancel286();get_viewport().set_input_as_handled();return
 if intro286:
  get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if intro286:return
 super._unhandled_input(event)
func _exit_tree() -> void:
 if intro286 and is_instance_valid(hero):release286()
 super._exit_tree()
