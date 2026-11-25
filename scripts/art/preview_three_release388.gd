extends SceneTree
const FOLDER := "res://assets/black_goose_attack388/"
class Fixture:
 extends Node3D
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
  draw_string(font,Vector2(24,32),"THREE NEW RELEASE POSES / SAME CONTINUOUS CASTING RHYTHM",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("f4e8d1"))
  for i in 3:
   draw_string(font,Vector2(i*400+25,72),["Left / casting release","Back / casting release","Right / casting release"][i],HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("ddd0ee"))
   draw_string(font,Vector2(i*400+155,600),str(rigs[i].pose386.phase).to_upper(),HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("f4e8d1"))
  for shot in shots:
   var age: float = time-shot.time
   if age<0 or age>.8: continue
   var a: Vector2 = camera.unproject_position(shot.origin+shot.direction*age*1.6)
   draw_set_transform(a,PI/2)
   draw_texture_rect_region(feather,Rect2(-26,-13,52,26),Rect2(134,415,1044,518))
   draw_set_transform(Vector2.ZERO)
  draw_rect(Rect2(0,625,1200,55),Color("171d2b"))
  draw_string(font,Vector2(24,651),"Idle > sustained release > idle | live four-frame wings, hover and northward recoil",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("c8bdd4"))
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
 overlay.feather=ImageTexture.create_from_image(Image.load_from_file("res://art/concepts/black_goose_feather_B_simple_20261114/feather-pixel.png"))
 for i in 3:
  var actor:=Node3D.new();w.add_child(actor);actor.position=Vector3((i-1)*1.5,.30,0)
  var rig:=preload("res://scripts/combat/flight_visual388.gd").new();rig.battle=w;actor.add_child(rig);rig.set_process(false);rig.face383([Vector3.LEFT,Vector3.FORWARD,Vector3.RIGHT][i]);overlay.rigs.append(rig)
 var next: Array=[.98,.98,.98]
 var failures: Array=[];var release_samples: Array=[0,0,0];var wing_indices: Array=[[],[],[]]
 for frame in 156:
  overlay.time=frame/24.0
  for i in 3:
   var trigger: bool=overlay.time>=.98 and overlay.time<4.2
   w.held387=trigger
   var rig=overlay.rigs[i]
   if trigger and overlay.time+.00001>=next[i]:
    rig.fired386(false);next[i]+=.34
    overlay.shots.append({"time":overlay.time,"origin":rig.muzzle383(),"direction":[Vector3.LEFT,Vector3.FORWARD,Vector3.RIGHT][i]})
   rig._process(1./24.)
   if rig.pose386.phase=="release":release_samples[i]+=1
   if not wing_indices[i].has(rig.index379):wing_indices[i].append(rig.index379)
  overlay.queue_redraw()
  for j in 2:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(FOLDER+"preview-"+str(frame).pad_zeros(3)+".png")
 for i in 3:
  if overlay.rigs[i].pose386.phase!="idle":failures.append("failed to return idle "+str(i))
  if wing_indices[i].size()!=4:failures.append("wing animation frozen "+str(i))
 var f:=FileAccess.open(FOLDER+"preview-validation.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"failures":failures,"release_samples":release_samples,"wing_frames":wing_indices,"release_hold":.32,"source_columns_in_preview_order":[0,2,1],"duration":6.5},"\t"));f.close()
 print("THREE_RELEASE388_DONE ",failures);quit(0 if failures.is_empty() else 1)
