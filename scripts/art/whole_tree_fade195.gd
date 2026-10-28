extends "res://scripts/art/whole_tree_fade76.gd"
## One policy for every registered map tree. Keep edge framing, clear the
## walking corridor in advance, then hold adjacent crowns as a group.
var forecast195 := Vector2.ZERO
var grouped195 := 0
func _scan() -> void:
 candidate_count=0;near_candidates76=0;grouped195=0
 var body: Vector3=world.hero.global_position+Vector3.UP*.8
 var reviewing: bool=world.review72 or (is_instance_valid(world.landmark62) and world.landmark62.review_view)
 var viewport: Rect2=world.get_viewport().get_visible_rect()
 var candidates: Array[Dictionary]=[]
 var seeds: Array[Dictionary]=[]
 for tree in world.trees:
  var sprite: Sprite3D=tree.visual;var key := sprite.get_instance_id()
  if not entries.has(key): entries[key]={"sprite":sprite,"opacity":1.,"held":0.,"target":false,"near76":false,"edge195":false}
  var entry: Dictionary=entries[key]
  entry.target=false;entry.near76=false;entry.edge195=false
  if not world.fade_enabled or reviewing or not sprite.is_visible_in_tree() or sprite.global_position.distance_squared_to(body)>55.*55. or not in_front(sprite,body): continue
  var bounds := screen_bounds(sprite)
  if not bounds.intersects(viewport): continue
  var blocked := false
  var margin: float=45. if entry.held>0. else 22.
  if overlaps_window(bounds,margin) or bounds.grow(margin).has_point(forecast195):
   for centre in [center_pixels,forecast195]:
    for offset in [Vector2.ZERO,Vector2(-.8,0),Vector2(.8,0),Vector2(0,-.8),Vector2(0,.8)]:
     if painted_at(sprite,centre+offset*radius_pixels): blocked=true;break
    if blocked: break
  var near := near_view_blocks76(sprite,bounds,entry.held>0.)
  # Peripheral foreground stays as a translucent frame instead of vanishing.
  var record := {"entry":entry,"bounds":bounds,"at":sprite.global_position}
  candidates.append(record)
  entry.near76=near;entry.edge195=near and not blocked
  if blocked:
   entry.target=true;entry.held=2.4;seeds.append(record);candidate_count+=1
  if near: near_candidates76+=1
 for record in candidates:
  if record.entry.target: continue
  for seed in seeds:
   if record.at.distance_squared_to(seed.at)<36. and record.bounds.intersects(seed.bounds) and record.bounds.grow(35.).has_point(forecast195):
    record.entry.target=true;record.entry.edge195=false;record.entry.held=2.4;grouped195+=1;break
func update(delta: float) -> void:
 changed67.clear()
 var at: Vector3=world.hero.global_position
 var jumped: bool=not previous_hero.is_finite() or at.distance_to(previous_hero)>3.
 previous_hero=at
 var head: Vector2=world.camera.unproject_position(at+Vector3.UP*1.45)
 var foot: Vector2=world.camera.unproject_position(at+Vector3.UP*.12)
 center_pixels=(head+foot)*.5
 var motion := Vector3(world.hero.velocity.x,0,world.hero.velocity.z)
 var lead := Vector2.ZERO
 if motion.length()>.15: lead=world.camera.unproject_position(at+motion.normalized()*1.8)-world.camera.unproject_position(at)
 lead_pixels=lead if jumped else lead_pixels.lerp(lead,1.-exp(-delta*3.))
 forecast195=center_pixels+lead_pixels
 var scale_ui: float=world.get_viewport().get_visible_rect().size.y/1000.
 var body_height := head.distance_to(foot)
 radius_pixels=Vector2(maxf(38.*scale_ui,body_height*.65),maxf(46.*scale_ui,body_height*.85))
 if jumped:
  for entry in entries.values():
   entry.opacity=1.;entry.held=0.;entry.target=false;entry.edge195=false
   entry.sprite.material_override.set_shader_parameter("fade",1.);changed67.append(entry.sprite.get_instance_id())
  shader_dirty67=true;scan_left=0.
 scan_left-=delta
 if scan_left<=0.: _scan();scan_left=.10
 active_count=0
 for key in entries:
  var entry: Dictionary=entries[key]
  entry.held=maxf(0.,entry.held-delta)
  var hidden: bool=world.fade_enabled and (entry.target or entry.held>0.)
  var target: float=.06 if hidden else (.58 if world.fade_enabled and entry.get("edge195",false) else 1.)
  var previous: float=entry.opacity
  entry.opacity=move_toward(previous,target,delta*(1.8 if target<previous else .45))
  if entry.opacity<1.: active_count+=1
  if previous==entry.opacity: continue
  var fade := sqrt(smoothstep(0.,1.,entry.opacity))
  if (previous<.999)!=(entry.opacity<.999): shader_dirty67=true
  entry.sprite.material_override.set_shader_parameter("fade",fade);changed67.append(key)
