extends "res://scripts/world/validate_plush220.gd"
func tap253(code: int,alt := false) -> void:
 var e=InputEventKey.new();e.pressed=true;e.physical_keycode=code;e.alt_pressed=alt;w._input(e)
func run() -> void:
 w=load("res://scenes/world/world253.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready253:await process_frame
 w.hero.set_physics_process(false);w.boss247.set_physics_process(false)
 check(not w.active114 and w.rig220.visible and w.rig220.standing.visible,"starts with sister standing beside hero, no combat")
 check(w.rig220.standing.texture.resource_path.contains("sister211"),"uses current selected sister art")
 check(w.originals253[0].shader.resource_path.ends_with("sister_receiver207.gdshader") and w.originals253[0].shader.code.contains("COLOR.rgb*.82"),"sister uses actual native receiver with .82 multiplier")
 check(w.rig220.body.collision_layer==0 and not w.rig220.hammock.visible and w.rig220.bats.all(func(b):return not b.visible),"standing diagnostic has no transport clutter or blocking footprint")
 var base=w.hero.receiver192;var original_shader=w.originals253[0].shader
 var transform=w.hero.visual.transform
 tap253(KEY_2,true);w.time55.visual_hour=12.;w.time55.apply_look()
 check(w.time55.clock55.hour==12.,"Alt time shortcut retained")
 for at in [1,0,2]:
  w.go253(at);await create_timer(.12).timeout
  for mode in [0,1,2]:
   w.set_lighting252(mode);w.hero.render_pose();w.apply_lighting252();w.place_sister253(0.)
   await shot("lighting253-place%d-mode%d"%[at,mode])
   var ink: ShaderMaterial=w.rig220.standing.material_override
   if mode==0:check(ink==w.originals253[0],"original sister receiver preserved place%d"%at)
   else:
    check(ink!=w.originals253[0] and not ink.shader.code.contains("COLOR.rgb*.82"),"sister comparison uses isolated neutral material place%d mode%d"%[at,mode])
    check(ink.shader.code.contains("unshaded")==bool(mode==2),"comparison light response matches selected mode place%d mode%d"%[at,mode])
 w.set_lighting252(0)
 check(w.hero.receiver192==base and w.rig220.standing.material_override.shader==original_shader and original_shader.code.contains("COLOR.rgb*.82"),"both original shared materials unchanged")
 var stage=w.lighting191.stage_enabled;tap253(KEY_F11)
 check(w.lighting191.stage_enabled!=stage,"stage lamp independently toggles")
 await shot("lighting253-stage-off")
 tap253(KEY_F11)
 var enabled=w.lighting191.enabled;tap253(KEY_F12)
 check(w.lighting191.enabled!=enabled and w.lighting191.lamps.all(func(l):return not l.visible),"forest lamp group can be isolated")
 await shot("lighting253-lamps-off");tap253(KEY_F12)
 var mood=w.forest_mood188.enabled;tap253(KEY_F10,true)
 check(w.forest_mood188.enabled!=mood,"regional grade independently toggles")
 await shot("lighting253-grade-off");tap253(KEY_F10,true)
 var old=w.rig220.person_at;tap253(KEY_F5)
 check(Vector2(w.hero.position.x,w.hero.position.z).distance_to(old)<.1,"actors can exchange sampling positions")
 check(w.hero.visual.rotation.x==transform.basis.get_euler().x,"lighting diagnostics do not tilt hero geometry")
 check(w.encounter_hud!=null and is_instance_valid(w.console226),"latest HUD and console still available")
 var ok=checks.all(func(c):return c.pass)
 var file=FileAccess.open("res://docs/lighting253-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));file.close()
 print("LIGHTING253_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
