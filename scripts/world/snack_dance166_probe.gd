extends "res://scripts/world/hero_moment161_probe.gd"
class Trial166:
 extends "res://scripts/world/woodland_world166.gd"
 var stops166: Array[float]=[]
 func _hero_script() -> Script: return Walker160
 func fire_input_held() -> bool: return false
 func hitstop(duration: float,_force := false) -> void: stops166.append(duration)
func capture166(tag: String) -> void:
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/snack_dance166_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial166.new();s.memory_save116="user://snack166_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.moment161): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var grove: Vector2=s.meadow.landmarks.grove;s._teleport15(grove+Vector2(0.,4.));await settle72(8)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0;enemy.position.x+=40.
 s.set_physics_process(false);s.hero.set_physics_process(false)
 var target: CharacterBody3D=s.enemies[0];target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(0.,0.,-2.);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06;keep153(target);s.rebuild_cells110()
 verify(s.memory_kit116.owned.snack>=1 and s.memory_kit116.owned.exercise>=1,"existing fragments available for notebook trial")
 s.fire_at(target.hit_area.global_position);var parent: Dictionary=s.shots[0];var damage: float=s.damage_for_shot(parent)
 verify(not parent.get("arc166",false),"original shot remains on ordinary direct path")
 s._apply_shot_hit(parent,{"collider":target.hit_area,"position":target.hit_area.global_position,"normal":Vector3.BACK})
 s.shots.erase(parent);s.pool110.retire(parent);s._step_shots(0.)
 verify(s.shots.size()==6 and s.shots.all(func(x: Dictionary) -> bool: return x.get("arc166",false)),"real native hit creates six ballistic children")
 var child: Dictionary=s.shots[0];var origin: Vector3=child.node.position
 verify(is_equal_approx(s.damage_for_shot(child),damage*.5) and child.ignore_rids110.has(target.hit_area.get_rid()),"child retains half damage and excludes original target")
 target.hit_area.collision_layer=0
 s._step_shots(.08)
 verify(child.node.position.y>origin.y and child.velocity.y<2.6,"ballistic child rises while gravity reduces upward speed")
 await capture166("short_arc")
 var maximum := 0.
 for i in 160:
  for shot in s.shots:
   if shot.get("arc166",false): maximum=maxf(maximum,Vector2(shot.node.position.x-shot.arc_origin166.x,shot.node.position.z-shot.arc_origin166.z).length())
  s._step_shots(1./120.)
 verify(s.shots.is_empty() and maximum<2.1,"tracking cannot straighten fragments or extend them beyond local splash radius")
 s.buffs.levels.erase("eye_exercise");var normal: Dictionary=s.data_shot110(s.hero.position+Vector3.UP*1.,Vector3.RIGHT*3.,1.)
 s._step_shots(.05);verify(is_equal_approx(normal.velocity.y,0.),"ordinary projectiles do not inherit gravity")
 s._clear_combat_shots();s.build166=6;s.apply_paper_build129()
 s.pending_splits110.append({"at":s.hero.position+Vector3(0.,1.,-1.),"damage":3.,"depth":2,"rid":target.hit_area.get_rid(),"velocity111":Vector3.RIGHT*12.})
 s._step_shots(0.)
 verify(s.shots.size()==4 and s.shots.all(func(x: Dictionary) -> bool: return x.arc166 and x.split_depth110==2),"second split generation also uses short parabola")
 s._clear_combat_shots();s.build166=2;s.apply_paper_build129()
 s.pending_splits110.append({"at":s.hero.position+Vector3(0.,2.5,-1.),"damage":4.,"depth":1,"rid":target.hit_area.get_rid(),"velocity111":Vector3.RIGHT*12.,"sword153":true})
 s._step_shots(0.)
 verify(s.shots.all(func(x: Dictionary) -> bool: return x.arc166 and x.sword153 and is_equal_approx(s.damage_for_shot(x),4.)),"airborne sword fragments preserve identity and budget once")
 s._clear_combat_shots();s.build166=4;s.apply_paper_build129()
 target.hit_area.collision_layer=8;target.position=s.hero.position+Vector3(.7,0.,0.);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06;target.impulse=Vector2.ZERO;keep153(target);s.rebuild_cells110()
 var hp: float=target.hp;var exercise_damage: float=s.projectile_damage()*.2
 s.hero.dash_cd=0.;s.hero.guarding109=false
 verify(s.hero.request_dash(Vector2.RIGHT),"real dash controller starts dance")
 s.skills110.step110(.016)
 verify(is_equal_approx(hp-target.hp,exercise_damage) and s.skills110.dance_events166==1,"dash applies original twenty-percent damage once and schedules one visual triple")
 s.skills110.step110(.09);s.skills110.step110(.02)
 verify(is_equal_approx(hp-target.hp,exercise_damage) and s.skills110.dance_events166==1,"three visual beats do not multiply damage or repeat contact")
 verify(s.stops166.count(.035)==1,"short hitstop triggers once per dash")
 await capture166("ribbon_star_combo")
 s.combat_paused=true;var age: float=s.skills110.dance166[0].age;s.skills110.step110(.4)
 verify(s.skills110.dance166[0].age==age,"pause freezes dance beats")
 s.combat_paused=false;s.hero.dash_left=0.;s.skills110.step110(.5)
 verify(s.skills110.dance166.is_empty(),"finished effects release their target references")
 s.hero.dash_cd=0.;s.hero.request_dash(Vector2.RIGHT);s.skills110.step110(.016)
 verify(s.skills110.dance_events166==2 and is_equal_approx(hp-target.hp,exercise_damage*2.),"next dash can hit same target again normally")
 s.skills110.reset110();verify(s.skills110.dance166.is_empty(),"encounter cleanup clears dance effects")
 s.hero.dash_left=0.;s.hero.set_physics_process(true);s.set_physics_process(true)
 await key153(KEY_F4);await settle72(3);disable_enemies(s);await key153(KEY_2)
 verify(s.paper_trial129 and s.build166==1 and s.buffs.level("paper_plane")==1,"paper encounter and fragment-plane preset input work")
 await key153(KEY_F5);await settle72(3);disable_enemies(s);await key153(KEY_6)
 verify(not s.paper_trial129 and s.buffs.level("snack")==0,"Tuantuan direct-shot comparison remains available")
 var report := {"checks":checks,"failures":failures,"maximum_fragment_range":maximum,"note":"Targeted fragment physics, native split inheritance, original dash damage and new visual beats; goose card values unchanged."}
 FileAccess.open("res://docs/snack-dance166-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("SNACK166_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
