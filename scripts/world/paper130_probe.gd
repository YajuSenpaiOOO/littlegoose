extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world130.gd"
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if player_hp>0.: player_hp=100.
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://paper130_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 var a: CharacterBody3D=s.enemies[0]
 for other in s.enemies:
  if other!=a: other.hide();other.collision_layer=0;other.hit_area.collision_layer=0
 var g: Vector2=s.meadow.landmarks.grove
 s._teleport15(g+Vector2(0.,3.));a.position=Vector3(g.x,s.floor_height(g)+.05,g.y)
 a.play119();a.gust_wait130=99.;a.set_physics_process(true)
 var speeds := [];var lifts := [];var acceleration := 0.;var previous: Vector2=a.drift130
 for i in 150:
  await physics_frame
  speeds.append(a.drift130.length());lifts.append(a.paper_lift129)
  acceleration=maxf(acceleration,(a.drift130-previous).length());previous=a.drift130
 verify(float(speeds.max())-float(speeds.min())>.2,"continuous wind produces changing drift speeds")
 verify(acceleration<.035,"ordinary drift changes velocity gradually rather than snapping")
 verify(float(lifts.min())>.12 and float(lifts.max())-float(lifts.min())>.08,"paper stays airborne with a continuous changing height")
 a.set_physics_process(false);var before: Vector3=a.position;var clock: float=a.paper_clock129
 s.combat_paused=true;a._physics_process(.2)
 verify(a.position==before and a.paper_clock129==clock,"pause freezes wind motion and attack timing")
 s.combat_paused=false
 a.position=Vector3(g.x-2.5,s.floor_height(g+Vector2(-2.5,0))+.05,g.y)
 a.drift130=Vector2.ZERO;a.paper_state129="drift";a.gust_wait130=0.;a._physics_process(1./60.)
 verify(a.paper_state129=="warning","a gust has a separate visible warning before attacking")
 a.set_physics_process(true)
 var states := {};var deviation := 0.;var locked: Vector2=a.locked130
 for i in 110:
  await physics_frame;states[a.paper_state129]=true
  if a.paper_state129=="gust":
   var axis: Vector2=(a.curve_c130-a.curve_a130).normalized()
   deviation=maxf(deviation,absf((Vector2(a.position.x,a.position.z)-a.curve_a130).cross(axis)))
 verify(states.has("gust") and states.has("coast") and deviation>.12,"the real actor follows a curved gust and then coasts")
 verify(a.locked130==locked,"the attack does not retarget the player during its gust")
 a.set_physics_process(false);a.paper_state129="drift";a.paper_lift129=.95;a.velocity=Vector3.ZERO;a.hp=100.;a.max_hp110=100.
 a.position=Vector3(s.hero.position.x,s.floor_height(Vector2(s.hero.position.x,s.hero.position.z-3.))+.05,s.hero.position.z-3.);a._render_legacy(.95)
 verify(absf(a.hit_area.position.y-1.67)<.001,"hurt capsule follows the visible high paper")
 s._steering_snapshot113();var index: int=s.steering_indices113[a]
 verify(absf(s.steering_positions113[index].y-a.position.y-.95)<.001,"tracking uses the floating height as well")
 s.paper_build129=0;s.apply_paper_build129();var hp: float=a.hp;s.fire_at(a.hit_area.global_position);await settle72(45)
 verify(a.hp<hp,"a native ordinary projectile hits the high floating paper")
 s.paper_build129=1;s.apply_paper_build129();hp=a.hp;s._release_charged(a.hit_area.global_position,1.);await settle72(45)
 verify(a.hp<hp,"a native charged projectile also hits the high floating paper")
 a.paper_state129="warning";a.paper_clock129=.3;a._render_legacy(.7);a.visual.reset_physics_interpolation()
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper130_wind.png")
 s.home116();await settle72(2)
 var data := {"checks":checks,"failures":failures,"max_velocity_change":acceleration,"gust_deviation":deviation,"states":states.keys()}
 FileAccess.open("res://docs/paper130-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("PAPER130_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
