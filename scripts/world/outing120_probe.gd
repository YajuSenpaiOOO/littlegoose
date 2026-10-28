extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world120.gd"
 func _hero_script() -> Script: return Fighter
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if player_hp>0.: player_hp=100.
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var s := Sample.new();s.memory_save116="user://outing120_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 await settle72(5);s.start_combat();s.rng120.seed=120003;disable_enemies(s);s.hero.set_physics_process(false)
 verify(s.total_enemies==15 and s.enemies.size()==3,"longer outing has fifteen total actors and three opening actors")
 var actor: CharacterBody3D=s.enemies[0]
 actor.receive_hit(1.,Vector3.RIGHT)
 verify(s.dropped120.is_empty() and s.drops120.items120.is_empty(),"nonlethal hits never roll or spawn a drop")
 actor.receive_hit(999.,Vector3.RIGHT);var drops_before: int=s.drops120.items120.size();s.defeat_drop120(actor)
 verify(s.dropped120.size()==1 and s.drops120.items120.size()==drops_before,"defeat rolls exactly once even if the callback repeats")
 s.drops120.clear120()
 var g: Vector3=s.hero.position;var at := g+Vector3(3.,.8,0.)
 s.drops120.spawn120(at,Vector3(.2,3.,0));await settle72(12)
 verify(s.drops120.items120.size()==1 and s.drops120.items120[0].root.position.y>at.y,"a loose collectible visibly launches upward")
 var count: int=s.drops120.items120.size();var pos: Vector3=s.drops120.items120[0].root.position
 s.combat_paused=true;await settle72(5)
 verify(s.drops120.items120.size()==count and s.drops120.items120[0].root.position==pos,"pause freezes collectible motion")
 s.combat_paused=false;await settle72(90)
 verify(s.drops120.items120[0].bounces==2,"the collectible lands and rebounds twice before hovering")
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/outing120_drop.png")
 var item: Dictionary=s.drops120.items120[0];s._teleport15(Vector2(item.root.position.x,item.root.position.z));await settle72(30)
 verify(s.drops120.items120.is_empty() and s.memory_kit116.gel119==1,"approaching attracts and picks up the collectible into actual inventory")
 var restored := preload("res://scripts/combat/memory_kit119.gd").new();restored.load_from(s.memory_save116)
 verify(restored.gel119==1,"picked materials are saved before the performance ends")
 s.finish114();s.home116();verify(s.memory_kit116.gel119==1,"retreat keeps already collected materials without a completion bundle")
 s.start_combat();s.hero.set_physics_process(false);s.rng120.seed=120500
 var fire_clock := 0.;var max_alive := 0;var joined_seen := false
 for i in 4800:
  await physics_frame
  if not s.active114: break
  var alive := 0
  for other in s.enemies:
   if not other.dead: alive+=1
  max_alive=maxi(max_alive,alive)
  if s.created120>3: joined_seen=true
  fire_clock-=1./60.
  if fire_clock>0. or s.combat_paused: continue
  for other in s.enemies:
   if not other.dead and s._visible114(other,s.projectile_origin()):
    var cursor: Vector2=s.camera.unproject_position(other.hit_area.global_position);root.warp_mouse(cursor);s.aim_tick114=-1;s.fire_at(s.aim_at_screen(cursor));fire_clock=.34;break
 verify(s.won119 and s.defeated_count==15,"real AI and normal native basic shots complete all fifteen participants")
 verify(joined_seen and max_alive<=5,"multiple arriving groups keep no more than five active actors")
 verify(s.elapsed114>=24. and s.elapsed114<80.,"natural basic-shot playthrough lasts longer than a few seconds and still ends")
 verify(s.dropped120.size()==15,"each of the fifteen defeated actors receives exactly one probability roll")
 var amount: int=s.memory_kit116.gel119;var collected: int=s.drops120.picked120
 verify(amount==1+collected and s.drops120.items120.is_empty(),"ending gathers remaining loose drops and grants no extra fixed material bundle")
 s.retry_reward119();verify(s.memory_kit116.gel119==amount,"reopening completion cannot generate an old guaranteed reward")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/outing120_result.png")
 var data := {"checks":checks,"failures":failures,"seconds":s.elapsed114,"max_active":max_alive,"natural_drops":collected,"expected_drops":15.*.25};var file := FileAccess.open("res://docs/outing120-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("OUTING120_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
