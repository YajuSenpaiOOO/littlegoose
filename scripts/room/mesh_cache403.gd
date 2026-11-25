extends RefCounted
# Only the 403 host opts in. Historical previews still execute their original builders.
static var enabled403:=false
static var checked403:=false
static var valid403:=false
static var held403: Dictionary={}
const SOURCES403=["res://scripts/room/bed_mesh364.gd","res://scripts/room/linen_mesh365.gd","res://scripts/room/quilt_mesh366.gd"]
static func get403(id: String) -> ArrayMesh:
 if not enabled403:return null
 if not checked403:
  checked403=true
  var manifest: Variant=JSON.parse_string(FileAccess.get_file_as_string("res://assets/room403/meshes.json"))
  valid403=manifest is Dictionary
  if valid403:
   for path in SOURCES403:
    if manifest.get(path,"")!=FileAccess.get_sha256(path):valid403=false
  if not valid403:push_warning("403 bed mesh bake missing/stale; falling back to original builders")
 if not valid403:return null
 if not held403.has(id):held403[id]=load("res://assets/room403/"+id+".res")
 return held403[id] as ArrayMesh
