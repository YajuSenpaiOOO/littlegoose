extends "res://scripts/world/combat111_probe.gd"
const Kit118=preload("res://scripts/combat/memory_kit118.gd")
class Sample:
 extends "res://scripts/world/woodland_world118.gd"
 func _hero_script() -> Script: return Fighter
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var model := Kit118.new();var stock := model.owned.duplicate();var made := model.crafted.duplicate()
 verify(model.ORDER.size()==14 and model.START.size()==6,"notebook catalogs fourteen childhood memories with six trial recipes")
 verify(model.valid(model.equipped) and not model.valid(["paper_racer","paper_racer"]),"duplicate equipment requires enough actual copies")
 verify(model.craft118("paper_racer",stock,made) and stock.paper_racer==2 and made.paper_racer==1,"crafting records one new copy separately from the starter gift")
 verify(model.valid(["paper_racer","paper_racer","slingshot"],stock),"duplicate copies fit using their individual slot costs")
 verify(not model.valid(["paper_racer","paper_racer","slingshot","eye_exercise"],stock),"duplicates cannot bypass capacity")
 verify(not model.craft118("red_banner",stock,made) and not model.craft118("unknown",stock,made),"locked and unknown recipes cannot be crafted")
 verify(model.stock_valid118(stock,made,model.unlocked) and not model.stock_valid118({},made,model.unlocked),"inventory validation rejects incomplete data")
 verify(model.valid([]),"empty loadout remains valid")
 var legacy := preload("res://scripts/combat/memory_kit116.gd").new();legacy.commit(["snack","paper_racer","eye_exercise"])
 var legacy_path := "user://legacy118_probe_%d.cfg"%Time.get_ticks_msec();legacy.save_to(legacy_path)
 var old_data := FileAccess.get_file_as_string(legacy_path);var migrated := Kit118.new();migrated.migrate118(legacy_path)
 verify(migrated.equipped==legacy.equipped and migrated.owned.snack==1 and FileAccess.get_file_as_string(legacy_path)==old_data,"legacy loadout migration retains starter quantities without modifying the old save")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(legacy_path))
 var sample := Sample.new();sample.memory_save116="user://notebook118_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(sample)
 while not sample.woodland_ready118: await physics_frame
 await settle72(12)
 verify(not sample.active114 and sample.can_open_memory116(),"startup still returns to the reachable home workshop")
 verify(sample.grounding118.entries118.size()==3,"house stump and tin each have fitted foot geometry")
 var seated := true;var unchanged := true
 for entry in sample.grounding118.entries118:
  seated=seated and entry.mesh.mesh.get_surface_count()==1 and entry.sprite.layers==0
  for i in entry.feet.size():
   if entry.valid[i]: seated=seated and absf(entry.feet[i].y-sample.floor_height(Vector2(entry.feet[i].x,entry.feet[i].z))-.009)<.0001
  unchanged=unchanged and entry.mesh.material_override==entry.sprite.material_override
 verify(seated,"all sampled painted foot contacts seat on the existing floor")
 verify(unchanged,"fitted cards retain the original shared lighting materials")
 var mesh_count: int=sample.grounding118.entries118[0].mesh.mesh.get_surface_count()
 for hour in [12.,18.,22.]:
  sample.time55.preview_at(hour);sample.time55.visual_hour=hour;sample.time55.apply_look();await settle72(6)
  var image := await snapshot();image.save_png("res://docs/captures/world_restart/notebook118_home_%d.png"%hour)
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 # Close-up from the player's screenshot direction; collision and terrain remain unchanged.
 sample._teleport15(Vector2(-7.4,-3.3));await settle72(15)
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/notebook118_ground_close.png")
 verify(sample.grounding118.entries118[0].mesh.mesh.get_surface_count()==mesh_count,"fitted scenery does not rebuild while the camera moves")
 var query := PhysicsRayQueryParameters3D.create(sample.workshop116.pot.global_position+Vector3(-2.,.4,0),sample.workshop116.pot.global_position+Vector3(2.,.4,0),2)
 var hit := sample.get_world_3d().direct_space_state.intersect_ray(query)
 verify(not hit.is_empty() and hit.collider.get_parent()==sample.workshop116.pot,"workshop still has native collision")
 var fitted_shadow := 0
 for shadow in sample.actor_shadows:
  if is_instance_valid(shadow) and shadow.visual in [sample.workshop116.pot.visual,sample.workshop116.tin.visual] and shadow.ink.shader==preload("res://scripts/art/actor_shadow118.gdshader"): fitted_shadow+=1
 verify(fitted_shadow==2,"both silhouette shadows use the same fitted foot displacement")
 verify(sample.open_memory116() and sample.combat_paused and not sample.hero.controls_enabled,"opening the notebook pauses controls")
 var ui: Control=sample.memory_ui116;ui.switch118("recipe");ui.select116("paper_racer")
 var layout_ok := true
 for id in model.ORDER:
  ui.select116(id);await process_frame
  layout_ok=layout_ok and ui.detail_effect.get_rect().end.y<=ui.detail_line.position.y+1. and ui.detail_line.get_rect().end.y<=ui.stock118.position.y+1.
 verify(layout_ok,"all fourteen descriptions and companion lines fit without overlapping recipe counts")
 ui.select116("paper_racer")
 verify(ui.ids118.size()==14 and ui.pager118.text=="1 / 3 页","recipe bookmark shows a paginated complete catalog")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/notebook118_recipe.png")
 ui.page118(2);ui.row_select118(3)
 verify(ui.pages118.recipe==2 and ui.craft_button118.disabled,"later recipe pages display locked entries without allowing fabrication")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/notebook118_locked.png")
 ui.page118(1);verify(ui.pages118.recipe==0,"recipe navigation wraps across three pages")
 var before: int=sample.memory_kit116.owned.paper_racer
 ui.select116("paper_racer");ui.craft118()
 verify(ui.working_owned.paper_racer==before+1 and sample.memory_kit116.owned.paper_racer==before,"crafting stays staged until the notebook is saved")
 sample.close_memory116(false)
 verify(sample.memory_kit116.owned.paper_racer==before and not sample.combat_paused and sample.hero.controls_enabled,"closing without saving cancels crafting as well as equipment")
 sample.open_memory116();ui.switch118("recipe");ui.select116("paper_racer");ui.craft118()
 ui.equip_tab118.pressed.emit()
 verify(ui.tab118=="equip" and ui.ids118.size()==6 and ui.pager118.text=="1 / 2 页","equipment bookmark has its own paginated inventory")
 ui.working.assign(["paper_racer"]);ui.select116("paper_racer");ui.add_one118()
 verify(ui.working==["paper_racer","paper_racer"] and ui.add118.disabled,"two owned copies can be equipped and no third unavailable copy can be added")
 ui.select116("slingshot");ui.add_one118()
 verify(sample.memory_kit116.used(ui.working)==4,"two racers and one slingshot consume four slots")
 ui.select116("eye_exercise");ui.add_one118()
 verify(ui.working==["paper_racer","paper_racer","slingshot"] and not ui.feedback.text.is_empty(),"UI refuses capacity overflow without modifying the staged kit")
 ui.select116("paper_racer");image=await snapshot();image.save_png("res://docs/captures/world_restart/notebook118_equipment.png")
 root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size);await settle72(3)
 var corner118: Vector2=ui.book.position+ui.book.size*ui.book.scale
 var canvas118: Vector2=ui.get_viewport_rect().size
 verify(ui.book.position.x>=0. and ui.book.position.y>=0. and corner118.x<=canvas118.x and corner118.y<=canvas118.y and root.size==Vector2i(1280,720),"the whole notebook and bookmarks fit the stretched canvas in a 1280 by 720 window")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/notebook118_equipment_720.png")
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size);await settle72(3)
 ui.remove_one118();verify(ui.working.count("paper_racer")==1 and ui.working_owned.paper_racer==2,"unequipping a copy returns it without destroying inventory")
 ui.add_one118();verify(sample.close_memory116(true),"one save commits crafted inventory and duplicate equipment together")
 var restored := Kit118.new();restored.load_from(sample.memory_save116)
 verify(restored.equipped==["paper_racer","slingshot","paper_racer"] and restored.owned.paper_racer==2 and restored.crafted.paper_racer==1,"copies equipped counts and crafted counts survive a saved reload")
 sample.start_combat();disable_enemies(sample)
 verify(sample.buffs.level("paper_racer")==2 and sample.buffs.level("slingshot")==1,"duplicate equipped copies apply the real existing second-level effect")
 verify(not sample.open_memory116(),"the notebook cannot be edited mid-performance")
 sample.hero.set_physics_process(false);sample.hero.controls_enabled=true
 var g: Vector2=sample.meadow.landmarks.grove;sample._teleport15(g+Vector2(0,2.))
 var actor: CharacterBody3D=sample.enemies[0];var at := g+Vector2(1.,-1.);actor.position=Vector3(at.x,sample.floor_height(at)+.06,at.y);actor.hp=1000.
 for i in [1,2]: sample.enemies[i].position+=Vector3(40,0,40)
 await settle72(5)
 var origin: Vector2=sample.camera.unproject_position(sample.hero.global_position+Vector3.UP*.8)
 var dir: Vector2=sample.camera.unproject_position(actor.hit_area.global_position)-origin
 root.warp_mouse(origin+dir.normalized().rotated(.45)*240.);await settle72(10)
 verify(sample.target114==actor and sample.candy117.active117 and sample.candy117.previous117==actor.get_instance_id(),"expanded candy corners follow the actual assisted actor off-body")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/notebook118_aim.png")
 var hp: float=actor.hp;sample._release_charged(sample.aim_at_screen(root.get_mouse_position()),1.);await settle72(45)
 verify(actor.hp<hp,"duplicate kit retains actual assisted charged projectile hits")
 sample.start_combat();disable_enemies(sample)
 verify(sample.buffs.level("paper_racer")==2 and sample.beam_left110==0.,"retry preserves duplicate equipment and clears transient shots")
 sample.finish114();sample.home116();await settle72(3)
 verify(Input.mouse_mode==Input.MOUSE_MODE_VISIBLE and not sample.candy117.active117,"home restores the system cursor and hides selection graphics")
 verify(sample.memory_kit116.equipped==restored.equipped and sample.enemies.is_empty(),"returning home retains inventory and clears actors")
 # Save failure must roll back both quantities and equipment, leaving the notebook open.
 sample._teleport15(Vector2(-7.4,-3.3));sample.open_memory116();ui.switch118("recipe");ui.select116("paper_racer");ui.craft118()
 var actual_path: String=sample.memory_save116;sample.memory_save116="user://missing118/no_file.cfg"
 verify(not sample.close_memory116(true) and ui.visible and sample.memory_kit116.owned.paper_racer==2,"failed save rolls back stock and keeps the draft available")
 sample.memory_save116=actual_path;sample.close_memory116(false)
 var data := {"checks":checks,"failures":failures};var file := FileAccess.open("res://docs/notebook118-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));DirAccess.remove_absolute(ProjectSettings.globalize_path(actual_path));print("NOTEBOOK118_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
