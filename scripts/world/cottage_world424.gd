extends "res://scripts/world/cottage_world423.gd"

func room_script355() -> Script:
 return preload("res://scripts/room/room_shell424.gd")

func house_script421() -> Script:
 return preload("res://scripts/room/cottage424.gd")

func _ready() -> void:
 await super._ready()
 help367="424 · 屋顶与墙体合拢\nWASD 走动 · F3 进出 · F8 完整屋顶对照 · F2 昼夜"
 DisplayServer.window_set_title("小白鹅 · 424 · 室内顶与合缝")
 refresh367()
 if "--capture424" in OS.get_cmdline_user_args():call_deferred("capture_comparison")

func camera_pose(value: bool) -> Transform3D:
 if not value:return super.camera_pose(false)
 var pose:=super.camera_pose(true)
 # Lower the eye within the same close shot so the roof reads from below.
 pose.origin.y-=.30
 return pose

func _input(event: InputEvent) -> void:
 if ready421 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F8:
  house.full_roof=not house.full_roof
  house.set_cut(cut_progress)
  get_viewport().set_input_as_handled()
  return
 super._input(event)

func capture_comparison() -> void:
 hero.set_physics_process(false)
 companion373.hold373()
 await walk(Vector3(0,0,-2.45),90)
 assert(inside and house.swing_side==1)
 await get_tree().create_timer(1.0).timeout
 assert(house.joinery.visible and not house.inner_eaves.visible)
 await save_424("inside")
 house.full_roof=true
 house.set_cut(cut_progress)
 assert(not house.joinery.visible and house.roof_cut[0].node.visible)
 await save_424("full-roof")
 house.full_roof=false
 house.set_cut(cut_progress)
 for side in [-1.,1.]:
  hero.position=Vector3(side*2.22,.04,.99)
  await walk(Vector3(side*2.35,0,0),45)
  assert(absf(hero.position.x)>3.5)
  await get_tree().create_timer(.26).timeout
  await save_424("left" if side<0. else "right")
 hero.position=Vector3(0,.04,2.28)
 await walk(Vector3(0,0,2.25),63)
 assert(not inside and house.swing_side==-1)
 await get_tree().create_timer(1.0).timeout
 assert(not house.joinery.visible and is_zero_approx(cut_progress))
 print("COTTAGE424_DONE underside, full-roof comparison, both alcoves and exit")
 get_tree().quit()

func save_424(tag: String) -> void:
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage424-"+tag+".png")
