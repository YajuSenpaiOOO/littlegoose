extends "res://scripts/world/cottage_world425.gd"

const MAP_SITE := Vector2(-5.30,-8.73)
var landscape: Node3D
var terrain_offset:=0.
var exterior_follow:=Vector3.ZERO
var hero_steps:=0

func house_script421() -> Script:
 return preload("res://scripts/room/cottage426.gd")

func _ready() -> void:
 var loading:=CanvasLayer.new()
 loading.layer=100
 add_child(loading)
 var cover:=ColorRect.new()
 cover.color=Color("262820")
 cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 loading.add_child(cover)
 var title:=Label.new()
 title.text="正在载入小院所在的大地图…"
 title.position=Vector2(52,46)
 title.add_theme_font_size_override("font_size",25)
 loading.add_child(title)
 await get_tree().process_frame
 var path:="res://scripts/world/woodland_world409.gd"
 ResourceLoader.load_threaded_request(path,"Script")
 while ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_IN_PROGRESS:
  await get_tree().process_frame
 if ResourceLoader.load_threaded_get_status(path)!=ResourceLoader.THREAD_LOAD_LOADED:
  title.text="大地图资源载入失败"
  return
 landscape=ResourceLoader.load_threaded_get(path).new()
 landscape.memory_save116="user://cottage426-preview.cfg"
 add_child(landscape)
 while not landscape.ready405:await get_tree().process_frame
 prepare_site()
 await super._ready()
 hero.collision_mask|=2|16
 companion373.collision_mask|=2|16
 # Disable the workshop and garden tree's actors together with the legacy map loop.
 loading.queue_free()
 help367="426 · 小屋落位试玩\nWASD 逛小院 / 推门 · F3 进出 · F8 屋顶对照 · F2 昼夜"
 DisplayServer.window_set_title("小白鹅 · 426 · 大世界小院落位")
 refresh367()
 print("COTTAGE426_SITE_READY ",terrain_offset)
 if "--capture426" in OS.get_cmdline_user_args():call_deferred("verify426")

func prepare_site() -> void:
 var grade: float=landscape.terrain405(MAP_SITE+Vector2(0,4.36))
 var highest:=grade
 for x in range(-6,7):
  for z in range(-3,4):
   if abs(x)>3 and (z< -2 or z>2):continue
   highest=maxf(highest,landscape.terrain405(MAP_SITE+Vector2(x,z)))
 terrain_offset=-maxf(grade+.22,highest+.055)
 for body in landscape.find_children("*","CollisionObject3D",true,false):
  body.disable_mode=CollisionObject3D.DISABLE_MODE_KEEP_ACTIVE
 landscape.process_mode=Node.PROCESS_MODE_DISABLED
 landscape.position=Vector3(-MAP_SITE.x,terrain_offset,-MAP_SITE.y)
 landscape.model405.hide()
 for body in landscape.model405.find_children("*","CollisionObject3D",true,false):body.collision_layer=0
 landscape.hero.hide()
 landscape.hero.collision_layer=0
 landscape.hero.collision_mask=0
 landscape.goose.hide()
 for node in landscape.find_children("*","CanvasLayer",true,false):node.hide()
 for node in landscape.find_children("*","Camera3D",true,false):node.current=false
 for node in landscape.find_children("*","WorldEnvironment",true,false):node.environment=null
 for node in landscape.find_children("*","DirectionalLight3D",true,false):node.hide()
 var house_pad:=Rect2(-6.40,-4.05,12.80,7.30)
 var front_aisle:=Rect2(-1.5,3.20,3.0,2.95)
 for tree in landscape.trees:
  var p: Vector3=tree.root.global_position
  if house_pad.has_point(Vector2(p.x,p.z)) or front_aisle.has_point(Vector2(p.x,p.z)):
   tree.root.hide()
   for body in tree.root.find_children("*","CollisionObject3D",true,false):body.collision_layer=0
 for batch in landscape.find_children("*","MultiMeshInstance3D",true,false):
  var multimesh: MultiMesh=batch.multimesh
  if multimesh==null:continue
  for i in multimesh.instance_count:
   var pose:=multimesh.get_instance_transform(i)
   var p: Vector3=batch.to_global(pose.origin)
   if p.y<.72 and (house_pad.has_point(Vector2(p.x,p.z)) or front_aisle.has_point(Vector2(p.x,p.z))):
    pose.basis=Basis().scaled(Vector3.ZERO)
    multimesh.set_instance_transform(i,pose)
 for sprite in landscape.find_children("*","Sprite3D",true,false):
  var p: Vector3=sprite.global_position
  if p.y<.84 and house_pad.has_point(Vector2(p.x,p.z)):sprite.hide()
 for body in landscape.find_children("*","StaticBody3D",true,false):
  var p: Vector3=body.global_position
  if p.y<.10 or not (house_pad.has_point(Vector2(p.x,p.z)) or front_aisle.has_point(Vector2(p.x,p.z))):continue
  for shape in body.find_children("*","CollisionShape3D",true,false):
   if shape.shape is BoxShape3D or shape.shape is CapsuleShape3D:
    body.collision_layer=0
    break
 # Move complete prop groups with their feet, colliders and contact shadow meshes.
 var offset:=Vector3(2.5,0,2.0)
 var center:=Vector2(.50,-5.5)
 offset.y=landscape.terrain405(center+Vector2(offset.x,offset.z))-landscape.terrain405(center)
 landscape.garden.position+=offset
 var workshop_offset:=Vector3(-2.3,0,.4)
 center=Vector2(-8.,-2.6)
 workshop_offset.y=landscape.terrain405(center+Vector2(workshop_offset.x,workshop_offset.z))-landscape.terrain405(center)
 landscape.workshop116.position+=workshop_offset

