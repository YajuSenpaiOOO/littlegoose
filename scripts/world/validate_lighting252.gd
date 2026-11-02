extends "res://scripts/world/validate_plush220.gd"
func alt252(code: int) -> void:
 var e=InputEventKey.new();e.pressed=true;e.physical_keycode=code;e.alt_pressed=true;w._input(e)
func run() -> void:
 w=load("res://scenes/world/world252.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready251:await process_frame
 w.boss247.set_physics_process(false);w.hero.set_physics_process(false);w.invulnerability=0.;w.combat_paused=true
 w._teleport15(w.meadow.landmarks.grove+Vector2(0.,3.));w.hero.reset_actions();w.hero.render_pose();w._clear_combat_shots()
 var transform=w.hero.visual.transform;var base=w.hero.receiver192;var stats=w.stats226.duplicate(true);var levels=w.levels226.duplicate(true)
 check(base.albedo_color.is_equal_approx(Color(.82,.82,.82,1.)) and base.shading_mode==BaseMaterial3D.SHADING_MODE_PER_PIXEL,"native192 receiver has .82 base and actual lighting")
 check(w.lighting_mode252==0 and w.hero.visual.material_override==base,"default visual remains unchanged")
 var hours=[8.,12.,18.,22.]
 for i in 4:
  alt252(KEY_1+i)
  check(w.time55.preview and w.time55.clock55.hour==hours[i],"Alt time shortcut reaches clock while combat active %d"%i)
  w.time55.visual_hour=w.time55.clock55.hour;w.time55.apply_look()
  for mode in 3:
   w.set_lighting252(mode);w.hero.render_pose();w.apply_lighting252()
   await shot("lighting252-%d-mode%d"%[i,mode])
  check(w.hero.visual.transform.is_equal_approx(transform),"material comparison preserves hero geometry %d"%i)
 check(w.levels226==levels,"Alt numbers do not alter loadout")
 w.set_lighting252(1)
 check(w.compare252!=base and w.compare252.albedo_color==Color.WHITE and w.compare252.shading_mode==BaseMaterial3D.SHADING_MODE_PER_PIXEL,"white native receiver is isolated copy")
 w.set_lighting252(2)
 check(w.compare252.shading_mode==BaseMaterial3D.SHADING_MODE_UNSHADED,"unlit comparison isolates native-light contribution")
 w.set_lighting252(0)
 check(w.hero.visual.material_override==base and base.albedo_color.is_equal_approx(Color(.82,.82,.82,1.)),"comparison restores original receiver")
 w.toggle_console226();alt252(KEY_2)
 check(w.console226.visible and w.time55.clock55.hour==12.,"time shortcut works with C console open")
 w.close_console226();alt252(KEY_0)
 check(not w.time55.preview and w.time55.clock55.speed==1.,"Alt0 restores natural clock")
 # Same camera/pose in forest, preserving the default receiver and existing mood.
 var at=w.FOREST188.CENTER+Vector2(5.,2.)
 w._teleport15(at);w.hero.render_pose();w.time55.visual_hour=12.;w.time55.clock55.hour=12.;w.time55.preview=true;w.time55.apply_look()
 for mode in [0,1,2]:
  w.set_lighting252(mode);w.apply_lighting252();await shot("lighting252-forest-mode%d"%mode)
 w.set_lighting252(0)
 check(w.hero.receiver192==base and w.hero.visual.material_override==base,"forest comparison restores shared receiver without editing it")
 var first=w;w=null;root.remove_child(first);first.queue_free();await process_frame;await process_frame
 w=load("res://scenes/world/world246.tscn").instantiate();root.add_child(w);current_scene=w
 while not is_instance_valid(w.relay245):await process_frame
 alt252(KEY_4)
 check(w.time55.preview and w.time55.clock55.hour==22.,"246 sister preview also regains Alt time shortcut")
 check(w.hero.get_script().resource_path.ends_with("hero192.gd") and w.hero.receiver192.albedo_color.is_equal_approx(Color(.82,.82,.82,1.)),"246 forest material unchanged")
 var ok=checks.all(func(c):return c.pass)
 var file=FileAccess.open("res://docs/lighting252-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));file.close()
 print("LIGHTING252_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
