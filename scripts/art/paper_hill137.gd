extends "res://scripts/art/paper_hill136.gd"
const HILL137=preload("res://scripts/world/park_layout137.gd")
var ramp_treads137 := 0
func _cylinder97(a: Vector3,b: Vector3,radius: float,material: Material,solid := false,parent: Node3D=null) -> MeshInstance3D:
 var p: Vector2=Vector2((a.x+b.x)*.5,(a.z+b.z)*.5)-Vector2(world.meadow.landmarks.grove)
 var blocks_exit := parent==null and maxf(a.y,b.y)<5. and HILL137.stair137(p).x<1.8
 var node := super._cylinder97(a,b,radius,material,solid and not blocks_exit,parent)
 if blocks_exit: node.hide()
 return node
func _prism99(poly: PackedVector2Array,at: Vector3,depth: float) -> MeshInstance3D:
 var mesh := super._prism99(poly,at,depth)
 var p: Vector2=Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
 var old: Vector2=world.PARK99.to_stair99(p)
 var entry: bool=absf(old.x-world.PARK99.STAIR_X)<1.9 and old.y>world.PARK99.STAIR_TOP-.5 and old.y<world.PARK99.STAIR_FOOT+.5
 if entry or HILL137.stair137(p).x<1.9:
  # Same arrangement as the station: stair silhouette above one continuous
  # terrain ramp, with no individual riser colliders or automatic step pushes.
  for child in mesh.get_children():
   if child is StaticBody3D: child.collision_layer=0;slab_bodies102.erase(child)
  for i in range(treads102.size()-1,-1,-1):
   if treads102[i].mesh==mesh: treads102.remove_at(i)
  ramp_treads137+=1
 return mesh
func _boulder99(at: Vector3,size: Vector3,seed_value: float) -> void:
 var p: Vector2=Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
 if HILL137.edge137(p)<-2. and HILL137.stair137(p).x>2.: return
 super._boulder99(at,size,seed_value)
