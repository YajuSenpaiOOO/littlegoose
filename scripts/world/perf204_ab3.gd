extends "res://scripts/world/perf_world_probe.gd"
# In-run A/B of the round-3 cuts, cancelling machine-state drift between runs.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-ab-round3-report.json"
func prefix_perf() -> String: return "perf204ab3"
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 var sun: DirectionalLight3D=sample.sun
 await measure("current_orthogonal_nocast",120,2.)
 sun.directional_shadow_mode=DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS;await settle(90)
 await measure("twosplit_nocast",120,2.)
 var trim: Node=sample.get_node("/root/@Node3D@2/@MeshInstance3D@5/NorthernBufferTrim140")
 var rock: Node=sample.get_node("/root/@Node3D@2/RockFacesAndGrassCaps91/FacetedBedrock91/NorthernRockTrim140")
 trim.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON;rock.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON;await settle(90)
 await measure("twosplit_cast",120,2.)
 sun.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL;await settle(90)
 await measure("orthogonal_cast",120,2.)
 trim.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;rock.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
