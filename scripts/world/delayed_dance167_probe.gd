extends "res://scripts/world/hero_moment161_probe.gd"
class Trial167:
 extends "res://scripts/world/woodland_world167.gd"
 var stops167: Array[float]=[]
 func _hero_script() -> Script: return Walker160
 func fire_input_held() -> bool: return false
 func hitstop(duration: float,_force := false) -> void: stops167.append(duration)
func capture167(tag: String) -> void:
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/delayed_dance167_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial167.new();s.memory_save116="user://dance167_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.arc_shadows167): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var grove: Vector2=s.meadow.landmarks.grove;s._teleport15(grove+Vector2(0.,4.));await settle72(8)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0;enemy.position.x+=40.
 s.set_physics_process(false);s.hero.set_physics_process(false);s.build166=4;s.apply_paper_build129()
 var target: CharacterBody3D=s.enemies[0];target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(.7,0.,0.);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06;keep153(target);s.rebuild_cells110()
 var skill: Node2D=s.skills110;var hp: float=target.hp;var damage: float=s.projectile_damage()*.2
 s.hero.dash_cd=0.;s.hero.guarding109=false;s.hero.request_dash(Vector2.RIGHT);skill.step110(.016)
 verify(target.hp==hp and skill.marks167.size()==1,"real dash marks target without immediate damage")
 skill.step110(.1)
 verify(target.hp==hp and skill.marks167.size()==1 and not skill.marks167[0].released,"same dash cannot duplicate marks and damage waits for dash completion")
 await capture167("marked_during_dash")
 s.hero.dash_left=0.;s.hero.position.x-=2.;s.hero.reset_physics_interpolation();skill.step110(.05)
 verify(target.hp==hp and skill.marks167[0].released,"after dash ends a brief delay remains even if player has moved away")
 skill.step110(.06)
 verify(is_equal_approx(hp-target.hp,damage/3.) and skill.pulses167==1,"first delayed beat applies one third of original damage")
 var impulse := Vector2(.8,.4);target.impulse=impulse;target.position.z-=.5;skill.step110(.16)
 verify(is_equal_approx(hp-target.hp,damage*2./3.) and target.impulse==impulse,"second beat follows moving target without extra knockback")
 await capture167("lingering_two_beats")
 s.combat_paused=true;var age: float=skill.marks167[0].age;skill.step110(.5)
 verify(skill.marks167[0].age==age and skill.pulses167==2,"pause freezes pending pulses and damage")
 s.combat_paused=false;skill.step110(.15)
 verify(is_equal_approx(hp-target.hp,damage) and skill.pulses167==3,"three delayed beats sum to exactly original twenty-percent damage")
 verify(s.stops167.count(.035)==1,"delayed combo uses one short hitstop per dash")
 skill.step110(.5);verify(skill.marks167.is_empty(),"finished marks release targets")
 s.hero.position=target.position-Vector3(.7,0.,0.);s.hero.dash_cd=0.;s.hero.request_dash(Vector2.RIGHT);s.rebuild_cells110();skill.step110(.016)
 target.dead=true;s.hero.dash_left=0.;var dead_hp: float=target.hp;skill.step110(.5)
 verify(target.hp==dead_hp and skill.marks167.is_empty(),"dead target cancels remaining delayed damage safely")
 target.dead=false;s.hero.dash_cd=0.;s.hero.request_dash(Vector2.RIGHT);skill.step110(.016);s._clear_combat_shots()
 verify(skill.marks167.is_empty(),"build cleanup cancels scheduled damage")
 s.build166=0;s.apply_paper_build129();target.hit_area.collision_layer=0
 var at: Vector3=s.hero.position+Vector3(0.,1.1,-.5)
 var shot: Dictionary=s.data_shot110(at,Vector3.RIGHT*3.,1.)
 shot.split_depth110=1;shot.fixed_damage110=2.;s.inherit_split153(shot,{"rid":target.hit_area.get_rid(),"sword153":false})
 await process_frame;await process_frame
 s._draw_projectile_shadows105()
 verify(s.arc_shadow_count167==1 and s.arc_shadows167.multimesh.visible_instance_count==1,"fragment has its own visible ground shadow batch")
 var projected: Vector3=s.arc_shadows167.multimesh.get_instance_transform(0).origin
 verify(absf(projected.y-s.floor_height(Vector2(projected.x,projected.z))-.045)<.003,"shadow rests on sampled terrain beneath airborne crumb")
 await capture167("crumb_ground_shadow")
 var first := projected;s._step_shots(.06);s._step_shots(.06)
 await process_frame;await process_frame
 s._draw_projectile_shadows105();var moved: Vector3=s.arc_shadows167.multimesh.get_instance_transform(0).origin
 verify(s.arc_shadow_count167==1 and moved.distance_to(first)>.01,"shadow follows crumb horizontal motion while remaining on ground")
 s._clear_combat_shots();verify(s.arc_shadows167.multimesh.visible_instance_count==0,"clearing fragments also clears shadow instances")
 var report := {"checks":checks,"failures":failures,"note":"Targeted delayed damage timing, exact total, cancellation, and real fragment ground projection; goose values unchanged."}
 FileAccess.open("res://docs/delayed-dance167-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("DANCE167_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
