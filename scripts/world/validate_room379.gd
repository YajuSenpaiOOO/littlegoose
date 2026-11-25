extends SceneTree
var errors: Array[String]=[]
func verify(ok: bool, label: String) -> void:
 if not ok:errors.append(label)
func capture(tag: String) -> void:
 for i in 8:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room379-"+tag+".png")
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world379.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.wing379):await process_frame
 w.playing379=false
 var body: Transform3D=w.body379.transform
 var attachment: Transform3D=w.wing379.transform
 for i in 4:
  w.show_frame379(i)
  verify(w.body379.transform==body,"static body "+str(i))
  verify(w.wing379.transform==attachment,"fixed back attachment "+str(i))
  var anchor: Vector2=w.ROOTS379[i]
  var root_local:=Vector3((anchor.x-384.+w.wing379.offset.x)*w.wing379.pixel_size,(256.-anchor.y+w.wing379.offset.y)*w.wing379.pixel_size,0.)
  verify(root_local.length()<.00001,"authored root mapped to origin "+str(i))
  await capture("frame"+str(i))
 w.set_night355(true);await capture("night");w.set_night355(false)
 w.soft370=false;await capture("fill-off");w.soft370=true
 for x in [-.8,.8]:
  w.flight_root377.position.x+=x;w.pose379()
  verify(w.wing379.transform==attachment,"attachment after translation")
 w.rig379.rotation.y=.25;await capture("turn-stress");w.rig379.rotation.y=0.
 w.reference379=true;w.pose379();verify(not w.rig379.visible and w.flight377.visible,"original reference")
 w.reference379=false;w.lift377=false;w.pose379();await capture("baseline")
 w.lift377=true;w.pose379();w.playing379=true
 var seen: Dictionary={}
 for i in 80:await create_timer(.02).timeout;seen[w.index379]=true
 verify(seen.size()==4,"actual playback visits all four frames")
 w.playing379=false;var stopped: int=w.index379
 await create_timer(.2).timeout;verify(w.index379==stopped,"pause holds frame")
 var f:=FileAccess.open("res://docs/room379-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"errors":errors,"seen":seen.keys(),"fixed_attachment":attachment},"\t"));f.close()
 print("ROOM379_DONE ",errors);quit(0 if errors.is_empty() else 1)
