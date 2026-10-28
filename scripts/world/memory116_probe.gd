extends "res://scripts/world/combat111_probe.gd"
const Kit=preload("res://scripts/combat/memory_kit116.gd")
class Sample:
 extends "res://scripts/world/woodland_world116.gd"
 func _hero_script() -> Script: return Fighter
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var model := Kit.new()
 verify(model.valid(model.equipped) and model.used(model.equipped)==3,"default kit fits four-slot capacity")
 verify(not model.valid(["slingshot","flashlight","snack"]),"over-capacity kit is rejected")
 verify(not model.valid(["snack","snack"]) and not model.valid(["not_a_memory"]),"duplicate and unknown memories are rejected")
 verify(model.valid([]),"empty kit is allowed")
 var sample := Sample.new();sample.memory_save116="user://memory116_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(sample)
 while not sample.woodland_ready116: await physics_frame
 await settle72(12)
 verify(not sample.active114 and sample.hero.controls_enabled and not sample.combat_paused and not sample.trial_ui114.menu.visible,"startup is playable at home instead of the old A/B menu")
 verify(sample.workshop116.near() and sample.can_open_memory116(),"workstation is reachable from the home entrance")
 var seated := true
 for prop in [sample.workshop116.pot,sample.workshop116.tin]:
  seated=seated and absf(prop.position.y-sample.floor_height(Vector2(prop.position.x,prop.position.z))-.025)<.00001
 verify(seated,"both props seat on unchanged actual terrain")
 var query := PhysicsRayQueryParameters3D.create(sample.workshop116.pot.global_position+Vector3(-2.,.4,0),sample.workshop116.pot.global_position+Vector3(2.,.4,0),2)
 var hit := sample.get_world_3d().direct_space_state.intersect_ray(query)
 verify(not hit.is_empty() and hit.collider.get_parent()==sample.workshop116.pot,"stump has native collision")
 query.from=sample.workshop116.tin.global_position+Vector3(1.5,.2,0);query.to=sample.workshop116.tin.global_position+Vector3(-1.5,.2,0);hit=sample.get_world_3d().direct_space_state.intersect_ray(query)
 verify(not hit.is_empty() and hit.collider.get_parent()==sample.workshop116.tin,"tin support has native collision")
 var shadows := 0
 for shadow in sample.actor_shadows:
  if is_instance_valid(shadow) and shadow.get_parent() in [sample.workshop116.pot,sample.workshop116.tin]: shadows+=int(shadow.visible)
 verify(shadows==2,"both props join the grounded silhouette shadow system")
 verify(sample.workshop116.steam_active and sample.workshop116.effect_ticks>0,"light steam animates near the workstation")
 var shared_light := true
 for prop in [sample.workshop116.pot,sample.workshop116.tin]:
  shared_light=shared_light and prop.visual.material_override is ShaderMaterial and sample.porch49.materials.has(prop.visual.material_override.get_instance_id())
 verify(shared_light,"props use the shared woodland light and day/night material pipeline")
 for hour in [12.,18.,22.]:
  sample.time55.preview_at(hour);sample.time55.visual_hour=hour;sample.time55.apply_look();await settle72(7)
  var capture := await snapshot();capture.save_png("res://docs/captures/world_restart/memory116_home_%d.png"%hour)
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look();await settle72(5)
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/memory116_home.png")
 verify(sample.open_memory116() and sample.memory_ui116.visible and sample.combat_paused and not sample.hero.controls_enabled,"nearby interaction opens the kit and pauses movement/combat")
 var original: Array=sample.memory_kit116.equipped.duplicate()
 sample.memory_ui116.select116("slingshot");sample.memory_ui116.toggle116()
 verify(sample.memory_kit116.equipped==original,"editing is staged until confirmation")
 sample.close_memory116(false)
 verify(sample.memory_kit116.equipped==original and sample.hero.controls_enabled and not sample.combat_paused,"cancel preserves the committed kit and restores controls")
 sample.open_memory116();sample.memory_ui116.working.assign(["flashlight","snack"]);sample.memory_ui116.select116("slingshot");sample.memory_ui116.toggle116()
 verify(sample.memory_ui116.working==["flashlight","snack"] and not sample.memory_ui116.feedback.text.is_empty(),"UI prevents adding beyond capacity with feedback")
 sample.memory_ui116.working.assign(["slingshot","flashlight"]);sample.memory_ui116.select116("flashlight")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/memory116_equipment.png")
 verify(sample.close_memory116(true) and sample.memory_kit116.equipped==["slingshot","flashlight"],"confirm commits the selected kit")
 var restored := Kit.new();restored.commit([]);restored.load_from(sample.memory_save116)
 verify(restored.equipped==["slingshot","flashlight"],"equipped memories persist to a local save")
 sample.start_combat();disable_enemies(sample)
 verify(sample.active114 and sample.buffs.level("slingshot")==1 and sample.buffs.level("flashlight")==1 and sample.buffs.levels.size()==2,"departing applies exactly the saved kit after parent retry clears buffs")
 verify(not sample.open_memory116(),"equipment cannot be edited during an active performance")
 sample._release_charged(sample.hero.position+Vector3(0,.8,-4.),1.)
 verify(sample.beam_left110>0.,"equipped slingshot plus flashlight enables the actual charged beam")
 sample.start_combat();disable_enemies(sample)
 verify(sample.buffs.levels.size()==2 and sample.beam_left110==0.,"retry preserves equipped memories and clears the previous beam")
 await settle72(24)
 verify(not sample.workshop116.steam_active,"steam suspends outside the nearby camera area")
 var ticks: int=sample.workshop116.effect_ticks;await settle72(12)
 verify(sample.workshop116.effect_ticks==ticks,"distant steam does not keep advancing")
 sample.finish114();verify(sample.trial_ui114.menu.visible,"performance ends at the new home/retry result panel")
 sample.home116();verify(not sample.active114 and sample.enemies.is_empty() and sample.buffs.levels.size()==2,"returning home clears actors and preserves the kit")
 sample.open_memory116();sample.memory_ui116.working.clear();sample.close_memory116(true,true);disable_enemies(sample)
 verify(sample.active114 and sample.buffs.levels.is_empty(),"empty kit can depart without residual buffs")
 sample.home116();sample.open_memory116();sample.memory_ui116.working.assign(["snack","paper_racer","eye_exercise"]);sample.close_memory116(true,true);disable_enemies(sample)
 verify(sample.buffs.level("snack")==1 and sample.buffs.level("paper_racer")==1 and sample.buffs.level("eye_exercise")==1,"alternative split/movement/tracking kit applies correctly")
 var g: Vector2=sample.meadow.landmarks.grove;sample._teleport15(g+Vector2(0,2.));sample.hero.set_physics_process(false)
 var enemy: CharacterBody3D=sample.enemies[0];var at := g+Vector2(0,-1.);enemy.position=Vector3(at.x,sample.floor_height(at)+.06,at.y);enemy.hp=100.
 for i in [1,2]: sample.enemies[i].position+=Vector3(40,0,40)
 await settle72(4);sample.fire_at(enemy.hit_area.global_position);var split_seen := false
 for i in 70:
  await physics_frame
  for shot in sample.shots:
   if int(shot.get("split_depth110",0))>0: split_seen=true
 verify(enemy.hp<100. and split_seen,"alternative kit hits the native actor and creates actual fragments")
 sample.home116();sample.open_memory116();sample.memory_ui116.select116("paper_racer");image=await snapshot();image.save_png("res://docs/captures/world_restart/memory116_equipment_final.png");sample.close_memory116(false)
 var data := {"checks":checks,"failures":failures};var file := FileAccess.open("res://docs/memory116-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));DirAccess.remove_absolute(ProjectSettings.globalize_path(sample.memory_save116));print("MEMORY116_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
