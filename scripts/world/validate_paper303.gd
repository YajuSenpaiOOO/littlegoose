extends "res://scripts/world/validate_paper302.gd"
class Harness303:
 extends "res://scripts/world/woodland_world303.gd"
 func export_stats226() -> Error:return OK
func world_script301() -> Script:return Harness303
func report_path301() -> String:return "res://docs/paper303-validation.json"
func shot301(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper303-"+tag+".png")
func solo303(kind: String) -> CharacterBody3D:
 w.focus303=kind;w.restart301();w.set_physics_process(false);w.auto114=false;w.hurt_flash=0.;w.porch49._update_actor()
 var c=w.cards301[0];prepare301(c);c.hp=100.;c.max_hp110=100.;c.angle302=Vector2.ZERO;c.angular302=Vector2.ZERO;c.anchor_velocity302=Vector2.ZERO;c.render301()
 return c
func advance303(c: CharacterBody3D,seconds: float) -> void:
 for i in int(ceil(seconds*120.)):c._physics_process(1./120.)
func clean303() -> void:
 w.invulnerability=0.;w.parry_grace258=0.;w.hero.dodge_invulnerability=0.;w.hero.dash_left=0.;w.hero.cancel_guard109();w.hurt_flash=0.;w.porch49._update_actor()
func run() -> void:
 w=world_script301().new();root.add_child(w);current_scene=w
 var deadline=Time.get_ticks_msec()+180000
 while not w.ready301 and Time.get_ticks_msec()<deadline:await process_frame
 if not w.ready301:check(false,"initialization");quit(1);return
 w.set_physics_process(false);w.auto114=false
 check(w.active114 and w.trial152 and w.active_cap301()==2,"mixed reward-free combat keeps two-card cap")
 w.spawn_left301=-1.;w._physics_process(.01);w.spawn_left301=-1.;w._physics_process(.01)
 check(w.live301().size()==2,"mixed scheduler preserves simultaneous card cap")
 var c=solo303("dinosaur");await settle(3)
 w._teleport15(Vector2(c.position.x-2.,c.position.z));c.enter301("warn");var locked=c.direction301;advance303(c,.75)
 check(c.cue301.visible and not c.fire303.visible,"dinosaur previews before paper fire")
 await shot301("fire-warn")
 w._teleport15(Vector2(c.position.x+2.,c.position.z+2.));advance303(c,.25)
 check(c.direction301==locked,"spray locks direction instead of homing")
 var early=c.fire303.extent303;advance303(c,.48)
 check(c.fire303.visible and c.fire303.extent303>early+1.,"three paper sections unfold into actual fire mesh")
 await shot301("fire-open")
 var mouth=c.mouth303();w._teleport15(Vector2(mouth.x,mouth.z)+c.direction301*2.);clean303();var hp=w.player_hp
 c.enter301("attack");c.clock301=.45;c._physics_process(.01)
 check(w.player_hp<hp,"unfolded paper fire has actual damage")
 hp=w.player_hp;w.invulnerability=0.;advance303(c,.1);check(w.player_hp==hp,"sustained fire cannot hit twice in one breath")
 c.enter301("attack");c.clock301=.45;clean303();w.hero.parried=false;w.hero.parry_t=.2;c._physics_process(.01)
 check(c.state301=="stunned" and not c.fire303.visible,"parrying fire interrupts entire breath")
 c.enter301("attack");c.clock301=.45;clean303();w.hero.dodge_invulnerability=.2;hp=w.player_hp;c._physics_process(.01)
 check(w.player_hp==hp,"native dodge protects against paper fire");w.hero.dodge_invulnerability=0.
 c.enter301("attack");c.clock301=.45;clean303()
 mouth=c.mouth303();var wall=StaticBody3D.new();wall.collision_layer=2;wall.position=mouth+Vector3(c.direction301.x,0,c.direction301.y)*1.2;w.add_child(wall)
 var shape=CollisionShape3D.new();var box=BoxShape3D.new();box.size=Vector3(.2,3.,2.);shape.shape=box;wall.add_child(shape);await settle(3)
 hp=w.player_hp;c._physics_process(.01)
 check(c.fire_reach303<1.3 and w.player_hp==hp,"scenery truncates paper fire and blocks damage");wall.queue_free();await settle(2)
 c.enter301("attack");advance303(c,1.4);check(not c.fire303.visible and c.state301=="recover","paper fire retracts and ends")
 c=solo303("monster");await settle(3);c.enter301("warn");advance303(c,.75)
 check(c.height303>1.1 and c.vertical303!=0.,"operator reels monster upward with inertia")
 await shot301("monster-pull")
 clean303();advance303(c,.23)
 for i in 120:
  if c.landings303>0:break
  c._physics_process(1./120.)
 check(c.landings303==1 and c.phase303=="catch","heavy drop reaches first rope catch")
 check(c.vertical303>0.,"taut rope reverses downward momentum")
 await shot301("monster-catch")
 # Put player directly under the jiggling card and remove invulnerability:
 # small catch oscillations must never become repeated contact damage.
 w._teleport15(c.attack_at301());clean303();hp=w.player_hp;advance303(c,.22)
 check(w.player_hp==hp,"catch tremors deal no repeated chip damage")
 var found_hold=false
 for i in 600:
  if c.drop_index303==2 and c.phase303=="pull" and c.phase_clock303>.47:found_hold=true;break
  c._physics_process(1./120.)
 check(found_hold and c.height303>1.1,"third drop includes a longer suspended beat")
 await shot301("monster-last-hold")
 for i in 300:
  if c.state301=="recover":break
  c._physics_process(1./120.)
 check(c.landings303==3 and c.state301=="recover","monster completes exactly three heavy drops")
 c=solo303("monster");await settle(3);c.enter301("warn");advance303(c,1.)
 w._teleport15(c.attack_at301());clean303();w.hero.parried=false;w.hero.parry_t=.2
 for i in 120:
  if c.landings303>0:break
  c._physics_process(1./120.)
 check(c.state301=="stunned","landing can be perfectly parried")
 advance303(c,.8);check(c.landings303==1,"parry cancels remaining yo-yo drops")
 c=solo303("knight");await settle(3);c.enter301("warn");advance303(c,.75)
 check(c.angle302.dot(c.direction301)<-.01,"knight is pulled backward before release")
 await shot301("knight-pull")
 advance303(c,.22);w._teleport15(c.attack_at301()+c.direction301*1.2);clean303();hp=w.player_hp
 for i in 65:
  c._physics_process(1./120.)
  if w.player_hp<hp:break
 check(w.player_hp<hp,"released swing thrust hits along actual swept path")
 await shot301("knight-out")
 for i in 90:
  if c.clock301>=.63:break
  c._physics_process(1./120.)
 var outward=c.position;w._teleport15(c.attack_at301()-c.direction301*.5);clean303();hp=w.player_hp
 advance303(c,.48)
 check(c.returned303 and (Vector2(c.position.x-outward.x,c.position.z-outward.z)).dot(c.direction301)<-.05,"knight swings backward after overshoot")
 check(w.player_hp==hp,"return swing is harmless")
 await shot301("knight-return")
 c.enter301("attack");c.clock301=.15;w._teleport15(c.attack_at301()+c.direction301*.2);clean303();w.hero.parried=false;w.hero.parry_t=.2;c._physics_process(.01)
 check(c.state301=="stunned","swing thrust can be perfectly parried")
 c=solo303("dinosaur");await settle(3);w._teleport15(Vector2(c.position.x+2.,c.position.z));c.enter301("warn");advance303(c,1.45)
 check(c.visual.flip_h and c.fire303.visible,"right-facing dinosaur keeps mouth fire connected")
 w.time55.preview_at(22.);w.time55.visual_hour=22.;w.time55.apply_look();w._grade_combat111();await shot301("fire-night")
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look();w._grade_combat111()
 for kind in ["dinosaur","monster","knight"]:
  c=solo303(kind);await settle(3);w.levels226={};w.apply_levels226();w._clear_combat_shots();var before=c.hp;w.fire_at(c.hit_area.global_position)
  for i in 50:w._step_shots(1./60.);await physics_frame
  check(c.hp<before,"native weapon hits new attack actor: "+kind)
  c.enter301("warn");advance303(c,1.)
  w.combat_paused=true;var age303=c.clock301;var vertical=c.vertical303;var phase=c.phase_clock303;var height=c.height303;c._physics_process(.3)
  check(c.clock301==age303 and c.vertical303==vertical and c.phase_clock303==phase and c.height303==height,"pause freezes attack and rope: "+kind);w.combat_paused=false
 check(w.active_cap301()==1,"focused attack test uses one card at a time")
 w.spawned301=6;w.defeated301=5;c.enter301("rest");c.receive_hit(999.,Vector3.FORWARD);await settle(2)
 check(not w.active114 and w.result301.contains("清场"),"six defeated cards still end without formal reward")
 # Reuse the pendulum/occlusion/time-of-day checks against the new actor.
 await extra_checks301()
 FileAccess.open(report_path301(),FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"metrics":metrics,"scope":"paper flame, three yo-yo drops and swing thrust; not full boss"},"  "))
 quit(0 if checks.all(func(v):return v.pass) else 1)
