extends "res://scripts/world/cottage_world421.gd"

var garden: Node3D

func room_script355() -> Script:
 return preload("res://scripts/room/room_shell422.gd")

func house_script421() -> Script:
 return preload("res://scripts/room/cottage422.gd")

func _ready() -> void:
 await super._ready()
 help367="422 · 后屋顶、木隔墙与真窗\nWASD走过门槛 · F3进出对照 · F2昼夜"
 DisplayServer.window_set_title("小白鹅 · 422 · 窗外花园")
 refresh367()
 if "--capture422" in OS.get_cmdline_user_args():call_deferred("validate421")

func build_ground() -> void:
 super.build_ground()
 garden=Node3D.new()
 garden.name="RearGarden422"
 add_child(garden)
 for data in [[-2.25,-7.6,1.0],[2.8,-9.0,1.12],[-3.9,-13.1,1.22],[5.0,-14.2,1.35],[-.55,-17.1,1.24],[2.7,-18.5,1.38],[-5.6,-17.,1.5]]:
  grow_tree(Vector3(data[0],-.22,data[1]),data[2])
 # Low foreground leaves and flowers fall within the window sightline.
 for data in [[-1.15,-6.14,.72],[1.22,-6.66,.95],[-1.69,-6.78,1.12],[1.83,-7.4,1.10]]:
  var at:=Vector3(data[0],-.17,data[1])
  for i in 5:
   var offset:=Vector3(sin(i*2.3)*.34,.22+i*.09,cos(i*2.3)*.28)*float(data[2])
   house.oval(garden,at+offset,Vector3(.77,.55,.68)*data[2],house.color("738e48" if i%2 else "96a659"))
  for i in 6:
   house.flowers(garden,at+Vector3(sin(i*2.2)*.37,.26+i*.043,cos(i*2.2)*.30),1.03)
 var rng:=RandomNumberGenerator.new()
 rng.seed=422
 for i in 36:
  var at:=Vector3(rng.randf_range(-5.8,5.8),-.14,rng.randf_range(-13.5,-5.4))
  if absf(at.x)<.72:continue
  house.oval(garden,at,Vector3(.48,.24,.38),house.color("556c36"))
  if i%3!=0:house.flowers(garden,at+Vector3.UP*.07,.68)
 for i in 13:
  var z:=-5.25-i*.72
  var x:=sin(i*.34)*.78
  var mesh:=CylinderMesh.new()
  mesh.height=.04
  mesh.top_radius=.36
  mesh.bottom_radius=.39
  mesh.radial_segments=7
  var tread: MeshInstance3D=house.mesh_at(garden,mesh,Vector3(x,-.20,z),house.stone)
  tread.scale.z=.66
  tread.rotation.y=i*.66

func grow_tree(at: Vector3,gain: float) -> void:
 var bark: Material=house.color("5d4931")
 house.block(garden,at+Vector3.UP*1.10*gain,Vector3(.27,2.20,.29)*gain,bark,true).rotation.z=-.08
 house.beam(garden,at+Vector3(0,1.4,0)*gain,at+Vector3(.7,2.2,.2)*gain,.13*gain,.14*gain,bark)
 for data in [[-.65,2.23,-.10,1.45,"637b3c"],[.66,2.53,.09,1.34,"8b9c4f"],[0.,3.04,-.12,1.74,"789144"],[.26,2.31,.57,1.19,"9aaa5b"],[-.45,2.73,.35,1.22,"84994f"]]:
  house.oval(garden,at+Vector3(data[0],data[1],data[2])*gain,Vector3(1.16,.88,1.04)*data[3]*gain,house.color(data[4]))

func set_night355(value: bool) -> void:
 super.set_night355(value)
 environment.background_color=Color("43546d") if value else Color("aab484")
 environment.ambient_light_color=Color("bac8e0") if value else Color("e4e3d9")

func move_camera(value: float) -> void:
 super.move_camera(value)
 if "--capture422" in OS.get_cmdline_user_args() and value>.53 and value<.67:queue_mid_capture421()

func capture421(tag: String) -> void:
 if tag=="inside":
  assert(not room.garden393.visible and not room.dressing393.visible)
  assert(house.roof_cut[0].node.visible and room.partitions.size()==4)
  assert(is_equal_approx(house.roof_cut[0].ink.get_shader_parameter("keep_behind"),house.REAR_CUT))
  for side in [-1.,1.]:
   var ray:=PhysicsRayQueryParameters3D.create(Vector3(side*2.60,1.2,-2.31),Vector3(side*3.40,1.2,-2.31))
   var hit:=get_world_3d().direct_space_state.intersect_ray(ray)
   assert(hit.get("collider") in room.partitions,"alcove return wall physically blocks")
  var view_ray:=PhysicsRayQueryParameters3D.create(Vector3(0.42,1.64,-3.47),Vector3(.42,1.64,-5.))
  assert(get_world_3d().direct_space_state.intersect_ray(view_ray).is_empty(),"window centre remains open to the scene")
  print("COTTAGE422_OPEN_WINDOW_PARTITIONS_AND_ROOF_DONE")
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage422-"+tag+".png")
