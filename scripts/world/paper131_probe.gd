extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world131.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://paper131_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 var a: CharacterBody3D=s.enemies[0]
 for other in s.enemies:
  if other!=a: other.hide();other.collision_layer=0;other.hit_area.collision_layer=0
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0.,2.))
 var connected := 0;var repeated := false
 for offset in [Vector2(-2.5,-.5),Vector2(3.4,-1.),Vector2(-1.,-4.4)]:
  a.play119();a.set_physics_process(true);a.position=Vector3(s.hero.position.x+offset.x,s.floor_height(Vector2(s.hero.position.x+offset.x,s.hero.position.z+offset.y))+.05,s.hero.position.z+offset.y)
  a.paper_state129="warning";a.paper_clock129=.60;a.locked130=Vector2(s.hero.position.x,s.hero.position.z);a.paper_lift129=1.4;a.drift130=Vector2.ZERO
  s.invulnerability=0.;s.player_hp=100.;var hits: int=s.hurt_count
  await settle72(115)
  if s.hurt_count>hits: connected+=1
  if s.hurt_count-hits>1: repeated=true
  a.set_physics_process(false)
 verify(connected==3,"three real curved gusts from different directions hit a stationary player")
 verify(not repeated,"a gust damages the player at most once")
 a.paper_state129="drift";a.air_clock131=0.;a.drift130=Vector2.ZERO;a.paper_lift129=1.5;a._render_legacy(1.5)
 var centre: Vector3=a.hit_area.global_position
 verify(a.air_threat131(centre-Vector3.RIGHT*1.5,Vector3.RIGHT*10.),"incoming projectile airflow is detected before impact")
 verify(not a.air_threat131(centre-Vector3.RIGHT*1.5,Vector3.RIGHT*10.),"airflow cooldown prevents repeated evasions")
 a.air_clock131=0.;a.paper_state129="coast"
 verify(not a.air_threat131(centre-Vector3.RIGHT*1.5,Vector3.RIGHT*10.),"post-gust coasting is an exposed window")
 a.paper_state129="warning"
 verify(not a.air_threat131(centre-Vector3.RIGHT*1.5,Vector3.RIGHT*10.),"the attack warning cannot chain air dodges")
 a.paper_state129="drift";a.air_clock131=0.
 verify(not a.air_threat131(centre+Vector3.RIGHT*1.5,Vector3.RIGHT*10.),"bullets moving away do not cause evasions")
 a.position=Vector3(s.hero.position.x,s.floor_height(Vector2(s.hero.position.x,s.hero.position.z-3.))+.05,s.hero.position.z-3.);a.hp=100.;a.max_hp110=100.;a.paper_lift129=1.45;a.gust_wait130=99.;a.drift130=Vector2.ZERO;a.air_count131=0;a.air_age131=1.;a._render_legacy(1.45);a.set_physics_process(true)
 s.paper_build129=0;s.apply_paper_build129();var fire := 0.
 for i in 150:
  await physics_frame
  fire-=1./60.
  if fire<=0.:
   s.fire_at(a.hit_area.global_position+a.velocity*.1);fire=.34
 verify(a.air_count131>0,"real native projectiles trigger visible airflow reactions")
 verify(a.hp<100.,"ordinary sustained fire still hits instead of being permanently evaded")
 verify(a.hit_area.position.y>1.0,"aim and hurt volume remain linked while paper floats higher")
 a.set_physics_process(false);a.paper_state129="drift";a.air_clock131=0.;a.air_threat131(a.hit_area.global_position-Vector3.RIGHT*1.5,Vector3.RIGHT*10.);a._physics_process(.1)
 a.visual.reset_physics_interpolation();var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper131_airflow.png")
 s.paper_count131=10;s.start_combat();disable_enemies(s)
 verify(s.enemies.size()==10 and s.total_enemies==10,"optional density comparison starts ten paper actors")
 for i in 6: s.enemies[i].receive_hit(999.,Vector3.RIGHT)
 verify(s.active114 and s.ending119<0.,"ten-paper encounter does not finish after only six defeats")
 for i in range(6,10): s.enemies[i].receive_hit(999.,Vector3.RIGHT)
 await settle72(45)
 verify(s.won119 and not s.active114,"ten-paper encounter ends after all ten defeats")
 s.home116();await settle72(2)
 var data := {"checks":checks,"failures":failures,"stationary_hits":connected}
 FileAccess.open("res://docs/paper131-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER131_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
