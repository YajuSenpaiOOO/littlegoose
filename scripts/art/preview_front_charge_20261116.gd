extends SceneTree
const FOLDER := "res://art/concepts/black_goose_charge_front_20261116/"
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
  draw_string(font,Vector2(24,32),"FRONT CHARGE / PUFFED CHEEKS > OPEN-MOUTH RECOIL",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("f4e8d1"))
  for i in 2:
   draw_string(font,Vector2(i*600+50,72),["Charge 0.72s / release","Fully charged / hold 1s longer / release"][i],HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("ddd0ee"))
   draw_string(font,Vector2(i*600+250,600),str(rigs[i].charge_state.phase).to_upper(),HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("f4e8d1"))
  for shot in shots:
   var age: float = time-shot.time
   if age<0 or age>.8: continue
   var a: Vector2 = camera.unproject_position(shot.origin+shot.direction*age*1.6)
   draw_set_transform(a,PI/2)
   draw_texture_rect_region(feather,Rect2(-30,-30,60,60),Rect2(680,245,414,414))
   draw_set_transform(Vector2.ZERO)
  draw_rect(Rect2(0,625,1200,55),Color("171d2b"))
  draw_string(font,Vector2(24,651),"Idle > squint + puffed cheeks > hands spring back + open mouth > idle | live wings",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("c8bdd4"))
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
 for i in 2:
  var actor:=Node3D.new();w.add_child(actor);actor.position=Vector3((i-.5)*1.9,.30,0)
  var rig:=preload("res://scripts/art/front_charge_visual_20261116.gd").new();rig.battle=w;actor.add_child(rig);rig.set_process(false);rig.face383(Vector3.BACK);overlay.rigs.append(rig)
 var release_at: Array=[1.36,2.36]
 var failures: Array=[];var release_samples: Array=[0,0];var wing_indices: Array=[[],[]]
 for frame in 130:
  overlay.time=frame*.04
  for i in 2:
   var rig=overlay.rigs[i]
   for step in 4:
    var t: float=overlay.time+step*.01
    var held: bool=t>=.64 and t<float(release_at[i])-.00001
    var before: Vector3=rig.stored_cast_point()
    rig.advance_charge(.01,held)
    if rig.charge_state.emitted:overlay.shots.append({"time":t,"origin":before,"direction":Vector3.BACK})
   if rig.charge_state.phase=="release":release_samples[i]+=1
   if not wing_indices[i].has(rig.index379):wing_indices[i].append(rig.index379)
  overlay.queue_redraw()
  for j in 2:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(FOLDER+"preview-"+str(frame).pad_zeros(3)+".png")
 for i in 2:
  if overlay.rigs[i].charge_state.emissions!=1:failures.append("expected one charge release "+str(i))
  if overlay.rigs[i].charge_state.phase!="idle":failures.append("failed to return idle "+str(i))
  if wing_indices[i].size()!=4:failures.append("wing animation frozen "+str(i))
 var f:=FileAccess.open(FOLDER+"preview-validation.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"failures":failures,"release_samples":release_samples,"wing_frames":wing_indices,"release_hold":.42,"charge_time":.72,"release_times":[1.36,2.36],"duration":5.2},"\t"));f.close()
 print("FRONT_CHARGE_PREVIEW_DONE ",failures);quit(0 if failures.is_empty() else 1)
