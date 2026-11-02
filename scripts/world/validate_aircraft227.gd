extends "res://scripts/world/perf226_combat.gd"
class LiveWorld:
 extends "res://scripts/world/woodland_world227.gd"
 var process_us226=0
 var process_count226=0
 var physics_us226=0
 var physics_count226=0
 var disable_sword_shadows226=false
 func _init() -> void:
  super._init();memory_save116="user://aircraft227_validation_preview.cfg"
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
 func _process(delta: float) -> void:
  var before=Time.get_ticks_usec();super._process(delta);process_us226+=Time.get_ticks_usec()-before;process_count226+=1
  if disable_sword_shadows226:
   for shadow in actor_shadows:
    if is_instance_valid(shadow) and swords153.is_ancestor_of(shadow):shadow.enabled=false;shadow.hide();shadow.set_process(false);shadow.set_physics_process(false)
 func _physics_process(delta: float) -> void:
  var before=Time.get_ticks_usec();super._physics_process(delta);physics_us226+=Time.get_ticks_usec()-before;physics_count226+=1
var checks227=[]
func check227(ok: bool,label: String) -> void:
 checks227.append({"pass":ok,"name":label});print("AIRCRAFT227_CHECK ",ok," ",label)
func capture227(tag: String) -> Image:
 await RenderingServer.frame_post_draw
 var image=root.get_texture().get_image();image.save_png("res://docs/aircraft227-"+tag+".png");return image
func run() -> void:
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 w=LiveWorld.new();root.add_child(w);current_scene=w
 while not w.ready227:await process_frame
 for priority in [-1000,1,79,81,89,91,99,101,109,111,200]:
  var marker=Marker.new();marker.process_priority=priority;marker.key226=priority;marker.owner226=self;root.add_child(marker)
 w.levels226={"paper_plane":1,"balloon_sword":1,"three_player":1,"eye_exercise":1};w.start_battle225(false)
 w.auto114=true;w.pigs_enabled220=true;w.invulnerability=10000.;w.hero.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 w.paper_memories146.legacy_canvas227=true
 await sample("live_old_canvas_warm",12.)
 await sample("live_old_canvas",10.)
 w.paper_memories146.legacy_canvas227=false
 await sample("live_ground_markers",12.)
 await capture227("live-ground")
 w.disable_sword_shadows226=true
 await sample("live_ground_no_sword_shadows_diagnostic",8.)
 w.disable_sword_shadows226=false
 # New births/pool reuse wake shadows naturally; begin again for a clean state.
 w.start_battle225(false);w.auto114=true;w.invulnerability=10000.;w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 await sample("live_ground_restart",10.)
 check227(w.paper_memories146.markers227.submitted227>0,"native aircraft submit depth-tested ring instances")
 var markers=w.paper_memories146.markers227
 check227(markers.multimesh.instance_count==256 and markers.multimesh.visible_instance_count<=256,"ground markers use fixed MultiMesh capacity")
 w.auto114=false;w.combat_paused=true;w.cat220.set_physics_process(false)
 var ground=Vector2(w.hero.position.x,w.hero.position.z)+Vector2(1,1)
 var samples_match=true
 for i in 8:
  var at=ground+Vector2(cos(i*TAU/8),sin(i*TAU/8))*2.4
  if absf(w.shadow_field113.sample(at)-w.floor_height(at))>.04:samples_match=false
 check227(samples_match,"marker terrain sampling agrees with gameplay floor at ring perimeter")
 w._clear_combat_shots();await process_frame
 check227(markers.multimesh.visible_instance_count==0,"reset clears ground rings immediately")
 # GPU occlusion probe: an opaque cube covers the front edge of a test ring.
 var at=Vector3(ground.x,w.floor_height(ground)+.04,ground.y)
 markers.ring227(at,.55,Color(1,.8,.2,1.))
 var item=markers.unique227.values()[0]
 markers.multimesh.set_instance_transform(0,Transform3D(Basis.IDENTITY,item.at));markers.multimesh.set_instance_color(0,item.color);markers.multimesh.set_instance_custom_data(0,Color(.55,0,0,0));markers.multimesh.visible_instance_count=1
 var box=MeshInstance3D.new();var geometry=BoxMesh.new();geometry.size=Vector3(.6,.6,.6);box.mesh=geometry
 var material=StandardMaterial3D.new();material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;material.albedo_color=Color(.15,.2,.25);box.material_override=material;w.add_child(box)
 box.global_position=at+Vector3(-.35,.25,0)
 var visible_image=await capture227("depth-on")
 markers.hide();var hidden_image=await capture227("depth-off")
 var p=w.camera.unproject_position(box.global_position)*Vector2(visible_image.get_size())/root.get_visible_rect().size
 var changes=0
 var visible_changes=0
 var center=w.camera.unproject_position(at)*Vector2(visible_image.get_size())/root.get_visible_rect().size
 for y in range(-50,51):
  for x in range(-70,71):
   var pixel=Vector2i(center)+Vector2i(x,y)
   if pixel.x<0 or pixel.y<0 or pixel.x>=visible_image.get_width() or pixel.y>=visible_image.get_height():continue
   var difference=visible_image.get_pixelv(pixel)-hidden_image.get_pixelv(pixel)
   if absf(difference.r)+absf(difference.g)+absf(difference.b)>.1:visible_changes+=1
 check227(visible_changes>10,"ground ring produces visible GPU pixels outside its occluder")
 for y in range(-3,4):
  for x in range(-3,4):
   var pixel=Vector2i(p)+Vector2i(x,y)
   var delta_color=visible_image.get_pixelv(pixel)-hidden_image.get_pixelv(pixel)
   if absf(delta_color.r)+absf(delta_color.g)+absf(delta_color.b)>.01:changes+=1
 check227(changes==0,"opaque foreground blocks the ring in rendered GPU pixels")
 box.queue_free();markers.show()
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look()
 await create_timer(.3).timeout;await capture227("night")
 check227(markers.multimesh.visible_instance_count==1,"night lighting keeps marker presentation without extra light")
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 w.combat_paused=false;w.stop225()
 var failures=checks227.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/aircraft227-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks227,"failed":failures.size(),"performance":results},"\t"))
 print("AIRCRAFT227_DONE failures=",failures.size());quit(0 if failures.is_empty() else 1)
