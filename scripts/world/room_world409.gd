extends "res://scripts/world/room_world407.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell409.gd")
func _ready() -> void:
 await super._ready()
 for node in room.get_children():
  if node is MeshInstance3D and node.mesh is BoxMesh and node.mesh.size.is_equal_approx(Vector3(2.05,.08,.22)):node.position.z=2.54;node.scale.x=.9
 room.collider(room,Vector3(0,-.06,2.7),Vector3(1.9,.08,.9))
 window400.position.x*=.9;window400.position.z*=.9
 help367="409 · 室内轻收紧10%\n家具与角色不缩放 · E查看/睡起 · F3出门"
 refresh367()
func _process(delta: float) -> void:
 super._process(delta)
 if home_ready403 and hero.position.z>2.95:exit406.emit()
