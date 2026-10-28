extends "res://scripts/world/perf_world_probe.gd"
# Discriminate script-CPU spikes vs render/driver stalls: capture per-frame
# process+physics times with the gaps, then stop all game processing.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-spikes2-report.json"
func prefix_perf() -> String: return "perf204spike2"
func trace(tag: String,seconds: float) -> void:
 await settle(60)
 var rows: Array=[]
 var t0 := Time.get_ticks_usec();var last := t0
 while Time.get_ticks_usec()-t0<int(seconds*1000000.):
  await process_frame
  var now := Time.get_ticks_usec();var gap := now-last;last=now
  rows.append([float(now-t0)/1000000.,float(gap)/1000.,float(Performance.get_monitor(Performance.TIME_PROCESS)),float(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)),int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))])
 var sorted := rows.duplicate(true)
 sorted.sort_custom(func(a,b): return a[1]>b[1])
 var top: Array=[]
 for row in sorted.slice(0,8): top.append({"t":roundf(row[0]),"gap_ms":roundf(row[1]),"proc":row[2],"phys":row[3],"draws":row[4]})
 var normal: Array=rows[rows.size()/2]
 report.spots.append({"tag":tag,"frames":rows.size(),"top":top,"median":{"gap_ms":roundf(normal[1]),"proc":normal[2],"phys":normal[3],"draws":normal[4]}})
 print("SPIKES2 ",JSON.stringify(report.spots[-1]))
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 await trace("forest_scripts_on",8.)
 sample.propagate_call("set_physics_process",[false])
 sample.propagate_call("set_process",[false])
 await settle(60)
 await trace("forest_scripts_off",8.)
 root.size=Vector2i(800,500);await settle(60)
 await trace("forest_scripts_off_halfres",8.)
 root.size=Vector2i(1600,1000);await settle(60)
 sample.propagate_call("set_physics_process",[true])
 sample.propagate_call("set_process",[true])
