extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 DirAccess.make_dir_recursive_absolute("res://assets/room403")
 var builders:={"skirt":preload("res://scripts/room/linen_mesh365.gd").new().mesh365(),"quilt-0":preload("res://scripts/room/quilt_mesh366.gd").mesh366(0),"quilt-1":preload("res://scripts/room/quilt_mesh366.gd").mesh366(1)}
 var manifest: Dictionary={}
 for path in preload("res://scripts/room/mesh_cache403.gd").SOURCES403:manifest[path]=FileAccess.get_sha256(path)
 for id in builders:
  var mesh: ArrayMesh=builders[id];var path: String="res://assets/room403/"+id+".res"
  if ResourceSaver.save(mesh,path,ResourceSaver.FLAG_COMPRESS)!=OK:quit(2);return
  var restored: ArrayMesh=ResourceLoader.load(path,"ArrayMesh",ResourceLoader.CACHE_MODE_IGNORE)
  for i in mesh.get_surface_count():
   if var_to_bytes(mesh.surface_get_arrays(i))!=var_to_bytes(restored.surface_get_arrays(i)):push_error("Bake changed mesh arrays: "+id);quit(3);return
  print("BAKE403_IDENTICAL ",id," vertices=",mesh.surface_get_array_len(0))
 FileAccess.open("res://assets/room403/meshes.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t"))
 quit()
