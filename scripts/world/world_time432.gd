extends "res://scripts/world/woodland_time122.gd"

const CALENDAR = preload("res://scripts/world/day_clock432.gd")
var efficient_updates432 := true

func _day_palette() -> Resource:
 # Match the last night sample across midnight, then ease into dawn.
 var overnight:=super._day_palette().duplicate(true)
 var midnight: Dictionary=overnight.keys.back().duplicate()
 midnight.hour=0.
 var predawn:=midnight.duplicate()
 predawn.hour=5.
 overnight.keys.push_front(predawn)
 overnight.keys.push_front(midnight)
 return overnight

func _ready() -> void:
 super._ready()
 clock55=CALENDAR.new(palette)

func blocked() -> bool:
 return not is_instance_valid(world.life432) or world.warming_room432 or world.ready350 or super.blocked() or (is_instance_valid(world.map_panel) and world.map_panel.visible)

func _look_interval55() -> float:
 # At normal speed, a quarter-second is under nine in-game seconds.
 if efficient_updates432 and not preview and clock55.speed<=1.:
  return .25
 return super._look_interval55()

func _apply_sun_pose(look: Dictionary) -> void:
 if not efficient_updates432 or preview or clock55.speed>1. or not is_instance_valid(world.life432):
  super._apply_sun_pose(look)
  return
 if freeze_sun57:return
 var pose:=Vector3(-look.elevation56,look.azimuth56,0.)
 # Natural progression can share a shadow direction within a fraction of a degree.
 if not last_pose57.is_finite() or pose.distance_squared_to(last_pose57)>=.28*.28:
  world.sun.rotation_degrees=pose
  last_pose57=pose
  pose_updates57+=1
 last_opacity57=look.shadow_opacity56

func _process(delta: float) -> void:
 var day_before: int=clock55.day
 super._process(delta)
 if clock55.day!=day_before:snap_to_clock()

func snap_to_clock() -> void:
 visual_hour=clock55.hour
 applied_hour55=visual_hour
 last_pose57=Vector3.INF
 apply_look()
 update_guide()

func can_sleep() -> bool:
 return false
