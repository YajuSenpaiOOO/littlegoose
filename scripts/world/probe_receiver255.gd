extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world254.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready253:await process_frame
 w.hero.set_physics_process(false);w.boss247.set_physics_process(false);w.go253(1)
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 await settle(4);await shot("receiver255-before")
 w.set_process(false);w.hero.set_process(false);w.rig220.set_process(false)
 var img=Image.create(8,8,false,Image.FORMAT_RGBA8);img.fill(Color(.7,.7,.7,1.));var tex=ImageTexture.create_from_image(img)
 w.compare252.albedo_texture=tex;w.rig220.standing.material_override.set_shader_parameter("paint",tex)
 await shot("receiver255-gray")
 print("GRAY_META hero ",w.hero.visual.material_override," sister ",w.rig220.standing.material_override," colors ",w.hero.visual.modulate," ",w.rig220.standing.modulate," layers ",w.hero.visual.layers," ",w.rig220.standing.layers)
 w.atmosphere41.focus_card.hide()
 await shot("receiver255-no-post")
 w.sun.light_energy=0.
 await shot("receiver255-no-sun")
 for light in w.find_children("*","Light3D",true,false):light.hide()
 await shot("receiver255-no-lights")
 quit()
