extends "res://scripts/world/woodland95_probe.gd"
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size)
 var sample := Sample95.new();root.add_child(sample)
 while not sample.woodland_ready95: await physics_frame
 await settle72(25)
 sample.hero.controls_enabled=false;sample.label.get_parent().hide();sample.frames66.panel.hide()
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 var g: Vector2=sample.meadow.landmarks.grove
 var results := {}
 var sites := {"field":g+Vector2(-3,-1),"west":g+Vector2(-18,3),"rear":g+Vector2(-6,-11),"station":Vector2(8.4,-42.9)}
 for tag in sites:
  sample._teleport15(sites[tag]);await settle72(40)
  sample.process_mode=Node.PROCESS_MODE_DISABLED
  sample.effect_scope95.set_enabled95(false)
  var before := await snapshot()
  sample.effect_scope95.set_enabled95(true);sample.effect_scope95.refresh95()
  var after := await snapshot()
  var changed_pixels := 0
  for y in before.get_height():
   for x in before.get_width():
    var a := before.get_pixel(x,y);var b := after.get_pixel(x,y)
    if absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)>.06: changed_pixels+=1
  var ratio := float(changed_pixels)/(before.get_width()*before.get_height())
  results[tag]={"changed_ratio":ratio,"active_projections":sample.effect_scope95.active95.size(),"all_projections":sample.effect_scope95.shadows95.size()}
  before.save_png("res://docs/captures/world_restart/woodland95_scope_"+tag+"_off.png")
  after.save_png("res://docs/captures/world_restart/woodland95_scope_"+tag+"_on.png")
  verify(ratio<.003,"padded shadow scope preserves visible image at "+tag)
  sample.process_mode=Node.PROCESS_MODE_INHERIT
 var data := {"checks":checks,"failures":failures,"sites":results}
 var file := FileAccess.open("res://docs/woodland95-scope-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("SCOPE95_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
