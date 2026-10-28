extends "res://scripts/world/forest192_capture.gd"
func result_prefix192() -> String: return "forest204"
func mean204(image: Image,point: Vector2) -> Color:
 var sum := Color(0,0,0,0)
 for y in range(-2,3):
  for x in range(-2,3): sum+=image.get_pixel(clampi(roundi(point.x)+x,0,image.get_width()-1),clampi(roundi(point.y)+y,0,image.get_height()-1))
 return sum/25.
func difference204(a: Color,b: Color) -> float: return Vector3(a.r-b.r,a.g-b.g,a.b-b.b).length()
func run() -> void:
 root.size=Vector2i(1600,1000)
 sample=preload("res://scripts/world/woodland_world204.gd").new();sample.memory_save116="user://forest204_validation_tmp.cfg";root.add_child(sample)
 while not sample.ready203: await physics_frame
 sample.hero.controls_enabled=false;sample.set_physics_process(false)
 for actor in sample.enemies: actor.set_physics_process(false)
 sample._clear_combat_shots();await hour(12.)
 var manager: Node3D=sample.paper_memories146
 var mark := Vector3(-43.,0.,30.);mark.y=sample.floor_height(Vector2(mark.x,mark.z))+.05
 manager.pending_mark149=mark;manager.rebuild204();await settle(5)
 verify(is_equal_approx(manager.marker_radius150(),2.4),"coverage radius remains the original 2.4 metres")
 var grounded: bool=not manager.vertices204.is_empty()
 for at in manager.vertices204: grounded=grounded and absf(at.y-sample.floor_height(Vector2(at.x,at.z))-.035)<.0001
 verify(grounded,"every marker vertex follows the terrain with a small surface offset")
 verify(not manager.ground204.material_override.shader.code.contains("depth_test_disabled"),"marker uses ordinary GPU depth testing")
 verify(manager.ground204.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"ground indicator has no cast shadow")
 var point := mark+Vector3(-2.4,0,0);point.y=sample.floor_height(Vector2(point.x,point.z))+.035
 var screen: Vector2=sample.camera.unproject_position(point)
 var cover := MeshInstance3D.new();var quad := QuadMesh.new();quad.size=Vector2(.65,.65);cover.mesh=quad
 var ink := StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.albedo_color=Color("35465c")
 cover.material_override=ink;cover.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 sample.add_child(cover);cover.global_basis=sample.camera.global_basis;cover.global_position=point+sample.camera.global_basis.z*.6
 await settle(3);var covered_on := mean204(await picture("depth_cover_on"),screen)
 manager.ground204.hide();manager.set_process(false);await settle(3)
 var covered_off := mean204(await picture("depth_cover_off"),screen)
 verify(difference204(covered_on,covered_off)<.015,"GPU fixture fully occludes the ring instead of receiving an overlaid line")
 cover.hide();manager.ground204.show();await settle(3)
 var exposed_on := mean204(await picture("depth_exposed_on"),screen)
 manager.ground204.hide();await settle(3)
 var exposed_off := mean204(await picture("depth_exposed_off"),screen)
 metrics.covered_difference=difference204(covered_on,covered_off);metrics.exposed_difference=difference204(exposed_on,exposed_off)
 verify(metrics.exposed_difference>.03,"same ring segment is visibly drawn on exposed ground")
 cover.queue_free();manager.set_process(true)
 sample._teleport15(Vector2(-44.,28.));manager.pending_mark149=Vector3(-49.,-2.15,24.5);await settle(100);await picture("tree_and_root_ground_ring")
 await hour(22.);await picture("tree_and_root_night")
 sample._teleport15(Vector2(-33.,31.));manager.pending_mark149=Vector3(-33.,0.,31.);await settle(40)
 var separated := true
 for i in range(0,manager.vertices204.size(),3):
  var low := INF;var high := -INF
  for j in 3: low=minf(low,manager.vertices204[i+j].y);high=maxf(high,manager.vertices204[i+j].y)
  separated=separated and high-low<=.20
 verify(separated,"marker never spans a large vertical cliff discontinuity")
 await picture("stairs_ground_ring")
 manager.reset146();verify(manager.ground204.mesh==null and manager.marks204.is_empty(),"reset removes the pending ground mesh immediately")
 sample.build170=3;sample.apply_paper_build129();sample.start_spider170()
 var target: Vector3=sample.hero.position+Vector3(-3,0,-1)
 var packet: Dictionary=sample.snapshot_packet146(target,false,0.)
 manager.launch146(packet,sample.projectile_origin(),target);manager.rebuild204()
 verify(manager.planes149.size()>0 and manager.marks204.size()>1,"live goose squad flights retain centre and six delivery-sector markings")
 var flight: Dictionary=manager.planes149[0];var original_mark: Vector3=flight.mark
 var history: int=manager.history149.size();manager.drop150(flight,0)
 verify(manager.history149.size()==history+1 and flight.mark==original_mark,"ground rendering leaves original delivery and target mark unchanged")
 sample.stop_trial202();verify(manager.ground204.mesh==null,"leaving the encounter clears flight ground markers")
 FileAccess.open("res://docs/forest204-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"metrics":metrics,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(sample.memory_save116));print("FOREST204_DONE ",failures);quit(0 if failures.is_empty() else 1)
