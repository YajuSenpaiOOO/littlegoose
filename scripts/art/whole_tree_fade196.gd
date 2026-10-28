extends "res://scripts/art/whole_tree_fade195.gd"
var precleared196 := 0
var max_precleared196 := 0
func _scan() -> void:
 super._scan()
 precleared196=0
 if not world.fade_enabled or world.review72 or (is_instance_valid(world.landmark62) and world.landmark62.review_view): return
 var camera: Camera3D=world.camera
 var viewport: Rect2=world.get_viewport().get_visible_rect()
 var corridor := Rect2(viewport.position+viewport.size*Vector2(.14,.08),viewport.size*Vector2(.72,.90))
 var motion := Vector3(world.hero.velocity.x,0,world.hero.velocity.z)
 var camera_forward := Vector3(camera.global_basis.z.x,0,camera.global_basis.z.z).normalized()
 for tree in world.trees:
  var sprite: Sprite3D=tree.visual
  if not sprite.is_visible_in_tree(): continue
  var size := Vector2(sprite.texture.get_size())*sprite.pixel_size
  var height := maxf(size.y,1.)
  var to_tree: Vector3=sprite.global_position-world.hero.global_position
  # A crown can reach the camera while its trunk/plane is not in_front(body).
  # Preclear from world-space camera proximity, before screen alpha samples.
  if Vector2(to_tree.x,to_tree.z).length()>32. or to_tree.dot(camera_forward)<-.5: continue
  var future_camera: Vector3=camera.global_position+motion*.9
  var flat_distance := Vector2(sprite.global_position.x-future_camera.x,sprite.global_position.z-future_camera.z).length()
  if flat_distance>maxf(7.,height*1.35): continue
  var depth: float=-camera.to_local(sprite.global_position).z
  if depth>height*1.25+motion.length()*.9 or depth< -height*.8: continue
  var bounds := screen_bounds(sprite)
  # Empty clipped bounds at the near plane are dangerous, not safe.
  var threatening := not bounds.has_area() or bounds.intersects(corridor)
  if not threatening: continue
  var key := sprite.get_instance_id()
  if not entries.has(key): continue
  var entry: Dictionary=entries[key]
  entry.target=true;entry.edge195=false;entry.held=4.;entry.near76=true
  precleared196+=1
 max_precleared196=maxi(max_precleared196,precleared196)
func update(delta: float) -> void:
 # The shared 195 update handles smooth opacity and root synchronization.
 # Its virtual _scan now also anticipates camera-plane crossings.
 var jumped: bool=not previous_hero.is_finite() or world.hero.global_position.distance_to(previous_hero)>3.
 super.update(delta)
 if jumped:
  for key in entries:
   var entry: Dictionary=entries[key]
   if not entry.target: continue
   entry.opacity=.06;entry.sprite.material_override.set_shader_parameter("fade",sqrt(smoothstep(0.,1.,.06)))
   if not changed67.has(key): changed67.append(key)
  shader_dirty67=true
