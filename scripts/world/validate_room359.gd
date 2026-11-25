extends SceneTree
var failures: Array[String]=[]
var config: Dictionary={}
func _initialize() -> void:call_deferred("run")
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(w: Node,tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room359-"+tag+".png")
func move(w: Node,at: Vector2,direction: Vector2,ticks: int) -> void:
 w.hero.position=Vector3(at.x,.05,at.y);w.hero.velocity=Vector3.ZERO;w.hero.reset_physics_interpolation()
 for i in ticks:
  await physics_frame
  w.hero.velocity=Vector3(direction.x*2.5,-.3,direction.y*2.5);w.hero.move_and_slide()
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg"):config[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=preload("res://scripts/world/room_world359.gd").new();root.add_child(w);current_scene=w
 var limit:=Time.get_ticks_msec()+30000
 while not w.ready355 and Time.get_ticks_msec()<limit:await process_frame
 check(w.ready355,"standalone room boots without forest or combat")
 if not w.ready355:quit(1);return
 for i in 20:await physics_frame
 check(w.hero.get_script().resource_path=="res://scripts/combat/hero192.gd" and w.hero.is_on_floor(),"unchanged 192 actor walks on the actual room floor")
 check(absf(w.hero.visual.rotation.x)<.001 and absf(w.hero.visual.pixel_size*w.hero.directions.down.idle_height-1.6)<.001,"approved upright hero body height and foot anchor preserved")
 check(absf(w.camera.rotation_degrees.x+25.)<.01 and w.camera.fov==42.,"fixed 25 degree perspective camera")
 check(w.room.footprints.size()>=10 and w.enemies.is_empty(),"furniture footprints exist without enemies or rewards")
 check(w.room.cards356.size()==2 and not w.goose_root.visible,"two painted props and no bird-form home actor")
 var basis: Basis=w.camera.global_basis
 for row in w.room.cards356:
  check(row.sprite.global_basis.is_equal_approx(basis) and row.sprite.scale.is_equal_approx(Vector3.ONE),"camera-facing art preserves uniform geometry: "+str(row.id))
  check(row.sprite.material_override.get_shader_parameter("depth356")==row.depth,"independent authored depth proxy: "+str(row.id))
 check(w.room.solid357.visible and w.room.solid357.rotation==Vector3.ZERO,"solid cabinet uses room-aligned real geometry")
 await capture(w,"solid")
 w.room.toggle357()
 check(not w.room.solid357.visible,"original painted cabinet remains available for comparison")
 await capture(w,"card")
 w.room.toggle357()
 check(w.room.sleep_anchors358.size()==2 and w.room.bed358.visible,"real bed has two separate sleep anchors")
 w.room.slots358.show();w.room.blanket358.hide()
 await capture(w,"sleep-slots")
 w.room.slots358.hide();w.room.blanket358.show()
 w.room.toggle_bed358();await capture(w,"old-bed");w.room.toggle_bed358()
 await capture(w,"day")
 w.room.toggle_soft359();await capture(w,"box-comparison");w.room.toggle_soft359()
 w.room.set_art356(false)
 await capture(w,"volumes")
 w.room.set_art356(true)
 # Native capsule clearance across the entire walkable room, not image rectangles.
 var shape:=CapsuleShape3D.new();shape.radius=.25;shape.height=1.26
 var query:=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1;query.exclude=[w.hero.get_rid()]
 var clear: Dictionary={}
 for x in range(-24,25):
  for z in range(-16,17):
   query.transform=Transform3D(Basis.IDENTITY,Vector3(float(x)*.25,.69,float(z)*.25))
   if w.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():clear[Vector2i(x,z)]=true
 var queue: Array[Vector2i]=[Vector2i(0,11)];var reached: Dictionary={Vector2i(0,11):true};var cursor:=0
 while cursor<queue.size():
  var cell: Vector2i=queue[cursor];cursor+=1
  for direction in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
   var next: Vector2i=cell+direction
   if clear.has(next) and not reached.has(next):reached[next]=true;queue.append(next)
 for row in w.room.footprints:
  var cell:=Vector2i(roundi(row.approach.x/.25),roundi(row.approach.y/.25))
  check(reached.has(cell),"walkable approach: "+str(row.id))
 w.hero.set_physics_process(false)
 w.hero.position=Vector3(-4.25,.03,-.55);w.hero.reset_physics_interpolation()
 await capture(w,"bed-front")
 w.hero.position=Vector3(-2.65,.03,-2.45);w.hero.reset_physics_interpolation()
 await capture(w,"bed-side")
 w.hero.position=Vector3(2.15,.03,-2.25);w.hero.reset_physics_interpolation()
 await capture(w,"wardrobe-front")
 await move(w,Vector2(-2.7,-.55),Vector2.LEFT,60)
 check(w.hero.position.x< -4.8,"removed round bed leaves clear passage")
 await move(w,Vector2(-4.7,2.7),Vector2.UP,65)
 check(w.hero.position.z<.3 and w.room.item356("nest").is_empty(),"former round bed area has no hidden collision or interaction")
 await move(w,Vector2(-2.55,-.55),Vector2.UP,70)
 check(w.hero.position.z< -2.7,"continuous movement past the right bed side")
 await capture(w,"bed-side-walk")
 await move(w,Vector2(-5.95,-.55),Vector2.UP,55)
 check(w.hero.position.z< -2.1,"continuous movement past the left bed side")
 await capture(w,"bed-left-walk")
 await move(w,Vector2(-4.25,-.55),Vector2.UP,70)
 check(w.hero.position.z>-.98,"bed physically blocks the player")
 await move(w,Vector2(2.15,-2.2),Vector2.UP,70)
 check(w.hero.position.z>-2.92,"wardrobe physically blocks the player")
 await move(w,Vector2(5.7,2.8),Vector2.RIGHT,60)
 check(w.hero.position.x<6.13,"cutaway side wall retains stable collision")
 await move(w,Vector2(0.,3.8),Vector2.DOWN,45)
 check(w.hero.position.z>5.0 and w.hero.position.y>-.1,"front doorway is a real open passage onto porch")
 w.hero.position=Vector3(4.55,.03,-1.35);w.hero.reset_physics_interpolation();w.interact355()
 check(w.pour355>1. and w.nearest355.id=="hourglass","hourglass has accessible interaction and sand feedback")
 await capture(w,"hourglass")
 w.hero.position=Vector3(2.15,.03,-2.25);w.interact355()
 check(w.nearest355.id=="wardrobe" and w.message355.contains("换洗"),"new wardrobe interaction is reachable")
 var body_count: int=w.room.find_children("*","StaticBody3D",true,false).size()
 w.room.overlay.show();w.set_night355(true)
 w.room.set_art356(false);w.room.set_art356(true)
 check(w.room.find_children("*","StaticBody3D",true,false).size()==body_count and w.sun.light_energy<.1,"night and footprint view leave collision unchanged")
 w.room.overlay.hide();w.reset355();w.message_left355=0.
 await capture(w,"night")
 w.set_night355(false);w.title_panel.hide();w.prompt.hide()
 await capture(w,"layout")
 check(ResourceLoader.exists("res://scenes/world/world169.tscn"),"exit points to preserved courtyard scene")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"user config unchanged "+file)
 FileAccess.open("res://docs/room359-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures,"reachable_cells":reached.size(),"furniture":w.room.footprints.size()},"\t"))
 print("ROOM359_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
