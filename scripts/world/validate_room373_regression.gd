extends "res://scripts/world/validate_room368.gd"
var face369: Dictionary={}
func capture(w: Node,tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room373-regression-"+tag+".png")
func face_probe369(w: Node) -> void:
 var hidden: Array[Node3D]=[]
 for n in w.room.craft364.find_children("*","GeometryInstance3D",true,false):
  if not w.room.sleep_root369.is_ancestor_of(n) and n.visible:hidden.append(n);n.hide()
 var reference: Image=await snap368()
 w.room.sleep_root369.hide();var background: Image=await snap368();w.room.sleep_root369.show()
 for n in hidden:n.show()
 var result: Image=await snap368()
 reference.save_png("res://docs/room373-regression-face-reference.png");background.save_png("res://docs/room373-regression-face-background.png");result.save_png("res://docs/room373-regression-face-result.png")
 var a: Vector2=w.camera.unproject_position(w.room.craft364.to_global(w.room.SLEEP369.point369(Vector2(.32,.30))))
 var b: Vector2=w.camera.unproject_position(w.room.craft364.to_global(w.room.SLEEP369.point369(Vector2(.68,.515))))
 # canvas_items uses a 1600x1000 logical viewport but captures the 1440x900 window texture.
 var render_scale: Vector2=Vector2(result.get_size())/w.camera.get_viewport().get_visible_rect().size
 a*=render_scale;b*=render_scale
 var count:=0;var lost:=0
 for y in range(maxi(0,int(a.y)),mini(reference.get_height(),int(b.y))):
  for x in range(maxi(0,int(a.x)),mini(reference.get_width(),int(b.x))):
   if delta368(reference.get_pixel(x,y),background.get_pixel(x,y))<.25:continue
   count+=1
   if delta368(reference.get_pixel(x,y),result.get_pixel(x,y))>.10:lost+=1
 face369={"pixels":count,"occluded":lost};print("FACE369 ",face369)
 check(count>100 and float(lost)/count<.02,"new face is visible above pillow and duvet, without cutting furniture")
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg"):config[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=preload("res://scripts/world/room_world373.gd").new();root.add_child(w);current_scene=w
 var limit:=Time.get_ticks_msec()+30000
 while not w.ready355 and Time.get_ticks_msec()<limit:await process_frame
 check(w.ready355,"369 room boots")
 if not w.ready355:quit(1);return
 while not is_instance_valid(w.companion373) or not w.companion373.ready373:await physics_frame
 w.companion373.hold373()
 for i in 25:await physics_frame
 check(not w.room.pixel367 and not w.room.old_pose369,"hand-painted bed and new small-sprite sleep are default")
 check(w.hero.get_script().resource_path=="res://scripts/combat/hero192.gd" and w.hero.is_on_floor(),"approved walking actor and physical floor preserved")
 check(absf(w.hero.visual.rotation.x)<.001,"walking character stays upright")
 var empty: Transform3D=w.room.pillow364.transform
 var right: Transform3D=w.room.right_pillow368.transform
 var entry: Vector3=w.hero.global_position
 var footprint: Transform3D=w.room.craft364.global_transform
 var bodies: int=w.room.find_children("*","StaticBody3D",true,false).size()
 w.set_detail364(true);await capture(w,"empty")
 w.hero.global_position=w.room.craft364.to_global(Vector3(1.7,.05,-.15));w.hero.reset_physics_interpolation()
 for i in 5:await physics_frame
 await capture(w,"standing-scale-reference")
 w.soft370=false;await capture(w,"standing-no-fill");w.soft370=true
 w.hero.global_position=entry;w.hero.reset_physics_interpolation()
 var updates371: int=w.room.mask_updates371
 for i in 30:await process_frame
 check(w.room.mask_updates371==updates371,"empty bed does not redraw the blanket viewport")
 w.set_sleep362(1)
 check(w.room.sleep_root369.visible and not w.room.sleep_actor368.visible and not w.hero.visible,"new full pose replaces old stretch, without duplicate actors")
 check(w.room.head369.visible and w.room.body369.visible,"full body exists under cover as a separate mesh section")
 check(w.room.right_pillow368.transform.is_equal_approx(right),"unused right pillow remains unchanged")
 var a: Vector2=w.camera.unproject_position(w.room.craft364.to_global(w.room.SLEEP369.point369(Vector2.ZERO)))
 var b: Vector2=w.camera.unproject_position(w.room.craft364.to_global(w.room.SLEEP369.point369(Vector2(1.,0.))))
 var c: Vector2=w.camera.unproject_position(w.room.craft364.to_global(w.room.SLEEP369.point369(Vector2(0.,1.))))
 var aspect: float=a.distance_to(b)/a.distance_to(c)
 print("CAMERA369 ",w.room.craft364.to_local(w.camera.global_position)," basis=",w.camera.global_basis," aspect=",aspect," corners=",[a,b,c])
 check(absf(aspect-1199./1312.)<.012,"reference close camera preserves full sprite aspect instead of stretching limbs")
 await head_probe368(w);await face_probe369(w)
 await capture(w,"sleep-close")
 var settled371: int=w.room.mask_updates371
 for i in 30:await process_frame
 check(w.room.mask_updates371==settled371,"stationary sleeping bed reuses the cached mask")
 await mask_probe370(w)
 w.room.show_duvet366=false;w.room.update_covers366();await capture(w,"full-body")
 check(w.room.body369.is_visible_in_tree() and not w.room.duvet_mesh366.visible and not w.room.throw_mesh366.visible,"Q reveals a complete body and hides both cover layers")
 w.room.show_duvet366=true;w.room.update_covers366()
 w.room.set_old_pose369(true);await capture(w,"old368-comparison")
 check(w.room.sleep_actor368.visible and not w.room.sleep_root369.visible,"R shows only the old368 pose")
 w.room.set_old_pose369(false)
 # Day/night uses the existing room switch; no new lights or emission.
 w.set_night355(true)
 for i in 15:await process_frame
 await capture(w,"sleep-night")
 w.set_night355(false)
 w.set_sleep362(2)
 check(w.room.sleep_root369.visible and w.room.right_pillow368.transform.is_equal_approx(right) and not w.goose_root.visible,"reserved second slot creates no unapproved character")
 w.set_detail364(false);w.set_follow363(true)
 for i in 100:await physics_frame
 check(w.camera.global_position.distance_to(w.follow_target363())<.14,"follow camera settles on bed head anchor")
 check(w.room.craft364.global_transform.is_equal_approx(footprint),"camera follow leaves bed and sleep pose fixed in room")
 await capture(w,"sleep-follow")
 await mask_probe370(w)
 w.set_follow363(false);w.set_sleep362(0)
 check(w.hero.visible and w.hero.is_physics_processing() and w.hero.global_position.is_equal_approx(entry),"waking restores walking actor, control and entry position")
 check(not w.room.sleep_root369.visible and w.room.pillow364.transform.is_equal_approx(empty),"waking removes sleep actor and restores empty pillow")
 check(w.room.find_children("*","StaticBody3D",true,false).size()==bodies,"sleep and appearance switches preserve stable collision")
 w.legacy_sleep368=true;w.set_sleep362(1)
 check(w.room.layered362.visible and not w.room.craft364.visible and not w.room.sleep_root369.visible,"B retains old2D comparison without showing new pose")
 w.set_sleep362(0);w.legacy_sleep368=false;w.room.set_craft364(true)
 await cloth_probe366(w)
 for file in config:
  check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"user config unchanged "+file)
 var report={"complete":true,"failures":failures,"face":face369,"cloth_contact":contact366,"sprite_aspect":aspect}
 var out:=FileAccess.open("res://docs/room373-regression-validation.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"\t"));out.close()
 print("ROOM373_REGRESSION_DONE ",failures);quit(0 if failures.is_empty() else 1)

func mask_probe370(w: Node) -> void:
 var following: bool=w.follow363;w.follow363=false
 for i in 8:await process_frame
 var with_actor: Image=await snap368()
 var mask: Image=w.room.blanket_view370.get_texture().get_image()
 w.room.sleep_root369.hide();var without_actor: Image=await snap368();w.room.sleep_root369.show()
 var total:=0;var leak:=0
 for y in range(2,with_actor.get_height()-2):
  for x in range(2,with_actor.get_width()-2):
   var mx:=int(float(x)*mask.get_width()/with_actor.get_width())
   var my:=int(float(y)*mask.get_height()/with_actor.get_height())
   if mask.get_pixel(mx,my).r<.9 or mask.get_pixel(mx-2,my).r<.9 or mask.get_pixel(mx+2,my).r<.9 or mask.get_pixel(mx,my-2).r<.9 or mask.get_pixel(mx,my+2).r<.9:continue
   total+=1
   if delta368(with_actor.get_pixel(x,y),without_actor.get_pixel(x,y))>.08:leak+=1
 w.follow363=following
 print("BLANKET370 pixels=",total," actor_leaks=",leak)
 check(total>1000 and leak==0,"actual blanket screen silhouette strictly covers sleeping actor")
