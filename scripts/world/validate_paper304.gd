extends "res://scripts/world/validate_paper303.gd"
class Harness304:
 extends "res://scripts/world/woodland_world304.gd"
 func export_stats226() -> Error:return OK
func world_script301() -> Script:return Harness304
func report304() -> String:return "res://docs/paper304-validation.json"
func extra304() -> void:pass
func shot301(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper304-"+tag+".png")
func run() -> void:
 w=world_script301().new();root.add_child(w);current_scene=w
 while not w.ready301:await process_frame
 w.set_physics_process(false);w.auto114=false
 var c=solo303("dinosaur");await settle(3);w._teleport15(Vector2(c.position.x-2.,c.position.z));c.enter301("warn");advance303(c,1.45)
 check(c.direction301.y==0. and c.fire303.visible,"fire uses horizontal locked direction")
 check(c.fire303.width_axis303(Vector3.ZERO,Vector3.RIGHT,Vector3.ONE)==Vector3.UP,"fire plane width is world vertical")
 await shot301("fire")
 c=solo303("monster");await settle(3);c.enter301("warn")
 var low=10.;var high=-10.;var card_low=10.;var card_high=-10.
 for i in 180:
  c._physics_process(1./120.);low=minf(low,c.operator301.position.y);high=maxf(high,c.operator301.position.y);card_low=minf(card_low,c.height303);card_high=maxf(card_high,c.height303)
 check(high-low>.5,"upper paper flies up and down rapidly")
 check(card_high-card_low>.15,"driven weight responds through spring and inertia")
 await shot301("monster")
 var monster_hp=w.player_hp;clean303()
 for i in 180:
  w._teleport15(c.attack_at301());c._physics_process(1./120.)
  if w.player_hp<monster_hp:break
 check(w.player_hp<monster_hp,"fast low downswing deals actual monster damage")
 var clock=c.clock301;var height=c.height303;w.combat_paused=true;c._physics_process(.2);check(c.clock301==clock and c.height303==height,"pause freezes driven monster");w.combat_paused=false
 c=solo303("knight");await settle(3);c.enter301("warn");advance303(c,1.1)
 check(c.visual.position.y<.1 and c.operator301.position.length()>4.,"knight stays planted while operator stretches line")
 await shot301("planted")
 advance303(c,.27);var dir=c.direction301;advance303(c,.12)
 check(c.ring_velocity304.length()>8. and c.ring304.length()>1.,"stored spring energy releases fast lunge")
 await shot301("lunge")
 c.clock301=.7;c.ring304=dir*2.;c.ring_velocity304=-dir*8.;c.pose302();w._teleport15(c.attack_at301());clean303();var hp=w.player_hp;c.contact_gate304=0.;c._physics_process(.001)
 check(w.player_hp<hp and c.launches304>0,"uncontrolled return swing remains dangerous")
 check(w.hero.combat_impulse.length()>15. and w.hero.velocity.y>0.,"actual hit applies long knockback and lift")
 var launch_height=w.hero.position.y;w.hero._physics_process(1./60.);check(w.hero.position.y>launch_height+.05,"launch really leaves native ground contact")
 var locked=c.direction301;w._teleport15(Vector2(c.position.x+4.,c.position.z));advance303(c,.2);check(c.direction301==locked,"ringing knight does not retarget player")
 c.contact_gate304=0.;clean303();w.hero.parried=false;w.hero.parry_t=.2;w._teleport15(c.attack_at301());c._physics_process(.001)
 check(c.state301=="stunned","dangerous swing can be parried")
 for kind in ["dinosaur","monster","knight"]:
  c=solo303(kind);await settle(3);w.levels226={};w.apply_levels226();w._clear_combat_shots();var before=c.hp;w.fire_at(c.hit_area.global_position)
  for i in 50:w._step_shots(1./60.);await physics_frame
  check(c.hp<before,"native weapon hits "+kind)
 await extra304()
 FileAccess.open(report304(),FileAccess.WRITE).store_string(JSON.stringify({"checks":checks},"  "))
 quit(0 if checks.all(func(v):return v.pass) else 1)
