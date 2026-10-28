extends "res://scripts/world/world_surface79.gd"
var terrain_hit84 := false
func terrain(enabled: bool) -> ArrayMesh:
	var cache := preload("res://scripts/art/startup_cache84.gd")
	if not cache.enabled84(): return super.terrain(enabled)
	var key := cache.signature84("terrain")+str([get_script().resource_path,enabled,profile.enabled,profile.depth])
	var path := cache.path84("terrain",key)
	if FileAccess.file_exists(path):
		var saved: Resource=load(path)
		if saved!=null and saved.mesh!=null and saved.mesh.get_surface_count()==saved.chunks.size():
			chunks.assign(saved.chunks.duplicate(true));terrain_hit84=true
			return saved.mesh.duplicate()
	var mesh := super.terrain(enabled)
	var saved := preload("res://scripts/art/terrain_bake84.gd").new();saved.mesh=mesh;saved.chunks.assign(chunks)
	var error := ResourceSaver.save(saved,path)
	if error!=OK: push_warning("Terrain bake could not be saved: "+str(error))
	return mesh
