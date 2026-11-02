extends SceneTree
var w: Node3D
var checks: Array[Dictionary]=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
 checks.append({"name":label,"pass":ok});print("216 ",ok," ",label)
func shot(tag: String) -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/fat-cat216-"+tag+".png")
func run() -> void:
 w=load("res://scenes/world/world216.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready216: await process_frame
 var c=w.cat216;c.manual216=true
 check(w.hero.get_script().resource_path.ends_with("hero192.gd"),"upright hero192 retained")
 check(not w.active114 and not w.context202,"no trial/progression or forest context replacement")
 check(c.atlas_frames.size()==6,"six approved walk frames loaded")
 check(c.visual.material_override.shader.resource_path.ends_with("sister_receiver207.gdshader"),"existing lighting and foot depth material reused")
 var normal=w.camera.global_basis
 c._process(0.)
 check(c.visual.global_basis.is_equal_approx(normal),"fixed camera-plane presentation preserves proportions")
 check(c.collision_layer==1 and is_equal_approx(c.get_child(0).shape.radius,.70),"independent stable physical footprint")
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 await shot("day")
 c.original216=true;c.update_visual216();await shot("original")
 c.original216=false;c.update_visual216()
 var previous: int=c.frame216;c.advance216(.08)
 check(c.frame216!=previous,"animation advances at 14fps")
 c.running216=false;var clock: float=c.clock216;c.advance216(1.)
 check(c.clock216==clock,"pause freezes animation")
 c.running216=true
 var start: Vector3=c.global_position;c.moving216=true
 for i in 40: c.advance216(.02)
 check(c.global_position.distance_to(start)>.05,"short walk moves in map")
 check(absf(c.global_position.y-w.floor_height(Vector2(c.global_position.x,c.global_position.z)))<.05,"walking stays grounded")
 c.reset216();c.running216=false
 w.hero.set_physics_process(false)
 w.hero.global_position=c.global_position+Vector3(-1.5,.05,0.)
 for i in 3: await physics_frame
 var hit=w.hero.move_and_collide(Vector3(2.,0.,0.))
 check(hit!=null and hit.get_collider()==c,"hero physically blocked by cat ground footprint")
 for side in [Vector2(0.,1.3),Vector2(0.,-1.3),Vector2(-1.6,0.),Vector2(1.6,0.)]:
  w._teleport15(c.origin216+side)
  for i in 3: await physics_frame
  await shot("side-"+str(checks.size())+"-"+str(side.x)+"-"+str(side.y))
 w._teleport15(c.origin216+Vector2(-2.1,0.))
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();await create_timer(.4).timeout
 await shot("night")
 var energies=[]
 for lamp in w.lighting191.lamps:
  energies.append(lamp.light_energy);lamp.light_energy=0.
 w.lighting191.set_process(false);await shot("lamps-off")
 for i in energies.size():w.lighting191.lamps[i].light_energy=energies[i]
 w.lighting191.set_process(true)
 check(c.shadow.visible and c.shadow.mesh!=null,"terrain contour shadow active")
 var key=InputEventKey.new();key.pressed=true;key.physical_keycode=KEY_F7;w._input(key)
 check(c.global_position.distance_to(start)<.01 and not c.moving216,"F7 restores position and stationary preview")
 var failures=checks.filter(func(a):return not a.pass)
 FileAccess.open("res://docs/fat-cat216-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size()},"\t"))
 print("216_RESULT ",checks.size()," checks ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
