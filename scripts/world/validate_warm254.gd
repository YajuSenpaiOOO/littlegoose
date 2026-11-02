extends "res://scripts/world/validate_plush220.gd"
func key254(code: int,alt := false) -> void:
 var e=InputEventKey.new();e.pressed=true;e.physical_keycode=code;e.alt_pressed=alt;w._input(e)
func run() -> void:
 w=load("res://scenes/world/world254.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready253 or not w.lighting191.ready254:await process_frame
 w.hero.set_physics_process(false);w.boss247.set_physics_process(false)
 var lighting=w.lighting191
 check(not lighting.stage_enabled,"follow-stage fill defaults off")
 check(w.lighting_mode252==1 and w.hero.receiver192.albedo_color.is_equal_approx(Color(.82,.82,.82,1.)),"neutral actor comparison does not edit shared materials")
 check(lighting.fixtures254.size()>5,"visible fixture bulbs have selective emission")
 check(lighting.fixtures254.all(func(i):return i.prop.material_override==i.ink),"emission is attached to final visible depth materials")
 check(lighting.fixtures254.any(func(i):return i.shader and i.ink.shader.code.contains("EMISSION") and i.ink.get_shader_parameter("glow254")!=null),"registered depth cards retain actual bulb emission")
 var masks_ok=lighting.masks254.size()>=2
 for texture in lighting.masks254.values():
  var image=texture.get_image();var bright=0;var count=0
  for y in range(0,image.get_height(),16):
   for x in range(0,image.get_width(),16):
    count+=1
    if image.get_pixel(x,y).r>.02:bright+=1
  masks_ok=masks_ok and bright>0 and float(bright)/count<.25 and image.get_pixel(0,0).r==0.
 check(masks_ok,"emission masks contain bulb-only light, not entire fixture")
 check(lighting.lamps.all(func(l):return not l.shadow_enabled),"decorative local lights do not use hard proxy shadows")
 check(lighting.lamps.all(func(l):return l.omni_range<=3.5 and l.light_energy<=.19 and l.light_color.r>l.light_color.g and l.light_color.g>l.light_color.b),"small warm bounded light pools")
 var aligned=true
 for l in lighting.lamps:
  if l.has_meta("fixture254"):
   var target=lighting.core(l.get_meta("fixture254"),l.get_meta("uv254"))+w.camera.global_basis.z*.12
   if l.global_position.distance_to(target)>.02:aligned=false
 check(aligned,"native sources align with visible bulb anchors")
 check(not w.time55.accents57.stage_beam.visible,"old triangular beam sheet disabled")
 for hour in [12.,22.]:
  w.time55.preview_at(hour);w.time55.visual_hour=hour;w.time55.apply_look()
  for place in [3,0,2]:
   w.go253(place);await create_timer(.15).timeout;lighting._process(0.)
   await shot("warm254-%d-place%d"%[int(hour),place])
   check(w.rig220.standing.visible and not w.active114,"sister and hero inspection retained %d-%d"%[int(hour),place])
 var before=w.hero.visual.global_position;var base=w.hero.receiver192
 key254(KEY_F12);lighting._process(0.)
 check(lighting.lamps.all(func(l):return l.light_energy==0.) and not w.time55.accents57.stage_light.visible,"lamp switch disables local sources and stage")
 var dark=true
 for item in lighting.fixtures254:
  if item.shader:dark=dark and float(item.ink.get_shader_parameter("glow_gain254"))==0.
  else:dark=dark and item.ink.emission_energy_multiplier==0.
 check(dark,"fixture emission toggles with its light group")
 await shot("warm254-off");key254(KEY_F12);lighting._process(0.)
 check(lighting.fixtures254.any(func(i):return not i.shader and i.ink.emission_energy_multiplier>0.),"native emissive bulb materials restore")
 check(w.hero.receiver192==base,"lighting repair leaves actor receiver unchanged")
 check(w.forest_mood188.enabled,"existing regional mood still enabled")
 var ok=checks.all(func(c):return c.pass)
 var file=FileAccess.open("res://docs/warm254-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));file.close()
 print("WARM254_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
