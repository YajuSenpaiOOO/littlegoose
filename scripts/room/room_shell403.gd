extends "res://scripts/room/room_shell402.gd"
var source_times403: Array=[]
var textures403: Dictionary={}
func build_furniture() -> void:
 var t:=Time.get_ticks_msec();super.build_furniture();print("HOME403_FURNITURE_MS ",Time.get_ticks_msec()-t)
func build_hourglass() -> void:
 var t:=Time.get_ticks_msec();super.build_hourglass();print("HOME403_HOURGLASS_MS ",Time.get_ticks_msec()-t)
func source356(path: String) -> Texture2D:
 if textures403.has(path):return textures403[path]
 var start:=Time.get_ticks_msec();var texture: Texture2D=super.source356(path)
 source_times403.append({"path":path,"ms":Time.get_ticks_msec()-start})
 textures403[path]=texture
 return texture
func build_shell() -> void:
 var t:=Time.get_ticks_msec()
 super.build_shell()
 print("HOME403_SHELL_MS ",Time.get_ticks_msec()-t)
 apply_boundary403()
func set_layout402(value: bool) -> void:
 super.set_layout402(value)
 if value:apply_boundary403()
func apply_boundary403() -> void:
 # The house ends at the threshold. No retained indoor flooring in the yard.
 var inner:=PlaneMesh.new();inner.size=Vector2(12.6,7.1)
 floor391.mesh=inner;floor391.position.z=-.85
 for saved in shell_state402:
  var c: Node3D=saved.node
  var size: Vector3=saved.mesh.size if saved.has("mesh") else saved.shape.size
  if absf(saved.at.z-5.25)<.01 or absf(saved.at.z-6.05)<.01:
   if c is StaticBody3D:c.collision_layer=0
   else:c.visible=false
  if absf(saved.at.y+.22)<.01 and size.x>12.:
   var mesh:=BoxMesh.new();mesh.size=Vector3(12.9,.42,7.2);c.mesh=mesh;c.position.z=-.9
  elif absf(saved.at.y+.15)<.01 and size.x>12.:
   var body_shape:=BoxShape3D.new();body_shape.size=Vector3(12.9,.3,7.2);c.get_child(0).shape=body_shape;c.position.z=-.9
 for node in roof402.get_children():
  if node is MeshInstance3D and node.mesh is PlaneMesh:node.hide()
