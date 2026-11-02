extends SceneTree
var w: Node3D
func _initialize() -> void:call_deferred("run")
func shot(tag: String) -> void:
 for i in 5:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/pig219-display-"+tag+".png")
func run() -> void:
 w=load("res://scenes/world/world219.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready219:await process_frame
 w.pig219.manual219=true;w.cotton219.manual219=true;w.cotton219.clear219();w.pig219.reset219();w.hero.set_physics_process(false)
 var checks=[]
 w.hero.position=w.pig219.position+Vector3(-1.2,.05,0.)
 for i in 3:await physics_frame
 var hit=w.hero.move_and_collide(Vector3(2.,0.,0.))
 checks.append({"name":"physical pig footprint blocks hero","pass":hit!=null and hit.get_collider()==w.pig219.body})
 for side in [Vector2(0,1.1),Vector2(0,-1.1),Vector2(-1.5,0),Vector2(1.5,0)]:
  w._teleport15(w.spawn216+side);await shot(str(side.x)+"_"+str(side.y))
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();await create_timer(.4).timeout
 await shot("lamps-on")
 w.lighting191.set_process(false)
 for lamp in w.lighting191.lamps:lamp.light_energy=0.
 await shot("lamps-off")
 checks.append({"name":"grounded silhouette visible","pass":w.pig219.shadow.visible and w.pig219.shadow.mesh!=null})
 FileAccess.open("res://docs/pig219-display-validation.json",FileAccess.WRITE).store_string(JSON.stringify(checks,"\t"))
 print("219_DISPLAY ",checks)
 quit(0 if checks.all(func(c):return c.pass) else 1)
