extends "res://scripts/combat/cotton351.gd"
func _ready() -> void:
 super._ready()
 for batch in batches:batch.multimesh.mesh.size*=1.18
func emit219(at: Vector3,direction: Vector2,nose: int) -> void:
 var old:=active.size()
 super.emit219(at,direction,nose)
 for i in range(old,active.size()):
  var e: Dictionary=records[active[i]]
  if e.danger:
   e.vel=Vector3(direction.x,0.,direction.y)*4.2;e.life=2.2;e.radius=.24
   e.clearance354=clampf(at.y-world.floor_height(Vector2(at.x,at.z)),.35,.85)
func advance219(delta: float) -> void:
 if not running or not enabled219:return
 var begin=Time.get_ticks_usec()
 invuln=maxf(0.,invuln-delta)
 for index in range(active.size()-1,-1,-1):
  var slot=active[index];var e: Dictionary=records[slot]
  var before: Vector3=e.pos
  e.age+=delta
  e.vel*=exp(-.40*delta)
  e.pos+=e.vel*delta
  if e.danger:
   var floor_before: float=world.floor_height(Vector2(before.x,before.z))
   var floor_now: float=world.floor_height(Vector2(e.pos.x,e.pos.z))
   if absf(floor_now-floor_before)>.4:retire219(index);continue
   e.pos.y=floor_now+float(e.get("clearance354",.55))
  if e.age>=e.life:
   retire219(index);continue
  if not e.danger:continue
  var at=Vector2(e.pos.x,e.pos.z)
  var ground: float=world.floor_height(at)
  if e.pos.y<ground+.03 or e.pos.y>ground+1.4:
   walls_count+=1;retire219(index);continue
  var ray=PhysicsRayQueryParameters3D.create(before,e.pos,1,[world.hero.get_rid(),pig.body.get_rid()])
  if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
   walls_count+=1;retire219(index);continue
  var hero_at=Vector2(world.hero.position.x,world.hero.position.z)
  var closest=Geometry2D.get_closest_point_to_segment(hero_at,Vector2(before.x,before.z),at)
  if closest.distance_squared_to(hero_at)<pow(float(e.radius)+.24,2.) and e.pos.y>=world.hero.position.y-.1 and e.pos.y<=world.hero.position.y+1.15:
   contact219();retire219(index)
 update_us=Time.get_ticks_usec()-begin
 if cpu_samples.size()<10000:cpu_samples.append(update_us)
