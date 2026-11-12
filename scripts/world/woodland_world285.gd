extends "res://scripts/world/woodland_world276.gd"
var transform285: Node2D
var shade285: ColorRect
var hint285: Label
var saved_pause285 := false
var saved_controls285 := true
var visual_saved285 := true
var intro285 := false
var auto285 := .65
var pixel285 := 0.
var camera_size285 := 0.
var camera_fov285 := 0.
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 285 · 手电变身 / 金色光带")
func _ready() -> void:
 await super._ready()
 var layer=CanvasLayer.new();layer.layer=45;add_child(layer)
 shade285=ColorRect.new();shade285.color=Color(0.,0.,0.,0.);shade285.mouse_filter=Control.MOUSE_FILTER_IGNORE;shade285.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);layer.add_child(shade285)
 transform285=preload("res://scripts/art/flashlight_transform285.gd").new();layer.add_child(transform285)
 transform285.revealed.connect(release285);transform285.finished.connect(finish285)
 hint285=Label.new();hint285.position=Vector2(24,24);hint285.add_theme_font_size_override("font_size",23);layer.add_child(hint285)
 hint285.text="285 手电变身演出　F2 重播 / Esc 结束演出\n闭眼凝神 → 举灯 → 冲天光束 → 金色光带 → 显形\n本轮仅演出预览，手电战斗规则仍为276。"
func start285() -> void:
 if not is_instance_valid(transform285) or intro285:return
 if combat_paused or (is_instance_valid(console226) and console226.visible):return
 saved_pause285=combat_paused;saved_controls285=hero.controls_enabled;visual_saved285=hero.visual.visible
 hero.cancel_guard109();hero.reset_actions();_cancel_charge();_clear_combat_shots()
 # Obtain neutral idle geometry; do not resize or tilt the native hero.
 hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.facing="down";hero.render_pose()
 pixel285=hero.visual.pixel_size*hero.visual.scale.x
 var atlas=AtlasTexture.new();atlas.atlas=preload("res://assets/hero_pixel/walk_source.png");atlas.region=Rect2(633,0,600,800)
 transform285.idle_texture=atlas;transform285.idle_offset=Vector2(0.,400.-749.)
 combat_paused=true;hero.controls_enabled=false;intro285=true;hero.visual.hide()
 camera_size285=camera.size;camera_fov285=camera.fov;transform285.start();project285()
func release285() -> void:
 if not intro285:return
 intro285=false;combat_paused=saved_pause285;hero.controls_enabled=saved_controls285;hero.visual.visible=visual_saved285
 restore_camera285()
func restore_camera285() -> void:
 if camera_size285>0.:camera.size=camera_size285
 if camera_fov285>0.:camera.fov=camera_fov285
func finish285() -> void:
 release285();shade285.color.a=0.
func cancel285() -> void:
 if not is_instance_valid(transform285):return
 transform285.playing=false;transform285.actor.hide();transform285.queue_redraw();finish285()
func project285() -> void:
 var at: Vector3=hero.global_position
 var p=camera.unproject_position(at)
 var x=camera.unproject_position(at+Vector3.RIGHT*pixel285).distance_to(p)
 var y=camera.unproject_position(at+Vector3.UP*pixel285).distance_to(p)
 transform285.position=p;transform285.scale=Vector2(x,y)
func lighting285() -> void:
 var t=transform285.age
 var dim=smoothstep(0.,.45,t)*(1.-smoothstep(1.9,2.75,t))
 shade285.color=Color(.045,.035,.08,.38*dim)
 if camera_size285>0. and intro285:
  var push=smoothstep(.15,.7,t)*(1.-smoothstep(2.1,3.15,t))
  camera.size=camera_size285*lerpf(1.,.84,push)
  camera.fov=rad_to_deg(2.*atan(tan(deg_to_rad(camera_fov285*.5))*lerpf(1.,.84,push)))
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(transform285):return
 if auto285>0.:
  auto285-=delta
  if auto285<=0.:start285()
 if transform285.playing:
  transform285.advance(delta);lighting285();project285()
  if intro285:hero.visual.hide()
func _input(event: InputEvent) -> void:
 if is_instance_valid(transform285) and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F2:start285();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_ESCAPE and transform285.playing:cancel285();get_viewport().set_input_as_handled();return
 if intro285:
  get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if intro285:return
 super._unhandled_input(event)
func _exit_tree() -> void:
 if intro285 and is_instance_valid(hero):release285()
