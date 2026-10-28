extends "res://scripts/world/perf_world_probe.gd"
# Measure frames WHILE WALKING through the forest - the real play condition
# the stationary probes never covered (tree fade churn, camera follow, lamp
# gates firing every frame while moving).
class WalkerMove:
 extends "res://scripts/combat/hero192.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
 func dash_key_down() -> bool: return false
 func parry_key_down() -> bool: return false
class TrialMove:
 extends "res://scripts/world/woodland_world204.gd"
 func _hero_script() -> Script: return WalkerMove
func world_script_perf() -> Script: return TrialMove
func out_path_perf() -> String: return "res://docs/perf204-moving-report.json"
func prefix_perf() -> String: return "perf204move"
func walk_measure(tag: String,route: Array,seconds: float) -> void:
 sample.hero.controls_enabled=true
 await settle(30)
 var gaps_over30 := 0;var worst := 0.;var frames := 0
 var t0 := Time.get_ticks_usec();var last := t0
 var waypoint := 0
 while Time.get_ticks_usec()-t0<int(seconds*1000000.):
  var target: Vector2=route[waypoint%route.size()]
  var flat := Vector2(sample.hero.position.x,sample.hero.position.z)
  if flat.distance_to(target)<.6: waypoint+=1
  else: sample.hero.command=(target-flat).normalized()
  await process_frame
  frames+=1
  var now := Time.get_ticks_usec();var gap: float=float(now-last)/1000.;last=now
  worst=maxf(worst,gap)
  if gap>30.: gaps_over30+=1
 sample.hero.command=Vector2.ZERO;sample.hero.controls_enabled=false
 report.spots.append({"tag":tag,"frames":frames,"fps":1000./(float(Time.get_ticks_usec()-t0)/1000./frames),"worst_ms":worst,"over30ms":gaps_over30})
 print("MOVE ",JSON.stringify(report.spots[-1]))
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 await settle(90)
 await walk_measure("forest_walk_loop",[Vector2(-52.,28.),Vector2(-48.,24.),Vector2(-44.,28.),Vector2(-40.,30.),Vector2(-37.,29.),Vector2(-40.,26.),Vector2(-48.,24.)],18.)
 sample._teleport15(Vector2(-4.7,-2.6));await settle(60)
 await walk_measure("yard_walk_loop",[Vector2(-8.,-2.),Vector2(-1.,-2.),Vector2(-4.7,-5.)],10.)