func build_ground() -> void:
 # Terrain and garden come from the map. Fit a short stone approach to it.
 var s:=SurfaceTool.new()
 s.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 6:
  var a:=lerpf(4.32,5.34,i/6.)
  var b:=lerpf(4.32,5.34,(i+1)/6.)
  var a_mix:=smoothstep(4.32,5.34,a)
  var b_mix:=smoothstep(4.32,5.34,b)
  var a0:=lerpf(-.22,terrain_at(Vector2(-1.18,a))+.015,a_mix)
  var a1:=lerpf(-.22,terrain_at(Vector2(1.18,a))+.015,a_mix)
  var b0:=lerpf(-.22,terrain_at(Vector2(-1.18,b))+.015,b_mix)
  var b1:=lerpf(-.22,terrain_at(Vector2(1.18,b))+.015,b_mix)
  house.cap_quad(s,Vector3(-1.18,a0,a),Vector3(1.18,a1,a),Vector3(1.18,b1,b),Vector3(-1.18,b0,b))
 s.generate_normals()
 var approach: MeshInstance3D=house.mesh_at(self,s.commit(),Vector3.ZERO,house.stone)
 approach.create_trimesh_collision()
 approach.get_child(0).get_child(0).shape.backface_collision=true
 for pad in [house.HALL,house.LEFT,house.RIGHT]:
  var center: Vector2=pad.get_center()
  house.block(self,Vector3(center.x,-.28,center.y),Vector3(pad.size.x,.52,pad.size.y),house.stone)

func terrain_at(at: Vector2) -> float:
 return landscape.terrain405(at+MAP_SITE)+terrain_offset

func floor_height(at: Vector2) -> float:
 if not is_instance_valid(landscape) or not landscape.ready405:return -.22
 if is_instance_valid(house):
  if absf(at.x)<house.STEP_HALF_WIDTH and at.y>=3.13 and at.y<=4.36:return house.stair_top(at.y)
  for pad in [house.HALL,house.LEFT,house.RIGHT]:
   if pad.has_point(at):return 0.
 return terrain_at(at)

func camera_pose(value: bool) -> Transform3D:
 var transform:=super.camera_pose(value)
 if not value:transform.origin+=exterior_follow
 return transform

func _physics_process(delta: float) -> void:
 if not ready421:return
 if hero.is_physics_processing() and not sleeping362 and house.try_step(hero,delta,hero.movement_input()):hero_steps+=1
 if companion373.is_physics_processing():house.try_step(companion373,delta)

func _process(delta: float) -> void:
 if ready421:
  var z:=hero.position.z
  var follow_z:=minf(0.,z+4.5)+maxf(0.,z-5.8)
  var target:=Vector3(hero.position.x,0,follow_z)
  exterior_follow=exterior_follow.lerp(target if not inside else Vector3.ZERO,1.-exp(-delta*5.))
 super._process(delta)

func verify426() -> void:
 companion373.hold373()
 await get_tree().create_timer(.42).timeout
 await save426("outside")
 drive426(KEY_W,true)
 var tread_saved:=false
 var deadline:=Time.get_ticks_msec()+4500
 while not inside and Time.get_ticks_msec()<deadline:
  await get_tree().physics_frame
  if hero_steps==1 and not tread_saved:
   tread_saved=true
   await save426("tread")
 drive426(KEY_W,false)
 hero.set_physics_process(false)
 hero.velocity=Vector3.ZERO
 print("COTTAGE426_STAIRS ",hero_steps," ",hero.position)
 assert(inside and hero_steps==2)
 await get_tree().create_timer(1.).timeout
 await save426("inside")
 hero.position=Vector3(0,.04,2.22)
 await walk(Vector3(0,0,2.32),103)
 assert(not inside and hero.position.z>5.1)
 assert(hero.position.y>terrain_at(Vector2(0,hero.position.z))-.09)
 for x in [-4.575,4.575]:
  var q:=PhysicsRayQueryParameters3D.create(Vector3(x,.84,3.6),Vector3(x,.84,2.24),1)
  var result:=get_world_3d().direct_space_state.intersect_ray(q)
  assert(result.get("collider") in house.wood_colliders,"window box blocks at its actual depth")
 for x in [-2.90,2.90]:
  var q:=PhysicsRayQueryParameters3D.create(Vector3(x,.35,4.10),Vector3(x,.35,3.28),1)
  var result:=get_world_3d().direct_space_state.intersect_ray(q)
  assert(result.get("collider") in house.wood_colliders,"stone socket blocks at its actual depth")
 set_night355(true)
 await get_tree().create_timer(.6).timeout
 await save426("night")
 print("COTTAGE426_DONE")
 get_tree().quit()

func drive426(key: Key,pressed: bool) -> void:
 var event:=InputEventKey.new()
 event.physical_keycode=key
 event.pressed=pressed
 Input.parse_input_event(event)

func save426(tag: String) -> void:
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage426-"+tag+".png")
