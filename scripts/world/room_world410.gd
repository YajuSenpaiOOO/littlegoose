extends "res://scripts/world/room_world404.gd"
var map410: Node3D
var ready410:=false
var room_layers410: Dictionary={}
var map_offset410:=Vector3(5.3,-.235,8.73)
func room_script355() -> Script:return preload("res://scripts/room/room_shell409.gd")
func yard_script403() -> Script:return preload("res://scripts/room/home_yard410.gd")
func _ready() -> void:
 await super._ready()
 home_ready403=false;hero.controls_enabled=false;hero.set_physics_process(false);companion373.set_physics_process(false)
 var path:="res://scripts/world/woodland_world409.gd"
 ResourceLoader.load_threaded_request(path,"Script")
 while ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_IN_PROGRESS:await get_tree().process_frame
 map410=ResourceLoader.load_threaded_get(path).new();add_child(map410)
 while not map410.ready405:await get_tree().process_frame
 for body in map410.find_children("*","CollisionObject3D",true,false):body.disable_mode=CollisionObject3D.DISABLE_MODE_KEEP_ACTIVE
 map410.process_mode=Node.PROCESS_MODE_DISABLED
 map410.position=map_offset410
 map410.model405.hide()
 for body in map410.model405.find_children("*","CollisionObject3D",true,false):
  if body!=map410.plinth_body405 and body!=map410.ramp_body405:body.collision_layer=0
 map410.hero.hide();map410.hero.collision_layer=0;map410.hero.collision_mask=0
 map410.goose.hide()
 for node in map410.find_children("*","CanvasLayer",true,false):node.hide()
 for node in map410.find_children("*","WorldEnvironment",true,false):node.environment=null
 for node in map410.find_children("*","Light3D",true,false):
  if node is DirectionalLight3D:node.hide()
 for node in map410.find_children("*","Camera3D",true,false):node.current=false
 camera.make_current()
 hero.collision_mask|=2|16
 window400.position.x*=.9;window400.position.z*=.9
 for body in room.find_children("*","CollisionObject3D",true,false):room_layers410[body]=body.collision_layer
 var backing: MeshInstance3D=room.box(yard403,Vector3(0,1.4,1.9),Vector3(2.0,2.8,.04),"24251f")
 backing.name="DarkDoorway410";backing.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 ready410=true;home_ready403=true;hero.controls_enabled=true
 hero.position=Vector3(0,.05,5.8);companion373.position=Vector3(.7,.05,5.8)
 hero.velocity=Vector3.ZERO;companion373.velocity=Vector3.ZERO
 hero.set_physics_process(true);companion373.set_physics_process(true)
 hero.reset_physics_interpolation();companion373.reset_physics_interpolation()
 apply_zone410();camera403(false)
 help367="410 · 小号实体屋 / 连续开门运镜\nWASD实际穿门 · 靠近自动开门\nE开门/进屋/查看 · F3进出对照\nK手动门 · P自动门 · F2昼夜\n同一角色与物理世界，无黑屏跨门"
 DisplayServer.window_set_title("小白鹅 · 410 · 小号3D屋连续开门")
 refresh367();print("HOME410_READY")
func floor_height(at: Vector2) -> float:
 if not ready410 or at.y<2.55:return 0.
 return map410.floor_height(at-Vector2(map_offset410.x,map_offset410.z))+map_offset410.y
func camera_target403(value: bool) -> Transform3D:
 if value:return super.camera_target403(value)
 var basis:=Basis.from_euler(Vector3(deg_to_rad(-25.),deg_to_rad(-18. if side_view404 else 0.),0))
 return Transform3D(basis,Vector3(0,1.1,2.0)+basis.z*16.5)
func apply_zone410() -> void:
 room.visible=inside403
 yard403.get_node("DarkDoorway410").visible=not inside403
 for body in room_layers410:body.collision_layer=room_layers410[body] if inside403 else 0
 for body in yard403.walls410:body.collision_layer=0 if inside403 else 1
 # The room is a cutaway stage, wider than its exterior. The old map is retained
 # in this same world; hide it indoors rather than letting trees pierce furniture.
 map410.visible=not inside403
 for body in map410.find_children("*","CollisionObject3D",true,false):
  if not body.has_meta("outside410"):body.set_meta("outside410",body.collision_layer)
  body.collision_layer=0 if inside403 else body.get_meta("outside410")
func switch_zone403(value: bool,animate: bool=true) -> void:
 super.switch_zone403(value,animate)
 if ready410:apply_zone410()
func enter403() -> void:
 if not ready410 or moving_camera403 or pending_door404:return
 pending_door404=true;yard403.set_open404(true)
 while yard403.door_moving404:await get_tree().physics_frame
 pending_door404=false;side_view404=false
 hero.position=Vector3(0,.05,1.85);hero.velocity=Vector3.ZERO;hero.reset_physics_interpolation();switch_zone403(true)
func leave371() -> void:
 if not ready410 or moving_camera403 or pending_door404:return
 if sleeping362:set_sleep362(0)
 pending_door404=true;yard403.set_open404(true)
 while yard403.door_moving404:await get_tree().physics_frame
 pending_door404=false;side_view404=false
 hero.position=Vector3(0,.05,3.5);hero.velocity=Vector3.ZERO;hero.reset_physics_interpolation();switch_zone403(false)
func _process(delta: float) -> void:
 super._process(delta)
 if ready410:
  if inside403 and hero.position.z>2.95:switch_zone403(false)
  # Retain the existing map scenery as a static household context in this trial.
  # Actors and all transition motion belong to this host, not the old map loop.
func door_clear404(distance: float) -> bool:
 return Vector2(hero.position.x,hero.position.z).distance_to(Vector2(0,2.43))>distance and Vector2(companion373.position.x,companion373.position.z).distance_to(Vector2(0,2.43))>distance
