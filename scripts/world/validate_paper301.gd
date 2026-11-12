extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world301.gd"
 func export_stats226() -> Error:return OK
func world_script301() -> Script:return Harness
func extra_checks301() -> void:pass
func report_path301() -> String:return "res://docs/paper301-validation.json"
func shot301(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper301-"+tag+".png")
func prepare301(c: CharacterBody3D) -> void:
 c.set_physics_process(false);c.enter301("rest");c.hit_area.collision_layer=8;c.flash=0.;c.position=Vector3(w.centre301.x,w.floor_height(w.centre301+Vector2(0,3.))+.04,w.centre301.y+3.);c.render301()
 w.reset_player264();w.invulnerability=0.;w.parry_grace258=0.;w.hero.cancel_guard109();w.auto114=false
 w._teleport15(w.centre301+Vector2(0,5.));w.hero.set_physics_process(false)
func run() -> void:
 w=world_script301().new();root.add_child(w);current_scene=w
 var deadline=Time.get_ticks_msec()+180000
 while not w.ready301 and Time.get_ticks_msec()<deadline:await process_frame
 if not w.ready301:check(false,"world initializes");quit(1);return
 w.set_physics_process(false);w.auto114=false
 var c=w.cards301[0];prepare301(c)
 check(w.active114 and w.trial152 and w.mode264=="paper301","isolated reward-free paper combat")
 check(w.hero.get_script().resource_path.ends_with("hero192.gd"),"hero192 geometry retained")
 check(c in w.enemies and c.hit_area.get_meta("enemy")==c,"native weapon target registered")
 check(c.operator301.texture.resource_path.ends_with("base_C.png") and c.thread301.mesh!=null,"ordinary flying paper operator with attached thread")
 check(c.visual.material_override!=c.operator301.material_override,"card and operator material states independent")
 for name in ["dinosaur","knight","monster"]:
  if name!="dinosaur":
   c.hide();c.hit_area.collision_layer=0;c.cue301.hide();c=w.spawn301();prepare301(c)
  c.enter301("warn");var locked=c.locked301;w._teleport15(w.centre301+Vector2(2.,5.));c._physics_process(.3)
  check(c.locked301==locked,"telegraph locks rather than tracks: "+name)
  c.render301();check(c.cue301.visible,"readable ground cue: "+name)
  await shot301(name)
  w.combat_paused=true;var age301=c.clock301;c._physics_process(.2);check(c.clock301==age301,"pause freezes: "+name);w.combat_paused=false
  # Contact occurs once and preserves native invulnerability/dodge/parry handling.
  w._teleport15(w.centre301+Vector2(0,5.));c.enter301("warn");c.enter301("attack")
  if name=="knight":w._teleport15(Vector2(c.position.x,c.position.z)+c.direction301*.5)
  if name=="monster":c.position.x=c.locked301.x;c.position.z=c.locked301.y;c.clock301=.25
  w.invulnerability=0.;w.hero.dodge_invulnerability=0.;w.hero.dash_left=0.;var hp=w.player_hp;c._physics_process(.01)
  check(w.player_hp<hp,"attack damages player: "+name)
  hp=w.player_hp;w.invulnerability=0.;c._physics_process(.01);check(w.player_hp==hp,"single contact cannot hit twice: "+name)
  c.enter301("attack");w.parry_grace258=0.;w.invulnerability=0.;w.hero.parried=false;w.hero.parry_t=.2
  if name=="monster":c.clock301=.25
  var parries=c.parries301;hp=w.player_hp;c._physics_process(.01)
  check(c.parries301==parries+1 and c.state301=="stunned" and w.player_hp==hp,"perfect parry cancels attack: "+name)
  w.hero.cancel_guard109();w.parry_grace258=0.;w.invulnerability=0.;w.hero.dodge_invulnerability=.2;c.enter301("attack")
  if name=="monster":c.clock301=.25
  hp=w.player_hp;c._physics_process(.01);check(w.player_hp==hp,"native dodge invulnerability protects: "+name)
  w.hero.dodge_invulnerability=0.;c.enter301("rest");c.render301()
 # Fire a real native projectile against the card's actual hit Area3D.
 c=w.cards301[-1];prepare301(c);c.hp=18.;w.levels226={};w.apply_levels226();w._clear_combat_shots()
 for other in w.cards301:
  if other!=c:other.hit_area.collision_layer=0
 await settle(4)
 var before=c.hp;w.fire_at(c.hit_area.global_position);check(not w.shots.is_empty(),"native fire emits projectile")
 for i in 50:w._step_shots(1./60.);await physics_frame
 check(c.hp<before,"native fired projectile hits hanging card")
 c.receive_hit(999.,Vector3.FORWARD);await settle(2)
 check(c.dead and c.hit_area.collision_layer==0 and w.defeated301==1,"shooting destroys card and cancels target")
 w.restart301();w.set_physics_process(false)
 check(w.spawned301==1 and w.defeated301==0 and w.live301().size()==1,"restart resets six-card test")
 w.spawn_left301=-1.;w._physics_process(.01);check(w.live301().size()==2,"scheduler brings a second card")
 w.spawn_left301=-1.;w._physics_process(.01);check(w.live301().size()==2,"scheduler caps simultaneous cards at two")
 # Real mixed actors, separate footprints and visible hanging operators.
 await create_timer(1.1).timeout
 w.hero.visual.modulate=Color.WHITE;await shot301("mixed")
 check(w.cards301[0].position.distance_to(w.cards301[1].position)>1.,"mixed cards retain separate footprints")
 # A native static blocker interrupts an otherwise valid cone hit.
 c=w.cards301[0];prepare301(c);c.enter301("warn");c.enter301("attack")
 var blocker=StaticBody3D.new();blocker.collision_layer=2;blocker.position=c.position+Vector3(0,.8,1.);w.add_child(blocker)
 var shape=CollisionShape3D.new();var box=BoxShape3D.new();box.size=Vector3(2.,2.,.2);shape.shape=box;blocker.add_child(shape);await settle(3)
 w.invulnerability=0.;w.parry_grace258=0.;var hp_before=w.player_hp;c._physics_process(.01);check(w.player_hp==hp_before,"native scenery blocks card attack damage")
 blocker.queue_free()
 w.spawned301=6;w.defeated301=5;c=w.cards301[0];c.enter301("rest");c.receive_hit(999.,Vector3.FORWARD);await settle(2)
 check(not w.active114 and w.result301.contains("清场"),"six defeated cards finish without reward or extra wave")
 w.finish251(false);check(not w.active114 and w.hero.controls_enabled,"finish restores controls")
 await extra_checks301()
 FileAccess.open(report_path301(),FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"metrics":metrics,"scope":"hanging card attacks, actual projectiles, damage, parry, pause, reset; no full boss"},"  "))
 quit(0 if checks.all(func(v):return v.pass) else 1)
