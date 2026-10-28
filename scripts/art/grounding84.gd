extends "res://scripts/art/grounding17.gd"
var hits84 := 0
var misses84 := 0
var textures84: Dictionary={}
func root_skirt(texture: Texture2D,profile: Dictionary,height: float,at: Vector3,landscape: RefCounted,terrain_on: bool,ratio: float=.052) -> Dictionary:
	ratio=float(profile.get("root_ratio",ratio))
	var cache := preload("res://scripts/art/startup_cache84.gd")
	if not cache.enabled84(): return super.root_skirt(texture,profile,height,at,landscape,terrain_on,ratio)
	var source: String=texture.resource_path
	if not textures84.has(source): textures84[source]=FileAccess.get_sha256(source)
	var key := cache.signature84("roots")+str([landscape.get_script().resource_path,textures84[source],profile,height,at,terrain_on,ratio,landscape.profile.enabled,landscape.profile.depth])
	var path := cache.path84("roots",key)
	if FileAccess.file_exists(path):
		var saved: Resource=load(path)
		if saved!=null and saved.mesh!=null:
			hits84+=1;return {"mesh":saved.mesh,"drop":saved.drop,"cut":saved.cut,"collider_x":saved.collider_x}
	misses84+=1
	var result := super.root_skirt(texture,profile,height,at,landscape,terrain_on,ratio)
	var saved := preload("res://scripts/art/root_bake84.gd").new()
	saved.mesh=result.mesh;saved.drop=result.drop;saved.cut=result.cut;saved.collider_x=result.collider_x
	var error := ResourceSaver.save(saved,path)
	if error!=OK: push_warning("Root bake could not be saved: "+str(error))
	return result
