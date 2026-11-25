extends "res://scripts/room/room_shell391.gd"
var tall392: Array[MeshInstance3D]=[]
var low392: Array[MeshInstance3D]=[]
var caps392: Array[MeshInstance3D]=[]
var walls392: Array[MeshInstance3D]=[]
var full392:=true
var style392:=0
var paper392: ShaderMaterial
func build_shell() -> void:
 super.build_shell()
 for child in get_children():
  if not child is MeshInstance3D or not child.mesh is BoxMesh:continue
  if absf(absf(child.position.x)-6.4)<.01:
   if absf(child.mesh.size.y-3.6)<.01:tall392.append(child);walls392.append(child)
   elif absf(child.mesh.size.y-.56)<.01:low392.append(child)
  elif absf(child.position.z+4.5)<.01 and absf(child.mesh.size.z-.22)<.01:walls392.append(child)
 for side in [-1.,1.]:caps392.append(box(self,Vector3(side*6.4,3.55,0),Vector3(.25,.15,9.1),"795337"))
 paper392=ShaderMaterial.new();paper392.shader=preload("res://scripts/room/wall392.gdshader")
 for wall in walls392:wall.material_override=paper392
 set_full392(true);set_style392(0)
func set_full392(value: bool) -> void:
 full392=value
 for wall in tall392:
  var mesh:=BoxMesh.new();mesh.size=Vector3(.22,3.6,9. if value else 4.2);wall.mesh=mesh
  wall.position.z=0. if value else -2.45
 for wall in low392:wall.visible=not value
 for cap in caps392:cap.visible=value
func set_style392(value: int) -> void:
 style392=posmod(value,3)
 paper392.set_shader_parameter("wallpaper",load("res://assets/room392/wall-"+["A","B","C"][style392]+".png"))
