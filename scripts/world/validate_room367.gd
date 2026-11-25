extends SceneTree
var failures: Array[String]=[]
var config: Dictionary={}
var contact366: Dictionary={}
func _initialize() -> void:call_deferred("run")
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(w: Node,tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room367-"+tag+".png")
func move(w: Node,at: Vector2,direction: Vector2,ticks: int) -> void:
 w.hero.position=Vector3(at.x,.05,at.y);w.hero.velocity=Vector3.ZERO;w.hero.reset_physics_interpolation()
 for i in ticks:
  await physics_frame
  w.hero.velocity=Vector3(direction.x*2.5,-.3,direction.y*2.5);w.hero.move_and_slide()
func probe_body366(parent: Node3D,mesh: Mesh,transform: Transform3D,layer: int) -> StaticBody3D:
 var faces:=mesh.get_faces()
 for i in faces.size():faces[i]=transform*faces[i]
 var shape:=ConcavePolygonShape3D.new();shape.set_faces(faces);shape.backface_collision=true
 var collision:=CollisionShape3D.new();collision.shape=shape
 var body:=StaticBody3D.new();body.collision_layer=layer;body.collision_mask=0;body.add_child(collision);parent.add_child(body);return body
func cloth_probe366(w: Node) -> void:
 var source=w.room.QUILT366
 var parent: Node3D=w.room.craft364
 var cover:=probe_body366(parent,w.room.duvet_mesh366.mesh,Transform3D.IDENTITY,1024)
 var sheet:=probe_body366(parent,w.room.fitted365.mesh,w.room.fitted365.transform,2048)
 for tick in 3:await physics_frame
 var space: PhysicsDirectSpaceState3D=w.get_world_3d().direct_space_state
 var min_gap:=100.;var max_gap:=-100.;var hits:=0;var crossings:=0
 var sheet_hits:=0;var sheet_crossings:=0;var sheet_min:=100.
 for y in 17:
  for x in 25:
   var uv:=Vector2(lerpf(.02,.98,float(x)/24.),lerpf(.02,.98,float(y)/16.))
   var lower: Vector3=source.point366(uv,1,false)
   var normal: Vector3=source.duvet_normal366(lerpf(-1.22,1.22,uv.x),lerpf(.43,1.12,uv.y))
   var at: Vector3=parent.global_transform*lower
   var ray:=PhysicsRayQueryParameters3D.create(at+normal*.04,at-normal*.04,1024)
   var hit:=space.intersect_ray(ray)
   if not hit.is_empty():
    var gap: float=(at-hit.position).dot(normal);hits+=1;min_gap=minf(min_gap,gap);max_gap=maxf(max_gap,gap)
    if gap<-.002:crossings+=1
   var bottom: Vector3=source.point366(uv,0,false)
   if source.sheet_distance366(bottom.x,bottom.z)<-.005:
    var world: Vector3=parent.global_transform*bottom
    var q:=PhysicsRayQueryParameters3D.create(world+Vector3.UP*.02,world-Vector3.UP*.25,2048)
    var under:=space.intersect_ray(q)
    if not under.is_empty():
     sheet_hits+=1;var clearance: float=world.y-under.position.y;sheet_min=minf(sheet_min,clearance)
     if clearance<-.002:sheet_crossings+=1
 contact366={"throw_samples":hits,"throw_crossings":crossings,"throw_min_gap":min_gap,"throw_max_gap":max_gap,"sheet_samples":sheet_hits,"sheet_crossings":sheet_crossings,"sheet_min_gap":sheet_min}
 print("CLOTH366 ",contact366)
 check(hits>=420 and crossings==0 and max_gap<.025,"actual throw triangles lie above the actual duvet mesh without a large air gap")
 check(sheet_hits>100 and sheet_crossings==0,"actual duvet underside clears the fitted sheet mesh")
 parent.remove_child(cover);cover.free();parent.remove_child(sheet);sheet.free()
 for tick in 2:await physics_frame
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg"):config[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=preload("res://scripts/world/room_world367.gd").new();root.add_child(w);current_scene=w
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
 check(w.room.craft364.visible and not w.room.layered362.visible,"new prototype is shown by default")
 check(w.room.craft364.find_children("*","Sprite3D",true,false).is_empty(),"prototype head and pillow are mesh volumes, not facing image cards")
 check(w.room.head364.global_basis.is_equal_approx(Basis.IDENTITY),"headboard stays aligned to the room")
 var original_craft364: Transform3D=w.room.craft364.global_transform
 check(w.room.linen365.visible and not w.room.old_mattress365.visible,"new fitted sheet replaces the old supporting surface")
 check(w.room.old_support365.size()==7,"old frame rails and legs are replaced only in the linen comparison")
 check(w.room.old_legs365.size()==4,"four original block legs identified without affecting other furniture")
 for leg in w.room.old_legs365:check(not leg.visible,"old block leg is hidden behind the new rounded foot and skirt")
 var bounds365: AABB=w.room.skirt365.mesh.get_aabb()
 check(bounds365.position.y>.07 and bounds365.end.y<.70,"hem clears the floor and top gathers meet mattress side")
 check(bounds365.size.x<2.78 and bounds365.size.z<3.14,"cloth remains within the stable bed collision envelope")
 for v365 in [0.,.3,.7,1.]:check(w.room.pattern365.point365(0.,v365).distance_to(w.room.pattern365.point365(1.,v365))<.0001,"skirt closes continuously at the rear join")
 await cloth_probe366(w)
 check(w.room.duvet_mesh366.visible and w.room.throw_mesh366.visible,"cream duvet and sage throw are separate visible meshes")
 check(not w.room.pixel367 and w.room.pixel_mats367.size()==6,"original hand-painted style is restored as startup default")
 for pair in w.room.pairs367:check(pair.node.material_override==pair.original,"startup keeps original hand-painted material reference")
 await capture(w,"handpaint-default")
 w.room.set_pixel367(true);w.refresh367()
 await capture(w,"prototype-layout")
 w.set_detail364(true);await capture(w,"detail-painted")
 var bounds367: Transform3D=w.room.craft364.global_transform
 var bodies367: int=w.room.find_children("*","StaticBody3D",true,false).size()
 w.room.set_pixel367(false);w.refresh367()
 for pair in w.room.pairs367:check(pair.node.material_override==pair.original,"P restores exact original hand-painted material reference")
 await capture(w,"detail-original-handpaint")
 w.set_detail364(false);await capture(w,"layout-original-handpaint")
 w.room.set_pixel367(true);w.refresh367()
 for pair in w.room.pairs367:check(pair.node.material_override==pair.pixel,"pixel atlas assigned to the intended bed mesh")
 check(w.room.craft364.global_transform.is_equal_approx(bounds367) and w.room.find_children("*","StaticBody3D",true,false).size()==bodies367,"style switch never changes geometry or collision")
 await capture(w,"layout-pixel")
 w.set_detail364(true)
 var cover_bodies366: int=w.room.find_children("*","StaticBody3D",true,false).size()
 w.room.show_throw366=false;w.room.update_covers366();await capture(w,"detail-duvet-only")
 w.room.show_duvet366=false;w.room.update_covers366();await capture(w,"detail-sheet-only")
 check(not w.room.duvet_mesh366.visible and not w.room.throw_mesh366.visible,"Q reveals the sheet without leaving a floating green throw")
 w.room.show_duvet366=true;w.room.show_throw366=true;w.room.update_covers366()
 check(w.room.find_children("*","StaticBody3D",true,false).size()==cover_bodies366,"duvet and throw switches do not change physics")
 var body_count365: int=w.room.find_children("*","StaticBody3D",true,false).size()
 w.room.set_linen365(false);await capture(w,"detail-old-support")
 check(w.room.old_mattress365.visible and not w.room.linen365.visible,"V comparison restores the old support without overlapping cloth")
 w.room.set_linen365(true)
 check(w.room.find_children("*","StaticBody3D",true,false).size()==body_count365,"linen comparison never changes collision")
 w.room.set_paint364(false);await capture(w,"detail-plain");w.room.set_paint364(true)
 w.room.set_craft364(false);await capture(w,"detail-2d-reference");w.room.set_craft364(true)
 w.set_detail364(false);w.set_follow363(true)
 var initial364: Vector3=w.hero.global_position
 w.hero.set_physics_process(false);w.hero.set_process(false)
 for sample in [[Vector3(-2.4,.05,-2.5),"prototype-follow-left"],[Vector3(3.8,.05,-2.),"prototype-follow-right"]]:
  w.hero.global_position=sample[0];w.hero.reset_physics_interpolation()
  for tick in 120:await physics_frame
  check(w.room.craft364.global_transform.is_equal_approx(original_craft364),"following camera does not move or turn the 3D bed")
  await capture(w,sample[1])
 w.set_follow363(false);w.hero.global_position=initial364;w.hero.reset_physics_interpolation();w.hero.set_physics_process(true);w.hero.set_process(true)
 w.room.set_craft364(false)
 await capture(w,"solid")
 w.room.toggle357()
 check(not w.room.solid357.visible,"original painted cabinet remains available for comparison")
 await capture(w,"card")
 w.room.toggle357()
 check(w.room.anchors362.size()==2 and w.room.layered362.visible,"real bed has two separate sleep anchors")
 w.room.slot_debug362.show();w.room.front362.hide()
 await capture(w,"sleep-slots")
 w.room.slot_debug362.hide();w.room.front362.show()
 w.room.toggle_soft359();await capture(w,"prototype-comparison");w.room.toggle_soft359()
 await capture(w,"day")
 check(not w.follow363 and w.camera.global_position.is_equal_approx(w.camera_home363),"default fixed camera is unchanged")
 var saved_at363: Vector3=w.hero.global_position
 var saved_basis363: Basis=w.camera.global_basis
 var saved_body363: int=w.room.find_children("*","StaticBody3D",true,false).size()
 w.hero.set_physics_process(false);w.hero.set_process(false)
 w.set_follow363(true)
 for sample in [[Vector3(-2.4,.05,-2.5),"follow-bed"],[Vector3(3.8,.05,-2.0),"follow-right"],[Vector3(0.,.05,3.9),"follow-door"]]:
  w.hero.global_position=sample[0];w.hero.reset_physics_interpolation()
  for tick in 120:await physics_frame
  check(w.camera.global_position.distance_to(w.follow_target363())<.13,"follow settles at "+str(sample[1]))
  check(w.camera.global_basis.is_equal_approx(saved_basis363) and w.camera.fov==42.,"follow does not rotate or zoom "+str(sample[1]))
  var shift: Vector3=w.camera.global_position-w.camera_home363
  check(absf(shift.x)<=2.11 and absf(shift.z)<=1.36 and absf(shift.y)<.001,"follow stays within the indoor translation bounds")
  await capture(w,sample[1])
 w.set_sleep362(1)
 for tick in 120:await physics_frame
 check(w.camera.global_position.distance_to(w.follow_target363())<.13,"sleep follows the visible bed anchor rather than the hidden walking actor")
 await capture(w,"follow-sleep")
 w.set_sleep362(0)
 w.set_follow363(false)
 check(w.camera.global_position.is_equal_approx(w.camera_home363),"turning follow off restores exact original shot")
 check(w.room.find_children("*","StaticBody3D",true,false).size()==saved_body363,"camera modes leave furniture collision unchanged")
 w.hero.global_position=saved_at363;w.hero.reset_physics_interpolation();w.hero.set_physics_process(true);w.hero.set_process(true)
 var entry: Vector3=w.hero.global_position
 w.set_sleep362(1)
 check(w.sleeping362 and not w.hero.visible and not w.hero.is_physics_processing(),"single sleep replaces walking actor without duplicate sprite")
 await capture(w,"single")
 w.set_sleep362(2)
 check(w.room.mode362==2 and w.room.actors362.size()==1,"double duvet has reserved second slot and no invented black goose actor")
 await capture(w,"double-reserved")
 w.room.front362.hide();await capture(w,"sleep-layer-open");w.room.front362.show()
 w.interact355()
 check(not w.sleeping362 and w.hero.visible and w.hero.is_physics_processing() and w.hero.global_position.is_equal_approx(entry),"E gets out of bed and restores the walking controller and return position")
 var bodies360: int=w.room.find_children("*","StaticBody3D",true,false).size()
 w.room.toggle_soft359();await capture(w,"prototype-physical-comparison");w.room.toggle_soft359()
 check(w.room.layered362.visible and not w.room.bed360.visible and not w.room.bed358.visible,"new bed disables the entire old assembly including its shadows")
 check(w.room.find_children("*","StaticBody3D",true,false).size()==bodies360,"bed comparison leaves physical clearance unchanged")
 var lamps: Array=w.room.item356("bedside").root.find_children("*","OmniLight3D",true,false)
 for lamp in lamps:lamp.visible=false
 await capture(w,"bedside-lamp-off")
 for lamp in lamps:lamp.visible=true
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
 w.hero.global_position=Vector3(-4.2,.05,-.55);w.hero.reset_physics_interpolation()
 w.interact355()
 check(w.sleeping362 and w.room.mode362==1,"E at the real bed approach enters the single sleeping state")
 w.interact355()
 check(not w.sleeping362 and w.hero.visible and w.hero.is_physics_processing(),"E at bedside restores walking after getting up")
 w.hero.set_physics_process(false)
 w.hero.set_process(false)
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
 await move(w,Vector2(-2.40,-.55),Vector2.UP,70)
 check(w.hero.position.z< -2.7,"continuous movement past the right bed side")
 await capture(w,"bed-side-walk")
 for z in [-1.35,-1.65,-2.5,-3.25]:
  await move(w,Vector2(-2.3,z),Vector2.LEFT,25)
  check(w.hero.position.x> -2.65,"bed right-side stand-off at "+str(z))
  await capture(w,"contact-"+str(z))

 await move(w,Vector2(-6.00,-.55),Vector2.UP,55)
 check(w.hero.position.z< -2.1,"continuous movement past the left bed side")
 await capture(w,"bed-left-walk")
 await move(w,Vector2(-6.,-1.65),Vector2.RIGHT,24)
 check(w.hero.position.x< -5.80,"left side contact retains room for the upright sprite")
 await capture(w,"left-contact")
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
 w.room.set_craft364(true);w.set_detail364(true);await capture(w,"detail-night")
 var lamps364: Array=w.room.item356("bedside").root.find_children("*","OmniLight3D",true,false)
 for lamp in lamps364:lamp.visible=false
 await capture(w,"detail-lamp-off")
 for lamp in lamps364:lamp.visible=true
 w.set_detail364(false);w.room.set_craft364(false)
 w.set_night355(false);w.title_panel.hide();w.prompt.hide()
 await capture(w,"layout")
 check(ResourceLoader.exists("res://scenes/world/world169.tscn"),"exit points to preserved courtyard scene")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"user config unchanged "+file)
 FileAccess.open("res://docs/room367-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"cloth_contact":contact366,"complete":true,"failures":failures,"reachable_cells":reached.size(),"furniture":w.room.footprints.size()},"\t"))
 print("ROOM367_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
