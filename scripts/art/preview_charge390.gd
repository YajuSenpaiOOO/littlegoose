extends SceneTree
const FOLDER := "res://assets/black_goose_charge390/"
class Fixture:
 extends Node3D
 class Buffs:
  extends RefCounted
  func level(id: String) -> int:return 1 if id=="slingshot" else 0
 var buffs:=Buffs.new()
 var player_hp:=12.0
 var charge_age:=0.0
 func charge_ratio() -> float:return clampf(charge_age/.72,0.,1.)
 var camera: Camera3D
 var sun: DirectionalLight3D
 var combat_paused := false
 var contact_enabled := true
 var held387:=false
 var beam_left110:=0.0
 var wave_state:="fighting"
 var result_open:=false
 var charge_active:=false
 var cooldown:=0.0
 func attack_cooldown() -> float:return .34
 func floor_height(_p: Vector2) -> float: return 0.0
class Overlay:
 extends Node2D
 var camera: Camera3D
 var rigs: Array = []
 var shots: Array = []
 var time := 0.0
 var feather: Texture2D
 func _draw() -> void:
  var font := ThemeDB.fallback_font
  draw_rect(Rect2(0,0,1200,91),Color("171d2b"))
  draw_string(font,Vector2(24,32),"FOUR-WAY CHARGE / ORIGINAL COLORS / SWAY AND BACKWARD KICK",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("f4e8d1"))
  for i in 3:
   draw_string(font,Vector2(i*400+25,72),["Left / charge > release","Back / charge > release","Right / charge > release"][i],HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("ddd0ee"))
   draw_string(font,Vector2(i*400+155,600),("IDLE" if rigs[i].charge_phase389()=="" else rigs[i].charge_phase389().to_upper()).to_upper(),HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("f4e8d1"))
  for shot in shots:
   var age: float = time-shot.time
   if age<0 or age>.8: continue
   var a: Vector2 = camera.unproject_position(shot.origin+shot.direction*age*1.6)
   draw_set_transform(a,PI/2)
   draw_texture_rect_region(feather,Rect2(-26,-26,52,52),Rect2(680,245,414,414))
   draw_set_transform(Vector2.ZERO)
  draw_rect(Rect2(0,625,1200,55),Color("171d2b"))
  draw_string(font,Vector2(24,651),"Gather and sway > hold full charge > release and recoil > idle | no red tint",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("c8bdd4"))
func _initialize() -> void: call_deferred("run")
func run() -> void:
 root.size=Vector2i(1200,680);root.content_scale_size=root.size
 var w:=Fixture.new();root.add_child(w);current_scene=w
 w.camera=Camera3D.new();w.add_child(w.camera);w.camera.projection=Camera3D.PROJECTION_ORTHOGONAL;w.camera.size=2.65
 w.camera.position=Vector3(0,1.05+sin(deg_to_rad(25.))*9,cos(deg_to_rad(25.))*9);w.camera.look_at(Vector3(0,1.05,0));w.camera.current=true
 var env:=WorldEnvironment.new();w.add_child(env);env.environment=Environment.new()
 env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("303548")
 env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color("e5dcf0");env.environment.ambient_light_energy=.8
 w.sun=DirectionalLight3D.new();w.add_child(w.sun);w.sun.rotation_degrees=Vector3(-55,-25,0);w.sun.light_energy=.8
 var floor_mesh:=MeshInstance3D.new();floor_mesh.mesh=PlaneMesh.new();floor_mesh.mesh.size=Vector2(12,12)
 var mat:=StandardMaterial3D.new();mat.albedo_color=Color("555064");floor_mesh.material_override=mat;w.add_child(floor_mesh)
 var overlay:=Overlay.new();root.add_child(overlay);overlay.camera=w.camera
 overlay.feather=preload("res://assets/candy_bullets_v1/pearl_core_v2.png")
 for i in 3:
  var actor:=Node3D.new();w.add_child(actor);actor.position=Vector3((i-1)*1.5,.30,0)
  var rig:=preload("res://scripts/combat/flight_visual390.gd").new();rig.battle=w;actor.add_child(rig);rig.set_process(false);rig.face383([Vector3.LEFT,Vector3.FORWARD,Vector3.RIGHT][i]);overlay.rigs.append(rig)
 var released:=false
 var failures: Array=[];var release_samples: Array=[0,0,0];var wing_indices: Array=[[],[],[]]
 for frame in 130:
  overlay.time=frame*.04
  for i in 3:
   w.charge_active=overlay.time>=.64 and overlay.time<2.36
   w.charge_age=maxf(0.,overlay.time-.64)
   var rig=overlay.rigs[i]
   if overlay.time>=2.36 and not released:
    rig.charge_emitting389=true;rig.charged_fired389()
    overlay.shots.append({"time":overlay.time,"origin":rig.muzzle383(),"direction":[Vector3.LEFT,Vector3.FORWARD,Vector3.RIGHT][i]})
    rig.charge_emitting389=false
   rig._process(.04)
   if rig.charge_phase389()=="release":release_samples[i]+=1
   if not wing_indices[i].has(rig.index379):wing_indices[i].append(rig.index379)
  if overlay.time>=2.36:released=true
  overlay.queue_redraw()
  for j in 2:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(FOLDER+"preview-"+str(frame).pad_zeros(3)+".png")
 for i in 3:
  if overlay.rigs[i].charge_phase389()!="":failures.append("failed to return idle "+str(i))
  if wing_indices[i].size()!=4:failures.append("wing animation frozen "+str(i))
 var f:=FileAccess.open(FOLDER+"preview-validation.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"failures":failures,"release_samples":release_samples,"wing_frames":wing_indices,"release_hold":.42,"source_columns_in_preview_order":[0,2,1],"duration":5.2},"\t"));f.close()
 print("FOUR_CHARGE390_PREVIEW_DONE ",failures);quit(0 if failures.is_empty() else 1)
