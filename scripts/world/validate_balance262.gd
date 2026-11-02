extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world262.gd"
 var legacy262 := false
 func _init() -> void:
  super._init();memory_save116="user://balance262-validation-preview.cfg"
 func test_config_path226() -> String:return "user://balance262-validation.cfg"
 func export_stats226() -> Error:return OK
 func flashlight_damage_gain110() -> float:
  if legacy262:return 1.35 if flashlight_red229() else 1.
  return super.flashlight_damage_gain110()
 func floor_height(at: Vector2) -> float:
  return 0. if at.x>400. else super.floor_height(at)
 func safe_goal247(start: Vector2,wanted: Vector2) -> Vector2:
  return wanted if start.x>400. else super.safe_goal247(start,wanted)
func equip(levels: Dictionary) -> void:
 w._clear_combat_shots();w.levels226=levels.duplicate();w.apply_levels226();w.auto114=false
func beam_damage(legacy: bool,hp: float) -> float:
 w.legacy262=legacy;w.player_hp=hp;w.emit_stream110(w.boss247.hit_area.global_position)
 var value=w.damage_for_shot(w.shots[-1]);w._clear_combat_shots();return value
func lock_case(b: CharacterBody3D,index: int,slow: float,pounce: bool=false,reverse: bool=false) -> Dictionary:
 b.position=Vector3(500,0,500);b.forward247=Vector2.RIGHT;b.group259=-1;b.turn_reset256=false
 w.hero.position=Vector3(505,0,500);w.hero.velocity=Vector3.ZERO
 b.jump247=index;b.enter247("pounce" if pounce else "flight");b.reverse_pending249=reverse
 b.set_meta("locomotion_scale153",slow);b.lock247()
 return {"distance":b.from247.distance_to(b.goal247),"duration":.48 if pounce else b.duration248(),"height":.6 if pounce else b.height248(),"from":b.from247,"goal":b.goal247}
