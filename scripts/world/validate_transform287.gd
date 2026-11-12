extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world287.gd"
 func _init() -> void:
  super._init();memory_save116="user://transform287-validation-preview.cfg"
 func test_config_path226() -> String:return "user://transform287-validation.cfg"
 func reward_path273() -> String:return "user://transform287-validation-reward.cfg"
 func export_stats226() -> Error:return OK
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.transform287):await process_frame
 w.auto287=0.;w.set_process(false);await settle(3)
 var at: Vector3=w.hero.position;var material=w.hero.visual.material_override;var collision=w.hero.collision_layer;var fov=w.camera.fov
 w.start287();var fx=w.transform287;fx.audio.set_enabled(false)
 check(w.intro287 and w.combat_paused and not w.hero.visual.visible,"intro preserves pause/portrait handover")
 check(not w.red_beacon263.is_processing(),"old HP red beacon suspended during timed visual preview")
 for t in [.28,.80,1.18,2.55]:
  fx.sample(t);w.lighting287();w.project287();await shot("transform287-%.2f"%t)
  check(w.hero.position.is_equal_approx(at),"fixed foot at %.2f"%t)
 fx.age=3.14;fx.advance(.02);w.project287()
 check(not w.intro287 and w.hero.controls_enabled and w.hero.visual.visible and not w.combat_paused,"reveal returns movement/native actor")
 check(is_equal_approx(fx.remaining(),7.99),"eight second duration starts after reveal")
 fx.sample(4.2);w.lighting287();w.project287();await shot("transform287-gold")
 check(fx.outline.visible and fx.badge.visible and not fx.actor.visible,"gold contour and bow marker use native animated sprite")
 check(fx.strips.slice(0,6).all(func(mesh):return mesh.mesh.get_surface_count()==0),"no wing/ribbon meshes remain at rest")
 fx.age=9.14;fx.advance(.02);w.project287();await shot("transform287-red")
 check(fx.is_red() and fx.remaining()<2. and w.player_hp==w.max_player_health(),"last two seconds turn red at full HP")
 check(fx.audio.events.count("pulse")==1,"first red pulse scheduled once")
 fx.advance(.6)
 check(fx.audio.events.count("pulse")==2,"red pulse clock progresses without rapid event flooding")
 fx.age=11.14;fx.advance(.18);w.project287();await shot("transform287-ending")
 check(fx.remaining()==0. and fx.playing and w.hero.controls_enabled,"outro fades while movement stays enabled")
 check(fx.audio.events.count("outro")==1,"outro sound emitted exactly once")
 fx.age=11.59;fx.advance(.02);w.project287();await shot("transform287-off")
 check(not fx.playing and not fx.outline.visible and not fx.badge.visible,"expiration removes state markers")
 check(w.red_beacon263.is_processing() and not fx.audio.hum.playing,"old beacon restored and hum stopped")
 check(w.hero.visual.material_override==material and w.hero.collision_layer==collision and is_equal_approx(w.camera.fov,fov),"native material/collision/camera retained")
 check(fx.audio.sounds.size()==6 and fx.audio.sounds.values().all(func(stream):return stream is AudioStreamWAV and stream.get_length()>0.),"six cached original WAV resources loaded")
 # Real depth test, including the newly added native contour and bow marker.
 w.start287();fx.sample(9.4);w.lighting287();w.project287()
 var panel=MeshInstance3D.new();var quad=QuadMesh.new();quad.size=Vector2(6,6);panel.mesh=quad
 var ink=StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.albedo_color=Color(.03,.08,.95);panel.material_override=ink;w.add_child(panel)
 var centre=w.hero.global_position+Vector3.UP*.9;panel.global_transform=Transform3D(w.camera.global_basis,centre+w.camera.global_basis.z)
 await shot("transform287-front-occluder")
 var p=w.camera.unproject_position(centre);var im=root.get_texture().get_image();var c=im.get_pixelv(Vector2i(p))
 check(c.b>.3 and c.b>c.r*3.,"opaque world geometry occludes new status presentation")
 panel.queue_free();w.cancel287()
 check(not w.combat_paused and w.hero.controls_enabled and w.hero.visual.visible and not fx.outline.visible,"cancel restores controls and clears visuals")
 check(fx.audio.voices.all(func(v):return not v.playing) and not fx.audio.hum.playing,"cancel stops all preview audio")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/transform287-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"sound_acceptance":"waveform integrity checked; timbre awaits listening","visual_acceptance":"pending user","scope":"8 second visual/audio state preview; timed active damage not implemented"},"  "));f.close()
 print("TRANSFORM287_VALIDATION ",ok);quit(0 if ok else 1)
