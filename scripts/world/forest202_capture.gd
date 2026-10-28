extends "res://scripts/world/forest192_capture.gd"
func result_prefix192() -> String: return "forest202"
func world_script192() -> Script: return preload("res://scripts/world/woodland_world202.gd")
func run() -> void:
 root.size=Vector2i(1600,1000)
 sample=world_script192().new();sample.memory_save116="user://"+result_prefix192()+"_validation_tmp.cfg";root.add_child(sample)
 while not sample.ready202: await physics_frame
 sample.hero.controls_enabled=false
 var next_event: int=sample.memory_kit116.next_event119
 verify(sample.context202 and sample.spider_trial170 and sample.enemies.size()==3,"three spiders start in the real forest trial")
 verify(sample.navigation==sample.forest_navigation202,"forest collision grid replaces combat navigation only in trial")
 verify(sample.lighting191.rejected_tree_casters202==1,"central tree cylinder proxy is explicitly rejected")
 var bad := 0
 for caster in sample.lighting191.casters:
  if caster.mesh is CylinderMesh and is_equal_approx(caster.mesh.bottom_radius,.65) and is_equal_approx(caster.mesh.height,4.): bad+=1
 verify(bad==0,"no tall cylindrical shadow remains on central roots")
 verify(sample.forest188.prop_shadows182.size()>0 and sample.forest188.contacts182.size()>0,"existing contour and ground contact shadows retained")
 verify(sample.whole67.get_script()==preload("res://scripts/art/whole_tree_fade200.gd"),"parked tree occlusion implementation unchanged")
 var states := {};var throws := 0;var celebrations := 0;var on_floor := true
 await hour(12.)
 for frame in 900:
  sample.player_hp=1000.;sample.invulnerability=1.
  for actor in sample.enemies:
   states[actor.state170]=true;throws=maxi(throws,actor.throws171);celebrations=maxi(celebrations,actor.celebrations172)
   on_floor=on_floor and absf(sample.floor_height(Vector2(actor.position.x,actor.position.z))+2.2)<.5
  if frame==180: await picture("spiders_day")
  await physics_frame
 verify(states.has("hop") and states.has("winding") and states.has("weave") and states.has("happy"),"real forest AI visits hop, silk windup, weaving and happy hops")
 verify(throws>0 and celebrations>0,"spiders actually release silk and finish weaving")
 verify(on_floor,"spider positions remain on lowland floor")
 var actor: CharacterBody3D=sample.enemies[0]
 var day: Color=actor.visual.modulate
 await hour(22.)
 var night: Color=actor.visual.modulate
 verify(night.r+night.g+night.b<day.r+day.g+day.b,"spiders receive day-night environmental grading")
 await picture("spiders_night")
 sample.spider_count170=1;sample.start_spider170();await settle(10)
 verify(sample.enemies.size()==1 and sample.context202,"restart supports single-spider trial")
 sample.stop_trial202();await settle(5)
 verify(not sample.context202 and sample.enemies.is_empty() and sample.pads172.is_empty() and sample.silk171.is_empty(),"stopping trial removes actors, silk and web pads")
 verify(sample.navigation==sample.original_navigation202 and sample.meadow.landmarks.grove==sample.original_grove202,"stopping restores original grove center and navigation")
 verify(sample.memory_kit116.next_event119==next_event,"trial does not advance formal progression")
 sample._teleport15(Vector2(-44,27));await settle(90);await picture("roots_no_column")
 sample.spider_count170=3;sample.start_spider170();await settle(5)
 verify(sample.enemies.size()==3,"three-spider restart works after returning to exploration")
 for enemy in sample.enemies.duplicate(): enemy.receive_hit(10000.,Vector3.ZERO)
 await settle(100)
 verify(not sample.active114 and sample.roam_left122==0 and not sample.won119,"victory does not queue ordinary roamers or reward reminders")
 sample.start_spider170();await settle(5)
 verify(sample.active114 and sample.enemies.size()==3 and sample.memory_kit116.next_event119==next_event,"victory can restart without advancing progression")
 metrics.states=states.keys();metrics.throws=throws;metrics.celebrations=celebrations
 await extra_checks192()
 FileAccess.open("res://docs/"+result_prefix192()+"-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"metrics":metrics,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(sample.memory_save116));print("FOREST202_DONE ",failures);quit(0 if failures.is_empty() else 1)
