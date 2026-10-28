extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world121.gd"
 func _hero_script() -> Script: return Fighter
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if player_hp>0.: player_hp=100.
func synced(actor: Node3D) -> bool:
 return actor.soft_ink.get_shader_parameter("art")==actor.visual.texture
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var s := Sample.new();s.memory_save116="user://outing121_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 await settle72(5)
 verify(not s.encounter_hud.visible and not s.trial_ui114.menu.visible,"exploration starts without combat HUD or menu")
 s.start_combat();disable_enemies(s);s.hero.set_physics_process(false);await settle72(8)
 verify(s.encounter_hud.modulate.a>0. and s.encounter_hud.modulate.a<1.,"HUD enters through a visible gradual transition")
 await settle72(28);verify(s.encounter_hud.modulate.a>.99,"HUD finishes entering during combat")
 var actor: CharacterBody3D=s.enemies[0]
 actor.receive_hit(1.,Vector3.RIGHT);actor.join119(s.meadow.landmarks.grove+Vector2(0,-6));actor.set_physics_process(true)
 await settle72(18)
 verify(not actor.dead and actor.hit_left==0. and synced(actor),"hit response expires during entry and shader art follows current pose")
 var saw_lift := false;var saw_land := false
 for i in 42:
  await physics_frame
  if actor.mode119=="entering":
   if actor.visual.position.y>.08: saw_lift=true
   if not actor.hopping and absf(actor.visual.position.y)<.04: saw_land=true
 verify(saw_lift and saw_land,"arrivals alternate airborne hops and grounded pauses instead of sliding")
 actor.receive_hit(999.,Vector3.RIGHT)
 verify(actor.dead and actor.is_physics_processing(),"defeat keeps updating until authored fall finishes")
 await settle72(45)
 verify(actor.visual.texture==s.combat_textures["defeated"] and synced(actor),"defeat settles on original defeated art in both sprite and shader")
 verify(not actor.is_physics_processing() and actor.hit_area.collision_layer==0 and actor.velocity==Vector3.ZERO,"settled actor stops updating and no longer receives combat hits")
 var pose: Texture2D=actor.visual.texture;await settle72(15)
 verify(actor.visual.texture==pose and actor.visual.transparency==0.,"defeated pose stays on the ground without freezing on hit art")
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/outing121_defeated.png")
 s.finish114()
 verify(not s.active114 and not s.combat_paused and s.hero.controls_enabled and not s.trial_ui114.menu.visible and not s.result_open,"leaving play returns control in place without a result popup")
 verify(s.encounter_hud.reveal121>0.,"HUD starts withdrawing instead of disappearing instantly")
 await settle72(28);verify(not s.encounter_hud.visible,"HUD finishes withdrawing after combat")
 s.start_combat();s.hero.set_physics_process(false);s.rng120.seed=120500
 var fire_clock := 0.
 for i in 6000:
  await physics_frame
  if not s.active114: break
  fire_clock-=1./60.
  if fire_clock>0. or s.combat_paused: continue
  for other in s.enemies:
   if not other.dead and s._visible114(other,s.projectile_origin()):
    var cursor: Vector2=s.camera.unproject_position(other.hit_area.global_position);root.warp_mouse(cursor);s.aim_tick114=-1;s.fire_at(s.aim_at_screen(cursor));fire_clock=.34;break
 verify(s.won119 and s.defeated_count==15,"real AI and native basic projectiles still complete the outing")
 var elapsed: float=s.elapsed114
 var hero_at: Vector3=s.hero.position;var gel: int=s.memory_kit116.gel119
 verify(not s.trial_ui114.menu.visible and not s.encounter_hud.result.visible and not s.combat_paused and s.hero.controls_enabled,"natural victory opens no menu and preserves exploration controls")
 verify(s.drops120.items120.is_empty() and s.memory_kit116.last_reward119>=s.event119,"existing ground drops are gathered and event is saved without reward popup")
 await settle72(45)
 var all_settled := true
 for other in s.enemies:
  if not other.dead or other.visual.texture!=s.combat_textures["defeated"] or not synced(other): all_settled=false
 verify(all_settled,"every participant retains its original defeated silhouette after victory")
 verify(not s.encounter_hud.visible and s.hero.position.distance_to(hero_at)<.05,"victory hides HUD without teleporting the player")
 s.hero.set_physics_process(true);s.hero.wish=Vector2(1,0);await settle72(20);s.hero.wish=Vector2.ZERO
 verify(s.hero.position.distance_to(hero_at)>.25,"player can walk away freely after victory")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/outing121_exploration.png")
 s.retry_reward119();verify(s.memory_kit116.gel119==gel,"completion adds no fixed materials")
 s.start_combat();verify(s.active114 and not s.trial_ui114.menu.visible,"a fresh outing starts after a popup-free victory")
 s.player_hp=0.;s.finish114();verify(s.trial_ui114.menu.visible and s.combat_paused,"player knockout retains recovery and retry flow")
 var data := {"checks":checks,"failures":failures,"seconds":elapsed}
 var file := FileAccess.open("res://docs/outing121-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("OUTING121_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
