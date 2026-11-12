extends SceneTree
class Harness:
 extends "res://scripts/world/woodland_world265.gd"
 func test_config_path226() -> String:return "user://rest266-probe.cfg"
 func _init() -> void:
  super._init();memory_save116="user://rest266-probe-preview.cfg"
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=Harness.new();root.add_child(w)
 while not w.ready264:await process_frame
 var rows=[];var centre=w.meadow.landmarks.grove
 var shape=BoxShape3D.new();shape.size=Vector3(4.1,1.2,2.6)
 var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=2
 for z in [-9.,-10.5,-12.,-13.5]:
  for x in [-3.,0.,3.,5.]:
   var wanted=centre+Vector2(x,z)
   var at=w.entry_navigation261.origin+Vector2(w.entry_navigation261.nearest(wanted))*w.entry_navigation261.CELL
   var h=w.floor_height(at);query.transform.origin=Vector3(at.x,h+.7,at.y)
   var hits=w.get_world_3d().direct_space_state.intersect_shape(query,4)
   var path=w.entry_navigation261.path(centre,at)
   rows.append({"offset":[x,z],"nearest_offset":[at.x-centre.x,at.y-centre.y],"height":h,"delta":h-w.floor_height(centre),"colliders":hits.map(func(hit):return str(hit.collider.name)),"path_end_distance":path[-1].distance_to(at) if not path.is_empty() else -1})
 var f=FileAccess.open("res://docs/rest266-site-probe.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close();print("SITES266 ",rows);quit()
