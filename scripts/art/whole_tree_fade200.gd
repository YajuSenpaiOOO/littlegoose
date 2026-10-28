extends "res://scripts/art/whole_tree_fade76.gd"
var near_hits200 := 0
func frame200(sprite: Sprite3D) -> Transform3D:
 var basis := sprite.global_basis
 var scale := basis.get_scale()
 if sprite.billboard==BaseMaterial3D.BILLBOARD_ENABLED:
  basis=world.camera.global_basis.orthonormalized()*Basis.from_scale(scale)
 elif sprite.billboard==BaseMaterial3D.BILLBOARD_FIXED_Y:
  var z := Vector3(world.camera.global_basis.z.x,0,world.camera.global_basis.z.z).normalized()
  basis=Basis(Vector3.UP.cross(z),Vector3.UP,z)*Basis.from_scale(scale)
 return Transform3D(basis,sprite.global_position)
func screen_bounds(sprite: Sprite3D) -> Rect2:
 var size := Vector2(sprite.texture.get_size());var frame := frame200(sprite)
 var quad: Array[Vector3]=[]
 for uv in [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN]:
  var pixel: Vector2=(uv-Vector2(.5,.5))*size+sprite.offset
  quad.append(frame*(Vector3(pixel.x,pixel.y,0)*sprite.pixel_size))
 var clipped: Array[Vector3]=[];var near: float=maxf(world.camera.near,.04)+.001
 for i in 4:
  var a: Vector3=quad[i];var b: Vector3=quad[(i+1)%4]
  var da: float=-world.camera.to_local(a).z;var db: float=-world.camera.to_local(b).z
  if da>=near: clipped.append(a)
  if (da>=near)!=(db>=near): clipped.append(a.lerp(b,(near-da)/(db-da)))
 if clipped.size()<3: return Rect2()
 var lo := Vector2.INF;var hi := -Vector2.INF
 for p in clipped:
  var screen: Vector2=world.camera.unproject_position(p);lo=lo.min(screen);hi=hi.max(screen)
 return Rect2(lo,hi-lo)
func hit200(sprite: Sprite3D,screen: Vector2,max_depth: float) -> bool:
 var frame := frame200(sprite)
 var origin: Vector3=world.camera.project_ray_origin(screen);var ray: Vector3=world.camera.project_ray_normal(screen)
 var hit: Variant=Plane(frame.basis.z.normalized(),frame.origin).intersects_ray(origin,ray)
 if hit==null: return false
 var depth: float=-world.camera.to_local(hit).z
 if depth<world.camera.near or depth>max_depth: return false
 var local: Vector3=(frame.affine_inverse()*hit)/sprite.pixel_size
 var size := Vector2(sprite.texture.get_size())
 var uv := Vector2(.5+(local.x-sprite.offset.x)/size.x,.5-(local.y-sprite.offset.y)/size.y)
 if uv.x<0. or uv.y<0. or uv.x>=1. or uv.y>=1.: return false
 return _mask(sprite.texture).get_bitv(Vector2i(uv*size))
func actor_depth200(screen: Vector2) -> float:
 var origin: Vector3=world.camera.project_ray_origin(screen);var ray: Vector3=world.camera.project_ray_normal(screen)
 var z := Vector3(world.camera.global_basis.z.x,0,world.camera.global_basis.z.z).normalized()
 var hit: Variant=Plane(z,world.hero.global_position).intersects_ray(origin,ray)
 return -world.camera.to_local(hit).z-.03 if hit!=null else INF
func _scan() -> void:
 candidate_count=0;near_candidates76=0;near_hits200=0
 var sprites: Array[Sprite3D]=[]
 for tree in world.trees: sprites.append(tree.visual)
 if is_instance_valid(world.forest188):
  for sprite in world.forest188.trees:
   if not sprite in sprites: sprites.append(sprite)
 var viewport: Rect2=world.get_viewport().get_visible_rect()
 var reviewing: bool=world.review72 or (is_instance_valid(world.landmark62) and world.landmark62.review_view)
 for sprite in sprites:
  var key := sprite.get_instance_id()
  if not entries.has(key): entries[key]={"sprite":sprite,"opacity":1.,"held":0.,"target":false,"near76":false,"extra200":is_instance_valid(world.forest188) and sprite in world.forest188.trees}
  var entry: Dictionary=entries[key];entry.target=false;entry.near76=false
  if not world.fade_enabled or reviewing or not sprite.is_visible_in_tree() or sprite.global_position.distance_squared_to(world.hero.global_position)>55.*55.: continue
  var bounds := screen_bounds(sprite)
  if not bounds.intersects(viewport): continue
  var blocked := false
  if overlaps_window(bounds,18. if entry.held>0. else 6.):
   for offset in [Vector2.ZERO,Vector2(-.7,-.8),Vector2(0,-.8),Vector2(.7,-.8),Vector2(-.7,0),Vector2(.7,0),Vector2(0,.8)]:
    var screen: Vector2=center_pixels+offset*radius_pixels
    if hit200(sprite,screen,actor_depth200(screen)): blocked=true;break
  # Screen-covering leaves are an independent test. Never gate this behind
  # a trunk-point distance or the old in_front(body) test.
  var near := false
  if bounds.intersection(viewport).get_area()>viewport.get_area()*.16:
   var hits := 0
   for y in [.20,.40,.60,.80]:
    for x in [.25,.5,.75]:
     var screen: Vector2=viewport.position+viewport.size*Vector2(x,y)
     if hit200(sprite,screen,actor_depth200(screen)): hits+=1
   near=hits>=3;near_hits200+=hits
  entry.target=blocked or near;entry.near76=near
  if entry.target: entry.held=.65;candidate_count+=1
  if near: near_candidates76+=1
func update(delta: float) -> void:
 # Restore the original whole-tree fast fade and slower recovery; no group
 # clearing, no opacity changes based merely on proximity, no physics edits.
 super.update(delta)
