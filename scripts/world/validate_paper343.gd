extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world343.gd"
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
var failures: Array[String]=[]
var config: Dictionary={}
func _initialize() -> void:call_deferred("run")
func check(ok: bool, label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/hud342-"+tag+".png")
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg"):config[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=Trial.new();root.add_child(w);current_scene=w
 var limit:=Time.get_ticks_msec()+180000
 while not is_instance_valid(w.combat_hud342) and Time.get_ticks_msec()<limit:await process_frame
 if not is_instance_valid(w.combat_hud342):quit(1);return
 w.set_process(false);w.set_physics_process(false);w.hero.set_physics_process(false)
 w.theatre314.set_process(false);w.theatre314.cancel();w.theatre314.sample(4.06);w.theatre314.finished=true
 w.waiting_intro314=false;w.core_phase326=true;w.fastener_hp321=144.;w.active114=true;w.combat_paused=false
 w.theatre314.enable_castle327(true);w.theatre314.enable_cannons326(true)
 await physics_frame
 await physics_frame
 w._clear_combat_shots();w.buffs.levels={"eye_exercise":1}
 var area: Area3D=w.theatre314.cannon_areas326[0]
 var shape: CollisionShape3D=area.get_child(0)
 var target: Vector3=shape.global_position
 var point: Vector3=w.section343(shape,target.y)
 check(point.is_finite() and absf(point.y-target.y)<.001,"actual tilted box cross-section preserves flight height")
 for ball in [false,true]:
  w._clear_combat_shots();w.buffs.levels={"eye_exercise":1}
  if ball:w.buffs.levels["bouncy_ball"]=1
  var shot: Dictionary=w.data_shot110(target+Vector3(1.,0.,3.),Vector3.FORWARD*20.,2.)
  shot.split_depth110=1;shot.tracking146=1
  if ball:shot.elastic275=true;shot.bounces275=1;shot.ball273=true
  var old: Vector3=shot.velocity
  w._step_shots(.04)
  check(w.shots.has(shot),"derived projectile survives "+str(ball))
  var turn:=Vector2(old.x,old.z).angle_to(Vector2(shot.velocity.x,shot.velocity.z))
  check(absf(turn)>.001 and absf(turn)<=.1001,"actual native/ball loop steers toward cannon "+str(ball))
  check(absf(shot.velocity.y)<.001 and is_equal_approx(shot.velocity.length(),20.),"tracking stays horizontal and preserves speed "+str(ball))
  check(not shot.has("saved_steer343") and shot.get("steer_age111",0.)>-1.,"legacy steering clock restored "+str(ball))
 w._clear_combat_shots();w.buffs.levels={"bouncy_ball":1}
 var castle: Area3D=w.theatre314.castle_target327
 var at: Vector3=castle.get_child(2).global_position
 for normal in [Vector3(0.,.422618,.906308),Vector3.UP,Vector3(0.,.8,.6)]:
  var incoming:=Vector3(2.,7.,-20.)
  var shot: Dictionary=w.data_shot110(at,incoming,2.)
  var node=shot.node;var fired: int=w.fired_count
  w.redirect275(shot,{"collider":castle,"position":at,"normal":normal},10.)
  check(absf(shot.velocity.y)<.001 and is_equal_approx(shot.velocity.length(),incoming.length()),"oblique incident and top/slope normals cannot launch skyward "+str(normal))
  check(shot.node==node and w.fired_count==fired and is_equal_approx(shot.fixed_damage110,7.),"redirect retains projectile and damage")
 w._clear_combat_shots();w.buffs.levels={}
 var shot: Dictionary=w.data_shot110(target+Vector3(1.,0.,3.),Vector3.FORWARD*20.,2.)
 shot.split_depth110=1;shot.tracking146=0
 var old: Vector3=shot.velocity
 w._step_shots(.04)
 check(shot.velocity==old,"no eye no derived tracking")
 w._clear_combat_shots();w.buffs.levels={"eye_exercise":1}
 var original: Dictionary=w.data_shot110(target+Vector3(1.,0.,3.),Vector3.FORWARD*20.,2.)
 w._step_shots(.04)
 check(not original.has("saved_steer343") and w.use_native113,"primary native path retained")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"config unchanged "+file)
 FileAccess.open("res://docs/paper343-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures,"tracking":w.tracking_stats343},"\t"))
 print("PAPER343_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
