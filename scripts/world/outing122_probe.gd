extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world122.gd"
 func _hero_script() -> Script: return Fighter
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if player_hp>0.: player_hp=100.
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var s := Sample.new();s.memory_save116="user://outing122_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 var actor: CharacterBody3D=s.enemies[0];actor.receive_hit(999.,Vector3.RIGHT)
 await settle72(45)
 verify(actor.dead and actor.visual.texture==s.combat_textures["defeated"] and not actor.is_physics_processing(),"original defeated art settles before the timed disappearance")
 verify(actor.corpse_time>.6 and actor.corpse_time<2.,"corpse lifetime continues after physics has stopped")
 actor.corpse_time=5.9;await settle72(10)
 verify(is_instance_valid(actor) and actor.visual.transparency>0. and actor.visual.modulate.a<1.,"six-second lifetime begins fading both art and shadow")
 s.combat_paused=true;var alpha: float=actor.visual.transparency;await settle72(8)
 verify(actor.visual.transparency==alpha,"pause freezes corpse fade")
 s.combat_paused=false;await settle72(22)
 verify(not is_instance_valid(actor) and s.enemies.size()==2,"faded corpse is removed from the scene and encounter registry")
 s.finish114();await settle72(75)
 verify(s.roamers122.is_empty(),"aborting an unfinished outing does not trigger victory visitors")
 s.start_combat();s.hero.set_physics_process(false);s.rng120.seed=120500
 var fire_clock := 0.
 for i in 6000:
  await physics_frame
  if not s.active114: break
  fire_clock-=1./60.
  if fire_clock>0. or s.combat_paused: continue
  for other in s.enemies:
   if is_instance_valid(other) and not other.dead and s._visible114(other,s.projectile_origin()):
    var cursor: Vector2=s.camera.unproject_position(other.hit_area.global_position);root.warp_mouse(cursor);s.aim_tick114=-1;s.fire_at(s.aim_at_screen(cursor));fire_clock=.34;break
 verify(s.won119 and s.defeated_count==15,"real AI and native shots finish with corpses disappearing during battle")
 var seconds: float=s.elapsed114;var amount: int=s.memory_kit116.gel119
 verify(not s.combat_paused and not s.trial_ui114.menu.visible and s.hero.controls_enabled,"victory still returns directly to free exploration")
 verify(s.roamers122.is_empty() and s.roam_left122==3,"new visitors are scheduled after victory rather than appearing all at once")
 await settle72(70)
 verify(s.roamers122.size()==1 and s.roamers122[0].spawn_age122<.75,"first visitor emerges before the later arrivals")
 var visitor: CharacterBody3D=s.roamers122[0]
 verify(visitor.visual.scale.y<1. or visitor.visual.position.y>0.,"new visitor visibly pops up instead of teleporting at full size")
 await settle72(95)
 verify(s.roamers122.size()==3 and not s.active114,"three noncombat visitors arrive without restarting battle")
 var before: Vector3=visitor.position
 for a in s.roamers122: a.roam_wait122=0.
 await settle72(100)
 verify(visitor.position.distance_to(before)>.15,"visitors hop around their nearby home area")
 verify(visitor.hit_area.collision_layer==0 and not visitor.active_ai,"visitors cannot attack or enter the combat target layer")
 s._teleport15(Vector2(visitor.position.x,visitor.position.z)+Vector2(0,3.));s.talk_wait122=0.
 for i in 180:
  await physics_frame
  if is_instance_valid(s.bubble122): break
 verify(is_instance_valid(s.bubble122) and s.talk_history122.size()>0,"walking near a visitor opens an actor-anchored speech bubble")
 verify(s.talk_history122[-1] in s.ROAM_LINES122,"the speech uses the original yard's cute taunt pool")
 var bubble: Node2D=s.bubble122;var history_count: int=s.talk_history122.size();s.say_roam122(visitor)
 verify(s.bubble122==bubble and s.talk_history122.size()==history_count,"only one visitor speech bubble appears at a time")
 # Stabilize the camera and explicitly preview a nearby speaker for visual QA.
 if is_instance_valid(s.bubble122): s.bubble122.queue_free()
 s.bubble122=null;s.talk_wait122=99.
 await settle72(35);s.say_roam122(visitor);await settle72(55)
 verify(is_instance_valid(s.bubble122) and s.bubble122.visible and s.bubble122.body.visible_characters>0,"the nearby actor bubble is visible and types its line on screen")
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/outing122_roaming.png")
 var count: int=s.defeated_count;visitor.receive_hit(999.,Vector3.RIGHT)
 verify(not visitor.dead and s.defeated_count==count and s.memory_kit116.gel119==amount,"visitors do not become farmable actors or award extra materials")
 await settle72(280)
 verify(s.enemies.is_empty() and s.roamers122.size()==3,"all defeated actors disappear while the three visitors remain")
 var anchor: Node3D=s.bubble122.anchor.get_ref() if is_instance_valid(s.bubble122) else null
 if is_instance_valid(anchor):
  s._teleport15(Vector2(anchor.global_position.x,anchor.global_position.z)+Vector2(0,2.));await settle72(8)
 image=await snapshot();image.save_png("res://docs/captures/world_restart/outing122_after.png")
 s.start_combat();await settle72(3)
 verify(s.active114 and s.roamers122.is_empty() and not is_instance_valid(s.bubble122),"new battle clears visitors and their speech")
 s.won119=true;s.finish114();verify(s.roam_left122==3,"a completed outing schedules fresh visitors before leaving");s.home116();await settle72(3)
 verify(s.roamers122.is_empty() and s.roam_left122==0 and not is_instance_valid(s.bubble122),"returning home cancels visitor spawn schedules and bubbles")
 var data := {"checks":checks,"failures":failures,"seconds":seconds,"lines":s.talk_history122}
 var file := FileAccess.open("res://docs/outing122-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("OUTING122_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
