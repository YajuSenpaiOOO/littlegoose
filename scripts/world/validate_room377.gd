extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func _initialize() -> void:call_deferred("run")
func capture(tag: String) -> void:
 for i in 8:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room377-"+tag+".png")
func run() -> void:
 var w=preload("res://scripts/world/room_world377.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.flight377) or not w.companion373.ready373:await physics_frame
 w.arrange377()
 for i in 30:await physics_frame
 check(is_equal_approx(w.flight377.pixel_size,1.44/1281.0),"flight uses idle head/body scale rather than total wingspan/height")
 check(w.flight377.rotation.is_zero_approx(),"upright source proportions")
 check(w.companion373.mode373=="hold" and w.companion373.direction373=="down","standing reference remains front and held")
 check(w.flight377.material_override!=w.human_visual372.material_override,"independent lit materials")
 check(w.flight_root377.get_child_count()==2,"display and shadow only, no wing-sized collider")
 check(is_equal_approx(w.flight377.position.y,.4),"actual display height creates hover")
 await capture("hover-day")
 w.flight377.position.y=0.;await capture("baseline-day")
 w.set_night355(true);await capture("baseline-night");w.set_night355(false)
 w.set_pair372(false);w.flight377.position.y=.4;await capture("room")
 w.reset355();check(w.near372 and w.companion373.mode373=="hold","reset returns comparison")
 var file:=FileAccess.open("res://docs/room377-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"failures":failures,"pixel_size":w.flight377.pixel_size,"hover_height":w.flight377.position.y},"\t"));file.close()
 print("ROOM377_DONE ",failures);quit(0 if failures.is_empty() else 1)
