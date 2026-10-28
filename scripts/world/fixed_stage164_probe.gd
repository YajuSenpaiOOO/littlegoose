extends "res://scripts/world/hero_moment161_probe.gd"
class Trial164:
 extends "res://scripts/world/woodland_world164.gd"
 func _hero_script() -> Script: return Walker160
 func fire_input_held() -> bool: return false
func capture164(tag: String) -> void:
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/fixed_stage164_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial164.new();s.memory_save116="user://field164_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.moment161): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var grove: Vector2=s.meadow.landmarks.grove;s._teleport15(grove+Vector2(0.,4.));await settle72(8)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 s.set_physics_process(false);s.hero.set_physics_process(false)
 var field: Node=s.moment161;field.set_process(false)
 var base_rate: float=s.attack_cooldown();var aim: Vector3=s.projectile_origin()+Vector3.FORWARD*4.
 s.fire_at(aim);var base_damage: float=s.damage_for_shot(s.shots[-1])
 await key153(KEY_Q);field.step161(.8);field._process(.8)
 verify(field.running161() and is_equal_approx(s.attack_cooldown(),base_rate*.5),"physical Q grants double fire rate inside fixed field")
 s.fire_at(aim);var inside_shot: Dictionary=s.shots[-1]
 verify(is_equal_approx(s.damage_for_shot(inside_shot),base_damage*1.3),"inside launch gains thirty-percent damage")
 verify(field.props164.size()==5 and field.ground164.mesh.get_surface_count()==1,"fixed stage has five world props and a real terrain-following surface")
 var anchor: Vector3=field.anchor164;var pole: Sprite3D=field.props164[0].pole;var position: Vector3=pole.global_position
 verify(absf(position.y-s.floor_height(Vector2(position.x,position.z))-.035)<.001,"pinwheel stem is planted on actual floor")
 var shadow_count := 0
 for prop in field.props164:
  shadow_count+=prop.pole.get_child_count()+prop.rotor.get_child_count()
 verify(shadow_count==10,"all five stems and rotors have grounded silhouette projectors")
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look();await capture164("inside_day")
 s.hero.position=anchor+Vector3(field.RADIUS164-.6,.04,0.);s.hero.position.y=s.floor_height(Vector2(s.hero.position.x,s.hero.position.z))+.06;s.hero.reset_physics_interpolation();field.step161(.1);field._process(.1)
 verify(field.running161() and field.anchor164==anchor and pole.global_position==position,"moving within large field does not move its centre or props")
 s.hero.position=anchor+Vector3(field.RADIUS164+.4,.04,0.);s.hero.position.y=s.floor_height(Vector2(s.hero.position.x,s.hero.position.z))+.06;s.hero.reset_physics_interpolation();field.step161(.1);field._process(.1)
 verify(not field.running161() and is_equal_approx(s.attack_cooldown(),base_rate) and field.left161>0.,"outside field removes rate bonus without removing the field")
 s.fire_at(aim);verify(is_equal_approx(s.damage_for_shot(s.shots[-1]),base_damage),"outside launch has no damage bonus")
 verify(is_equal_approx(s.damage_for_shot(inside_shot),base_damage*1.3),"previously launched empowered bullets retain their snapshot outside")
 verify(field.anchor164==anchor and pole.global_position==position,"leaving keeps all decorations fixed in world")
 await capture164("outside_day")
 s.hero.position=anchor+Vector3(0,.04,0);s.hero.reset_physics_interpolation();var life: float=field.left161;field.step161(.1);field._process(.1)
 verify(field.running161() and field.left161<life and is_equal_approx(s.attack_cooldown(),base_rate*.5),"returning restores bonus without refreshing timer")
 s.hero.position.y=anchor.y-2.;field.step161(0.)
 verify(not field.running161(),"another floor beneath the circle does not receive field buff")
 s.hero.position.y=anchor.y+.04;field.step161(0.)
 s.time55.preview_at(22.);s.time55.visual_hour=22.;s.time55.apply_look();field._process(.1);await capture164("inside_night")
 verify(s.time55.visual_hour==22.,"fixed peach field leaves global night clock untouched")
 s.combat_paused=true;var turn: float=field.props164[0].turn;var left: float=field.left161;field.step161(.5);field._process(.5)
 verify(field.left161==left and field.props164[0].turn==turn,"pause freezes field timer and rotor")
 s.combat_paused=false;field.step161(8.);field._process(.01)
 verify(not field.running161() and field.cooldown161==20. and s.buffs.moment_rate161==1.,"expiration removes buffs and begins full cooldown")
 field.step161(.7);field._process(.01);verify(not field.root164.visible,"props and terrain surface disappear after exit fade")
 field.reset161();verify(not field.root164.visible and field.cooldown161==0.,"cleanup clears fixed field and timers")
 var actors: int=s.actor_shadows.size();field.request161();field.reset161();field.request161()
 verify(s.actor_shadows.size()==actors,"repeated casts reuse props and shadows rather than accumulating projectors")
 s.build161=2;s.apply_paper_build129();var packet0: Dictionary=s.snapshot_packet146(aim,false,0.,true)
 field.request161();var packet1: Dictionary=s.snapshot_packet146(aim,false,0.,true)
 verify(packet1.specs[0].sword153 and is_equal_approx(packet1.specs[0].damage,packet0.specs[0].damage*1.3),"sword-airplane payload preserves original budget with single field multiplier")
 var report := {"checks":checks,"failures":failures,"radius":6.5,"rate_multiplier":2.,"note":"Fixed field membership, real shots/packets, grounded props and lifecycle only; not a final balance verdict."}
 FileAccess.open("res://docs/fixed-stage164-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("FIELD164_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
