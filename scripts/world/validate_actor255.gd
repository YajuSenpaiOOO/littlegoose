extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world255.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready253:await process_frame
 w.hero.set_physics_process(false);w.boss247.set_physics_process(false);w.hero.controls_enabled=false
 var geometry=w.hero.visual.transform
 check(w.aligned255 and w.lighting_mode252==1,"default keeps neutral receiver and aligns sister environment tint")
 check(w.hero.receiver192.albedo_color.is_equal_approx(Color(.82,.82,.82,1.)),"shared hero receiver unchanged")
 for hour in [8.,12.,18.,22.]:
  w.time55.preview_at(hour);w.time55.visual_hour=hour;w.time55.apply_look()
  for place in [1,3]:
   w.go253(place);await settle(5);w.porch49._update_actor();w.apply_actor255()
   var at=Vector2(w.hero.global_position.x,w.hero.global_position.z)
   var expected=w.porch49.actor_tint255(at)
   check(w.hero.visual.modulate.is_equal_approx(expected),"environment helper matches existing hero chain %d-%d"%[int(hour),place])
   check(w.rig220.standing.modulate.is_equal_approx(w.porch49.actor_tint255(w.rig220.person_at)),"sister samples own position %d-%d"%[int(hour),place])
   await shot("actor255-%d-place%d"%[int(hour),place])
 w.go253(1);w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look();await settle(5)
 w.aligned255=false;w.apply_actor255();check(w.rig220.standing.modulate==Color.WHITE,"254 comparison restores untinted sister")
 await shot("actor255-original")
 w.aligned255=true;w.apply_actor255()
 w.hurt_flash=.18;w.legacy_feel=true;w.combat_ready=true;w.porch49._update_actor();w.apply_actor255()
 check(w.rig220.standing.modulate.r/w.rig220.standing.modulate.g<1.4 and w.hero.visual.modulate.r/w.hero.visual.modulate.g>1.5,"hero damage flash does not leak to sister")
 w.hurt_flash=0.;w.porch49._update_actor()
 var params=w.rig220.standing.material_override
 check(params.shader.code.contains("LIGHT_VERTEX") and params.shader.code.contains("DEPTH"),"sister depth proxy and native receiver retained")
 check(not w.lighting191.stage_enabled,"254 warm lighting defaults retained")
 # Compare identical gray cards in the full map, excluding source art differences.
 w.set_process(false);w.set_physics_process(false);w.rig220.set_process(false);w.porch49.set_process(false)
 var img=Image.create(8,8,false,Image.FORMAT_RGBA8);img.fill(Color(.7,.7,.7,1.));var tex=ImageTexture.create_from_image(img)
 w.compare252.albedo_texture=tex;params.set_shader_parameter("paint",tex)
 w.rig220.standing.modulate=w.hero.visual.modulate
 await shot("actor255-gray")
 var im=root.get_texture().get_image()
 var a=w.camera.unproject_position(w.hero.visual.to_global(Vector3(w.hero.visual.offset.x,w.hero.visual.offset.y,0.)*w.hero.visual.pixel_size))
 var b=w.camera.unproject_position(w.rig220.standing.to_global(Vector3(w.rig220.standing.offset.x,w.rig220.standing.offset.y,0.)*w.rig220.standing.pixel_size))
 var scale=Vector2(im.get_size())/w.get_viewport().get_visible_rect().size
 a*=scale;b*=scale
 var ca=im.get_pixelv(Vector2i(a));var cb=im.get_pixelv(Vector2i(b))
 metrics.gray_hero=str(ca);metrics.gray_sister=str(cb);metrics.sample_hero=str(a);metrics.sample_sister=str(b)
 check(absf(ca.r-cb.r)<.05 and absf(ca.g-cb.g)<.05,"identical gray and environment tint produce matched map brightness")
 var ok=checks.all(func(c):return c.pass)
 var file=FileAccess.open("res://docs/actor255-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));file.close()
 print("ACTOR255_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