func lunge(m: CharacterBody3D,slow: float) -> Dictionary:
 w.hero.position=Vector3(504,0,500);m.position=Vector3(500,0,500);m.home=Vector2(500,500)
 m.impulse=Vector2.ZERO;m.velocity=Vector3.ZERO;m.parry_stun=0.;m.play_state123="";m.peer_cooldown123=100.
 m.set_meta("locomotion_scale153",slow);m._begin_windup(Vector2(504,500));m.phase_clock=m.WINDUP-.001
 await physics_frame;m._physics_process(1./60.)
 var started=m.attack_phase=="lunge";var distance=m.attack_distance;var start=m.position;var time=0.
 # A sword expiring during flight must not stretch the already locked lunge.
 m.set_meta("locomotion_scale153",1.)
 while m.attack_phase=="lunge" and time<1.:
  await physics_frame;m._physics_process(1./60.);time+=1./60.
 return {"started":started,"locked_distance":distance,"travel":Vector2(m.position.x-start.x,m.position.z-start.z).length(),"seconds":time}
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while w.entry_navigation261==null or not w.console226.has_method("draft_level257"):await process_frame
 w.set_physics_process(false);w.hero.set_physics_process(false);w.hero.controls_enabled=false;w.auto114=false
 var b=w.boss247;b.set_physics_process(false)
 check(b.get_script().resource_path.ends_with("tuantuan_boss262.gd") and b.hp==90. and w.capacity257()==4 and w.max_player_health()==12.,"262 actor with unchanged boss health and initial progression")
 equip({"flashlight":1,"eye_exercise":1})
 var old=beam_damage(true,12.);var normal=beam_damage(false,12.);var red=beam_damage(false,3.)
 metrics.beam={"old_normal":old,"normal":normal,"red":red,"old_red":beam_damage(true,3.)}
 check(is_equal_approx(normal/old,.7) and is_equal_approx(red/old,1.4) and is_equal_approx(red/normal,2.),"native emitted beam damage is 70 percent normal and 140 percent red")
 w.legacy262=false;w.player_hp=4.;check(not w.flashlight_red229() and is_equal_approx(w.flashlight_damage_gain110(),.7),"exact one third is not red")
 w.player_hp=3.;check(w.flashlight_red229() and w.flashlight_rate_gain110()==1. and is_equal_approx(w.buffs.rate(),1.25),"red activates at three of twelve without added fire rate")
 w.player_hp=1.;check(is_equal_approx(w.flashlight_damage_gain110(),1.4),"further health loss does not stack additional damage")
 w.player_hp=0.;check(not w.flashlight_red229(),"zero health does not activate red bonus")
 w.player_hp=12.;w.emit_stream110(b.hit_area.global_position)
 var shot_data=w.shots[-1];var expected=w.damage_for_shot(shot_data);var before=b.hp
 w._apply_shot_hit(shot_data,{"collider":b.hit_area,"position":b.hit_area.global_position,"normal":Vector3.LEFT})
 check(is_equal_approx(before-b.hp,expected),"real boss collider hit receives resolved beam damage once")
 equip({"flashlight":1,"paper_plane":1})
 w.player_hp=12.;w.legacy262=true;var old_packet=w.snapshot_packet146(b.hit_area.global_position,false,0.,true)
 w.legacy262=false;var packet=w.snapshot_packet146(b.hit_area.global_position,false,0.,true)
 check(not packet.is_empty() and is_equal_approx(packet.specs[0].damage/old_packet.specs[0].damage,.7) and packet.pulse_interval==old_packet.pulse_interval,"plane beam snapshot inherits nerf once with unchanged pulse cadence")
 var saved=packet.specs[0].damage;w.player_hp=3.;w.emit_packet146(packet,w.projectile_origin(),b.hit_area.global_position,1.)
 check(is_equal_approx(w.damage_for_shot(w.shots[-1]),saved),"stored normal payload does not gain or double scale from later red state")
 w._clear_combat_shots();var red_packet=w.snapshot_packet146(b.hit_area.global_position,false,0.,true)
 check(is_equal_approx(red_packet.specs[0].damage/saved,2.),"new red payload correctly captures double normal damage")
 equip({"balloon_sword":1,"eye_exercise":1});w.player_hp=12.
 for i in 5:w.swords153.attach153(b,b.hit_area.global_position,Vector3.RIGHT)
 check(is_equal_approx(b.get_meta("locomotion_scale153"),.6),"five real adhesive swords produce existing forty percent locomotion scale")
 var rows=[]
 for index in [0,2,5]:
  var a=lock_case(b,index,1.);var c=lock_case(b,index,.6);rows.append({"index":index,"normal":a.distance,"slowed":c.distance})
  check(is_equal_approx(c.distance/a.distance,.8) and a.duration==c.duration and a.height==c.height,"boss hop "+str(index)+" loses twenty percent horizontal reach only")
 var one=lock_case(b,0,.92);var base=lock_case(b,0,1.)
 check(is_equal_approx(one.distance/base.distance,.96),"one sword gives four percent boss control")
 var p=lock_case(b,0,1.,true);var q=lock_case(b,0,.6,true)
 check(is_equal_approx(q.distance/p.distance,.8) and q.duration==p.duration,"short pounce obeys same horizontal control and original timing")
 var r=lock_case(b,6,1.,false,true);var s=lock_case(b,6,.6,false,true)
 check(is_equal_approx(r.distance,s.distance) and b.reflected248 and b.attack_connected,"parry return retains full reach and harmless consumed attack")
 var frozen=lock_case(b,0,.6);var goal=b.goal247;b.set_meta("locomotion_scale153",1.)
 check(b.goal247==goal,"expiring adhesive cannot modify current boss trajectory")
 metrics.boss_reach=rows
 # Place hero outside slowed sweep but inside the old horizontal segment.
 lock_case(b,5,.6);b.attack_connected=false;b.lift247=.2;b.clock247=b.duration248()*.8
 var travel=b.from247.distance_to(b.goal247);var old_travel=travel/.8
 w.hero.position=Vector3(500+old_travel+1.58,0,500);w.hero.reset_actions();w.invulnerability=0.;w.parry_grace258=0.
 var hp=w.player_hp
 await physics_frame;b.move247((b.goal247-b.from247)/(1./60.),1./60.)
 check(w.player_hp==hp,"slowed physical sweep cannot hit the former unslowed endpoint")
 w.swords153.step153(3.1)
 check(is_equal_approx(b.get_meta("locomotion_scale153"),1.) and w.swords153.layers153.is_empty(),"independent sword expiry restores locomotion without lingering control")
 # Live minion actor, actual native takeoff and physical travel on isolated flat space.
 b.position=Vector3(530,0,500);w.hero.position=Vector3(w.meadow.landmarks.grove.x,2.,w.meadow.landmarks.grove.y+3.)
 var m=w.spawn_minion260();check(is_instance_valid(m),"261 perimeter entry still creates new minion subclass")
 if not is_instance_valid(m):quit(1);return
 m.set_physics_process(false);m.ground260();m.rustle261.hide()
 var full=await lunge(m,1.);var reduced=await lunge(m,.6)
 metrics.minion={"normal":full,"slowed":reduced}
 check(full.started and reduced.started and is_equal_approx(reduced.locked_distance/full.locked_distance,.6),"ordinary attack snapshots forty percent shorter distance at actual takeoff")
 check(absf(reduced.travel/full.travel-.6)<.03 and full.seconds==reduced.seconds,"physical ordinary lunge distance follows slow while flight duration stays fixed")
 check(not m.rest_with_boss260() and w.minion_attack_allowed260(),"boss flat phase still does not globally stop minions")
 check(w.memory_kit116.card("flashlight").fx.contains("2倍") and w.memory_kit116.card("balloon_sword").fx.contains("效果减半"),"live card explanations describe new red bonus and boss control")
 var report=w.report_stats226()
 check(report.balance229.flashlight_damage_gain==2. and report.balance262.flashlight_normal==.7 and report.balance262.flashlight_red==1.4,"recording exports current balance instead of stale thirty five percent bonus")
 w.begin251();b=w.boss247;b.set_physics_process(false);w.hero.set_physics_process(false);w.auto114=false
 equip({"flashlight":1,"eye_exercise":1});w.player_hp=3.;w._process(0.);w.combat_paused=true
 await shot("balance262-red")
 check(w.guide206.text.contains("伤害×2") and not w.guide206.text.contains("＋35%"),"red HUD uses current multiplier")
 w.combat_paused=false;w.finish251(false)
 check(w.minions260.is_empty() and w.swords153.layers153.is_empty(),"ending clears minions and adhesive layers")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/balance262-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("BALANCE262_VALIDATION ",ok," checks=",checks.size()," metrics=",metrics);quit(0 if ok else 1)
