extends "res://scripts/world/balloon_sword158_probe.gd"
func visible_target158(s: Node3D) -> CharacterBody3D:
 var chosen: CharacterBody3D;var best := INF
 var origin: Vector3=s.projectile_origin()
 for enemy in s.enemies:
  if not is_instance_valid(enemy) or enemy.dead: continue
  var centre: Vector3=enemy.hit_area.global_position
  var query := PhysicsRayQueryParameters3D.create(origin,centre,1|2,[s.hero.get_rid()])
  if not s.get_world_3d().direct_space_state.intersect_ray(query).is_empty(): continue
  var distance := origin.distance_squared_to(centre)
  if distance<best: best=distance;chosen=enemy
 return chosen
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial158.new();s.memory_save116="user://sword158_live_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.swords153): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=true;s.start_combat();s.hero.controls_enabled=true
 s._teleport15(Vector2(s.meadow.landmarks.grove)+s.HILL136.CENTER+Vector2(-2.,0.));await settle72(10)
 s.build153=2;s.apply_paper_build129()
 for enemy in s.enemies: enemy.hp=1000.;enemy.max_hp110=1000.
 var m: Node3D=s.swords153;var captured := false
 for i in 180:
  if i%14==0:
   var target := visible_target158(s)
   if is_instance_valid(target): s.fire_at(target.hit_area.global_position)
  await settle72(1)
  if not captured and not m.contact158.events158.is_empty():
   await capture158("live_paper_pop");captured=true
 verify(s.hits152>0 and m.contact158.played158>0,"new A sword, comic pop and slime atlas actually damage live wind-drifting paper AI")
 verify(m.contact158.gel_art158.size()==3 and m.contact158.voices158.size()==3,"gel particles reuse three existing atlas sprites with three bounded spatial pop voices")
 s.build153=1;s.apply_paper_build129()
 for i in 240:
  if i%72==0:
   var target := visible_target158(s)
   if is_instance_valid(target): s.aim158=target.hit_area.global_position;s.fire_at(s.aim158)
  await settle72(1)
 await capture158("live_paper_rain")
 verify(s.hits152>0 and not m.resting153.is_empty() and m.contact158.events158.size()<=24,"live six-drop plane delivery damages moving paper while retaining bounded effects and independent gel adhesion")
 FileAccess.open("res://docs/balloon-sword158-live-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"pops":m.contact158.played158,"plane_hits":s.hits152},"\t"))
 print("BALLOON_SWORD158_LIVE_DONE checks=",checks," failures=",failures);quit(0 if failures.is_empty() else 1)
