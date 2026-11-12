extends "res://scripts/art/paper_stage334.gd"
var gap335: MeshInstance3D
func _ready() -> void:
 super._ready()
 gap335=make_ring327()
 gap335.hide()
func show_gap335(at: Vector3, direction: Vector2, visible_gap: bool) -> void:
 if not is_instance_valid(gap335): return
 gap335.visible=visible_gap
 var mesh:=gap335.mesh as ImmediateMesh
 mesh.clear_surfaces()
 if not visible_gap: return
 mesh.surface_begin(Mesh.PRIMITIVE_LINES)
 for angle in [-PI/6.,PI/6.]:
  var heading:=direction.rotated(angle)
  for distance in [1.,3.5]:
   var p: Vector2=Vector2(at.x,at.z)+heading*distance
   mesh.surface_set_color(Color(1.,.85,.45,.65))
   mesh.surface_add_vertex(Vector3(p.x,battle.floor_height(p)+.06,p.y))
 mesh.surface_end()
