extends "res://scripts/room/room_shell398.gd"
var frame399: Node3D
var old_frame399: Array[MeshInstance3D]=[]
var use_frame399:=true
func build_shell() -> void:
 super.build_shell()
 for c in get_children():
  if not c is MeshInstance3D or not c.mesh is BoxMesh:continue
  if c.position.distance_to(Vector3(0,3.5,-4.25))<.01 or (absf(absf(c.position.x)-6.1)<.01 and c.position.distance_to(Vector3(c.position.x,1.8,-4.27))<.01):old_frame399.append(c)
 frame399=preload("res://scripts/room/timber_frame399.gd").new();add_child(frame399);frame399.build399(paper392)
 set_frame399(true)
func set_frame399(value: bool) -> void:
 use_frame399=value;frame399.visible=value
 for c in old_frame399:c.visible=not value
