extends "res://scripts/art/paper_hill141.gd"
const PLAN142=preload("res://scripts/world/hill_layout142.gd")
var visual_treads142: Array[Dictionary]=[]
func _prism99(poly: PackedVector2Array,at: Vector3,depth: float) -> MeshInstance3D:
 var node := super._prism99(poly,at,depth)
 var p: Vector2=Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
 if stair_piece139(p): visual_treads142.append({"mesh":node,"polygon":poly})
 return node
func visual_support142(at: Vector2) -> float:
 var result := -INF
 for tread in visual_treads142:
  var mesh: MeshInstance3D=tread.mesh
  var local: Vector3=mesh.to_local(Vector3(at.x,mesh.global_position.y,at.y))
  if Geometry2D.is_point_in_polygon(Vector2(local.x,local.z),tread.polygon): result=maxf(result,mesh.global_position.y)
 return result
func _boulder99(at: Vector3,size: Vector3,seed_value: float) -> void:
 # Do not plant square, flat-topped stone blocks in the new mountain slopes.
 var p: Vector2=Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
 if PLAN142.west_radius(p)<1.4 or ((p-Vector2(-17.4,-22.2))/Vector2(3.0,4.0)).length()<1.: return
 if p.x< -12. and p.x> -34. and p.y< -17. and p.y> -32.:
  var mesh := SphereMesh.new();mesh.radial_segments=7;mesh.rings=3;mesh.radius=.5;mesh.height=1.
  var node := MeshInstance3D.new();node.mesh=mesh;node.material_override=stone97
  node.position=at+Vector3.UP*size.y*.08;node.scale=Vector3(size.x,size.y*.6,size.z);node.rotation.y=seed_value*.7;add_child(node)
  return
 super._boulder99(at,size,seed_value)
func _ready() -> void:
 super._ready()
 for p in [Vector2(-14.5,-28.5),Vector2(-12.6,-29.7),Vector2(-15.,-30.)]:
  _boulder99(point97(p,-.06),Vector3(.65,.50,.55),p.x)
 sit_point141.set_meta("purpose","Reserved narrative seat on a low dirt clearing; scenic camera retained.")
