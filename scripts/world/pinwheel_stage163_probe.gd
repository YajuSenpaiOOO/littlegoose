extends "res://scripts/world/hero_moment161_probe.gd"
class Trial163:
 extends "res://scripts/world/woodland_world163.gd"
 func _hero_script() -> Script: return Walker160
 func fire_input_held() -> bool: return false
func capture163(tag: String) -> void:
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/pinwheel_stage163_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 # Render the film over a known colour to verify outside preservation, not just uniforms.
 var viewport := SubViewport.new();viewport.size=Vector2i(640,480);viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
 var background := ColorRect.new();background.size=Vector2(640,480);background.color=Color(.18,.27,.40);viewport.add_child(background)
 await snapshot();var baseline := viewport.get_texture().get_image()
 var overlay := ColorRect.new();overlay.size=Vector2(640,480)
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/combat/pinwheel_stage163.gdshader")
 material.set_shader_parameter("hero_uv",Vector2(.5,.5));material.set_shader_parameter("screen_size",Vector2(640,480));material.set_shader_parameter("strength",1.);material.set_shader_parameter("unfold",1.);overlay.material=material;viewport.add_child(overlay)
 await snapshot();var filtered := viewport.get_texture().get_image()
 var original: Color=baseline.get_pixel(320,240);var peach: Color=filtered.get_pixel(320,240)
 verify(peach.r>original.r+.05 and peach.r-peach.b>original.r-original.b,"real rendered film adds peach warmth at its centre")
 verify(filtered.get_pixel(10,10).is_equal_approx(baseline.get_pixel(10,10)),"real rendered pixels outside ellipse remain unchanged")
 material.set_shader_parameter("strength",0.);await snapshot();var clear := viewport.get_texture().get_image()
 verify(clear.get_pixel(320,240).is_equal_approx(original),"zero-strength film restores original scene exactly")
 viewport.queue_free()
 var s := Trial163.new();s.memory_save116="user://stage163_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.moment161): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var grove: Vector2=s.meadow.landmarks.grove;s._teleport15(grove+Vector2(0.,4.));await settle72(8)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 s.set_physics_process(false);s.hero.set_physics_process(false)
 var stage: Node=s.moment161;stage.set_process(false)
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look()
 var interval: float=s.attack_cooldown()
 await key153(KEY_Q);stage.step161(.18);stage._process(.18)
 verify(stage.running161() and stage.wind163.size()==3,"physical Q unfolds exactly three paper pinwheels")
 verify(stage.entrance_strength161()==0. and stage.cone_strength161()==0. and stage.unfolded163>0. and stage.unfolded163<1.,"pinwheel opening replaces cardboard rays and hard spotlight cone as film grows")
 verify(is_equal_approx(s.attack_cooldown(),interval/1.4) and stage.DURATION==7. and stage.COOLDOWN==20.,"existing skill rate, duration and cooldown are preserved")
 await capture163("opening_day")
 for i in 60: stage.step161(1./60.);stage._process(1./60.)
 verify(stage.unfolded163==1. and stage.wind163.all(func(w: RefCounted) -> bool: return w.initialized),"film fully opens and all pinwheels have independent float state")
 await capture163("sustained_day")
 s.time55.preview_at(22.);s.time55.visual_hour=22.;s.time55.apply_look();stage._process(.016)
 await capture163("sustained_night")
 verify(s.time55.visual_hour==22.,"local sunset effect never changes night time")
 var turns: PackedFloat32Array=stage.turns163.duplicate();var position: Vector3=stage.wind163[0].position
 s.combat_paused=true;stage._process(.5);stage.step161(.5)
 verify(stage.turns163==turns and stage.wind163[0].position==position,"pause freezes pinwheel rotation and floating motion")
 s.combat_paused=false
 var at: Vector3=stage.wind163[0].position;s.hero.position.x+=1.;s.hero.reset_physics_interpolation()
 await process_frame;await process_frame
 stage._process(.016)
 verify(stage.wind163[0].position.x>at.x and stage.wind163[0].position.x<at.x+.2,"pinwheels lag gently behind movement instead of snapping")
 stage.finish161();var before: float=stage.turns163[0];stage.step161(.25);stage._process(.25)
 verify(stage.turns163[0]-before<.2 and stage.strength161()<1.,"ending slows rotation while film fades")
 await capture163("ending_night")
 stage.step161(.5);stage._process(.5)
 verify(not stage.visual_active163 and not stage.shade161.visible and s.buffs.moment_rate161==1.,"film and pinwheels disappear with no lingering stat bonus")
 stage.reset161()
 verify(stage.wind163.all(func(w: RefCounted) -> bool: return not w.initialized) and stage.unfolded163==0.,"cleanup resets pinwheel inertia and opening state")
 s.build161=4;s.apply_paper_build129();stage.request161();stage.step161(.5);stage._process(.5);s.hero.guarding109=true;s.hero.velocity=Vector3.ZERO;s.pillow160.step160(.46);s.pillow160.step160(.2)
 await capture163("fort_night")
 verify(s.pillow160.protects160() and stage.running161(),"new stage still combines with pillow and sword-airplane loadout")
 var report := {"checks":checks,"failures":failures,"centre_before":str(original),"centre_after":str(peach),"note":"Targeted rendered film, stage lifecycle and combination checks; old map suites not repeated."}
 FileAccess.open("res://docs/pinwheel-stage163-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("STAGE163_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
