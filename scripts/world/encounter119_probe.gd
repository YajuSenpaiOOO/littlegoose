extends "res://scripts/world/combat111_probe.gd"
const Kit119=preload("res://scripts/combat/memory_kit119.gd")
class Sample:
 extends "res://scripts/world/woodland_world119.gd"
 var immortal119 := false
 func _hero_script() -> Script: return Fighter
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if immortal119 and player_hp>0.: player_hp=100.
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var model := Kit119.new();var stock := model.owned.duplicate();var made := model.crafted.duplicate()
 verify(model.equipped.is_empty() and model.owned.slingshot==0 and model.gel119==0,"fresh independent progress has no gifted slingshot or materials")
 verify(model.try_craft119("slingshot",stock,made,2)==-1 and stock.slingshot==0,"insufficient materials cannot fabricate an item")
 verify(model.try_craft119("slingshot",stock,made,3)==0 and stock.slingshot==1 and made.slingshot==1,"real recipe consumes three droplets and produces one slingshot")
 verify(not model.craft118("slingshot",stock,made) and model.try_craft119("snack",stock,made,30)==-1,"old free crafting and unfinished recipes cannot bypass consumption")
 verify(not model.award119(1),"unreserved events cannot grant rewards")
 model.next_event119=2
 verify(model.award119(1) and model.gel119==3 and not model.award119(1),"a reserved event grants exactly one material bundle")
 var s := Sample.new();s.memory_save116="user://encounter119_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.woodland_ready119: await physics_frame
 await settle72(10)
 verify(s.enemies.size()==3 and not s.active114 and s.standby119.is_empty(),"three peaceful playmates already exist in the woodland before the invitation")
 var peaceful := true;var original_ids := []
 for actor in s.enemies: peaceful=peaceful and actor.mode119=="ambient" and not actor.active_ai and actor.hit_area.collision_layer==0;original_ids.append(actor.get_instance_id())
 verify(peaceful,"ambient playmates neither attack nor intercept shots")
 s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 verify(s.active114 and s.enemies.size()==3 and s.standby119.size()==2 and s.total_enemies==5,"invitation starts three players and reserves exactly two visible bystanders")
 var reused := true
 for actor in s.enemies: reused=reused and actor.get_instance_id() in original_ids
 verify(reused,"the actual ambient three are reused instead of replaced at the start")
 s.elapsed114=44.95;s._physics_process(.1)
 verify(s.active114 and s.elapsed114>45. and s.refill114==0.,"the former 45-second timeout and automatic refill are disabled")
 var first: CharacterBody3D=s.enemies[0];first.receive_hit(999.,Vector3.RIGHT);s.enemy_defeated(first)
 verify(s.defeated_count==1 and s.joined119==0,"one resting actor counts once and does not instantly spawn replacements")
 await settle72(2)
 verify(s.notice119>0. and s.standby119.size()==2,"incoming companions are announced before they join")
 var notice: float=s.notice119;s.combat_paused=true;s._physics_process(.1)
 verify(s.notice119==notice and s.joined119==0,"pause freezes the arrival warning and does not admit a companion")
 s.combat_paused=false
 for i in 140:
  await physics_frame
  if s.joined119==1: break
 verify(s.joined119==1 and s.enemies.size()==4,"first companion joins only after the warning")
 var incoming: CharacterBody3D=s.enemies[-1];var from: Vector3=incoming.position
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/encounter119_join.png")
 await settle72(20)
 verify(incoming.position.distance_to(from)>.08,"joining companion actually walks along its entry path")
 for i in 100:
  await physics_frame
  if s.joined119==2: break
 verify(s.joined119==2 and s.enemies.size()==5 and s.standby119.is_empty(),"the second companion joins once and the finite cast stops at five")
 disable_enemies(s)
 for actor in s.enemies:
  if not actor.dead: actor.receive_hit(999.,Vector3.RIGHT)
 for i in 90:
  await physics_frame
  if not s.active114: break
 verify(s.won119 and not s.active114 and s.trial_ui114.menu.visible and s.defeated_count==5,"all five resting ends the performance with a clear result")
 verify(s.memory_kit116.gel119==3 and s.retry_reward119() and s.memory_kit116.gel119==3,"successful scatter awards three droplets and repeated collection cannot duplicate them")
 var restored := Kit119.new();restored.load_from(s.memory_save116)
 verify(restored.gel119==3 and restored.last_reward119==s.event119,"reward and claim marker persist together")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/encounter119_result.png")
 # Resume the retired actor's own step to check that it rests instead of fading away.
 first._physics_process(.1);first._physics_process(30.)
 verify(is_instance_valid(first) and first.mode119=="resting" and first.visual.transparency==0.,"retired playmates remain visible and do not despawn like corpses")
 s.home116();await settle72(3)
 verify(s.enemies.size()==3 and not s.active114 and s.memory_kit116.gel119==3,"home retains materials and restores the peaceful woodland group")
 s._teleport15(Vector2(-7.4,-3.3));verify(s.open_memory116(),"reward can be taken directly to the nearby notebook")
 var ui: Control=s.memory_ui116;ui.switch118("recipe");ui.select116("slingshot")
 verify(ui.working_gel119==3 and not ui.craft_button118.disabled and ui.stock118.text.contains("3 / 3"),"recipe page shows real owned and required droplet quantities")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/encounter119_recipe.png")
 ui.craft118();verify(ui.working_gel119==0 and ui.working_owned.slingshot==1 and s.memory_kit116.gel119==3,"crafting stages both consumption and item creation")
 var good_path: String=s.memory_save116;s.memory_save116="user://missing119/craft.cfg"
 verify(not s.close_memory116(true) and s.memory_kit116.gel119==3 and s.memory_kit116.owned.slingshot==0 and ui.visible,"failed crafting save rolls back both material and item while retaining the draft")
 s.memory_save116=good_path;s.close_memory116(false)
 verify(s.memory_kit116.gel119==3 and s.memory_kit116.owned.slingshot==0,"cancel restores materials and discards the uncommitted item")
 s.open_memory116();ui.switch118("recipe");ui.select116("slingshot");ui.craft118();ui.switch118("equip");ui.add_one118()
 verify(s.close_memory116(true) and s.memory_kit116.gel119==0 and s.memory_kit116.owned.slingshot==1,"saving commits actual material consumption and owned slingshot")
 restored=Kit119.new();restored.load_from(s.memory_save116)
 verify(restored.gel119==0 and restored.equipped==["slingshot"] and restored.crafted.slingshot==1,"crafted gear and spent material survive a fresh model reload")
 s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 verify(s.buffs.level("slingshot")==1 and s.buffs.levels.size()==1,"the genuinely crafted and equipped slingshot activates on the next outing")
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0,2.))
 var target: CharacterBody3D=s.enemies[0];var at := g+Vector2(1.,-1.);target.position=Vector3(at.x,s.floor_height(at)+.06,at.y);target.hp=1000.
 for i in [1,2]: s.enemies[i].position+=Vector3(35,0,35)
 await settle72(4)
 root.warp_mouse(s.camera.unproject_position(target.hit_area.global_position)+Vector2(35,0));await settle72(3)
 var hp: float=target.hp;s._release_charged(s.aim_at_screen(root.get_mouse_position()),1.);await settle72(50)
 verify(target.hp<hp,"crafted slingshot fires a real assisted charged shot into the native actor")
 s.finish114();verify(not s.won119 and s.memory_kit116.gel119==0,"retreat without completing the cast grants no materials")
 s.start_combat();disable_enemies(s)
 for actor in s.enemies: actor.receive_hit(999.,Vector3.RIGHT)
 for i in 220:
  await physics_frame
  if s.joined119==2: break
 disable_enemies(s)
 for actor in s.enemies:
  if not actor.dead: actor.receive_hit(999.,Vector3.RIGHT)
 var path: String=s.memory_save116;s.memory_save116="user://missing119/no_save.cfg"
 for i in 90:
  await physics_frame
  if not s.active114: break
 verify(s.won119 and s.memory_kit116.gel119==0 and s.trial_ui114.retry119.visible,"failed reward save rolls back the material and exposes an explicit retry")
 var id: int=s.event119;s.start_combat()
 verify(s.event119==id and not s.active114,"a pending uncommitted reward cannot be overwritten by starting another event")
 s.memory_save116=path
 verify(s.retry_reward119() and s.memory_kit116.gel119==3 and s.retry_reward119() and s.memory_kit116.gel119==3,"retry saves the pending reward exactly once")
 # Exercise natural AI and native projectiles: no direct damage or scripted retirement.
 s.immortal119=true;s.memory_kit116.equipped.clear();s.start_combat();s.hero.set_physics_process(false)
 var fire_clock := 0.
 for i in 1400:
  await physics_frame
  if not s.active114: break
  fire_clock-=1./60.
  if fire_clock>0. or s.combat_paused: continue
  for actor in s.enemies:
   if not actor.dead and s._visible114(actor,s.projectile_origin()):
    var cursor: Vector2=s.camera.unproject_position(actor.hit_area.global_position)
    root.warp_mouse(cursor);s.aim_tick114=-1;s.fire_at(s.aim_at_screen(cursor));fire_clock=.34;break
 verify(s.won119 and s.defeated_count==5,"real AI traverses the entrance routes and all five can finish through paced native basic shots")
 var data := {"checks":checks,"failures":failures};var file := FileAccess.open("res://docs/encounter119-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));DirAccess.remove_absolute(ProjectSettings.globalize_path(path));print("ENCOUNTER119_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
