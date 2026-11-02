extends "res://scripts/world/validate_plush220.gd"
class TestWorld:
 extends "res://scripts/world/woodland_world231.gd"
 func _init() -> void:
  super._init();memory_save116="user://cat231_validation_preview.cfg"
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
func capture231(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/cat231-"+tag+".png")
func run() -> void:
 var configs={}
 for path in ["user://boss_balance230.cfg","user://boss_balance231.cfg"]:configs[path]=FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
 w=TestWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 var cat=w.cat220
 check(cat.get_script().resource_path.ends_with("fat_cat_boss231.gd"),"231 cat factory selected")
 check(w.hero.get_script().resource_path.ends_with("hero192.gd"),"approved hero geometry retained")
 check(w.paper_memories146.get_script().resource_path.ends_with("paper_squad230.gd"),"230 aircraft changes retained")
 check(w.cat_health226==100. and w.bat_health226==80.,"existing boss health retained")
 check(is_equal_approx(cat.get_child(0).shape.radius,.95) and is_equal_approx(cat.hit_area.get_child(0).shape.radius,1.),"physical footprint and hurt capsule unchanged")
 w.combat_paused=true;cat.phase220="roll";cat.planned_time221=.9
 for frame in 6:
  cat.clock220=(float(frame)+.2)/12.*cat.planned_time221;cat._render_legacy(0.)
  check(cat.visual.texture==cat.rolls220[frame],"roll selects correct atlas cell "+str(frame))
  var f: Dictionary=cat.roll_data220.frames[frame]
  var bottom=(float(f.bounds[1])+float(f.bounds[3])-float(f.anchor[1]))*cat.visual.pixel_size
  check(absf(bottom)<.0001,"roll sole remains on ground "+str(frame))
  if frame in [2,3,4]:await capture231("roll"+str(frame))
 cat.enter220("down");cat.dead=true;cat._render_legacy(0.)
 check(cat.visual.texture==cat.down231 and cat.down231.resource_path.ends_with("down-runtime.png"),"down uses separate approved prone art")
 check(cat.ink220.get_shader_parameter("paint")==cat.down231 and cat.ink220.get_shader_parameter("alpha_cut220")==.98,"down shader uses matching image and discards glow")
 for face in [false,true]:
  cat.facing_right220=face;cat._render_legacy(0.)
  var a: Array=cat.roll_data220.rest231.anchor;var b: Array=cat.roll_data220.rest231.bounds
  var sole=(float(b[1])+float(b[3])-float(a[1]))*cat.visual.pixel_size
  check(cat.visual.flip_h==face and absf(sole)<.0001,"down mirror keeps ground registration "+str(face))
  await capture231("down-right" if face else "down-left")
 check(cat.shadow.visual==cat.visual and cat.shadow.last_texture==cat.down231,"contour shadow follows independent down image")
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();await capture231("down-night")
 var normal=(w.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))).normalized()
 check((cat.ink220.get_shader_parameter("receiver_normal207") as Vector3).distance_to(normal)<.0001,"down keeps existing world-light receiver")
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 w.combat_paused=false;cat.dead=false;cat.hp=1.;cat.enter220("chase");cat.receive_hit(100.,Vector3.ZERO)
 await create_timer(1.5).timeout
 check(w.battle_phase220=="repair" and w.bats220.all(func(b):return b.enabled220),"real cat defeat opens existing bat repair window")
 check(cat.visual.texture==cat.down231 and w.rig_at220.y<cat.position.z,"approved prone pose held with sister behind cat")
 w.combat_paused=true;await capture231("repair")
 w.combat_paused=false;cat.set_physics_process(true);w.phase_age220=5.95;await create_timer(1.65).timeout
 check(w.battle_phase220=="fight" and not cat.dead and cat.visual.texture!=cat.down231,"repair restores walking art and next round")
 w.start_battle225(false);w.auto114=false
 check(w.rig220.visible and w.player_hp==14. and w.cat220.get_script().resource_path.ends_with("fat_cat_boss231.gd"),"restart retains new cat and visible sister")
 w.stop225()
 for path in configs:check(configs[path]==(FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null),"test config unchanged: "+path)
 var failed=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/cat231-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failed.size()},"\t"))
 print("CAT231_DONE ",checks.size()," failed=",failed.size());quit(0 if failed.is_empty() else 1)
