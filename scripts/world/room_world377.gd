extends "res://scripts/world/room_world376.gd"
var flight377: Sprite3D
var flight_root377: Node3D
var lift377:=true
func _ready() -> void:
 await super._ready()
 flight_root377=Node3D.new();flight_root377.name="FlightAReference377";add_child(flight_root377)
 flight377=Sprite3D.new();flight377.name="FrontFlightA377";flight377.texture=room.source356("res://assets/black_goose_flight377/front.png")
 flight377.pixel_size=1.44/1281.0;flight377.offset=Vector2(1086.0*.5-550.0,1378.0-1448.0*.5)
 flight377.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;flight377.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;flight377.layers=1|(1<<19)
 var ink=preload("res://scripts/combat/hero192.gd").make_receiver192();ink.albedo_texture=flight377.texture;flight377.material_override=ink;flight377.shaded=true;flight_root377.add_child(flight377)
 var shadow=preload("res://scripts/combat/actor_shadow105.gd").new();shadow.battle=self;shadow.visual=flight377;shadow.opacity_scale=.7;flight_root377.add_child(shadow)
 DisplayServer.window_set_title("小白鹅 · 377 · 正面飞姿A比例对照")
 help367="377 · 正面飞姿A比例对照\n左：主角 · 中：原站姿 · 右：飞姿A\nY 悬浮/同基线 · K 重排对照\nN 近看/全屋 · F2 昼夜 · L 补光\nWASD 走动 · J 跟随/等候\n飞姿仅静态参考，未做拍翼与飞行控制"
 arrange377();refresh367()
func arrange377() -> void:
 hero.global_position=Vector3(-1.6,.05,2.8);hero.velocity=Vector3.ZERO;hero.facing="down";hero.moving=false;hero.render_pose();hero.reset_physics_interpolation()
 companion373.global_position=Vector3(0.,.05,2.8);companion373.hold373();companion373.preview374=0;companion373.direction373="down";companion373.reset_physics_interpolation()
 flight_root377.position=Vector3(1.6,.05,2.8);flight377.position.y=.40 if lift377 else 0.0
 set_pair372(true)
func set_pair372(value: bool) -> void:
 super.set_pair372(value)
 if value and is_instance_valid(flight377):
  camera.global_position=Vector3(0.,1.05,2.8)+camera.global_basis.z*6.7;camera.reset_physics_interpolation()
func reset355() -> void:
 super.reset355()
 if is_instance_valid(flight377):arrange377()
func _input(event: InputEvent) -> void:
 if ready355 and is_instance_valid(flight377) and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_Y:
   lift377=not lift377;flight377.position.y=.40 if lift377 else 0.0;get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_K:arrange377();get_viewport().set_input_as_handled();return
 super._input(event)
