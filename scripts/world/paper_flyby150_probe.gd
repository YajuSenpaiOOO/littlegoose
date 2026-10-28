extends "res://scripts/world/paper_memories146_probe.gd"
class Trial150:
 extends "res://scripts/world/woodland_world150.gd"
 var aim150 := Vector3.ZERO
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func paper_aim146() -> Vector3: return aim150
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func capture150(tag: String) -> void:
 if "--capture150" in OS.get_cmdline_user_args():
  var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/paper_flyby150_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial150.new();s.memory_save116="user://flyby150_probe_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.hill_visited136=true;s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24,-17));await settle72(10)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 var target: CharacterBody3D=s.enemies[0];target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(0,0,-4);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06;target.set_physics_process(true);s.rebuild_cells110()
 var mark := target.position;mark.y=s.floor_height(Vector2(mark.x,mark.z))+.05;s.aim150=mark
 var m: Node3D=s.paper_memories146;m.flight_rng146.seed=150
 set146(s,{"paper_plane":1,"homework":1});var hp: float=target.hp;s.fire_at(mark)
 verify(m.planes149.size()==1 and s.shots.is_empty(),"throw produces one plane and no direct projectile duplicate")
 var f: Dictionary=m.planes149[0];var slowest := INF;var fastest := 0.;var min_screen := INF
 for i in 30:
  var age := float(f.release)-.3+float(i)*.02
  var a: Vector3=m.point150(f,age);var b: Vector3=m.point150(f,age+.01)
  var speed := a.distance_to(b)/.01;slowest=minf(slowest,speed);fastest=maxf(fastest,speed)
  min_screen=minf(min_screen,s.camera.unproject_position(a).distance_to(s.camera.unproject_position(b))/.01)
 verify(slowest>2. and fastest/slowest<1.3,"arc-distance sampling keeps flyover speed continuous without a delivery-point hold")
 verify(min_screen>35.,"diagonal flyover remains visibly moving in screen space")
 var wait := 0
 while m.history149.is_empty() and wait<180: await settle72(1);wait+=1
 verify(not s.shots.is_empty() and s.shots[0].get("packet146",false) and s.shots[0].velocity.y<0. and target.hp==hp,"delivery creates the actual current downward projectile before any collision damage")
 await capture150("release")
 await settle72(15);await capture150("three_payloads")
 verify(m.history149.size()==3 and float(m.history149[2].age)-float(m.history149[0].age)<.23,"three payload releases complete during one quick flyby")
 await settle72(70)
 verify(target.hp<hp and m.pages146.size()==1,"real airborne projectiles hit the native enemy and do not recursively record notes")
 set146(s,{"paper_plane":1,"homework":1,"slingshot":1});m.history149.clear();s._release_charged(mark,1.)
 var packet: Dictionary=m.planes149[0].packet
 verify(packet.specs[0].charged and is_equal_approx(packet.specs[0].speed,(320.+430.)/s.Profile.PPM),"charged payload keeps its actual projectile speed and charge properties")
 wait=0
 while m.history149.is_empty() and wait<180: await settle72(1);wait+=1
 verify(not s.shots.is_empty() and s.shots[-1].charged and is_equal_approx(s.damage_for_shot(s.shots[-1]),float(packet.specs[0].damage)/3.),"heavy projectile damage is divided among three deliveries without generic blast replacement")
 await capture150("charged")
 set146(s,{"paper_plane":1,"homework":1,"snack":1});m.history149.clear();var split_hp: float=target.hp;var split_births: int=s.fired_count;s.fire_at(mark);wait=0
 while m.history149.is_empty() and wait<180: await settle72(1);wait+=1
 verify(s.shots[-1].snack146==1,"split property remains attached to the delivered projectile")
 await settle72(70)
 verify(target.hp<split_hp and s.fired_count-split_births>3 and s.shots.size()<=512,"split payloads actually hit and generate secondary native projectiles within budget")
 set146(s,{"paper_plane":1,"homework":1,"flashlight":1,"distract":1});m.history149.clear();s.fire_at(mark);wait=0
 while m.history149.is_empty() and wait<180: await settle72(1);wait+=1
 await settle72(8);await capture150("water")
 var lanes := {};var water := false
 for shot in s.shots:
  if shot.get("stream110",false): water=true;lanes[int(shot.stream_lane110)]=true
 verify(water and lanes.size()==2,"water remains an actual finite stream with separate downward lanes")
 var following := false
 for burst in m.bursts146:
  if burst.has("flight150"): following=true
 verify(following,"water emission follows the moving aircraft instead of an abandoned muzzle point")
 set146(s,{"paper_plane":1,"homework":1});m.history149.clear()
 for i in 8: s.fire_at(mark)
 verify(m.planes149.size()==8,"aircraft have no three-plane capacity gate")
 m.request146();await settle72(75)
 verify(m.pending146.is_empty() and m.planes149.size()>=11,"notebook replays can join the existing fleet")
 var age: float=m.planes149[0].age;s.combat_paused=true;await settle72(10)
 verify(is_equal_approx(m.planes149[0].age,age),"pause stops the flyby and delivery clocks")
 s.combat_paused=false;s._clear_combat_shots()
 verify(m.planes149.is_empty() and m.bursts146.is_empty() and m.pages146.is_empty(),"reset clears planes, moving stream emitters and notebook state")
 var report := {"checks":checks,"failures":failures,"min_flyover_speed":slowest,"max_flyover_speed":fastest,"min_screen_speed_px":min_screen}
 FileAccess.open("res://docs/paper-flyby150-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("PAPER_FLYBY150_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
