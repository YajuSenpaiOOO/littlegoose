extends RefCounted
# Conservative cell masks only: all possible impacts still use native physics.
var world: Node3D
var target_cells := {}
var environment := {}
var terrain_ceiling := {}
var bounds := Rect2()
var current_cells := {}
var rid_bits := {}
var stamp := 0
var dynamic_bodies: Array[Node3D]=[]
var box := BoxShape3D.new()
var query := PhysicsShapeQueryParameters3D.new()
var births := 0
var skipped := 0
var native := 0
var terrain_flag := true
var overflow := false
const ENV_SIZE := Vector3(2.,.25,2.)
const ENV_BIT := 1<<30
func setup(sample: Node3D) -> void:
 world=sample;box.size=ENV_SIZE+Vector3.ONE*.04;query.shape=box;query.collision_mask=1|2|8;query.collide_with_areas=true
 terrain_flag=world.terrain_enabled;collect_dynamic(world);bake_terrain()
func collect_dynamic(node: Node) -> void:
 if (node is AnimatableBody3D or node is RigidBody3D) and (node.collision_layer & 3)!=0: dynamic_bodies.append(node)
 for child in node.get_children(): collect_dynamic(child)
func invalidate() -> void: environment.clear();current_cells.clear()
func cell(at: Vector3,size: Vector3) -> Vector3i: return Vector3i(floori(at.x/size.x),floori(at.y/size.y),floori(at.z/size.z))
func rebuild() -> void:
 target_cells.clear();rid_bits.clear();current_cells.clear();births=0;overflow=false
 if environment.size()>4096: environment.clear()
 if terrain_flag!=world.terrain_enabled: terrain_flag=world.terrain_enabled;invalidate()
 var index := 0
 for enemy in world.enemies:
  if not is_instance_valid(enemy) or not enemy.is_inside_tree() or enemy.hit_area.collision_layer==0: continue
  if index>=30: overflow=true;break
  var bit := 1<<index;index+=1;rid_bits[enemy.hit_area.get_rid()]=bit
  var shape_node: CollisionShape3D=enemy.hit_area.get_child(0);var capsule: CapsuleShape3D=shape_node.shape
  var at := shape_node.global_position;var extent := Vector3(capsule.radius,capsule.height*.5,capsule.radius)+Vector3.ONE*.10
  var lo := cell(at-extent,Vector3.ONE*2.);var hi := cell(at+extent,Vector3.ONE*2.)
  for z in range(lo.z,hi.z+1):
   for y in range(lo.y,hi.y+1):
    for x in range(lo.x,hi.x+1):
     var key := Vector3i(x,y,z);target_cells[key]=int(target_cells.get(key,0))|bit
 stamp=hash(rid_bits)
 var excluded: Array[RID]=[]
 for rid: RID in rid_bits: excluded.append(rid)
 query.exclude=excluded
func mask_for(key: Vector3i) -> int:
 if current_cells.has(key): return current_cells[key]
 var center := (Vector3(key)+Vector3.ONE*.5)*ENV_SIZE
 var mask: int=target_cells.get(cell(center,Vector3.ONE*2.),0)
 var column := Vector2i(key.x,key.z)
 if not terrain_ceiling.has(column) or center.y-ENV_SIZE.y*.5<=float(terrain_ceiling[column])+.04:
  mask|=ENV_BIT;current_cells[key]=mask;return mask
 # The entire cell lies inside this conservative moving-scenery guard band.
 for body in dynamic_bodies:
  if is_instance_valid(body) and center.distance_squared_to(body.global_position)<64.:
   mask|=ENV_BIT;current_cells[key]=mask;return mask
 if not environment.has(key):
  if births>=8: current_cells[key]=mask|ENV_BIT;return mask|ENV_BIT
  births+=1;query.transform=Transform3D(Basis.IDENTITY,center)
  environment[key]=not world.space110.intersect_shape(query,1).is_empty()
 if environment[key]: mask|=ENV_BIT
 current_cells[key]=mask;return mask
func might_hit(start: Vector3,end: Vector3,shot: Dictionary={}) -> bool:
 if overflow or not bounds.has_point(Vector2(start.x,start.z)) or not bounds.has_point(Vector2(end.x,end.z)): native+=1;return true
 var ignored := 0
 if not shot.is_empty():
  var hits: Array=shot.hit_rids;var omit: Array=shot.ignore_rids110
  var piercing: bool=shot.get("piercing110",false) or shot.get("charged",false)
  var count := omit.size()+(hits.size() if piercing else 0)
  if int(shot.get("grid_stamp111",0))!=stamp or int(shot.get("grid_count111",-1))!=count:
   for rid in omit: ignored|=int(rid_bits.get(rid,0))
   if piercing:
    for rid in hits: ignored|=int(rid_bits.get(rid,0))
   shot.grid_mask111=ignored;shot.grid_stamp111=stamp;shot.grid_count111=count
  else: ignored=shot.grid_mask111
 if float(shot.get("spawn_grace111",0.))>0.: ignored=ENV_BIT-1
 var lo := cell(start.min(end),ENV_SIZE);var hi := cell(start.max(end),ENV_SIZE)
 if lo==hi:
  if (mask_for(lo)&~ignored)!=0: native+=1;return true
  skipped+=1;return false
 for z in range(lo.z,hi.z+1):
  for y in range(lo.y,hi.y+1):
   for x in range(lo.x,hi.x+1):
    if (mask_for(Vector3i(x,y,z))&~ignored)!=0: native+=1;return true
 skipped+=1;return false
func bake_terrain() -> void:
 terrain_ceiling.clear()
 var g: Vector2=world.meadow.landmarks.grove;bounds=Rect2(g-Vector2.ONE*28.,Vector2.ONE*56.)
 # Native concave terrain can fail a convex-volume overlap from its back side.
 # Rasterize conservative quad ceilings from the SAME collider vertices instead.
 for tile in world.floor_tiles.values():
  if not tile.rect.intersects(bounds.grow(2.)): continue
  var vertices: PackedVector3Array=tile.vertices;var width: int=tile.width
  for y in width-1:
   for x in width-1:
    var i := y*width+x
    var a: Vector3=world.ground.global_transform*vertices[i];var b: Vector3=world.ground.global_transform*vertices[i+1]
    var c: Vector3=world.ground.global_transform*vertices[i+width];var d: Vector3=world.ground.global_transform*vertices[i+width+1]
    var lo := a.min(b).min(c).min(d);var hi := a.max(b).max(c).max(d)
    var first := Vector2i(floori(lo.x/2.),floori(lo.z/2.));var last := Vector2i(floori(hi.x/2.),floori(hi.z/2.))
    for z in range(first.y,last.y+1):
     for xx in range(first.x,last.x+1):
      var key := Vector2i(xx,z);terrain_ceiling[key]=maxf(hi.y,float(terrain_ceiling.get(key,-INF)))
 invalidate()
