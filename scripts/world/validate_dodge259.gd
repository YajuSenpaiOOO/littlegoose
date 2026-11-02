extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world259.gd"
 var legacy259 := false
 func _init() -> void:
  super._init();memory_save116="user://boss259-validation-preview.cfg"
 func test_config_path226() -> String:return "user://boss259-validation.cfg"
 func export_stats226() -> Error:return OK
 func boss_script251() -> Script:
  return load("res://scripts/combat/tuantuan_boss258.gd") if legacy259 else super.boss_script251()
func trial259(legacy: bool,pattern: String,trigger: float=.05) -> Dictionary:
 w.legacy259=legacy;w.begin251();var b=w.boss247
 b.set_physics_process(false);w.hero.set_physics_process(false);w.auto114=false;w.player_hp=1000.;w.invulnerability=0.
 w.hero.cancel_guard109();w.hero.reset_actions();b.enter247("angry")
 var side=Vector2.RIGHT;var dashed=false;var dash_at=-1.;var hits=0;var later=0;var loss=0.;var elapsed=0.;var count=w.parry_count;var first=false
 for i in 480:
  await physics_frame
  var dt=1./float(Engine.physics_ticks_per_second);elapsed+=dt
  w.reset_impact248();Engine.time_scale=1.;w.invulnerability=maxf(0.,w.invulnerability-dt)
  if b.phase247=="flight":first=true
  if pattern=="dash" and not dashed and b.phase247=="flight" and b.jump247==2 and b.clock247>=trigger:
   var incoming=(b.goal247-b.from247).normalized();side=incoming.orthogonal()
   dashed=w.hero.request_dash(side);dash_at=elapsed
  if w.hero.dash_left>0.:
   w.hero._physics_process(dt)
  else:
   w.hero.dash_cd=maxf(0.,w.hero.dash_cd-dt);w.hero.dodge_invulnerability=maxf(0.,w.hero.dodge_invulnerability-dt)
   var direction=side if dashed else Vector2.ZERO
   if pattern=="retreat" and first:direction=(Vector2(w.hero.position.x-b.position.x,w.hero.position.z-b.position.z)).normalized()
   w.hero.velocity=Vector3(direction.x*4.1,-.3,direction.y*4.1);w.hero.move_and_slide()
  var hp=w.player_hp;b._physics_process(dt)
  if w.player_hp<hp:
   hits+=1;loss+=hp-w.player_hp
   if dashed and elapsed-dash_at>.55:later+=1
  if b.phase247=="flat":break
 var result={"version":258 if legacy else 259,"pattern":pattern,"trigger":trigger,"hits":hits,"loss":loss,"late_hits":later,"dashed":dashed,"parries":w.parry_count-count,"landings":b.landings247.size(),"seconds":elapsed,"distance_at_flat":Vector2(w.hero.position.x-b.position.x,w.hero.position.z-b.position.z).length()}
 if not legacy and pattern=="dash":await shot("dodge259-after-side-dash")
 text_dummy259(result)
 return result
func text_dummy259(result: Dictionary) -> void:print("DODGE259_TRIAL ",result)
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready251 or not w.console226.has_method("draft_level257"):await process_frame
 w.set_physics_process(false);w.hero.set_physics_process(false);var b=w.boss247;b.set_physics_process(false);w.auto114=false
 check(w.player_hp==12. and w.capacity257()==4,"initial progression and current console remain unchanged")
 b.enter247("angry");b.enter247("flight");b.jump247=2
 w.hero.position=b.position+Vector3(0.,0.,4.);w.hero.velocity=Vector3(4.1,0,0);b.forward247=Vector2.DOWN;b.lock247()
 var commitment=b.committed259;var heading=b.forward247
 w.hero.position+=Vector3(-5.,0,2.)
 b.jump247=3;b.enter247("flight");b.lock247()
 check(b.committed259==commitment and b.forward247==heading,"fourth hop keeps third-hop target after player changes direction")
 w.hero.position.x+=8.;b.jump247=4;b.enter247("flight");b.lock247()
 check(b.committed259==commitment and b.forward247==heading,"fifth hop also keeps the same committed destination")
 w.hero.position=b.position-Vector3(heading.x*4.,0,heading.y*4.);b.jump247=5;b.enter247("flight");b.lock247()
 check(absf(heading.angle_to(b.forward247))<=.6001 and b.group259==1,"final group can only turn about34 degrees")
 commitment=b.committed259;w.hero.position.x+=4.;b.jump247=6;b.enter247("flight");b.lock247()
 check(b.committed259==commitment,"seventh hop cannot re-lock onto dodge endpoint")
 var lock=b.goal247;w.hero.position.z+=3.;b._physics_process(.02)
 check(b.goal247==lock,"airborne trajectory remains fixed")
 # Prove the new commitment does not regress258's consumed return attack.
 w.begin251();b=w.boss247;b.set_physics_process(false);w.hero.set_physics_process(false);w.auto114=false;w.invulnerability=0.;w.hero.dodge_invulnerability=0.;w.hero.parry_t=.15;w.hero.parried=false
 b.hp=1000.;b.enter247("angry");b.enter247("flight");b.jump247=6;b.position=w.hero.position+Vector3(.2,0,0);b.from247=Vector2(b.position.x,b.position.z)-Vector2.RIGHT;b.goal247=Vector2(b.position.x,b.position.z)
 var hp=w.player_hp;b.strike257(2.,Vector2(b.position.x,b.position.z),"tuantuan_sweep");w.reset_impact248();w.parry_grace258=0.;b._physics_process(.21);b._physics_process(.02)
 check(b.reflected248 and b.attack_connected and w.player_hp==hp and b.total248==9,"successful parry still returns one harmless bounce and adds two")
 w.hero.position.z+=5.;b.land247();b._physics_process(.05)
 check(not b.reflected248 and b.phase247=="flight" and b.forward247.dot((Vector2(w.hero.position.x,w.hero.position.z)-b.from247).normalized())>.95,"normal pursuit resumes directly after the parry return")
 metrics.trials=[]
 for pattern in ["stand","retreat","dash"]:
  metrics.trials.append(await trial259(true,pattern));metrics.trials.append(await trial259(false,pattern))
 metrics.trials.append(await trial259(false,"dash",.18))
 var normal=metrics.trials.filter(func(m):return m.version==259 and m.pattern=="stand")[0]
 var retreat=metrics.trials.filter(func(m):return m.version==259 and m.pattern=="retreat")[0]
 var dodges=metrics.trials.filter(func(m):return m.version==259 and m.pattern=="dash")
 check(normal.hits>0 and retreat.hits>0,"standing still and straight retreat remain threatened")
 check(dodges.all(func(m):return m.dashed and m.parries==0 and m.landings==7),"one native side dash works without any parry through the full chain")
 check(dodges.all(func(m):return m.late_hits==0 and m.distance_at_flat>1.85),"side dash then ordinary walking escapes remaining hops after invulnerability expires")
 w.legacy259=false;w.begin251();b=w.boss247;b.set_physics_process(false)
 check(w.echoes256.is_empty() and w.parry_grace258==0. and b.group259==-1,"restart clears committed target and temporary effects")
 w.finish251(false);check(w.echoes256.is_empty() and not w.active114,"ending still clears encounter")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/dodge259-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("DODGE259_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
