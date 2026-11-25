extends SceneTree
var failures: Array[String]=[]
var cfg383: Dictionary={}
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func shot(tag: String) -> void:
 for i in 5:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/flight383-"+tag+".png")
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg") and not "383" in file:cfg383[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=preload("res://scripts/world/woodland_world383.gd").new();root.add_child(w);current_scene=w
 var until:=Time.get_ticks_msec()+180000
 while not w.ready350 and Time.get_ticks_msec()<until:await process_frame
 if not w.ready350:check(false,"scene ready deadline");quit(1);return
 check(w.goose.get_script()==preload("res://scripts/combat/goose383.gd"),"real primary goose factory")
 check(w.context202 and w.spider_trial170,"real 354 forest combat context")
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
 w.jobs347.clear();w._clear_combat_shots()
 for actor in w.enemies.duplicate():actor.queue_free()
 w.enemies.clear();w.actors347.clear()
 for i in 3:await process_frame
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
 w.fire_at(enemy.hit_area.global_position);check(w.shots.size()>0,"native weapon fire creates shots")
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
 for file in cfg383:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==cfg383[file],"existing cfg unchanged "+file)
 var f:=FileAccess.open("res://docs/flight383-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"failures":failures,"primary_only":true,"existing_cfg":cfg383.size()},"\t"));f.close()
 print("FLIGHT383_DONE ",failures);quit(0 if failures.is_empty() else 1)
