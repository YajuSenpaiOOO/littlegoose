extends "res://scripts/combat/goose_follow376.gd"
func setup373() -> void:
 var start:=Time.get_ticks_msec()
 await super.setup373();ready373=false
 while not host.yard_built403:await get_tree().physics_frame
 grid373.region=Rect2i(0,0,47,65);grid373.cell_size=Vector2(.35,.35);grid373.offset=Vector2(-8.,-4.);grid373.update()
 var capsule:=CapsuleShape3D.new();capsule.radius=.24;capsule.height=.68
 var query:=PhysicsShapeQueryParameters3D.new();query.shape=capsule;query.collision_mask=1;query.exclude=[get_rid(),host.hero.get_rid()]
 for y in 65:
  for x in 47:
   var at:=grid373.get_point_position(Vector2i(x,y));query.transform=Transform3D(Basis.IDENTITY,Vector3(at.x,.42,at.y))
   grid373.set_point_solid(Vector2i(x,y),not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty())
  if y%8==7:await get_tree().physics_frame
 ready373=true
 print("HOME403_NAV_MS ",Time.get_ticks_msec()-start)
func nearest373(at: Vector3) -> Vector2i:
 var center:=Vector2i((Vector2(at.x,at.z)-grid373.offset)/grid373.cell_size)
 center=center.clamp(Vector2i.ZERO,grid373.region.end-Vector2i.ONE)
 var best:=center;var distance:=INF
 for radius in range(0,14):
  for y in range(maxi(0,center.y-radius),mini(grid373.region.end.y,center.y+radius+1)):
   for x in range(maxi(0,center.x-radius),mini(grid373.region.end.x,center.x+radius+1)):
    var id:=Vector2i(x,y)
    if grid373.is_point_solid(id):continue
    var d:=grid373.get_point_position(id).distance_squared_to(Vector2(at.x,at.z))
    if d<distance:distance=d;best=id
  if distance<INF:return best
 return best
