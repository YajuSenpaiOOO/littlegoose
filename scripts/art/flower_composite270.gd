extends RefCounted
## Runtime-only composition, requested by the user. Source PNGs remain intact.
static var cache270 := {}
static func build(poses: Dictionary,textures: Dictionary,kind: String) -> Dictionary:
 var cache_key=kind+str(hash(poses))
 if cache270.has(cache_key):return cache270[cache_key]
 var spec=JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_v2/flowers.json"))[kind]
 var flower: Image=load(spec.texture).get_image();flower.convert(Image.FORMAT_RGBA8)
 var result={"poses":poses.duplicate(true),"textures":textures.duplicate()}
 for key in textures:
  if not poses.has(key) or not poses[key].has("foot"):continue
  var pose: Dictionary=poses[key];var body: Image=textures[key].get_image();body.convert(Image.FORMAT_RGBA8)
  var bounds=body.get_used_rect();var px=float(pose.scale)/24.
  var ratio=float(spec.scale)/float(pose.scale);var ornament=flower.duplicate()
  ornament.resize(maxi(1,roundi(flower.get_width()*ratio)),maxi(1,roundi(flower.get_height()*ratio)),Image.INTERPOLATE_NEAREST)
  var flower_bounds=ornament.get_used_rect()
  var head=Vector2(float(pose.foot[0])+.12/px,bounds.position.y+bounds.size.y*.12)
  var flower_origin=Vector2i((head-Vector2(spec.center[0],spec.center[1])*ratio).round())
  var combined=bounds.merge(Rect2i(flower_origin+flower_bounds.position,flower_bounds.size))
  # Keep native body centre as rotation pivot; allocate all quadrants of the combined silhouette.
  var pivot=Vector2(float(pose.foot[0]),float(pose.foot[1])-float(pose.visible_height)/48./px)
  var radius=0.
  for corner in [Vector2(combined.position),Vector2(combined.end),Vector2(combined.position.x,combined.end.y),Vector2(combined.end.x,combined.position.y)]:radius=maxf(radius,corner.distance_to(pivot))
  var half=ceili(radius)+4;var origin=Vector2i(pivot.floor())-Vector2i(half,half)
  var canvas=Image.create(half*2+2,half*2+2,false,Image.FORMAT_RGBA8)
  canvas.blend_rect(body,bounds,bounds.position-origin)
  canvas.blend_rect(ornament,flower_bounds,flower_origin+flower_bounds.position-origin)
  result.textures[key]=ImageTexture.create_from_image(canvas)
  result.poses[key].foot=[float(pose.foot[0])-origin.x,float(pose.foot[1])-origin.y]
 cache270[cache_key]=result
 return result
