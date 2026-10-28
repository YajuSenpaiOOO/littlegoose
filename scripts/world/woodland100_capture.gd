extends "res://scripts/world/woodland100_probe.gd"
func run() -> void:
 var sample := Sample100.new();root.add_child(sample)
 while not sample.woodland_ready100: await physics_frame
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 var g: Vector2=sample.meadow.landmarks.grove
 await shot99(sample,g+Vector2(16,-6),"tree_layers_day")
 await shot99(sample,g+Vector2(13,-3),"root_contact_day")
 await shot99(sample,g+Vector2(5,-1),"swing_day")
 await shot99(sample,g+Vector2(0,2.5),"park_day")
 print("WOODLAND100_CAPTURE_READY");quit()
