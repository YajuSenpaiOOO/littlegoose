extends "res://scripts/world/woodland104_profile.gd"
class CostSample:
 extends Sample103
 var timing := false
 var totals: Dictionary={}
 var skip_contacts := false
 func sum104(key: String,start: int) -> void:
  var value: Vector2=totals.get(key,Vector2.ZERO);totals[key]=value+Vector2(Time.get_ticks_usec()-start,1.)
 func _process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._process(delta)
  if timing: sum104("root_process",t)
 func _physics_process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._physics_process(delta)
  if timing: sum104("root_physics",t)
 func _update_prop_contacts() -> void:
  if skip_contacts: return
  var t := Time.get_ticks_usec();super._update_prop_contacts()
  if timing: sum104("contacts",t)
 func _update_forest_occlusion(delta: float) -> void:
  var t := Time.get_ticks_usec();super._update_forest_occlusion(delta)
  if timing: sum104("occlusion",t)
 func _update_grass() -> void:
  var t := Time.get_ticks_usec();super._update_grass()
  if timing: sum104("grass_upload",t)
 func _update_camera(delta: float,snap := false) -> void:
  var t := Time.get_ticks_usec();super._update_camera(delta,snap)
  if timing: sum104("camera",t)
func take104(sample: Node3D,tag: String,walking := false) -> Dictionary:
 sample.totals.clear();sample.timing=true
 var result := await measure104(sample,tag,walking,240 if walking else 180)
 sample.timing=false;var methods := {}
 for key in sample.totals:
  var value: Vector2=sample.totals[key];methods[key]={"ms_per_call":value.x/maxf(1.,value.y)/1000.,"calls":value.y}
 result.methods=methods;print("METHODS104 ",tag," ",JSON.stringify(methods));return result
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 var sample := CostSample.new();root.add_child(sample)
 while not sample.woodland_ready103: await physics_frame
 await settle72(30);sample.label.get_parent().hide();sample.frames66.panel.hide();sample.details101.audio.set_enabled(false)
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 var g: Vector2=sample.meadow.landmarks.grove;sample._teleport15(g+Vector2(.5,7.8));sample.hero.controls_enabled=true;await settle72(30)
 var data := {};data.baseline=await take104(sample,"baseline")
 sample.process_mode=Node.PROCESS_MODE_DISABLED;data.scripts_frozen=await measure104(sample,"scripts_frozen");sample.process_mode=Node.PROCESS_MODE_INHERIT
 sample.skip_contacts=true;await settle72(20);data.contacts_off=await take104(sample,"contacts_off");sample.skip_contacts=false
 for piece in sample.root_pieces: piece.node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 await settle72(20);data.root_cast_off=await take104(sample,"root_cast_off")
 var original_distance: float=sample.sun.directional_shadow_max_distance;var original_mode: int=sample.sun.directional_shadow_mode
 sample.sun.directional_shadow_max_distance=38.;sample.sun.directional_shadow_mode=DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
 await settle72(20);data.shadow_budget=await take104(sample,"shadow_budget")
 data.walking=await take104(sample,"budget_walking",true)
 sample.permit99=true;sample.start_combat(true);await settle72(80);data.combat=await take104(sample,"budget_combat")
 var file := FileAccess.open("res://docs/woodland104-costs.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("COST104_DONE ",JSON.stringify(data));quit()
