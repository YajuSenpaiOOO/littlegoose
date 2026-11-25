extends "res://scripts/room/room_shell362.gd"
var foot_contacts363: Array[MeshInstance3D]=[]
func build_furniture() -> void:
 super.build_furniture()
 # Painted front feet are at canvas x282/1025, y1120; anchor1127 is already within ~4cm of ground.
 # Add local contact marks where those feet actually meet the floor, not just a broad shadow behind the card.
 var row:=item356("bed")
 for x in [-1.006,.993]:
  var mesh:=PlaneMesh.new();mesh.size=Vector2(.48,.36)
  var mat:=ShaderMaterial.new();mat.shader=preload("res://scripts/art/foot_contact16.gdshader")
  var n:=shape(row.root,mesh,Vector3(x,.016,1.55),mat);n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;foot_contacts363.append(n)
 apply362()
func apply362() -> void:
 super.apply362()
 for n in foot_contacts363:n.visible=art356 and use_layers362
