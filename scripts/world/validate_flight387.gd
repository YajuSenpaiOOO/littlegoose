extends SceneTree
var failures: Array[String]=[]
var cfg383: Dictionary={}
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func shot(tag: String) -> void:
 for i in 5:
  if tag=="south-beam":
   current_scene.beam_left110=.12
   current_scene.emit_stream110(current_scene.goose.global_position+Vector3(0,.55,3.))
  await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/flight387-"+tag+".png")
func _initialize() -> void:call_deferred("run")
class Harness:
 extends "res://scripts/world/woodland_world387.gd"
 var test_input387:=false
 var click387:=false
 func raw_fire387() -> bool:return click387 if test_input387 else super.raw_fire387()
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg") and not "387" in file:cfg383[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=Harness.new();root.add_child(w);current_scene=w
 var until:=Time.get_ticks_msec()+180000
 while not w.ready350 and Time.get_ticks_msec()<until:await process_frame
 if not w.ready350:check(false,"scene ready deadline");quit(1);return
 check(w.goose.get_script()==preload("res://scripts/combat/goose387.gd"),"real primary goose factory")
 check(w.context202 and w.spider_trial170,"real 354 forest combat context")
 check(w.goose.find_children("*","CollisionObject3D",true,false).is_empty(),"free follower has no scene collider")
 var g=w.goose;var v=g.human383
 check(v.get_child_count()==4,"portable rig only four sprite pieces, no room")
 check(is_instance_valid(v.shadow380) and v.shadow380.mesh!=null,"terrain-conforming union shadow")
 w.combat_paused=true;w.set_process(false);w.set_physics_process(false);w.hero.set_physics_process(false)
 for e in w.enemies:e.set_physics_process(false)
 var vectors: Array[Vector3]=[Vector3.LEFT,Vector3.FORWARD,Vector3.RIGHT,Vector3.BACK]
 for i in 4:
  v.face383(vectors[i]);check(v.direction381==i,"four-way aim "+str(i))
  await shot("direction"+str(i))
 v.face383(Vector3.RIGHT);v.face383(Vector3(.95,0,1.));check(v.direction381==2,"diagonal hysteresis retains right")
 v.face383(Vector3(.7,0,1.));check(v.direction381==3,"dominant forward switches front")
 var paused_phase: float=v.age379;var paused_pose: Transform3D=v.transform
 await create_timer(.2).timeout;check(v.age379==paused_phase and v.transform.is_equal_approx(paused_pose),"pause freezes wings and float")
 w.combat_paused=false
 var oldpos: Vector3=g.position
 for i in 30:g.update_follow(.016,g.position+Vector3.LEFT*4.,false)
 check(g.position.is_finite() and g.position.distance_to(oldpos)<10.,"native follow remains finite and bounded")
 check(g.muzzle().distance_to(v.muzzle383())<.001,"real projectile origin is visible hand anchor")
 check(g.peak385<=g.MAX_SPEED385+.001,"real forest follower speed cap")
 w.jobs347.clear();w._clear_combat_shots()
 for actor in w.enemies.duplicate():actor.queue_free()
 w.enemies.clear();w.actors347.clear()
 for i in 3:await process_frame
 # Exercise actual input scheduler with empty enemies, rather than directly fire_at.
 w.auto114=true;w.target114=null;w.aim_tick114=-1;w.structure335.clear()
 w.test_input387=true;w.click387=true;w.cooldown=0.;w.stop_until=0.;w.fire_needs_release=false
 var empty_before: int=w.fired_count
 w._step_fire_input(.016)
 check(w.fired_count>empty_before and not is_instance_valid(w.target114),"auto mode allows real left-click fire into empty space")
 w.auto114=false;w.cooldown=0.;empty_before=w.fired_count;w._step_fire_input(.016)
 check(w.fired_count>empty_before,"manual mode allows empty-space fire")
 w.test_input387=false;w.click387=false;w.held387=false
 var cursor: Vector2=w.camera.unproject_position(g.global_position+Vector3(0,.44,3))
 var picked: Array=[]
 for phase in ["idle","ready","release"]:
  v.pose386.phase=phase;v.apply_pose386();w.aim_tick114=-1;w._refresh_aim114(cursor);picked.append(w.aim114)
 check(picked[0].distance_to(picked[1])<.0001 and picked[0].distance_to(picked[2])<.0001,"cursor aim invariant under idle/ready/release palm heights")
 var aim_tick: int=w.aim_tick114;v._process(.01)
 check(w.aim_tick114==aim_tick,"visual update does not run aim/input refresh")
 check(w.feather_shot387({}) and not w.feather_shot387({"charged":true}) and not w.feather_shot387({"sword153":true}) and not w.feather_shot387({"stream110":true}),"base feather / charged candy / sword / beam priorities")
 w._clear_combat_shots()
 var enemy=w.spawn347("normal");enemy.set_physics_process(false);enemy.travel351="";enemy.entry350=0.;enemy.play119()
 var at:=Vector2(g.position.x+2.,g.position.z)
 enemy.global_position=Vector3(at.x,w.floor_height(at)+.04,at.y)
 for i in 3:await physics_frame
 w.rebuild_cells110()
 var hp: float=enemy.hp
 var from: Vector3=g.muzzle();var target: Vector3=enemy.hit_area.global_position
 var bullet: Dictionary=w.data_shot110(from,(target-from).normalized()*12.,1.5);bullet.fixed_damage110=1.;bullet.tracking146=0.
 var trace: Dictionary=w._trace_shot(bullet,from,target)
 print("MUZZLE_TRACE383 target_area=",trace.get("collider",null)==enemy.hit_area," layer=",enemy.hit_area.collision_layer)
 for i in 24:w._step_shots(.025);await physics_frame
 check(enemy.hp<hp,"native projectile from human muzzle damages real enemy")
 w._clear_combat_shots()
 w.levels226={"homework":1,"forest_fireboy":1};w.apply_levels226()
 check(w.skills110.geese110.size()==1,"one phantom copy summoned")
 var copy=w.skills110.geese110[0]
 check(copy.get_script()==preload("res://scripts/combat/goose168.gd"),"phantom keeps original bird form")
 w.fire_at(enemy.hit_area.global_position);check(w.shots.size()>0,"native weapon fire creates shots")
 var gains: Array=[]
 for shot in w.shots:gains.append(float(shot.get("goose_gain168",1.)))
 check(gains.has(.4) and gains.has(1.),"native weapon keeps 100% primary / 40% copy")

 # Immediate real firing: no preparation/animation timer runs before bullets.
 w._clear_combat_shots();w.cooldown=0.;w.stop_until=0.
 var south: Vector3=g.global_position+Vector3(0,.55,3.)
 var count_before: int=w.fired_count
 var events_before: int=v.emissions386
 w.fire_at(south)
 check(w.fired_count>count_before and v.emissions386==events_before+1,"first real shot and pose event occur synchronously")
 check(v.direction381==3 and v.pose386.phase=="release","south first shot immediately displays release")
 check(v.body379.texture==v.poses386[1],"connected release body selected, no third cell")
 var primary: Dictionary={}
 for b in w.shots:
  if int(b.get("goose_source168",0))==0:primary=b;break
 check(not primary.is_empty() and (primary.node.global_position-primary.velocity.normalized()*5./w.Profile.PPM).distance_to(g.muzzle())<.003,"native 5px spawn offset originates at release palm")
 await shot("south-release")
 check(w.skills110.feathers_drawn387>0,"real native renderer draws feather projectiles")
 w.cooldown=0.;w.auto114=false
 v._process(.33)
 check(v.pose386.phase=="idle","normal release returns straight to idle")
 w.combat_paused=true;var frozen: float=v.pose386.since_shot;v._process(.2)
 check(v.pose386.since_shot==frozen,"pause freezes attack timing")
 w.combat_paused=false
 # Active native flashlight form; invoke the real emission method, not mock effects.
 w.levels226={"flashlight":1};w.apply_levels226()
 w.skill288=true;w.transform288.playing=true;w.transform288.age=w.transform288.INTRO+.1;w.sync_weapon288();w.beam_left110=.12
 w._clear_combat_shots();w.beam_left110=.12
 var beam_before: int=v.emissions386
 w.emit_stream110(south)
 check(w.shots.size()>0 and v.emissions386>beam_before,"native flashlight emission notifies pose")
 v._process(.02)
 check(v.pose386.phase=="release" and v.beam_mode386,"native beam holds release")
 await shot("south-beam")
 w.beam_left110=0.;v._process(.02)
 check(v.pose386.phase=="idle","beam stop returns directly idle")
 w.reset_skill288();w.levels226={"homework":1};w.apply_levels226()
 v.set_direction381(0);v.fired386(false);v._process(.01)
 check(v.body379.texture!=v.poses386[1],"side flight does not use front attack art")
 v.set_direction381(1);v._process(.01)
 check(v.hair382.visible and v.wing379.position.z>0.,"back wing and foreground hair order retained")
 await shot("firing")
 g.use_human383=false;g._update_follow_visual(g.position+Vector3.RIGHT,false)
 check(g.visual.visible and not v.visible,"old bird comparison switches")
 await process_frame;check(not v.shadow380.visible,"human union shadow hides with rig")
 g.use_human383=true;g._update_follow_visual(g.position+Vector3.RIGHT,false)
 w.auto114=true;w.target114=null;w.hero.velocity=Vector3.FORWARD
 g._update_follow_visual(g.position+Vector3.RIGHT,false);check(v.direction381==1,"auto without target faces travel")
 w.hero.velocity=Vector3.ZERO;g._update_follow_visual(g.position+Vector3.RIGHT,false);check(v.direction381==1,"idle holds heading")
 w.auto114=false;g.last_shot_direction=Vector3.LEFT;g._update_follow_visual(g.position+Vector3.LEFT,false);check(v.direction381==0,"manual mouse aim faces left")
 w.auto114=true
 w.set_process(true);w.set_physics_process(true);w.hero.set_physics_process(true);w.combat_paused=false
 w.restart301()
 await create_timer(3.).timeout;await shot("live-combat")
 check(w.goose==g and g.use_human383,"restart retains real human companion")
 check(Vector2(g.position.x- w.hero.position.x,g.position.z-w.hero.position.z).length()<3.,"restart places companion in forest alongside hero")
 check(g.find_children("*","CollisionObject3D",true,false).is_empty(),"restart does not reintroduce collision")
 for file in cfg383:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==cfg383[file],"existing cfg unchanged "+file)
 var f:=FileAccess.open("res://docs/flight387-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"failures":failures,"primary_only":true,"existing_cfg":cfg383.size()},"\t"));f.close()
 print("FLIGHT387_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():
  w.restart301()
  return
 quit(0 if failures.is_empty() else 1)
