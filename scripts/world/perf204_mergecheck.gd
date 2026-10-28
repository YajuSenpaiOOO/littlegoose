extends "res://scripts/world/perf_world_probe.gd"
# Verify the ground surface merge: counts, triangle totals, reference shots.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-mergecheck-report.json"
func prefix_perf() -> String: return "perf204merge"
func spots_perf() -> void:
 var trim: MeshInstance3D=sample.get_node("/root/@Node3D@2/@MeshInstance3D@5/NorthernBufferTrim140")
 var mesh: ArrayMesh=trim.mesh
 var tris := 0
 var per_surface: Array=[]
 for surface in mesh.get_surface_count():
  var arrays: Array=mesh.surface_get_arrays(surface)
  var count: int=arrays[Mesh.ARRAY_INDEX].size()/3 if arrays[Mesh.ARRAY_INDEX]!=null and not arrays[Mesh.ARRAY_INDEX].is_empty() else arrays[Mesh.ARRAY_VERTEX].size()/3
  tris+=count;per_surface.append(count)
 report.merge={"surfaces":mesh.get_surface_count(),"tris":tris,"expected_tris":122066}
 print("MERGECHECK ",JSON.stringify(report.merge))
 print("MERGE_SURFACE_TRIS ",JSON.stringify(per_surface))
 sample._teleport15(Vector2(-4.7,-2.6));await hour(12.)
 await measure("yard_day_postmerge");await shot_perf("yard_day_postmerge")
 sample._teleport15(Vector2(-48.,24.));await settle(60)
 await measure("forest_day_postmerge");await shot_perf("forest_day_postmerge")
