extends "res://scripts/world/cottage_world424.gd"

func house_script421() -> Script:
 return preload("res://scripts/room/cottage425.gd")

func build_threshold421() -> void:
 # The cottage itself supplies the visible, collidable stair.
 pass

func floor_height(at: Vector2) -> float:
 if is_instance_valid(house) and absf(at.x)<house.STEP_HALF_WIDTH and at.y>=3.13:
  return house.stair_top(at.y)
 return super.floor_height(at)

func _ready() -> void:
 await super._ready()
 help367="425 · 石阶与屋檐修复\nWASD 走动 · F3 进出 · F8 屋顶对照 · F2 昼夜"
 DisplayServer.window_set_title("小白鹅 · 425 · 石阶与屋檐修复")
 refresh367()
 if "--capture425" in OS.get_cmdline_user_args():call_deferred("verify425")

func verify425() -> void:
 hero.set_physics_process(false)
 companion373.hold373()
 await save425("outside")
 var heights: Array[Vector2]=[]
 var stair_image:=false
 for i in 103:
  await get_tree().physics_frame
  hero.velocity=Vector3(0,-.78,-2.2)
  hero.move_and_slide()
  var at: Vector3=hero.position
  if at.z>=3.26 and at.z<4.22:
   heights.append(Vector2(at.z,at.y))
   if not stair_image and at.z<3.93:
    stair_image=true
    await save425("on-tread")
   assert(absf(at.y-house.stair_top(at.z))<.052,"feet follow stone surface")
 assert(inside and heights.size()>20)
 for z in [4.0,3.82,3.59,3.35]:
  var ray:=PhysicsRayQueryParameters3D.create(Vector3(.70,.25,z),Vector3(.70,-.28,z),1)
  var hit:=get_world_3d().direct_space_state.intersect_ray(ray)
  assert(hit.get("collider")==house.stairs and absf(hit.position.y-house.stair_top(z))<.004)
 await get_tree().create_timer(1.).timeout
 await save425("inside")
 for x in [-1.8,1.8]:
  hero.position=Vector3(x,.04,.92)
  await get_tree().create_timer(.38).timeout
  await save425("left" if x<0. else "right")
 hero.position=Vector3(0,.04,2.25)
 await walk(Vector3(0,0,2.2),92)
 assert(not inside and hero.position.z>5.2)
 print("COTTAGE425_DONE: ",heights.size()," foot samples, four stone rays, and push-door round trip")
 get_tree().quit()

func save425(tag: String) -> void:
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage425-"+tag+".png")
