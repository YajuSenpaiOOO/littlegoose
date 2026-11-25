extends "res://scripts/world/room_world403.gd"
var auto_door404:=true
var side_view404:=false
var pending_door404:=false
var away404:=0.
func yard_script403() -> Script:return preload("res://scripts/room/home_yard404.gd")
func _ready() -> void:
 await super._ready()
 yard403.door_settled404.connect(refresh_door404)
 DisplayServer.window_set_title("小白鹅 · 404 · 实体尖顶小屋与开门")
 help367="404 · 实体尖顶小屋与开门\nWASD走过门槛 · E开门/进屋/查看\nK手动开关门 · P自动开门开关\n9正面/侧看 · F3进出屋 · F2昼夜\n屋内：1衣柜 · 2洗漱 · G书桌\n局部家园样件，尚未迁移原大地图"
 refresh367()
func camera_target403(value: bool) -> Transform3D:
 if value:return super.camera_target403(value)
 var basis:=Basis.from_euler(Vector3(deg_to_rad(-25.),deg_to_rad(-18. if side_view404 else 0.),0))
 return Transform3D(basis,Vector3(0,1.4,4.6)+basis.z*20.8)
func door_clear404(distance: float) -> bool:
 var at:=Vector2(0,2.7)
 return Vector2(hero.position.x,hero.position.z).distance_to(at)>distance and Vector2(companion373.position.x,companion373.position.z).distance_to(at)>distance
func refresh_door404() -> void:
 await get_tree().physics_frame
 var grid: AStarGrid2D=companion373.grid373
 var capsule:=CapsuleShape3D.new();capsule.radius=.24;capsule.height=.68
 var query:=PhysicsShapeQueryParameters3D.new();query.shape=capsule;query.collision_mask=1;query.exclude=[hero.get_rid(),companion373.get_rid()]
 # Rescan only the swept door area after each actual physics animation.
 for y in range(12,27):
  for x in range(17,29):
   var id:=Vector2i(x,y);var at:=grid.get_point_position(id);query.transform=Transform3D(Basis.IDENTITY,Vector3(at.x,.42,at.y))
   grid.set_point_solid(id,not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty())
 companion373.route373.clear();companion373.repath373=0.
func choose355() -> Dictionary:
 var row: Dictionary=super.choose355()
 if home_ready403 and not inside403 and not row.is_empty() and not yard403.opened404:row.title="打开小屋的门"
 return row
func interact355() -> void:
 if home_ready403 and not inside403 and not choose355().is_empty() and not yard403.opened404:
  yard403.set_open404(true);return
 super.interact355()
func enter403() -> void:
 if not home_ready403 or pending_door404 or moving_camera403:return
 pending_door404=true;yard403.set_open404(true)
 while yard403.door_moving404:await get_tree().physics_frame
 pending_door404=false;side_view404=false;super.enter403()
func leave371() -> void:
 if not home_ready403 or pending_door404 or moving_camera403:return
 pending_door404=true;yard403.set_open404(true)
 while yard403.door_moving404:await get_tree().physics_frame
 pending_door404=false;side_view404=false;super.leave371()
func _process(delta: float) -> void:
 if home_ready403 and is_instance_valid(yard403):
  if auto_door404:
   if not door_clear404(2.8):yard403.set_open404(true);away404=0.
   elif door_clear404(3.5):
    away404+=delta
    if away404>1.5:yard403.set_open404(false)
  for material in yard403.glow404:material.emission_energy_multiplier=.45 if night355 else .10
 super._process(delta)
 if home_ready403:
  for ink in yard403.door_inks404:ink.set_shader_parameter("cutaway",inside403 or moving_camera403)
func refresh367() -> void:
 super.refresh367()
 if home_ready403 and is_instance_valid(label367):label367.text+="\n自动开门："+("开" if auto_door404 else "关（K手动）")
func _input(event: InputEvent) -> void:
 if home_ready403 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_P:
   auto_door404=not auto_door404;away404=0.;refresh367();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_K:
   auto_door404=false
   if yard403.opened404 and not door_clear404(2.5):message355="先离门扇远一点，再关门。";message_left355=2.
   else:yard403.set_open404(not yard403.opened404)
   refresh367();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_9 and not inside403 and not moving_camera403:
   side_view404=not side_view404;camera403();get_viewport().set_input_as_handled();return
 super._input(event)
