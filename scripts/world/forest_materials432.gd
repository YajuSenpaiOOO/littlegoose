extends Node3D

const THOUGHT=preload("res://scripts/room/interaction_cloud432.gd")
const TWIG_MESH=preload("res://scripts/art/fallen_twig432.gd")
const PICKUP_FX=preload("res://scripts/world/material_pickup_fx432.gd")
const PICK_RANGE:=1.42
const RESET_DISTANCE:=19.

var world:Node3D
var sites:Array[Vector2]=[]
var twigs:Array[Node3D]=[]
var cloud:THOUGHT
var toast:Label
var toast_left:=0.
var pickup_fx:PICKUP_FX
var twig_meshes:Array[ArrayMesh]=[]
var bark:ShaderMaterial

func build() -> void:
 bark=ShaderMaterial.new()
 bark.shader=preload("res://scripts/art/log108.gdshader")
 bark.set_shader_parameter("paint108",preload("res://assets/woodland108/painted_log108.png"))
 world.porch49.shade_material(bark)
 for style in TWIG_MESH.PROFILES.size():twig_meshes.append(TWIG_MESH.build(style))
 find_tree_sites()
 for index in sites.size():
  var twig:=make_twig(index)
  twigs.append(twig)
  place_twig(twig,sites[index],index)
 var layer:=CanvasLayer.new()
 layer.layer=25
 add_child(layer)
 pickup_fx=PICKUP_FX.new()
 layer.add_child(pickup_fx)
 cloud=THOUGHT.new()
 cloud.body_size=Vector2(228,49)
 layer.add_child(cloud)
 toast=Label.new()
 toast.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 toast.add_theme_font_size_override("font_size",22)
 toast.add_theme_color_override("font_color",Color("fff0d5"))
 toast.add_theme_color_override("font_outline_color",Color("483126"))
 toast.add_theme_constant_override("outline_size",6)
 toast.mouse_filter=Control.MOUSE_FILTER_IGNORE
 layer.add_child(toast)
 toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 toast.offset_left=-230.
 toast.offset_right=230.
 toast.offset_top=-118.
 toast.offset_bottom=-80.
 toast.hide()

func find_tree_sites() -> void:
 var roots:Array[Vector2]=[]
 for tree in world.trees:
  var root:Node3D=tree.root
  if not is_instance_valid(root) or not root.visible:continue
  var base:=Vector2(root.global_position.x,root.global_position.z)
  if base.distance_to(world.grove432)>24. or world.meadow.route_distance(base)>6.:
   continue
  roots.append(base)
 roots.sort_custom(func(a:Vector2,b:Vector2):return world.meadow.route_distance(a)<world.meadow.route_distance(b))
 var used_roots:Array[Vector2]=[]
 for root in roots:
  if used_roots.any(func(other:Vector2):return other.distance_squared_to(root)<12.):continue
  var before:=sites.size()
  for index in 8:
   var angle:=TAU*index/8.
   var candidate:=root+Vector2.from_angle(angle)*(1.40+float(index%2)*.56)
   var cell:Vector2i=world.navigation.nearest(candidate)
   var at:Vector2=world.navigation.origin+Vector2(cell)*world.navigation.CELL
   if world.navigation.grid.is_point_solid(cell) or candidate.distance_to(at)>.60:continue
   if at.distance_to(root)<1.18 or world.meadow.is_water(at) or world.meadow.route_distance(at)>4.2:continue
   if sites.any(func(other:Vector2):return other.distance_squared_to(at)<1.50):continue
   sites.append(at)
   if sites.size()-before==2:break
  if sites.size()>before:used_roots.append(root)
  if used_roots.size()>=4:break

func make_twig(index:int) -> Node3D:
 var twig:=Node3D.new()
 twig.name="Twig"
 add_child(twig)
 var shadow:=MeshInstance3D.new()
 var shadow_plane:=PlaneMesh.new()
 var length:float=[1.70,1.52,1.63][index%3]
 shadow_plane.size=Vector2(length*.95,.32)
 shadow.mesh=shadow_plane
 shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var soft_edge:=ShaderMaterial.new()
 soft_edge.shader=preload("res://scripts/art/foot_contact16.gdshader")
 shadow.material_override=soft_edge
 shadow.position.y=.016
 shadow.rotation.y=-.22
 twig.add_child(shadow)
 var art:=MeshInstance3D.new()
 art.mesh=twig_meshes[index%twig_meshes.size()]
 art.material_override=bark
 art.rotation.z=-PI*.5
 art.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 twig.add_child(art)
 return twig

