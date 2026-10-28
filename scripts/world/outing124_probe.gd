extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world124.gd"
 func _hero_script() -> Script: return Fighter
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if player_hp>0.: player_hp=100.
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://outing124_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 var g: Vector2=s.meadow.landmarks.grove
 s._teleport15(g+Vector2(0,8.))
 var a: CharacterBody3D=s.enemies[0];var b: CharacterBody3D=s.enemies[1]
 a.position=Vector3(g.x,s.floor_height(g),g.y)
 b.position=a.position+Vector3(2.,0.,0.)
 a.play119();b.play119();a.set_physics_process(false);b.set_physics_process(false)
 # Real lunge transition, not direct roll start.
 a.attack_phase="lunge";a.phase_clock=a.LUNGE-.01;a.attack_connected=false;a.attack_direction=Vector2.LEFT;a.attack_distance=1.4
 a._physics_process(1./60.)
 verify(a.play_state123=="roll" and a.roll_count123==1,"missed lunge transitions into a roll")
 var before: Vector3=a.position
 a._physics_process(.1)
 verify(a.position.distance_to(before)>.03 and absf(float(a.soft_ink.get_shader_parameter("roll_angle123")))>.1,"roll translates and rotates the centred art")
 a.visual.reset_physics_interpolation()
 var roll_image := await snapshot();roll_image.save_png("res://docs/captures/world_restart/outing124_roll.png")
 if "--visual-only123" in OS.get_cmdline_user_args():
  print("OUTING123_VISUAL_DONE");DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));quit();return
 s.combat_paused=true;var timer: float=a.play_clock123;a._physics_process(.1)
 verify(a.play_clock123==timer,"pause freezes rolling")
 s.combat_paused=false
 for i in 32: a._physics_process(1./60.)
 verify(a.play_state123=="" and absf(a.visual.rotation.z)<.15,"roll settles upright and returns to recovery")
 a.attack_phase="lunge";a.phase_clock=a.LUNGE-.01;a.attack_connected=true
 a._physics_process(1./60.)
 verify(a.play_state123=="","successful player contact does not trigger a missed-lunge roll")
 # Swept peer collision, including crossing the whole peer in one step.
 a.peer_cooldown123=0.;b.peer_cooldown123=0.
 a.position=b.position+Vector3(-.9,0,0);a.attack_phase="lunge";a.phase_clock=0.;a.attack_distance=3.8;a.attack_direction=Vector2.RIGHT;a.attack_connected=false;a.collision_mask=3
 a._physics_process(.04)
 verify(a.play_state123=="cheer" and b.play_state123=="cheer" and a.peer123==b and b.peer123==a,"real lunge contact starts mutual anger hops")
 var health: float=s.player_hp;var hp: float=b.hp;var hits: int=b.hit_count;var defeats: int=s.defeated_count
 for i in 55: a._physics_process(1./60.);b._physics_process(1./60.)
 verify(a.play_state123=="shove" and b.play_state123=="shove","anger hops transition into mutual shoving")
 for i in 55: a._physics_process(1./60.);b._physics_process(1./60.)
 verify(b.hp<hp and hp-b.hp<.5 and b.hit_count==hits and s.defeated_count==defeats,"peer nudges do little damage without player hit rewards or defeats")
 verify(s.player_hp==health,"quarrelling does not damage the player")
 b.hp=.03
 a.shove_tick123=0;a.play_clock123=1.;a._physics_process(.01)
 verify(b.hp==.03 and not b.dead,"peer damage never finishes an actor or heals a low-health one")
 var file_image := await snapshot();file_image.save_png("res://docs/captures/world_restart/outing124_shove.png")
 a.receive_hit(.1,Vector3.RIGHT)
 verify(a.play_state123=="" and a.player_breaks123==1 and a.attack_phase=="recover","player hit interrupts the quarrel and restores player-directed AI")
 b._physics_process(1./60.)
 verify(b.play_state123=="","partner stops when the other actor loses interest")
 a.peer_cooldown123=0.;b.peer_cooldown123=0.;a.begin_quarrel123(b);b.begin_quarrel123(a)
 for i in 245: a._physics_process(1./60.);b._physics_process(1./60.)
 verify(a.play_state123=="" and b.play_state123=="","quarrel expires without requiring player intervention")
 a.peer_cooldown123=0.;b.peer_cooldown123=0.;a.position=b.position+Vector3(-.80,0,0);a.attack_direction=Vector2.RIGHT;a.begin_roll123()
 a._physics_process(.1)
 verify(a.play_state123=="cheer" and b.play_state123=="cheer","rolling contact also initiates a paired quarrel")
 a.receive_hit(.01,Vector3.RIGHT);b._physics_process(1./60.)
 a.begin_roll123();a.deflect(a.position)
 verify(a.play_state123=="" and a.parry_stun>0.,"parry cancels rolling and preserves existing stun")
 a.parry_stun=0.;a.peer_cooldown123=0.;b.peer_cooldown123=0.
 var c: CharacterBody3D=s.enemies[2];c.play119();c.set_physics_process(false);c.position=b.position+Vector3(.8,0,.3)
 a.position=b.position+Vector3(-.8,0,0)
 a.begin_quarrel123(b);b.begin_quarrel123(a);c.begin_quarrel123(b)
 for i in 55: a._physics_process(1./60.);b._physics_process(1./60.);c._physics_process(1./60.)
 verify(a.play_state123=="shove" and b.play_state123=="shove" and c.play_state123=="shove","three actors can join the same shared quarrel")
 verify(a.visual.texture==a.textures.shove124 and c.visual.texture==c.textures.shove124,"shared quarrel uses the new lowered-head puffed-cheek pose")
 for actor in [a,b,c]: actor.visual.reset_physics_interpolation()
 var group_image := await snapshot();group_image.save_png("res://docs/captures/world_restart/outing124_group.png")
 a.receive_hit(.01,Vector3.RIGHT);b._physics_process(1./60.);c._physics_process(1./60.)
 verify(a.play_state123=="" and b.play_state123=="shove" and c.play_state123=="shove" and b.peer123==c,"hitting one participant leaves the remaining actors able to shove each other")
 b.clear_play123();c.clear_play123()
 a.begin_quarrel123(b);b.begin_quarrel123(a);a.receive_hit(999.,Vector3.RIGHT);b._physics_process(1./60.)
 verify(a.dead and b.play_state123=="" and a.play_state123=="","defeat releases both actors and keeps real player drops")
 a.set_physics_process(true);await settle72(45)
 verify(a.visual.texture==s.combat_textures.defeated,"defeat settles to the original art")
 a.set_process(false);a.corpse_time=a.FADE_START124+.4;a._process(.1)
 var opacity: float=a.soft_ink.get_shader_parameter("tint").a
 verify(opacity>0. and opacity<1. and a.soft_ink.shader==preload("res://scripts/combat/soft_fade124.gdshader"),"defeated art uses a blending shader with intermediate opacity")
 var fade_image := await snapshot();fade_image.save_png("res://docs/captures/world_restart/outing124_fade.png")
 s.combat_paused=true;var corpse_age: float=a.corpse_time;a._process(.2)
 verify(a.corpse_time==corpse_age,"pause freezes the longer gentle fade")
 s.combat_paused=false;a._process(2.);await settle72(2)
 verify(not is_instance_valid(a),"gentle fade removes the actor only after completion")
 # Verify concurrency without changing health or actor counts.
 s.next_attack33=0.;s.pressure124=false;b.attack_phase="windup";c.attack_phase="approach"
 verify(not s.reserve_attack(c),"baseline retains one attacker at a time")
 s.pressure124=true;s.next_attack33=0.
 verify(s.reserve_attack(c),"pressure comparison permits a second attacker")
 s.next_attack33=0.;c.attack_phase="windup"
 var d: CharacterBody3D=s.make_actor119(90,g+Vector2(4.,4.));s.enemies.append(d);d.play119();d.set_physics_process(false)
 verify(not s.reserve_attack(d),"pressure comparison still caps concurrency at two")
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
 verify(s.won119 and s.defeated_count==15,"real AI and native projectiles complete the fifteen-actor outing")
 verify(not s.combat_paused and not s.trial_ui114.menu.visible,"victory preserves natural free exploration")
 await settle72(190)
 verify(s.roamers122.size()==3 and not s.active114,"victory still spawns three peaceful visitors")
 var data := {"checks":checks,"failures":failures,"seconds":s.elapsed114}
 FileAccess.open("res://docs/outing124-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 s.home116();await settle72(3)
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("OUTING124_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)









