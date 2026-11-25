extends "res://scripts/world/room_world371.gd"
const GOOSE_HEIGHT372=1.44
var human372: Node3D
var human_visual372: Sprite3D
var human_shadow372: MeshInstance3D
var human_body372: StaticBody3D
var near372:=false
func _ready() -> void:
 await super._ready()
 human372=Node3D.new();human372.name="BlackGooseHumanIdle372";human372.position=Vector3(1.1,.05,2.8);add_child(human372)
 human_visual372=Sprite3D.new();human_visual372.name="UprightIdleV2";human_visual372.texture=room.source356("res://assets/black_goose_human_v2/idle_front.png")
 human_visual372.pixel_size=GOOSE_HEIGHT372/1281.;human_visual372.offset=Vector2(1086.*.5-550.,1378.-1448.*.5)
 human_visual372.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;human_visual372.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;human_visual372.layers=1|(1<<19)
 var ink=preload("res://scripts/combat/hero192.gd").make_receiver192();ink.albedo_texture=human_visual372.texture;human_visual372.material_override=ink;human_visual372.shaded=true;human372.add_child(human_visual372)
 human_body372=StaticBody3D.new();human_body372.name="SmallFootprintOnly372";human_body372.collision_layer=1;human_body372.collision_mask=0
 var shape:=CollisionShape3D.new();var capsule:=CapsuleShape3D.new();capsule.radius=.19;capsule.height=.7;shape.shape=capsule;shape.position.y=.35;human_body372.add_child(shape);human372.add_child(human_body372)
 human_shadow372=preload("res://scripts/combat/actor_shadow105.gd").new();human_shadow372.battle=self;human_shadow372.visual=human_visual372;human_shadow372.opacity_scale=.7;human372.add_child(human_shadow372)
 DisplayServer.window_set_title("小白鹅 · 372 · 小黑鹅人形同屏")
 help367="372 · 小黑鹅正面idle同屏
小黑鹅1.44m / 主角1.60m
N 双人近看/全屋 · F7 回到并排位置
WASD 走动 · F2 昼夜 · L 补光
F12 跟随 · C 床近看 · E 互动
当前为单张站姿，无行走/双人睡姿"
 refresh367()
func set_pair372(value: bool) -> void:
 near372=value;detail364=false;set_follow363(false)
 if value:
  var center: Vector3=(hero.global_position+human372.global_position)*.5+Vector3(0.,.78,0.)
  camera.global_position=center+camera.global_basis.z*5.4
 else:camera.global_position=camera_home363
 camera.reset_physics_interpolation()
func reset355() -> void:
 super.reset355()
 if is_instance_valid(human372):human372.position=Vector3(1.1,.05,2.8)
 if near372:set_pair372(true)
func interact355() -> void:
 if not sleeping362 and is_instance_valid(human372) and hero.global_position.distance_to(human372.global_position)<.95:
  message355="小黑鹅 · 人形站姿预览，暂未接入对话或双人动作";message_left355=4.;return
 super.interact355()
func _input(event: InputEvent) -> void:
 if ready355 and is_instance_valid(human372) and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_N:set_pair372(not near372);get_viewport().set_input_as_handled();return
  if near372 and event.physical_keycode in [KEY_C,KEY_F12]:set_pair372(false)
 super._input(event)
