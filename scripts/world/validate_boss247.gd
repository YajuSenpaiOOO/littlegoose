extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world247.tscn").instantiate();root.add_child(w);current_scene=w
 var deadline=Time.get_ticks_msec()+240000
 while not w.ready247 and Time.get_ticks_msec()<deadline:await process_frame
 if not w.ready247:check(false,"initialization deadline");finish247();return
 var b=w.boss247
 w.auto114=false;w.invulnerability=10000.;w.hero.set_physics_process(false);b.set_physics_process(false)
 var progress={"next":w.memory_kit116.next_event119,"gel":w.memory_kit116.gel119,"reward":w.memory_kit116.last_reward119}
 check(w.active114 and w.enemies.size()==1 and w.trial152,"single boss reward-free trial")
 check(b.body_scale110==1.65 and b.max_hp110==90.,"independent prototype body and HP")
 check(not is_instance_valid(b.flower110) or b.flower110.is_queued_for_deletion(),"no legacy boss flower")
 b.enter247("squat");b._physics_process(.4)
 var clock=b.clock247;var at=b.position;w.combat_paused=true;b._physics_process(.5)
 check(b.clock247==clock and b.position==at,"pause freezes timing and movement")
 w.combat_paused=false;b.enter247("squat")
 for i in 52:b._physics_process(1./60.)
 check(b.phase247=="flight" and b.jump247==0,"squat starts first flight")
 var goal=b.goal247
 w.hero.position+=Vector3(2.,0,0);b._physics_process(.1)
 check(b.goal247==goal,"moving player cannot steer committed flight")
 check(absf(b.hit_area.position.y-(.8*b.body_scale110+b.lift247))<.001,"native target follows visible flight height")
 await shot("boss247-air")
 b.landings247.clear();b.flights247.clear();b.enter247("squat")
 for i in 200:b._physics_process(1./60.)
 check(b.landings247.size()==3,"exactly three landings")
 check(b.phase247=="flat","third landing exposes long recovery")
 check(b.HEIGHTS247[0]>b.HEIGHTS247[1] and b.HEIGHTS247[1]>b.HEIGHTS247[2],"bounce heights decay")
 check(b.TIMES247[0]>b.TIMES247[1] and b.TIMES247[1]>b.TIMES247[2],"bounce intervals shorten")
 check(not b.marker247.visible,"landing marker clears in recovery")
 check(b.visual.scale.y<b.visual.scale.x,"flat recovery visibly squashes body")
 await shot("boss247-flat")
 # Native firing path, static grounded target, clear sight line selected from map.
 b.enter247("rest");b.render247();w.build247=0;w.apply_paper_build129()
 var found=false
 for dir in [Vector2.LEFT,Vector2.RIGHT,Vector2.DOWN,Vector2.UP]:
  var spot=Vector2(b.position.x,b.position.z)+dir*3.
  var start=Vector3(spot.x,w.floor_height(spot)+.65,spot.y)
  if w.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start,b.hit_area.global_position,1|2,[w.hero.get_rid()])).is_empty():w._teleport15(spot);found=true;break
 check(found,"clear real map projectile line")
 await settle()
 var hp=b.hp
 for i in 8:
  w.fire_needs_release=false;w.cooldown=0.;w.fire_at(b.hit_area.global_position);await create_timer(.15).timeout
 await create_timer(.5).timeout
 check(b.hp<hp,"native ordinary projectiles damage boss")
 w._clear_combat_shots();b.enter247("flight");b.jump247=0;w.hero.position=b.position;w.invulnerability=0.;w.hero.dodge_invulnerability=0.;w.hero.parry_t=0.;w.hero.guarding109=false
 hp=w.player_hp;b.land247()
 check(w.player_hp<hp,"landing footprint causes native damage")
 w.invulnerability=0.;w.hero.dodge_invulnerability=.3;hp=w.player_hp;b.enter247("flight");b.land247()
 check(w.player_hp==hp,"landing respects dodge invulnerability")
 w.hero.dodge_invulnerability=0.;w.hero.parry_t=.15;w.hero.parried=false;b.enter247("flight");var parries=b.parried_count;b.land247()
 check(b.phase247=="flat" and b.parried_count>parries,"landing parry cancels chain into flat recovery")
 w.hero.cancel_guard109();w.finish247(false)
 check(not w.active114 and w.wave_state=="waiting" and not b.marker247.visible,"stop clears encounter and marker")
 w.begin247();b=w.boss247;b.set_physics_process(false)
 check(w.enemies.size()==1 and w.active114,"restart replaces rather than duplicates boss")
 check(w.memory_kit116.next_event119==progress.next and w.memory_kit116.gel119==progress.gel and w.memory_kit116.last_reward119==progress.reward,"restart leaves formal materials and progress untouched")
 b.receive_hit(10000.,Vector3.RIGHT);await process_frame;await process_frame
 check(not w.active114 and b.dead and b.hit_area.collision_layer==0,"defeat ends without respawn or reward screen")
 await create_timer(1.1).timeout
 check(w.enemies.size()==1 and not w.active114,"victory cannot summon legacy reinforcements")
 await shot("boss247-ended")
 finish247()
func finish247() -> void:
 var ok=checks.all(func(c):return c.pass)
 var file=FileAccess.open("res://docs/boss247-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));file.close()
 print("BOSS247_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
