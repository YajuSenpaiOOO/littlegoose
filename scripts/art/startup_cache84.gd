extends RefCounted
static var signatures84: Dictionary={}
static func signature84(kind: String) -> String:
	if signatures84.has(kind): return signatures84[kind]
	var hash := HashingContext.new();hash.start(HashingContext.HASH_SHA256)
	var paths: Array[String]=[]
	for name in DirAccess.get_files_at("res://scripts/world"):
		if name.begins_with("world_surface") and name.ends_with(".gd"): paths.append("res://scripts/world/"+name)
		if name.begins_with("park_layout") and name.ends_with(".gd"): paths.append("res://scripts/world/"+name)
		if kind=="grass" and name.begins_with("world") and name.ends_with(".gd"): paths.append("res://scripts/world/"+name)
	paths.append_array(["res://scripts/art/path_surface18.gd","res://scripts/art/home_route15.gd","res://scripts/world/path_profile18.gd","res://scripts/art/grounding15.gd","res://scripts/art/grounding17.gd","res://assets/landscape78/shore_distance78.png"])
	paths.append_array(["res://scripts/art/forest_landscape13.gd","res://scripts/art/meadow_lab12.gd","res://docs/world-restart-layout.json"])
	paths.sort()
	for path in paths:
		hash.update(path.to_utf8_buffer());hash.update(FileAccess.get_file_as_bytes(path))
	var result := hash.finish().hex_encode();signatures84[kind]=result;return result
static func path84(kind: String,key: String) -> String:
	var path := "res://assets/bake84/"+kind
	DirAccess.make_dir_recursive_absolute(path)
	return path+"/"+key.sha256_text()+".res"
static func enabled84() -> bool: return not "--no-startup-cache84" in OS.get_cmdline_user_args()
