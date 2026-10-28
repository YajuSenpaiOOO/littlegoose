extends "res://scripts/world/combat113_compare.gd"
func make_heightmaps(s: Node3D,rotated: bool) -> StaticBody3D:
 var body := StaticBody3D.new();body.collision_layer=512;body.collision_mask=0
 for tile in s.floor_tiles.values():
  var w: int=tile.width;var vertices: PackedVector3Array=tile.vertices;var values := PackedFloat32Array();values.resize(w*w)
  for y in w:
   for x in w: values[y*w+x]=vertices[(w-1-x)*w+y].y if rotated else vertices[y*w+x].y
  var shape := HeightMapShape3D.new();shape.map_width=w;shape.map_depth=w;shape.map_data=values
  var node := CollisionShape3D.new();node.shape=shape;var rect: Rect2=tile.rect;node.position=Vector3(rect.get_center().x,0,rect.get_center().y)
  node.scale=Vector3(rect.size.y/(w-1),1.,rect.size.x/(w-1)) if rotated else Vector3(rect.size.x/(w-1),1.,rect.size.y/(w-1))
  if rotated: node.rotation.y=PI*.5
  body.add_child(node)
 s.add_child(body);return body
func check_heightmap(s: Node3D) -> Dictionary:
 var rng := RandomNumberGenerator.new();rng.seed=113113;var error := 0.;var failures := 0;var compared := 0
 var query := PhysicsRayQueryParameters3D.new();var bounds: Rect2=s.shadow_field113.bounds.grow(-.01)
 for i in 3000:
  var at := bounds.position+Vector2(rng.randf(),rng.randf())*bounds.size;query.from=Vector3(at.x,40.,at.y);query.to=Vector3(at.x,-25.,at.y)
  query.collision_mask=1;var old: Dictionary=s.space110.intersect_ray(query)
  if old.is_empty() or old.collider!=s.floor_collider.get_parent(): continue
  query.collision_mask=512;var candidate: Dictionary=s.space110.intersect_ray(query);compared+=1
  if candidate.is_empty(): failures+=1;continue
  error=maxf(error,Vector3(old.position).distance_to(candidate.position))
 return {"max_error":error,"missing":failures,"compared":compared}
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var s := Battle113.new();await setup(s,"woodland_ready113")
 var data := {};var terrain := make_heightmaps(s,false);await settle72(3);data.normal=check_heightmap(s);print("HEIGHT113 normal ",JSON.stringify(data.normal))
 if float(data.normal.max_error)>.001:
  s.remove_child(terrain);terrain.queue_free();await settle72(2);terrain=make_heightmaps(s,true);await settle72(3);data.rotated=check_heightmap(s);print("HEIGHT113 rotated ",JSON.stringify(data.rotated))
 var selected: Dictionary=data.get("rotated",data.normal)
 if selected.missing==0 and float(selected.max_error)<.001:
  build(s,["forest_fireboy","three_player","eye_exercise","eye_exercise","snack","snack"]);data.before=await compare_measure111(s,"113_mesh_collider")
  terrain.collision_layer=1;s.floor_collider.disabled=true;await settle72(3)
  build(s,["forest_fireboy","three_player","eye_exercise","eye_exercise","snack","snack"]);data.after=await compare_measure111(s,"113_heightmap_collider")
 var file := FileAccess.open("res://docs/combat113-heightmap.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));quit()
