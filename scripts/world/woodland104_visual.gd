extends "res://scripts/world/woodland104_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var sample := Sample104.new();root.add_child(sample)
 while not sample.woodland_ready104: await physics_frame
 await settle72(30);sample.label.get_parent().hide();sample.frames66.panel.hide();sample.hero.controls_enabled=false
 var g: Vector2=sample.meadow.landmarks.grove
 for hour in [12.,18.,23.]:
  sample.time55.preview_at(hour);sample.time55.visual_hour=hour;sample.time55.apply_look()
  sample._teleport15(g+Vector2(.5,7.8));await settle72(45);sample.process_mode=Node.PROCESS_MODE_DISABLED
  for grade in [false,true]:
   sample.set_grade104(grade);await settle72(3)
   var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland104_palette_"+str(int(hour))+"_"+str(grade)+".png")
  sample.process_mode=Node.PROCESS_MODE_INHERIT
 print("VISUAL104_DONE");quit()
