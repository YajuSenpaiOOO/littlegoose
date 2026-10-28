extends "res://scripts/world/station85_probe.gd"
class Sample86:
 extends "res://scripts/world/world86.gd"
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(_reposition := true) -> void: pass
func capture86(sample: Node3D,at: Vector2,name: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(30)
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/station86_"+name+".png")
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);Engine.max_fps=0
 var sample := Sample86.new();root.add_child(sample)
 while not is_instance_valid(sample.station81): await physics_frame
 await settle72(25)
 var s: RefCounted=sample.meadow
 for x in [3.2,4.8,7.,10.]:
  sample.hero.controls_enabled=true;sample._teleport15(Vector2(x,-49.));await settle72(10)
  var reached := await walk_to(sample,Vector2(x,-47.4))
  var pos: Vector3=sample.hero.position
  print("CAP86 ",x," ",pos)
  verify(reached and pos.y>2.09,"upper approach stands above solid wall at x="+str(x))
 var side := await press85(sample,Vector2(7.,-42.7),Vector2.UP)
 verify(side.z> -44.1,"lower approach still blocked by moss cheek")
 sample.hero.controls_enabled=true;sample._teleport15(s.SIDE_FOOT75+Vector2(.7,0));await settle72(8)
 var passable := true
 for target in [s.SIDE_TOP75,Vector2(4.8,-49.),s.SIDE_TOP75,s.SIDE_FOOT75]:
  var stage := await walk_to(sample,target)
  print("STAIR86_STAGE ",target," ",stage," ",sample.hero.position)
  passable=passable and stage
 verify(passable,"capped walls retain normal stair climb and return")
 verify(await walk_route72(sample,"junction_to_station"),"whole road remains passable")
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var time: Node=sample.time55;time.preview_at(12.);time.visual_hour=12.;time.apply_look()
 await capture86(sample,Vector2(7.,-47.4),"wall_top")
 await capture86(sample,Vector2(8.4,-42.9),"light_dof")
 var perf := {}
 perf.original_cached=await record(sample,240,false)
 await settle72(30)
 perf.original_repeat=await record(sample,240,false)
 time.focus_mode86=1;time.apply_look();await settle72(30)
 perf.light=await record(sample,240,false)
 await capture86(sample,Vector2(8.4,-42.9),"original_dof")
 time.focus_mode86=0;time.apply_look();await settle72(30)
 perf.original_final=await record(sample,240,false)
 time.heat_enabled86=true;time.vignette_enabled86=true;time.apply_look();await settle72(30)
 perf.optional_effects=await record(sample,180,false)
 await capture86(sample,s.landmarks.station+Vector2(0,1.),"heat_on")
 # Freeze only the heat phase to verify distortion is actually visible in pixels.
 var material: ShaderMaterial=sample.atmosphere41.focus_material
 material.set_shader_parameter("heat_strength86",0.);var off := await snapshot()
 off.save_png("res://docs/captures/world_restart/station86_heat_off.png")
 time.heat_enabled86=false;time.vignette_enabled86=false;time.apply_look()
 verify(sample.sun.light_color==time.palette.sample(12.).sun,"noon uses neutral original sunlight colour")
 for hour in [8.,18.,22.]:
  time.visual_hour=hour;time.apply_look()
  verify(float(material.get_shader_parameter("heat_strength86"))==0.,"heat absent outside noon at "+str(hour))
 time.visual_hour=22.;time.apply_look()
 await capture86(sample,s.landmarks.station+Vector2(0,1.),"night")
 var data := {"checks":checks,"failures":failures,"performance":perf}
 var file := FileAccess.open("res://docs/station86-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("STATION86 ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
