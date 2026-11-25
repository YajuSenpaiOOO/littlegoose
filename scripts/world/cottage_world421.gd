extends "res://scripts/world/room_world400.gd"

var house: Node3D
var inside:=false
var cut_progress:=0.
var ready421:=false
var camera_move: Tween
var crossing:=false

func room_script355() -> Script:
 return preload("res://scripts/room/room_shell421.gd")

func house_script421() -> Script:
 return preload("res://scripts/room/cottage421.gd")

func _ready() -> void:
 # Build before the shared room host so navigation sees the actual shell.
 house=house_script421().new()
 house.name="House421"
 add_child(house)
 build_ground()
 house.pivot.rotation.y=deg_to_rad(101.)
 await super._ready()
 while not companion373.ready373:await get_tree().physics_frame
 # The navigation grid was baked with the doorway open.
 house.door_target=true
 house.set_door(false)
 ready421=true
 set_follow363(false)
 camera.far=240.
 environment.background_color=Color("aab484")
 reset355()
 window400.position=Vector3(0,2.57,-3.57)
 window400.look_at(Vector3(0,.05,-.75),Vector3.UP)
 help367="421 · A稿小屋家具与切墙\nWASD走过门槛 · F3进出对照 · F2昼夜"
 DisplayServer.window_set_title("小白鹅 · 421 · 同址娃娃屋")
 refresh367()
 if "--capture421" in OS.get_cmdline_user_args():call_deferred("validate421")

func build_ground() -> void:
 var plane:=PlaneMesh.new()
 plane.size=Vector2(360,360)
 house.mesh_at(self,plane,Vector3(0,-.22,0),house.color("758252"))
 house.block(self,Vector3(0,-.38,0),Vector3(120,.32,120),house.color("758252"),true).hide()
 build_threshold421()

func build_threshold421() -> void:
 var ramp:=SurfaceTool.new()
 ramp.begin(Mesh.PRIMITIVE_TRIANGLES)
 for p in [Vector3(-1,0,3.14),Vector3(1,0,3.14),Vector3(1,-.22,4.32),Vector3(-1,0,3.14),Vector3(1,-.22,4.32),Vector3(-1,-.22,4.32)]:
  ramp.set_normal(Vector3.UP)
  ramp.set_uv(Vector2(p.x,p.z))
  ramp.add_vertex(p)
 var walk: MeshInstance3D=house.mesh_at(self,ramp.commit(),Vector3.ZERO,house.stone)
 walk.create_trimesh_collision()
 walk.get_child(0).get_child(0).shape.backface_collision=true

func camera_pose(value: bool) -> Transform3D:
 var basis:=Basis.from_euler(Vector3(deg_to_rad(-18. if value else -25.),0,0))
 var look:=Vector3(0,.85,-1.9) if value else Vector3(0,2.45,.8)
 var screen_size:=get_viewport().get_visible_rect().size
 var aspect:=screen_size.x/maxf(screen_size.y,1.)
 var distance:=10.9*maxf(1.,1.76/aspect) if value else 18.5
 return Transform3D(basis,look+basis.z*distance)

func apply_camera() -> void:
 camera.global_transform=camera_pose(false).interpolate_with(camera_pose(true),cut_progress)
 house.set_cut(cut_progress)

func switch_room(value: bool) -> void:
 if inside==value:return
 inside=value
 if is_instance_valid(camera_move):camera_move.kill()
 crossing=true
 camera_move=create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
 camera_move.tween_method(move_camera,cut_progress,1. if inside else 0.,.95*absf(float(inside)-cut_progress))
 camera_move.tween_callback(func():crossing=false)
 refresh367()

func move_camera(value: float) -> void:
 cut_progress=value
 apply_camera()
 if OS.get_cmdline_user_args().has("--capture421") and value>.53 and value<.67:
  queue_mid_capture421()

func reset355() -> void:
 super.reset355()
 if not ready421:return
 if is_instance_valid(camera_move):camera_move.kill()
 crossing=false
 inside=false
 move_camera(0.)
 hero.position=Vector3(0,-.17,5.80)
 hero.reset_physics_interpolation()
 companion373.position=Vector3(1.,-.17,5.80)
 companion373.reset_physics_interpolation()

func floor_height(at: Vector2) -> float:
 for area in [room.HOUSE.HALL,room.HOUSE.LEFT,room.HOUSE.RIGHT] if is_instance_valid(room) else []:
  if area.has_point(at):return 0.
 if absf(at.x)<1. and at.y>=3.14 and at.y<4.32:return lerpf(0.,-.22,(at.y-3.14)/1.18)
 return -.22

