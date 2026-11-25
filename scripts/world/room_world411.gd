extends "res://scripts/world/room_world410.gd"
var ready411:=false
var sample411: Array=[]
func yard_script403() -> Script:return preload("res://scripts/room/home_yard411.gd")
func camera_target403(value: bool) -> Transform3D:
 if value:return super.camera_target403(value)
 var basis:=Basis.from_euler(Vector3(deg_to_rad(-25.),deg_to_rad(-18. if side_view404 else 0.),0))
 return Transform3D(basis,Vector3(0,1.4,4.6)+basis.z*20.8)
func _ready() -> void:
 await super._ready()
 yard403.get_node("DarkDoorway410").hide()
 clear_footprint411()
 # Geometry remains resident and visible. Only the covering shell cuts away.
 ready411=true;apply_zone410();camera403(false)
 help367="411 · 室内外常驻 / 连续切屋顶\nWASD实际穿门 · 靠近自动开门\nF3快捷进出 · F2昼夜 · F12跟随\n外壳加宽以包住原尺寸家具，409/410保留"
 DisplayServer.window_set_title("小白鹅 · 411 · 室内外常驻与连续切墙")
 refresh367();print("HOME411_READY")
func apply_zone410() -> void:
 if not ready410:return
 room.show();map410.show()
 # These are interior cutaway ceiling/rear arch overlays, not the furnishings
 # visible through an open door. Cover them with the exterior outside.
 room.roof402.visible=inside403;room.frame399.visible=inside403
 if yard403.has_node("DarkDoorway410"):yard403.get_node("DarkDoorway410").hide()
 # Keep both sets of surfaces physical through the whole camera movement.
 for body in room_layers410:body.collision_layer=room_layers410[body]
 for body in yard403.walls410:body.collision_layer=1
 # 410 temporarily disables the map when invoking this virtual hook during
 # startup; this version never removes its physics or display for a crossing.
 for body in map410.find_children("*","CollisionObject3D",true,false):
  if body.has_meta("outside410"):body.collision_layer=body.get_meta("outside410")
func clear_footprint411() -> void:
 var footprint:=Rect2(-6.05,-4.8,12.10,7.20)
 var removed:=0
 for tree in map410.trees:
  var p: Vector3=tree.root.global_position
  if footprint.has_point(Vector2(p.x,p.z)):
   tree.root.hide()
   for body in tree.root.find_children("*","CollisionObject3D",true,false):body.collision_layer=0
 for sprite in map410.find_children("*","Sprite3D",true,false):
  var p: Vector3=sprite.global_position
  if p.y<5.5 and footprint.has_point(Vector2(p.x,p.z)):sprite.hide()
 for node in map410.find_children("*","MultiMeshInstance3D",true,false):
  var mm: MultiMesh=node.multimesh
  if mm==null:continue
  for i in mm.instance_count:
   var pose: Transform3D=mm.get_instance_transform(i);var p: Vector3=node.global_transform*pose.origin
   if p.y<.8 and footprint.has_point(Vector2(p.x,p.z)):
    pose.basis=Basis().scaled(Vector3.ZERO);mm.set_instance_transform(i,pose);removed+=1
 for body in map410.find_children("*","StaticBody3D",true,false):
  var p: Vector3=body.global_position
  if p.y<.12 or not footprint.has_point(Vector2(p.x,p.z)):continue
  if body.get_child_count()>0 and body.get_child(0) is CollisionShape3D and not body.get_child(0).shape is ConcavePolygonShape3D:body.collision_layer=0
 print("HOME411_FOOTPRINT_GRASS ",removed)
func switch_zone403(value: bool,animate: bool=true) -> void:
 if not home_ready403 or inside403==value:return
 inside403=value
 # Both directions restore/cut the shell in this frame, never after the tween.
 yard403.facade403.visible=not value
 camera403(animate);apply400();refresh367();apply_zone410()
 transitions403.append({"inside":value,"ms":Time.get_ticks_msec(),"node_count":get_tree().get_node_count()})
func finish_camera403() -> void:
 super.finish_camera403()
 if ready410:apply_zone410()
func _process(delta: float) -> void:
 super._process(delta)
 if ready411 and moving_camera403:
  sample411.append({"inside":inside403,"room":room.visible,"map":map410.visible,"shell":yard403.facade403.visible,"camera":camera.global_position})
 # 404 hides the door upper half while any camera moves. On exit the complete
 # leaf belongs to the restored exterior immediately, including the moving shot.
 if ready411:
  for ink in yard403.door_inks404:ink.set_shader_parameter("cutaway",inside403)
