extends "res://scripts/world/station86_probe.gd"
class Profile86:
 extends Sample86
 var contact_time86 := 0
 var refits86 := 0
 func _update_prop_contacts() -> void:
  var before := contact_stamp65
  var start := Time.get_ticks_usec()
  super._update_prop_contacts()
  contact_time86+=Time.get_ticks_usec()-start
  if before!=contact_stamp65: refits86+=1
func segment86(sample: Node3D) -> Dictionary:
 var values: Array[float]=[]
 var over20 := 0
 var end := Time.get_ticks_msec()+8000
 var last := Time.get_ticks_usec()
 sample.contact_time86=0;sample.refits86=0
 while Time.get_ticks_msec()<end:
  await process_frame
  var now := Time.get_ticks_usec();var ms := (now-last)/1000.;last=now
  values.append(ms)
  if ms>20.: over20+=1
 values.sort()
 return {"median_ms":values[values.size()/2],"p95_ms":values[int(values.size()*.95)],"max_ms":values[-1],"over20":over20,"frames":values.size(),"contact_ms":sample.contact_time86/1000.,"refits":sample.refits86,"viewport":root.size,"window":DisplayServer.window_get_size()}
func run() -> void:
 var sample := Profile86.new();root.add_child(sample)
 while not is_instance_valid(sample.station81): await physics_frame
 DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);Engine.max_fps=0
 sample.time55.visual_hour=12.;sample.time55.preview_at(12.);sample.time55.apply_look()
 sample._teleport15(Vector2(7.,-49.));sample.hero.controls_enabled=true;await settle72(15)
 verify(await walk_to(sample,Vector2(7.,-47.4)),"walk onto repaired wall from upper terrace")
 sample.hero.controls_enabled=false;await settle72(40)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/station86_wall_top.png")
 var results := {}
 for mode in ["full","full_repeat","no_dof","full_vsync"]:
  sample.time55.focus_mode86=2 if mode=="no_dof" else 0;sample.time55.apply_look()
  DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if mode=="full_vsync" else DisplayServer.VSYNC_DISABLED)
  await settle72(30)
  results[mode]=await segment86(sample)
  print("STILL86 ",mode," ",JSON.stringify(results[mode]))
 var file := FileAccess.open("res://docs/still86-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(results,"\t"))
 quit()
