extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world129.gd"
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if player_hp>0.: player_hp=100.
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://paper129_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 var amount: int=s.memory_kit116.gel119;var event: int=s.memory_kit116.next_event119
 s.paper_trial129=true;s.start_combat();s.hero.set_physics_process(false)
 verify(s.enemies.size()==6 and s.total_enemies==6,"paper trial contains six paper actors without mixed encounters")
 verify(s.enemies[0].visual.texture.resource_path.ends_with("scrap.svg"),"the prototype has its own paper appearance")
 verify(s.memory_kit116.gel119==amount and s.memory_kit116.next_event119==event and not FileAccess.file_exists(s.memory_save116),"practice does not consume material or persist an event to the player save")
 disable_enemies(s)
 var a: CharacterBody3D=s.enemies[0];a.play119();a.set_physics_process(true)
 var states := {}
 for i in 220:
  await physics_frame
  states[a.paper_state129]=true
 verify(states.has("float") and states.has("settle") and states.has("windup") and states.has("swoop"),"actual AI cycles through floating, a stable window and a telegraphed swoop")
 a.set_physics_process(false);a.curl_gate129=0.;var juice: int=s.jelly_fx.drops.size()
 a.receive_hit(.1,Vector3.RIGHT)
 verify(a.curl_left129>0. and a.impulse.length()<=.851,"a hit causes a short bounded paper flutter")
 var kick: Vector2=a.impulse;a.receive_hit(.1,Vector3.RIGHT)
 verify(a.impulse==kick and s.jelly_fx.drops.size()==juice,"repeated hits do not stack blowback or spray jelly juice")
 s.paper_build129=1;s.apply_paper_build129()
 verify(s.buffs.level("slingshot")==1 and s.buffs.level("snack")==0,"slingshot trial build is available without crafting")
 s.paper_build129=2;s.apply_paper_build129()
 verify(s.buffs.level("snack")==1 and s.buffs.level("slingshot")==0,"switching to split shots clears the previous build")
 s.paper_build129=3;s.apply_paper_build129()
 verify(s.buffs.level("eye_exercise")==1 and s.memory_kit116.gel119==amount,"tracking build also leaves persistent materials untouched")
 s.paper_build129=0;s.apply_paper_build129()
 a.hp=100.;a.max_hp110=100.;a.impulse=Vector2.ZERO
 s._teleport15(s.meadow.landmarks.grove+Vector2(0.,3.));await settle72(15)
 a.position=Vector3(s.hero.position.x,s.floor_height(Vector2(s.hero.position.x,s.hero.position.z-3.))+.05,s.hero.position.z-3.)
 a._render_legacy(.15);var before: float=a.hp
 s.fire_at(a.hit_area.global_position)
 await settle72(45)
 verify(a.hp<before,"native ordinary projectile can hit the paper actor")
 a._render_legacy(.25);a.visual.reset_physics_interpolation()
 var shot := await snapshot();shot.save_png("res://docs/captures/world_restart/paper129_trial.png")
 for actor in s.enemies:
  if not actor.dead: actor.receive_hit(999.,Vector3.RIGHT)
 await settle72(50)
 verify(s.won119 and not s.active114 and s.roam_left122==0 and s.roamers122.is_empty(),"paper trial ends naturally without spawning tuantuan visitors")
 verify(s.memory_kit116.gel119==amount and s.dropped120.is_empty(),"paper trial has no gel reward or material drops")
 s.paper_trial129=false;s.start_combat();disable_enemies(s)
 verify(s.enemies.size()==6 and s.enemies[0].get_script().resource_path.ends_with("tuantuan128.gd"),"the original fixed tuantuan encounter remains separately available")
 s.home116();await settle72(2)
 var data := {"checks":checks,"failures":failures,"states":states.keys()}
 FileAccess.open("res://docs/paper129-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("PAPER129_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
