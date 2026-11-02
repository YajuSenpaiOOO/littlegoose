extends SceneTree
var checks: Array[Dictionary]=[]
var world: Node3D
var rig: Node3D
func _initialize() -> void: call_deferred("run")
func check(value: bool,label: String) -> void:
 checks.append({"name":label,"pass":value});print("205 ","PASS " if value else "FAIL ",label)
func snapshot(name205: String) -> void:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/sister205-"+name205+".png")
func run() -> void:
 world=load("res://scenes/world/world205.tscn").instantiate();root.add_child(world);current_scene=world
 var deadline=Time.get_ticks_msec()+180000
 while not world.ready205 and Time.get_ticks_msec()<deadline: await process_frame
 if not world.ready205:
  check(false,"world205 initialization deadline");finish();return
 rig=world.transport205;rig.manual=true
 check(not world.context202 and not world.active114,"no trial context or combat auto-start")
 check(world.meadow.landmarks.grove==world.original_grove202,"original grove reference preserved")
 check(world.memory_save116=="user://sister205_preview.cfg","isolated preview save")
 check(world.clear_route205,"route is swept clear of existing physical props")
 check(world.hero.get_script().resource_path.ends_with("hero192.gd"),"upright192 hero retained")
 check(rig.cards.size()==5 and rig.shadows.size()==5,"independent sprites and contour shadows")
 check(rig.textures.bat_up.get_size()==rig.textures.bat_down.get_size(),"flap frames share canvas")
 check(rig.bat_anchor(0).is_equal_approx(rig.bat_anchor(1)),"ring anchor stable across flap frames")
 check(rig.textures.bat_up.get_image().get_pixel(0,0).a<.01,"real transparent sprite background")
 var manifest={}
 for key in rig.manifests:
  var b: Rect2i=rig.manifests[key]
  var dimensions: Vector2=rig.textures[key].get_size()
  manifest[key]={"dimensions":[dimensions.x,dimensions.y],"alpha_bounds":[b.position.x,b.position.y,b.size.x,b.size.y],"alpha_threshold":.6}
 FileAccess.open("res://assets/sister205/manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t"))
 var safe=true
 for i in 21:
  var p: Vector2=rig.start_at.lerp(rig.end_at,float(i)/20.)
  if absf(world.floor_height(p)+2.2)>.25: safe=false
 check(safe,"transport path stays on low forest floor")
 rig.running=false;var clock205: float=rig.elapsed;rig.advance(3.)
 check(rig.elapsed==clock205,"pause freezes transport clock and flapping")
 var pause_key=InputEventKey.new();pause_key.pressed=true;pause_key.physical_keycode=KEY_F6
 world._input(pause_key)
 check(rig.running,"F6 resumes animation through real preview input")
 rig.running=true
 for step in ["approach","board","lift","travel","land","alight","depart","rest"]:
  rig.enter(step);rig.age=float(rig.DURATIONS[step])*.65;rig.evaluate();rig._process(0.)
  if step=="approach": check(rig.rig_visible and not rig.sitting,"empty pickup approaches standing sister")
  if step=="board": check(rig.sitting,"boarding switches to seated key pose")
  if step=="travel":
   check(rig.person_at.distance_to(rig.start_at)>1. and rig.lift>.65,"flight displaces and lifts visual")
   check(absf(rig.body.global_position.y-world.floor_height(rig.person_at))<.01,"collision remains at ground footprint")
   for i in 2:
    var uv=Vector2(.089,.091) if i==0 else Vector2(.922,.091)
    var mount=rig.pixel_point(rig.hammock,rig.textures.hammock.get_size()*uv)
    check(rig.bats[i].global_position.distance_to(mount)<.001,"bat "+str(i)+" ring joins hammock mount")
   await snapshot("travel")
  if step=="alight": check(not rig.sitting and rig.person_at.is_equal_approx(rig.end_at),"sister stands at destination")
  if step=="depart":
   check(not rig.sitting and rig.rig_visible and rig.rig_at.distance_to(rig.person_at)>1.,"empty hammock departs without carrying sister")
   await snapshot("depart")
  if step=="rest": check(not rig.rig_visible and not rig.sitting,"all carriers hidden after departure")
 var shape=SphereShape3D.new();shape.radius=.15
 var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.transform.origin=rig.body.global_position+Vector3.UP*.3;query.collision_mask=1
 await physics_frame
 var blocked=false
 for hit in world.get_world_3d().direct_space_state.intersect_shape(query):
  if hit.collider==rig.body: blocked=true
 check(blocked,"real collision exists independently of artwork visibility")
 rig.restart();rig.manual=true
 var full=0.
 for duration in rig.DURATIONS.values(): full+=float(duration)
 rig.advance(full+.01)
 check(rig.cycles==1 and rig.state=="idle","full cycle returns and reverses route")
 rig.restart()
 for i in 180: rig.advance(1./30.)
 var position30: Vector2=rig.person_at;var phase30: String=rig.state
 rig.restart()
 for i in 720: rig.advance(1./120.)
 check(rig.person_at.distance_to(position30)<.001 and rig.state==phase30,"route and timing independent of frame rate")
 rig.restart();rig.enter("travel");rig.age=1.4;rig.evaluate();rig._process(0.)
 world.time55.preview_at(20.);world.time55.visual_hour=20.;world.time55.apply_look()
 await create_timer(.5).timeout
 check(rig.seated.material_override.shader.resource_path.ends_with("card_depth199.gdshader"),"native lit depth material reused")
 await snapshot("night")
 world.time55.preview_at(10.);world.time55.visual_hour=10.;world.time55.apply_look()
 await create_timer(.5).timeout
 await snapshot("day")
 rig.restart();rig._process(0.)
 check(rig.state=="idle" and rig.standing.visible and not rig.seated.visible,"restart restores stable idle")
 finish()
func finish() -> void:
 var failures=checks.filter(func(item): return not item["pass"])
 FileAccess.open("res://docs/sister205-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"scope":"205 transport and real-world GPU captures; not full combat or manual art acceptance"},"\t"))
 print("205_RESULT ",checks.size()," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