func place_twig(twig:Node3D,at:Vector2,index:int) -> void:
 twig.position=Vector3(at.x,world.floor_height(at),at.y)
 var rise_x:float=world.floor_height(at+Vector2(.23,0.))-world.floor_height(at-Vector2(.23,0.))
 var rise_z:float=world.floor_height(at+Vector2(0.,.23))-world.floor_height(at-Vector2(0.,.23))
 var up:=Vector3(-rise_x,.46,-rise_z).normalized()
 var yaw:=float(index)*.73+float(twig.get_meta("slide_yaw",0.))
 var back:=Vector3.BACK.rotated(Vector3.UP,yaw).slide(up).normalized()
 twig.basis=Basis(up.cross(back),up,back)

func _physics_process(delta:float) -> void:
 if not is_instance_valid(world.hero) or world.combat_paused:return
 var hero:Vector3=world.hero.global_position
 var motion:=Vector2(world.hero.velocity.x,world.hero.velocity.z)
 for index in twigs.size():
  var twig:=twigs[index]
  if not twig.visible:continue
  var at:=Vector2(twig.position.x,twig.position.z)
  var away:=at-Vector2(hero.x,hero.z)
  var speed:Vector2=twig.get_meta("slide",Vector2.ZERO)
  var gate:float=maxf(0.,float(twig.get_meta("kick_wait",0.))-delta)
  var axis:=Vector2(twig.basis.x.x,twig.basis.x.z).rotated(.22).normalized()
  var contact:=away-axis*clampf(away.dot(axis),-.48,.48)
  if gate<=0. and contact.length_squared()<.36*.36 and motion.length_squared()>.65*.65 and absf(hero.y-twig.position.y)<.45 and contact.dot(motion)>0.:
   speed=(motion.normalized()*.65+away.normalized()*.45).limit_length(1.1)
   gate=.42
  if gate>0. or twig.has_meta("kick_wait"):twig.set_meta("kick_wait",gate)
  if speed.length_squared()<.0001:continue
  var next:=at+speed*delta
  var from:=twig.global_position+Vector3.UP*.13
  var end:=Vector3(next.x,from.y,next.y)
  var query:=PhysicsRayQueryParameters3D.create(from,end,2)
  if not world.meadow.is_water(next) and next.distance_to(sites[index])<1.25 and absf(world.floor_height(next)-twig.position.y)<.16 and get_world_3d().direct_space_state.intersect_ray(query).is_empty():
   twig.set_meta("slide_yaw",float(twig.get_meta("slide_yaw",0.))+speed.length()*delta*.65)
   place_twig(twig,next,index)
  twig.set_meta("slide",speed.move_toward(Vector2.ZERO,2.2*delta))

func nearest_twig() -> Node3D:
 var target:Node3D=null
 var distance:=PICK_RANGE*PICK_RANGE
 for twig in twigs:
  var next:float=world.hero.global_position.distance_squared_to(twig.global_position)
  if twig.visible and next<distance:
   target=twig
   distance=next
 return target

func pick_twig() -> bool:
 var twig:=nearest_twig()
 if twig==null:return false
 var kit=world.memory_kit116
 if kit.twigs>=999999:return true
 kit.twigs+=1
 if kit.save_to(world.memory_save116)==OK:
  pickup_fx.burst(twig.global_position+Vector3.UP*.09,Color("ffdd9a"))
  twig.hide()
  notify("捡到小树枝 ×1")
 else:
  kit.twigs-=1
  notify("树枝暂时没收好 · 可以再捡一次")
 return true

func notify(copy:String) -> void:
 if not is_instance_valid(toast):return
 toast.text=copy
 toast_left=1.9

func update_prompt(delta:float,available:bool,playmate:Node3D,invitation:String) -> void:
 if not is_instance_valid(cloud):return
 toast_left=maxf(0.,toast_left-delta)
 toast.visible=toast_left>0.
 toast.modulate.a=minf(1.,toast_left/.28)
 for index in twigs.size():
  var twig:=twigs[index]
  if not twig.visible and world.hero.global_position.distance_to(twig.global_position)>RESET_DISTANCE:
   twig.set_meta("slide_yaw",0.)
   place_twig(twig,sites[index],index)
   twig.set_meta("slide",Vector2.ZERO)
   twig.set_meta("kick_wait",0.)
   twig.show()
 var target:=nearest_twig() if available else null
 var prompt:=""
 if target!=null:
  prompt="E · 捡起小树枝"
 elif is_instance_valid(playmate):
  target=playmate
  prompt="E · "+invitation
 var anchor:=Vector2.ZERO
 if target!=null:
  var camera:Camera3D=get_viewport().get_camera_3d()
  var point:=target.global_position+Vector3.UP*(1.35 if target is CharacterBody3D else .25)
  if camera.is_position_behind(point):
   prompt=""
  else:
   anchor=camera.unproject_position(point)
 cloud.present(delta,prompt,anchor)
