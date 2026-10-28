extends "res://scripts/art/whole_tree_fade76.gd"
var near_hits200 := 0
var cached_sprites200: Array[Sprite3D]=[]
var cached_count200 := -1
func frame200(sprite: Sprite3D) -> Transform3D:
 var basis := sprite.global_basis
 var scale := basis.get_scale()
 if sprite.billboard==BaseMaterial3D.BILLBOARD_ENABLED:
  basis=world.camera.global_basis.orthonormalized()*Basis.from_scale(scale)
 elif sprite.billboard==BaseMaterial3D.BILLBOARD_FIXED_Y:
  var z := Vector3(world.camera.global_basis.z.x,0,world.camera.global_basis.z.z).normalized()
  basis=Basis(Vector3.UP.cross(z),Vector3.UP,z)*Basis.from_scale(scale)
 return Transform3D(basis,sprite.global_position)
func bounds_from_frame200(sprite: Sprite3D,frame: Transform3D,camera_origin: Vector3,forward: Vector3) -> Rect2:
 var size := Vector2(sprite.texture.get_size())
 var quad: Array[Vector3]=[]
 for uv in [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN]:
  var pixel: Vector2=(uv-Vector2(.5,.5))*size+sprite.offset
  quad.append(frame*(Vector3(pixel.x,pixel.y,0)*sprite.pixel_size))
 var clipped: Array[Vector3]=[];var near: float=maxf(world.camera.near,.04)+.001
 for i in 4:
  var a: Vector3=quad[i];var b: Vector3=quad[(i+1)%4]
  var da: float=-(a-camera_origin).dot(forward);var db: float=-(b-camera_origin).dot(forward)
  if da>=near: clipped.append(a)
  if (da>=near)!=(db>=near): clipped.append(a.lerp(b,(near-da)/(db-da)))
 if clipped.size()<3: return Rect2()
 var lo := Vector2.INF;var hi := -Vector2.INF
 for p in clipped:
  var screen: Vector2=world.camera.unproject_position(p);lo=lo.min(screen);hi=hi.max(screen)
 return Rect2(lo,hi-lo)
func screen_bounds(sprite: Sprite3D) -> Rect2:
 var camera: Camera3D=world.camera
 return bounds_from_frame200(sprite,frame200(sprite),camera.global_position,camera.global_basis.z)
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
func hit_shared200(sprite: Sprite3D,frame: Transform3D,inv: Transform3D,normal: Vector3,camera_origin: Vector3,forward: Vector3,ray: Vector3,depth_limit: float) -> bool:
 var hit: Variant=Plane(normal,frame.origin).intersects_ray(camera_origin,ray)
 if hit==null: return false
 var depth: float=-(hit-camera_origin).dot(forward)
 if depth<world.camera.near or depth>depth_limit: return false
 var local: Vector3=(inv*hit)/sprite.pixel_size
 var size := Vector2(sprite.texture.get_size())
 var uv := Vector2(.5+(local.x-sprite.offset.x)/size.x,.5-(local.y-sprite.offset.y)/size.y)
 if uv.x<0. or uv.y<0. or uv.x>=1. or uv.y>=1.: return false
 return _mask(sprite.texture).get_bitv(Vector2i(uv*size))
func sprite_list200() -> Array[Sprite3D]:
 var extra: int=world.forest188.trees.size() if is_instance_valid(world.forest188) else 0
 var total: int=world.trees.size()+extra
 if cached_count200!=total or cached_sprites200.is_empty():
  var sprites: Array[Sprite3D]=[]
  for tree in world.trees: sprites.append(tree.visual)
  if is_instance_valid(world.forest188):
   var known := {}
   for sprite in sprites: known[sprite.get_instance_id()]=true
   for sprite in world.forest188.trees:
    if not known.has(sprite.get_instance_id()): sprites.append(sprite)
  cached_sprites200=sprites;cached_count200=total
 return cached_sprites200
