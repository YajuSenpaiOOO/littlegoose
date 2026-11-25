extends "res://scripts/world/cottage_world422.gd"

var look_follow:=Vector3.ZERO
var capture_pending:=false

func room_script355() -> Script:
 return preload("res://scripts/room/room_shell423.gd")

func house_script421() -> Script:
 return preload("res://scripts/room/cottage423.gd")

func companion_script373() -> Script:
 return preload("res://scripts/combat/goose_follow423.gd")

func _ready() -> void:
 await super._ready()
 # Preserve one-way yielding even when the room corner leaves no sidestep.
 companion373.collision_layer=1<<21
 companion373.add_collision_exception_with(hero)
 help367="423 · 低视点与随行镜头\nWASD 推门 / 让路 · F3 进出对照 · F2 昼夜"
 DisplayServer.window_set_title("小白鹅 · 423 · 小屋内景")
 refresh367()
 if "--capture423" in OS.get_cmdline_user_args():call_deferred("validate_motion")

func camera_pose(value: bool) -> Transform3D:
 if not value:return super.camera_pose(false)
 var size:=get_viewport().get_visible_rect().size
 var aspect:=size.x/maxf(size.y,1.)
 var basis:=Basis.from_euler(Vector3(deg_to_rad(-12.),0,0))
 var distance:=10.50*maxf(1.,1.68/aspect)
 var target:=Vector3(0,1.52,-1.58)+look_follow
 return Transform3D(basis,target+basis.z*distance)

func _process(delta: float) -> void:
 super._process(delta)
 if not ready421:return
 var target:=Vector3(clampf(hero.position.x*.15,-.75,.75),0,clampf((hero.position.z-.4)*.09,-.31,.30)) if inside and not sleeping362 else Vector3.ZERO
 look_follow=look_follow.lerp(target,1.-exp(-delta*5.5))
 camera.global_transform=camera_pose(false).interpolate_with(camera_pose(true),cut_progress)
 follow_label363.text="镜头移动中" if crossing else ("室内 12° · 轻跟随" if inside else "屋外 25°")

func update_door421(point: Vector2) -> void:
 var offset: float=point.y-house.THRESHOLD
 var face:=1 if offset>=0. else -1
 var approaching:=hero.velocity.z*face<-.10
 var in_mouth:=absf(point.x)<1.12 and absf(offset)<.68
 var inside_swing:=absf(point.x)<1.25 and absf(offset)<1.83
 var companion_gap: Vector3=companion373.position-Vector3(0,0,house.THRESHOLD)
 if in_mouth and approaching:
  # Latch through the threshold. A genuine reversal away from the pivot
  # can request a swing in the opposite direction.
  if house.swing_side==0 or absf(offset)>.28:house.swing(face)
 elif not inside_swing:
  if absf(companion_gap.x)<1.10 and absf(companion_gap.z)<.88 and companion373.mode373!="hold":
   if house.swing_side==0:house.swing(1 if companion_gap.z>=0. else -1)
  elif not crossing:
   house.swing(0)

func quick_cross(value: bool) -> void:
 super.quick_cross(value)
 house.swing(1 if value else -1)

func move_camera(value: float) -> void:
 super.move_camera(value)
 if "--capture423" in OS.get_cmdline_user_args() and value>.53 and value<.67:queue_mid_capture421()

func capture421(tag: String) -> void:
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage423-"+tag+".png")

func walk(direction: Vector3,steps: int) -> void:
 for i in steps:
  await get_tree().physics_frame
  hero.velocity=direction+Vector3.DOWN*.55
  hero.move_and_slide()

func validate_motion() -> void:
 hero.set_physics_process(false)
 companion373.hold373()
 await capture421("outside")
 await walk(Vector3(0,0,-2.45),90)
 assert(inside and hero.position.z<3.0 and house.swing_side==1,"inward door push")
 await get_tree().create_timer(1.0).timeout
 await capture421("inside")
 # Disengage and return through the door after it closes.
 hero.position=Vector3(1.73,.04,1.03)
 hero.velocity=Vector3.ZERO
 await get_tree().create_timer(.7).timeout
 assert(house.swing_side==0)
 assert(look_follow.x>.18 and look_follow.x<.75)
 await capture421("follow")
 hero.position=Vector3(0,.04,2.29)
 await walk(Vector3(0,0,2.25),61)
 assert(not inside and hero.position.z>4.35 and house.swing_side==-1,"outward door push")
 await walk(Vector3(0,0,2.25),24)
 hero.velocity=Vector3.ZERO
 await get_tree().create_timer(1.2).timeout
 assert(absf(house.pivot.rotation.y)<.01)
 companion373.position=Vector3(0,-.20,5.24)
 hero.position=Vector3(0,-.20,5.97)
 await walk(Vector3(0,0,-2.2),48)
 assert(companion373.yielding_steps>0 and absf(companion373.position.x)>.27 and hero.position.z<4.40)
 print("COTTAGE423_DONE door two-way, close, camera follow and contact yielding")
 if not inside:quick_cross(true)
 hero.velocity=Vector3.ZERO
 await get_tree().create_timer(1.05).timeout
 set_night355(true)
 await capture421("night")
 get_tree().quit()
