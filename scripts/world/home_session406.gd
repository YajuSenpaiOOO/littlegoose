extends Node
var outside406: SubViewport
var inside406: SubViewport
var map406: Node3D
var room406: Node3D
var view406: TextureRect
var curtain406: ColorRect
var ready406:=false
var indoors406:=false
var busy406:=false
var swaps406:=0
var hint406: Label
func room_path406() -> String:return "res://scripts/world/room_world406.gd"
func map_path406() -> String:return "res://scripts/world/woodland_world405.gd"
func configure_map406() -> void:map406.set_mode405(1)
func door_point406() -> Vector2:return Vector2(-4.7,-4.8)
func return_point406() -> Vector2:return door_point406()+Vector2(0,2.2)
func viewport406() -> SubViewport:
 var v:=SubViewport.new();v.size=get_viewport().get_visible_rect().size;v.own_world_3d=true;v.handle_input_locally=true;add_child(v);return v
func _ready() -> void:
 Engine.max_fps=60
 var ui:=CanvasLayer.new();add_child(ui)
 view406=TextureRect.new();view406.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);view406.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui.add_child(view406)
 curtain406=ColorRect.new();curtain406.color=Color.BLACK;curtain406.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);curtain406.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui.add_child(curtain406)
 var status:=Label.new();status.position=Vector2(60,75);status.text="正在一次性准备小院与室内…\n首次仍需构建旧大地图，进出屋不会重新读取。";status.add_theme_font_size_override("font_size",22);ui.add_child(status)
 await get_tree().process_frame
 outside406=viewport406();inside406=viewport406()
 var path:=map_path406();ResourceLoader.load_threaded_request(path,"Script")
 while ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_IN_PROGRESS:await get_tree().process_frame
 map406=ResourceLoader.load_threaded_get(path).new();outside406.add_child(map406)
 while not map406.ready405:await get_tree().process_frame
 configure_map406();map406.panel405.hide();map406.overview405=false;map406.follow_camera=true;map406._teleport15(return_point406())
 map406.process_mode=Node.PROCESS_MODE_DISABLED
 preload("res://scripts/room/mesh_cache403.gd").enabled403=true
 room406=load(room_path406()).new();inside406.add_child(room406)
 while not room406.home_ready403:await get_tree().process_frame
 for i in 5:await get_tree().physics_frame
 room406.exit406.connect(func():transition406(false))
 room406.process_mode=Node.PROCESS_MODE_DISABLED;inside406.render_target_update_mode=SubViewport.UPDATE_DISABLED
 map406.process_mode=Node.PROCESS_MODE_INHERIT;map406.camera.make_current();outside406.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 view406.texture=outside406.get_texture();curtain406.color.a=0.;status.queue_free();ready406=true
 DisplayServer.window_set_title("小白鹅 · 406 · 小屋淡黑进出 / 室内原尺寸")
 var hint:=Label.new();hint.position=Vector2(20,20);hint.text="406 · 小巧外屋 / 原尺寸室内\n门前 E进屋 · F3快捷进出 · WASD走动";hint.add_theme_color_override("font_outline_color",Color.BLACK);hint.add_theme_constant_override("outline_size",5);ui.add_child(hint)
 hint406=hint
 print("HOME406_READY")
func transition406(value: bool) -> void:
 if not ready406 or busy406 or indoors406==value:return
 busy406=true;map406.hero.controls_enabled=false;room406.hero.controls_enabled=false
 var fade:=create_tween();fade.tween_property(curtain406,"color:a",1.,.20);await fade.finished
 indoors406=value;swaps406+=1
 if not value and room406.sleeping362:room406.set_sleep362(0)
 map406.process_mode=Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT
 room406.process_mode=Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
 outside406.render_target_update_mode=SubViewport.UPDATE_DISABLED if value else SubViewport.UPDATE_ALWAYS
 inside406.render_target_update_mode=SubViewport.UPDATE_ALWAYS if value else SubViewport.UPDATE_DISABLED
 if value:
  room406.set_night355(map406.time55.visual_hour>18.)
  room406.reset355();room406.camera403(false)
  var target: Transform3D=room406.camera.global_transform
  room406.set_follow363(false);room406.camera.position+=room406.camera.global_basis.z*.65
  var move:=create_tween();move.set_trans(Tween.TRANS_SINE);move.set_ease(Tween.EASE_OUT);move.tween_property(room406.camera,"global_transform",target,.75);move.tween_callback(func():room406.set_follow363(true))
 else:
  map406.time55.preview_at(20. if room406.night355 else 10.)
  map406._teleport15(Vector2(-4.7,-2.6));map406.hero.velocity=Vector3.ZERO
 view406.texture=inside406.get_texture() if value else outside406.get_texture()
 (room406.camera if value else map406.camera).make_current()
 hint406.visible=not value
 print("HOME406_BLACK_SWITCH alpha=",curtain406.color.a)
 await get_tree().process_frame;await get_tree().process_frame
 fade=create_tween();fade.tween_property(curtain406,"color:a",0.,.28);await fade.finished
 map406.hero.controls_enabled=not value;room406.hero.controls_enabled=value;busy406=false
 print("HOME406_CROSS ",swaps406," indoors=",value)
func _input(event: InputEvent) -> void:
 if not ready406:return
 if busy406:get_viewport().set_input_as_handled();return
 if event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F3:
   transition406(not indoors406);get_viewport().set_input_as_handled();return
  if not indoors406 and event.physical_keycode==KEY_E and Vector2(map406.hero.position.x,map406.hero.position.z).distance_to(door_point406())<3.:
   transition406(true);get_viewport().set_input_as_handled();return
  if not indoors406 and event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_F7,KEY_F8,KEY_F9]:get_viewport().set_input_as_handled();return
 (inside406 if indoors406 else outside406).push_input(event,true)
func _process(_delta: float) -> void:
 if ready406:
  var size:=Vector2i(get_viewport().get_visible_rect().size)
  if outside406.size!=size:outside406.size=size;inside406.size=size