func refresh367() -> void:
 if is_instance_valid(label367):label367.text=help367

func choose355() -> Dictionary:
 if ready421 and not inside:return {}
 if ready421 and absf(hero.position.x)<1. and hero.position.z>2.45:return {"id":"exit","title":"离开小屋"}
 return super.choose355()

func leave371() -> void:
 if ready421 and inside:quick_cross(false)

func quick_cross(value: bool) -> void:
 if sleeping362:set_sleep362(0)
 hero.position=Vector3(0,.05,2.63) if value else Vector3(0,-.17,4.76)
 hero.velocity=Vector3.ZERO
 hero.reset_physics_interpolation()
 house.set_door(true)
 switch_room(value)

func _process(delta: float) -> void:
 if is_instance_valid(room) and is_instance_valid(room.stream):super._process(delta)
 if not ready421:return
 var point:=Vector2(hero.position.x,hero.position.z)
 update_door421(point)
 if absf(point.x)<1.08:
  if not inside and point.y<3.04 and point.y>2.10:switch_room(true)
  elif inside and point.y>3.55 and point.y<4.60:switch_room(false)
 follow_label363.text="镜头移动中" if crossing else ("室内 18°" if inside else "屋外 25°")

func update_door421(point: Vector2) -> void:
 var near_door:=point.distance_to(Vector2(0,3.30))<1.80
 var companion_near:=Vector2(companion373.position.x,companion373.position.z).distance_to(Vector2(0,3.30))<.95
 house.set_door(inside or near_door or companion_near or crossing)

func _input(event: InputEvent) -> void:
 if ready421 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F3:
   quick_cross(not inside)
   get_viewport().set_input_as_handled()
   return
  # Keep the main lens fixed. The historical quick-close targets belong to the old layout.
  if event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_F4,KEY_F12,KEY_G,KEY_Y,KEY_Z,KEY_X,KEY_V,KEY_B,KEY_M,KEY_N]:
   get_viewport().set_input_as_handled()
   return
 super._input(event)

func validate421() -> void:
 hero.set_physics_process(false)
 companion373.hold373()
 await capture421("outside")
 var actor:=hero.get_instance_id()
 for i in 98:
  await get_tree().physics_frame
  hero.velocity=Vector3(0,-.55,-2.2)
  hero.move_and_slide()
 print("COTTAGE421_ENTRY ",hero.position," cut=",cut_progress)
 assert(inside and hero.position.z<3.04,"actual entry through the door")
 await get_tree().create_timer(1.).timeout
 assert(is_equal_approx(cut_progress,1.) and not house.front_cut[0].node.visible)
 assert(camera.global_transform.is_equal_approx(camera_pose(true)))
 await capture421("inside")
 for side in [-1.,1.]:
  hero.position=Vector3(side*2.2,.04,.98)
  for i in 45:
   await get_tree().physics_frame
   hero.velocity=Vector3(side*2.35,-.55,0)
   hero.move_and_slide()
  assert(absf(hero.position.x)>3.50,"alcove threshold is physically passable")
 hero.position=Vector3(0,.04,2.46)
 for i in 85:
  await get_tree().physics_frame
  hero.velocity=Vector3(0,-.55,2.25)
  hero.move_and_slide()
 await get_tree().create_timer(1.).timeout
 print("COTTAGE421_EXIT ",hero.position," inside=",inside," cut=",cut_progress)
 for hit in hero.get_slide_collision_count():
  print("COTTAGE421_HIT ",hero.get_slide_collision(hit).get_collider().get_path())
 assert(not inside and is_zero_approx(cut_progress) and house.front_cut[0].node.visible)
 assert(hero.get_instance_id()==actor)
 quick_cross(true)
 await get_tree().create_timer(.43).timeout
 var midway:=cut_progress
 assert(midway>.05 and midway<.95)
 quick_cross(false)
 assert(is_equal_approx(cut_progress,midway),"reversing preserves the current camera and cut")
 await get_tree().create_timer(1.).timeout
 assert(is_zero_approx(cut_progress))
 quick_cross(true)
 await get_tree().create_timer(1.).timeout
 var bed: Dictionary=room.item356("bed")
 hero.position=Vector3(bed.approach.x,.04,bed.approach.y)
 interact355()
 assert(sleeping362,"original bed interaction remains reachable")
 set_sleep362(0)
 set_night355(true)
 await capture421("inside-night")
 print("COTTAGE421_DONE")
 get_tree().quit()

var mid_saved:=false
func queue_mid_capture421() -> void:
 if mid_saved:return
 mid_saved=true
 capture421("crossing")

func capture421(tag: String) -> void:
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage421-"+tag+".png")
