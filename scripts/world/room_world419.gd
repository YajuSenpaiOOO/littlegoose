extends "res://scripts/world/room_world418.gd"
var yard_ready419:=false
var path419: Array[Vector3]=[]
func room_script355() -> Script:return preload("res://scripts/room/room_shell419.gd")
func yard_script403() -> Script:return preload("res://scripts/room/home_yard419.gd")
func camera_target403(value: bool) -> Transform3D:
 if not value:return super.camera_target403(value)
 var basis:=Basis.from_euler(Vector3(deg_to_rad(-30.),0,0))
 return Transform3D(basis,Vector3(0,1.0,-.8)+basis.z*15.5)
func apply_zone410() -> void:
 super.apply_zone410()
 if ready410:
  # No independent full-width barrel ceiling above the three-volume house.
  room.roof402.hide();room.frame399.hide()
  for node in room.retired419:node.hide()
func _ready() -> void:
 await super._ready()
 rebuild_approach419()
 help367="419 · 同址娃娃屋与门前步道\nWASD实际穿门 · F3进出 · F2昼夜\n中央主厅 / 左床龛 / 右洗漱间"
 DisplayServer.window_set_title("小白鹅 · 419 · 同址娃娃屋")
 refresh367()
func rebuild_approach419() -> void:
 # Clear only the new approach corridor, retaining terrain and stable physics.
 var corridor:=Rect2(-1.7,3.35,3.4,5.8)
 for sprite in map410.find_children("*","Sprite3D",true,false):
  var p: Vector3=sprite.global_position
  if p.y<1.2 and corridor.has_point(Vector2(p.x,p.z)):sprite.hide()
 for node in map410.find_children("*","MultiMeshInstance3D",true,false):
  var mm: MultiMesh=node.multimesh
  if mm==null:continue
  for i in mm.instance_count:
   var pose:=mm.get_instance_transform(i)
   var p: Vector3=node.global_transform*pose.origin
   if p.y<.8 and corridor.has_point(Vector2(p.x,p.z)):
    pose.basis=Basis().scaled(Vector3.ZERO);mm.set_instance_transform(i,pose)
 var ground:=Node3D.new();ground.name="DoorApproach419";add_child(ground)
 for i in 9:
  var z:=3.65+i*.60
  for side in [-1.,1.]:
   var x: float=side*.43+sin(i*.8)*.10
   var y:=floor_height(Vector2(x,z))+.015
   var stone:=CylinderMesh.new()
   stone.top_radius=.43;stone.bottom_radius=.45;stone.height=.035;stone.radial_segments=7
   var tile: MeshInstance3D=room.shape(ground,stone,Vector3(x,y,z),yard403.stone413)
   tile.scale.z=.70;tile.rotation.y=i*.37+side*.12
   path419.append(Vector3(x,y,z))
 # Move complete groups, including collision and contact shadows.
 var garden_lift: float=map410.floor_height(Vector2(3.9,-2.4))-map410.floor_height(Vector2(.5,-5.5))
 map410.garden.position+=Vector3(3.4,garden_lift,3.1)
 var workshop_lift: float=map410.floor_height(Vector2(-11.2,-2.4))-map410.floor_height(Vector2(-8.,-2.6))
 map410.workshop116.position+=Vector3(-3.2,workshop_lift,.2)
 yard_ready419=true

func refresh367() -> void:
 super.refresh367()
 if is_instance_valid(follow_label363):
  follow_label363.text="镜头："+("入屋运镜" if moving_camera403 else ("室内30°" if inside403 else "小院25°"))
