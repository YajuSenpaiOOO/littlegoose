extends "res://scripts/world/perf_world_probe.gd"
# Attribute the periodic long frames ("still feels stuttery"): record raw
# frame-gap traces for 10 s per configuration and report the worst spikes,
# their cadence and percentiles.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-spikes-report.json"
func prefix_perf() -> String: return "perf204spike"
func trace(tag: String,seconds: float) -> void:
 await settle(60)
 var gaps: Array=[]
 var marks: Array=[]
 var t0 := Time.get_ticks_usec();var last := t0
 while Time.get_ticks_usec()-t0<int(seconds*1000000.):
  await process_frame
  var now := Time.get_ticks_usec();var gap := now-last;last=now
  if gap>1500: gaps.append([float(now-t0)/1000000.,float(gap)/1000.])
 var sorted := gaps.duplicate(true)
 sorted.sort_custom(func(a,b): return a[1]>b[1])
 var top: Array=sorted.slice(0,12)
 var spikes := sorted.filter(func(entry): return entry[1]>20.)
 var intervals := []
 for i in range(1,spikes.size()): intervals.append(round((spikes[i][0]-spikes[i-1][0])*1000.))
 var total_ms := 0.
 for entry in sorted: total_ms+=entry[1]
 var result := {"tag":tag,"frames":gaps.size(),"over20ms":spikes.size(),"sum_over1.5ms":roundf(total_ms),"top":top,"spike_intervals_ms":intervals}
 report.spots.append(result)
 print("SPIKES ",JSON.stringify(result))
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 await trace("forest_day",10.)
 sample.fade_enabled=false
 await trace("forest_day_fadeoff",10.)
 sample.fade_enabled=true;await settle(60)
 var lighting: Object=sample.get("lighting191")
 lighting.enabled=false;await settle(150)
 sample.fade_enabled=false
 await trace("forest_day_fadeoff_lightsoff",10.)
 lighting.enabled=true;sample.fade_enabled=true;await settle(150)
 sample._teleport15(Vector2(-4.7,-2.6));await settle(60)
 await trace("yard_day",10.)
 sample.fade_enabled=false
 await trace("yard_day_fadeoff",10.)
 sample.fade_enabled=true
