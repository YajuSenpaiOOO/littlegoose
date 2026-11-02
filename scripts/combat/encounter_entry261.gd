extends RefCounted
## Authored origins/gates; navigation and physical clearance must agree.
const LANES=[
 {"name":"西侧林边","origin":Vector2(-10.,0.),"gate":Vector2(-5.,1.5)},
 {"name":"东侧树后","origin":Vector2(10.,0.),"gate":Vector2(5.,1.5)},
 {"name":"北侧坡脚","origin":Vector2(5.,-9.),"gate":Vector2(2.,-4.)},
 {"name":"西北林隙","origin":Vector2(-5.,-9.),"gate":Vector2(-2.,-4.)}]
static func plan(w: Node,nav: RefCounted,serial: int,occupied: Array[Vector2],lanes: Array=LANES) -> Dictionary:
 var center: Vector2=w.meadow.landmarks.grove
 var shape=CapsuleShape3D.new();shape.radius=.30;shape.height=.8
 var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1|2
 for offset in lanes.size():
  var lane=lanes[(serial+offset)%lanes.size()]
  var from: Vector2=nav.origin+Vector2(nav.nearest(center+lane.origin))*nav.CELL
  var gate: Vector2=nav.origin+Vector2(nav.nearest(center+lane.gate))*nav.CELL
  if from.distance_to(center)<7. or from.distance_to(Vector2(w.hero.position.x,w.hero.position.z))<4.:continue
  if occupied.any(func(p):return p.distance_to(from)<1.2):continue
  var route: PackedVector2Array=nav.path(from,gate)
  if route.size()<3 or route[-1].distance_to(gate)>.8:continue
  var length=0.;var clear=true
  for i in route.size():
   var at=route[i];var h: float=w.floor_height(at)
   query.transform.origin=Vector3(at.x,h+.45,at.y)
   if not w.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():clear=false;break
   if i>0:
    length+=at.distance_to(route[i-1])
    if absf(h-w.floor_height(route[i-1]))>.32:clear=false;break
  if clear and length>=2.5:return {"name":lane.name,"route":route,"length":length}
 return {}
