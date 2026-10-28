extends "res://scripts/world/hero_moment161_probe.gd"
class Trial165:
 extends "res://scripts/world/woodland_world165.gd"
 func _hero_script() -> Script: return Walker160
 func fire_input_held() -> bool: return false
func capture165(tag: String) -> void:
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/popup_stage165_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial165.new();s.memory_save116="user://popup165_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.moment161): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var grove: Vector2=s.meadow.landmarks.grove;s._teleport15(grove+Vector2(0.,4.));await settle72(8)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 s.set_physics_process(false);s.hero.set_physics_process(false)
 var stage: Node=s.moment161;stage.set_process(false)
 var interval: float=s.attack_cooldown()
 await key153(KEY_Q);stage.step161(.35);stage._process(.35)
 verify(stage.panels165.size()==19 and stage.textures165.size()==4,"four saved assets provide three tall panels and sixteen low edge pieces")
 verify(stage.panels165[0].fold<-.4 and stage.panels165[0].fold> -PI*.5,"rear scenery rises progressively from its ground hinge")
 verify(stage.panels165[1].fold<stage.panels165[0].fold,"side scenery opens after rear scenery")
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look();await capture165("opening_day")
 stage.step161(.9);stage._process(.9)
 verify(absf(stage.panels165[0].fold)<.001 and absf(stage.panels165[2].fold)<.001,"all main scenery unfolds fully upright")
 verify(stage.ground_material164.shader.resource_path.ends_with("paper_page165.gdshader"),"paper fibres replace the luminous circle material")
 verify(is_equal_approx(s.attack_cooldown(),interval*.5) and stage.RADIUS164==6.5,"six-point-five-metre field and double rate remain unchanged")
 var anchor: Vector3=stage.anchor164;var panel: Dictionary=stage.panels165[0];var base: Vector3=panel.base
 verify(absf(base.y-s.floor_height(Vector2(base.x,base.z))-.035)<.001,"paper hinge rests on terrain rather than floating")
 await capture165("unfolded_day")
 s.hero.position.x+=2.;s.hero.reset_physics_interpolation();stage.step161(.1);stage._process(.1)
 verify(stage.anchor164==anchor and panel.base==base,"scenery and field remain fixed when player moves")
 # Place the hero behind the rear panel along the camera ray through its centre.
 var face: Sprite3D=panel.face
 var middle: Vector3=face.to_global(Vector3(0.,face.texture.get_height()*face.pixel_size*.5,0.))
 var ray := (middle-s.camera.global_position).normalized()
 s.hero.position=middle+ray*1.5-Vector3.UP*.65;s.hero.reset_physics_interpolation()
 await process_frame;await process_frame
 stage.update_panels165(.5)
 verify(panel.fade<.4,"tall scenery fades when it covers the hero")
 await capture165("readable_behind_panel")
 s.hero.position=anchor+Vector3(0.,.04,0.);s.hero.reset_physics_interpolation()
 await process_frame;await process_frame
 stage.update_panels165(.5)
 verify(panel.fade>.9,"scenery returns when no longer covering combat")
 s.time55.preview_at(22.);s.time55.visual_hour=22.;s.time55.apply_look();stage._process(.1);await capture165("unfolded_night")
 verify(s.time55.visual_hour==22.,"pop-up stage does not alter night time")
 var fold: float=panel.fold;s.combat_paused=true;stage.step161(1.);stage._process(1.)
 verify(panel.fold==fold,"pause freezes unfolding")
 s.combat_paused=false;stage.finish161();stage.step161(.3);stage._process(.3)
 verify(panel.fold<-.3 and panel.fold> -PI*.5,"exit folds scenery back down instead of only fading it")
 await capture165("folding_exit")
 stage.step161(.5);stage._process(.5);verify(not stage.root164.visible,"all scenery disappears after close")
 var shadows: int=s.actor_shadows.size();stage.reset161();stage.request161();stage.reset161();stage.request161()
 verify(s.actor_shadows.size()==shadows,"reopening reuses scenery and shadows")
 var report := {"checks":checks,"failures":failures,"assets":4,"panels":19,"note":"Targeted pop-up choreography, terrain, readability and unchanged field checks; no old-map suite."}
 FileAccess.open("res://docs/popup-stage165-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("POPUP165_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
