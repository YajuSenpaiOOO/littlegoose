extends "res://scripts/world/woodland93_probe.gd"
class Sample95:
 extends "res://scripts/world/woodland_world95.gd"
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(_reposition := true) -> void: pass

func shot95(sample: Node3D,at: Vector2,tag: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(45)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland95_"+tag+".png")

func receiver95(sample: Node3D,visual: Sprite3D,tag: String) -> bool:
 var at := Vector2(visual.global_position.x,visual.global_position.z)
 sample._teleport15(at+Vector2(2.8,2.8));sample.hero.controls_enabled=false;await settle72(25)
 sample.forest87.set_process(false)
 var ray: Vector3=-sample.sun.global_basis.z.normalized()
 var height: float=visual.texture.get_height()*visual.pixel_size
 var caster := MeshInstance3D.new();var box := BoxMesh.new();box.size=Vector3(6,2,6)
 caster.mesh=box;caster.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
 sample.add_child(caster);caster.global_position=visual.global_position+Vector3.UP*height*.5-ray*4.
 var material: ShaderMaterial=visual.material_override
 var receiving: Shader=material.shader
 var disabled := Shader.new();disabled.code=receiving.code.replace("render_mode cull_disabled;","render_mode cull_disabled, shadows_disabled;")
 material.shader=disabled;await settle72(8)
 var before := await snapshot();before.save_png("res://docs/captures/world_restart/woodland95_"+tag+"_unreceived.png")
 material.shader=receiving;await settle72(8)
 var after := await snapshot();after.save_png("res://docs/captures/world_restart/woodland95_"+tag+"_received.png")
 var texture: Image=visual.texture.get_image()
 if texture.is_compressed(): texture.decompress()
 var changed := 0;var total := 0;var difference := 0.
 for y in range(2,19):
  for x in range(2,19):
   var uv := Vector2(x/20.,y/20.)
   if texture.get_pixel(int(uv.x*(texture.get_width()-1)),int(uv.y*(texture.get_height()-1))).a<.9: continue
   var pixel := uv*Vector2(visual.texture.get_size())
   var local := Vector3((pixel.x-texture.get_width()*.5+visual.offset.x)*visual.pixel_size,(texture.get_height()*.5-pixel.y+visual.offset.y)*visual.pixel_size,0)
   var screen: Vector2=sample.camera.unproject_position(visual.to_global(local))
   var point := Vector2i(screen*Vector2(before.get_size())/sample.get_viewport().get_visible_rect().size)
   if not Rect2i(Vector2i.ZERO,before.get_size()).has_point(point): continue
   var a := before.get_pixelv(point);var b := after.get_pixelv(point)
   var d := (a.r+a.g+a.b-b.r-b.g-b.b)/3.
   difference+=d;total+=1
   if d>.015: changed+=1
 caster.queue_free();sample.forest87.set_process(true)
 print("RECEIVER95 ",tag," pixels=",total," darker=",changed," mean=",difference/maxi(total,1))
 # Alpha samples can be occluded by neighbouring leaves. Require a meaningful
 # visible darkening, without assuming every sampled source texel is visible.
 return total>10 and changed>10 and difference/total>.015

func measure95(sample: Node3D,scoped: bool) -> Dictionary:
 sample.effect_scope95.set_enabled95(scoped)
 for i in 35: await process_frame
 var times: Array[float]=[];var cpu: Array[float]=[]
 var last := Time.get_ticks_usec();var updates: int=sample.effect_scope95.updates95
 var rebuilds := 0
 for shadow in sample.effect_scope95.shadows95: rebuilds+=shadow.rebuild_count
 for i in 180:
  await process_frame
  var now := Time.get_ticks_usec();times.append((now-last)/1000.);last=now
  cpu.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.)
 var after := 0
 for shadow in sample.effect_scope95.shadows95: after+=shadow.rebuild_count
 times.sort();cpu.sort()
 return {"median_ms":times[90],"p95_ms":times[171],"max_ms":times[-1],"cpu_median_ms":cpu[90],"projection_calls":sample.effect_scope95.updates95-updates,"projection_rebuilds":after-rebuilds,"active_projections":sample.effect_scope95.active95.size(),"all_projections":sample.effect_scope95.shadows95.size(),"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}

func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);Engine.max_fps=0
 var sample := Sample95.new();root.add_child(sample)
 while not sample.woodland_ready95: await physics_frame
 await settle72(25)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 var props: Node3D=sample.forest87
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot95(sample,g+Vector2(-3,-1),"field_day")
 await shot95(sample,g+Vector2(0,4),"centre_day")
 verify(props.colonies94.size()==1 and props.flower_points94.size()>250,"flowers form one concentrated field")
 var together := true
 for at in props.flower_points94: together=together and ((at-g-Vector2(-3.1,-5.7))/Vector2(5.8,3.4)).length()<=1.001
 verify(together,"all added flowers belong to the same clearing")
 var receives := true
 for plant in props.plants87: receives=receives and not plant.material_override.shader.code.contains("shadows_disabled") and plant.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 for batch in props.flower_batches94: receives=receives and not batch.material_override.shader.code.contains("shadows_disabled") and batch.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 for rock in props.rocks87: receives=receives and not rock.visual.material_override.shader.code.contains("shadows_disabled") and is_instance_valid(rock.shadow)
 verify(receives,"plants and flowers cast and receive sun shadows; rocks receive and retain their fitted projections")
 verify(await receiver95(sample,props.plants87[-1],"fern"),"rendered fern actually darkens beneath a controlled shadow caster")
 verify(await receiver95(sample,props.rocks87[-1].visual,"rock"),"rendered painted rock actually darkens beneath a controlled shadow caster")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot95(sample,g+Vector2(-3,-1),"field_sunset")
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 await shot95(sample,g+Vector2(-3,-1),"field_night")
 var scope: Node=sample.effect_scope95
 scope.refresh95()
 verify(scope.active95.size()<scope.shadows95.size(),"padded camera scope excludes distant custom projections")
 var distant: Node
 for shadow in scope.shadows95:
  if not scope.active95.has(shadow): distant=shadow;break
 var count: int=distant.rebuild_count
 sample.sun.rotate_y(.01);await settle72(12)
 verify(distant.rebuild_count==count and not distant.visible and not distant.is_processing(),"distant projection does not rebuild or run its own process after sun changes")
 var target := Vector2(distant.visual.global_position.x,distant.visual.global_position.z)
 sample._teleport15(target+Vector2(0,2));await settle72(45)
 verify(scope.active95.has(distant),"approaching a previously distant projection reactivates it")
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 verify(await walk_route72(sample,"junction_to_grove"),"original entrance remains traversable")
 verify(await path93(sample,g+Vector2(-8,-5),g+Vector2(1,-5),true),"concentrated flower field remains freely walkable")
 # Paired samples in reversed order reduce simple warm-up/order bias.
 sample.hero.controls_enabled=false;sample._teleport15(g+Vector2(-3,-1));await settle72(30)
 sample.time55.preview=false;sample.time55.focused=true
 var performance := {}
 performance.unscoped_first=await measure95(sample,false)
 performance.scoped_first=await measure95(sample,true)
 performance.scoped_second=await measure95(sample,true)
 performance.unscoped_second=await measure95(sample,false)
 scope.set_enabled95(true)
 sample.sun.shadow_enabled=false
 performance.no_native_shadows=await measure95(sample,true)
 sample.sun.shadow_enabled=true
 var focus_mode: int=sample.time55.focus_mode86
 sample.time55.focus_mode86=2;sample.time55.apply_look()
 performance.no_depth_of_field=await measure95(sample,true)
 sample.time55.focus_mode86=focus_mode;sample.time55.apply_look()
 var data := {"checks":checks,"failures":failures,"flowers":props.flower_points94.size(),"performance":performance}
 var file := FileAccess.open("res://docs/woodland95-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("WOODLAND95_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