func _scan() -> void:
 candidate_count=0;near_candidates76=0;near_hits200=0
 var sprites: Array[Sprite3D]=sprite_list200()
 var viewport: Rect2=world.get_viewport().get_visible_rect()
 var reviewing: bool=world.review72 or (is_instance_valid(world.landmark62) and world.landmark62.review_view)
 var camera: Camera3D=world.camera
 var camera_origin: Vector3=camera.global_position
 var forward: Vector3=camera.global_basis.z
 var hero_at: Vector3=world.hero.global_position
 # Sample rays and actor depths do not depend on the sprite: build once per scan.
 var hero_plane := Plane(Vector3(forward.x,0,forward.z).normalized(),hero_at)
 var window_rays: Array=[];var window_limits: Array=[]
 for offset in [Vector2.ZERO,Vector2(-.7,-.8),Vector2(0,-.8),Vector2(.7,-.8),Vector2(-.7,0),Vector2(.7,0),Vector2(0,.8)]:
  var screen: Vector2=center_pixels+offset*radius_pixels
  var ray: Vector3=camera.project_ray_normal(screen)
  var body: Variant=hero_plane.intersects_ray(camera_origin,ray)
  window_rays.append(ray)
  window_limits.append(-(body-camera_origin).dot(forward)-.03 if body!=null else INF)
 var grid_rays: Array=[];var grid_limits: Array=[]
 for y in [.20,.40,.60,.80]:
  for x in [.25,.5,.75]:
   var screen: Vector2=viewport.position+viewport.size*Vector2(x,y)
   var ray: Vector3=camera.project_ray_normal(screen)
   var body: Variant=hero_plane.intersects_ray(camera_origin,ray)
   grid_rays.append(ray)
   grid_limits.append(-(body-camera_origin).dot(forward)-.03 if body!=null else INF)
 for sprite in sprites:
  var key := sprite.get_instance_id()
  if not entries.has(key): entries[key]={"sprite":sprite,"opacity":1.,"held":0.,"target":false,"near76":false,"extra200":is_instance_valid(world.forest188) and sprite in world.forest188.trees}
  var entry: Dictionary=entries[key];entry.target=false;entry.near76=false
  if not world.fade_enabled or reviewing or not sprite.is_visible_in_tree() or sprite.global_position.distance_squared_to(hero_at)>55.*55.: continue
  # A sprite whose closest point is still behind the near plane cannot reach
  # the viewport; the full bounds math below used to pay for it anyway.
  var scale := sprite.global_basis.get_scale()
  var radius: float=.5*sprite.texture.get_size().length()*sprite.pixel_size*maxf(maxf(absf(scale.x),absf(scale.y)),absf(scale.z))
  var view_dist: float=-(sprite.global_position-camera_origin).dot(forward)
  if view_dist+radius<maxf(camera.near,.04): continue
  var frame := frame200(sprite)
  var bounds := bounds_from_frame200(sprite,frame,camera_origin,forward)
  if not bounds.intersects(viewport): continue
  var inv := frame.affine_inverse()
  var normal: Vector3=frame.basis.z.normalized()
  var blocked := false
  if overlaps_window(bounds,18. if entry.held>0. else 6.):
   for i in window_rays.size():
    if hit_shared200(sprite,frame,inv,normal,camera_origin,forward,window_rays[i],float(window_limits[i])): blocked=true;break
  # Screen-covering leaves are an independent test. Never gate this behind
  # a trunk-point distance or the old in_front(body) test.
  var near := false
  if bounds.intersection(viewport).get_area()>viewport.get_area()*.16:
   var hits := 0
   for i in grid_rays.size():
    if hit_shared200(sprite,frame,inv,normal,camera_origin,forward,grid_rays[i],float(grid_limits[i])): hits+=1
   near=hits>=3;near_hits200+=hits
  entry.target=blocked or near;entry.near76=near
  if entry.target: entry.held=.65;candidate_count+=1
  if near: near_candidates76+=1
func update(delta: float) -> void:
 # Restore the original whole-tree fast fade and slower recovery; no group
 # clearing, no opacity changes based merely on proximity, no physics edits.
 super.update(delta)
