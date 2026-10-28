extends "res://scripts/art/nature_park100.gd"
var treads102: Array[Dictionary]=[]
var slab_bodies102: Array[StaticBody3D]=[]
func _prism99(poly: PackedVector2Array,at: Vector3,depth: float) -> MeshInstance3D:
 var mesh := super._prism99(poly,at,depth)
 mesh.create_convex_collision()
 var body: StaticBody3D=mesh.get_child(0);body.collision_layer=1;body.collision_mask=0;slab_bodies102.append(body)
 treads102.append({"mesh":mesh,"polygon":poly})
 return mesh
func _boulder99(at: Vector3,size: Vector3,seed_value: float) -> void:
 # Broad angular, half-buried shoulders replace the rounded bead-like stones.
 var poly := PackedVector2Array([Vector2(-.48,-.31),Vector2(-.23,-.55),Vector2(.36,-.42),Vector2(.52,.12),Vector2(.23,.48),Vector2(-.44,.37)])
 for i in poly.size(): poly[i]*=Vector2(size.x*1.18,size.z)
 var local := Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
 if size.x<.5 and ((local-PLAN99.DECK)/Vector2(3.7,3.)).length()<1.: return
 var top := at.y+size.y*.22
 var depth := size.y*.8
 for corner in poly:
  var ground: float=world.floor_height(Vector2(at.x,at.z)+corner)
  depth=maxf(depth,top-ground+.10)
 var stone := super._prism99(poly,Vector3(at.x,top,at.z),depth)
 stone.rotation=Vector3(.07*sin(seed_value),seed_value*.14,.09*cos(seed_value));embedded_stones99+=1
func support102(at: Vector2) -> float:
 var top := -INF
 for item in treads102:
  var mesh: MeshInstance3D=item.mesh
  var p: Vector3=mesh.to_local(Vector3(at.x,mesh.global_position.y,at.y))
  if Geometry2D.is_point_in_polygon(Vector2(p.x,p.z),item.polygon): top=maxf(top,mesh.global_position.y)
 return top
