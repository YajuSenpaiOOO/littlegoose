extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world256.tscn").instantiate();root.add_child(w);current_scene=w
 var deadline=Time.get_ticks_msec()+180000
 while not w.ready251 and Time.get_ticks_msec()<deadline:await process_frame
 if not w.ready251:check(false,"initialization");quit(1);return
 var old=load("res://scripts/world/woodland_world251.gd").new()
 check(old.boss_script251().resource_path.ends_with("tuantuan_boss251.gd"),"old251 factory default remains original actor");old.free()
 var b=w.boss247;w.auto114=false;w.invulnerability=1000.;w.hero.set_physics_process(false);b.set_physics_process(false)
 check(b.get_script().resource_path.ends_with("tuantuan_boss256.gd"),"new actor uses latest combat factory")
 check(w.player_hp==w.max_player_health() and w.encounter_hud.gems!=null and is_instance_valid(w.relay245),"determination HUD and relay baseline retained")
 check(w.hero.receiver192.albedo_color==Color.WHITE and w.porch49.has_method("actor_tint255"),"approved255 hero appearance retained")
 check(w.lighting191.has_method("attach_glow254") and not w.lighting191.stage_enabled,"254 warm-light repair retained")
 var at=Vector2(b.position.x,b.position.z)
 w._teleport15(at+Vector2(0,5));w.hero.velocity=Vector3.ZERO
 b.chains256=0;b.landings247.clear();b.flights247.clear();b.enter247("angry")
 b._physics_process(.1)
 check(b.lift247>.1 and b.visual.texture==b.textures.shove124,"angry expression and impatient little hops retained")
 await shot("boss256-angry")
 var guard=0
 while b.phase247!="flat" and guard<600:
  b._physics_process(1./60.);guard+=1
 check(b.landings247.size()==7 and b.phase247=="flat","seven real landings end in recovery")
 check(b.flights247[0].height>b.flights247[-1].height and b.flights247[0].duration>b.flights247[-1].duration,"bounce height and flight interval diminish together")
 check(w.echoes256.is_empty(),"first chain teaches solo pattern without echo balls")
 # Reframe only for visual QA after the inertial chain has travelled across the grove.
 b.position=w.hero.position+Vector3(-2.5,0.,-.3)
 b.position.y=w.floor_height(Vector2(b.position.x,b.position.z))+.03
 b.reset_physics_interpolation();b.clock247=1.;b.render247();await shot("boss256-flat")
 b._physics_process(1.5);check(b.phase247=="flat","punish window remains open for 2.65 seconds")
 b._physics_process(.2);check(b.phase247=="rest","recovery cleanly returns to rest")
 b.enter247("angry");b.jump247=6;b.enter247("flight");b.lock247()
 var flight=b.flights247[-1]
 var direction=b.forward247
 w.hero.position=b.position+Vector3(-direction.x*4.,0.,-direction.y*4.)
 b.lock247()
 check(absf(direction.angle_to(b.forward247))<=.6201,"late bounces limit turning so sidesteps can escape")
 var effective=flight.speed*flight.duration/(flight.duration+b.rebound_delay256())
 check(effective>w.hero.movement_speed() and flight.duration<=.3,"late low hops retain walking pursuit pressure")
 var locked=b.goal247;w.hero.position.x+=2.;b._physics_process(.07)
 check(b.goal247==locked,"each airborne jump stays committed instead of homing")
 await shot("boss256-low")
 b.jump247=0;b.enter247("flight");b.land247()
 check(w.echoes256.size()==2,"second chain emits two side echo balls on selected heavy landing")
 var ball=w.echoes256[0];ball.set_physics_process(false)
 var age=ball.age256;w.combat_paused=true;ball._physics_process(.2);b._physics_process(.2)
 check(ball.age256==age,"pause freezes echo projectile")
 w.combat_paused=false
 w.emit_echoes256(Vector2(b.position.x,b.position.z),Vector2.DOWN);w.emit_echoes256(Vector2(b.position.x,b.position.z),Vector2.DOWN)
 check(w.echoes256.size()==4,"echo pressure is capped at four live balls")
 await shot("boss256-echoes")
 b.enter247("flat");check(w.echoes256.is_empty(),"recovery removes lingering balls for a clean counterattack")
 # Actual native collision body tests both projectile reflection and parry wall reward.
 var wall=StaticBody3D.new();wall.collision_layer=1;var collision=CollisionShape3D.new();var shape=BoxShape3D.new();shape.size=Vector3(.3,3.,5.);collision.shape=shape;wall.add_child(collision)
 wall.position=b.position+Vector3(-1.8,1.,0.);w.add_child(wall);await settle(3)
 w.emit_echoes256(Vector2(b.position.x,b.position.z),Vector2.DOWN)
 ball=w.echoes256[0];ball.set_physics_process(false);ball.position=b.position+Vector3(-.7,.2,0.);ball.direction=Vector2.LEFT
 for i in 40:
  ball._physics_process(1./60.)
  if ball.bounces256>0:break
 check(ball.bounces256>0 and ball.direction.x>0.,"echo ball physically reflects off obstacle")
 ball.age256=2.69;ball._physics_process(.02);check(ball.is_queued_for_deletion(),"echo projectile lifetime is bounded")
 w.clear_echoes256()
 b.enter247("angry");b.enter247("flight");b.hp=1000.;b.from247=Vector2(b.position.x,b.position.z)-Vector2.RIGHT;b.goal247=Vector2(b.position.x,b.position.z)
 w.hero.position=b.position;w.hero.parry_t=.15;w.hero.parried=false;w.hero.dodge_invulnerability=0.;w.invulnerability=0.
 b.land247()
 check(b.phase247=="deflected" and b.reverse_pending249 and b.total248==9,"landing parry arms one reverse bounce and adds two")
 w.reset_impact248();w.hero.cancel_guard109();w.invulnerability=1000.;w.hero.position.z+=5.
 b._physics_process(.21)
 check(b.reflected248 and not b.reverse_pending249,"reverse direction is consumed by only one flight")
 var hp=b.hp;var jump=b.jump247
 for i in 60:
  b._physics_process(1./60.)
  if b.phase247=="bumper":break
 check(b.phase247=="bumper" and b.hp==hp-5. and b.jump247==jump+2,"reflected physical wall crash damages boss and consumes one extra bounce")
 await shot("boss256-wall")
 b._physics_process(.43)
 check(b.phase247=="flight" and not b.reflected248 and b.forward247.dot((Vector2(w.hero.position.x,w.hero.position.z)-b.from247).normalized())>.95,"boss resumes pursuing player after wall stagger")
 wall.queue_free();w.clear_echoes256()
 w.emit_echoes256(Vector2(w.hero.position.x,w.hero.position.z),Vector2.DOWN)
 ball=w.echoes256[0];ball.set_physics_process(false);ball.position=w.hero.position+Vector3.UP*.2;w.invulnerability=0.;var health=w.player_hp
 ball._physics_process(.001)
 check(w.player_hp==health-1.,"echo hit uses native determination damage")
 w.clear_echoes256();w.emit_echoes256(Vector2(b.position.x,b.position.z),Vector2.DOWN)
 w.toggle_console226();await process_frame
 check(w.console226.visible and w.combat_paused,"C console still opens and pauses latest fight")
 w.close_console226();w.begin251();await process_frame;b=w.boss247;b.set_physics_process(false)
 check(w.echoes256.is_empty() and w.enemies.size()==1 and b.chains256==0,"restart clears projectiles and resets chain teaching")
 check(w.projection250.visible and not b.shadow.visible and not b.marker247.visible,"shared silhouette shadow and default circle-off preserved")
 b.receive_hit(10000.,Vector3.RIGHT);await create_timer(.2).timeout
 check(not w.active114 and w.echoes256.is_empty(),"victory cleans remaining projectiles")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/boss256-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));f.close()
 print("BOSS256_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
