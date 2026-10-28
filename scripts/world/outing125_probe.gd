extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world125.gd"
 func _hero_script() -> Script: return Fighter
func run() -> void:
 var s := Sample.new();s.memory_save116="user://outing125_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.start_combat();s.hero.set_physics_process(false)
 for actor in s.enemies: actor.set_physics_process(false)
 verify(s.enemies.size()==6 and s.created120==6,"six actors start the outing")
 s.next_attack33=INF
 var free := 0
 for actor in s.enemies:
  actor.attack_phase="windup"
  if s.reserve_attack(actor): free+=1
 verify(free==6,"all six may attack despite shared cooldown and busy actors")
 s.combat_paused=true
 verify(not s.reserve_attack(s.enemies[0]),"pause still prevents attacks")
 s.combat_paused=false;s.player_hp=0.
 verify(not s.reserve_attack(s.enemies[0]),"player defeat still prevents attacks")
 s.player_hp=100.;s.active114=false
 verify(not s.reserve_attack(s.enemies[0]),"leaving combat prevents attacks")
 s.active114=true;s.enemies[0].dead=true;s.elapsed114=4.
 s._step_outing119(0.)
 verify(s.group_left120==3 and s.standby119.size()==3,"reinforcements prepare with five actors still alive")
 for i in 3: s._step_outing119(1.3)
 var alive := 0
 for actor in s.enemies:
  if is_instance_valid(actor) and not actor.dead: alive+=1
 verify(alive==8 and s.created120==9 and s.group_left120==0,"three entrants fill eight live slots without waiting for two survivors")
 s.next_join120=0.;s._step_outing119(.1)
 verify(s.group_left120==0,"eight live actors do not spawn another group")
 verify(s.enemies[1].textures.shove124==s.enemies[1].textures.idle,"original blank face remains until a candidate is chosen")
 var data := {"checks":checks,"failures":failures}
 FileAccess.open("res://docs/outing125-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 s.home116();await settle72(2);DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("OUTING125_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
