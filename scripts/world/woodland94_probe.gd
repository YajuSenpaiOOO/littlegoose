extends "res://scripts/world/woodland93_probe.gd"
class Sample94:
 extends "res://scripts/world/woodland_world94.gd"
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(_reposition := true) -> void: pass

func shot94(sample: Node3D,at: Vector2,tag: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(35)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland94_"+tag+".png")

func run() -> void:
 var sample := Sample94.new();root.add_child(sample)
 while not sample.woodland_ready94: await physics_frame
 await settle72(20)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 var props: Node3D=sample.forest87
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot94(sample,g+Vector2(0,4),"centre_day")
 await shot94(sample,g+Vector2(-3,-1),"flowers_day")
 await shot94(sample,g+Vector2(-18,3),"west_day")
 await shot94(sample,g+Vector2(14,8),"entry_day")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot94(sample,g+Vector2(-3,-1),"flowers_sunset")
 verify(props.flower_points94.size()>100 and props.flower_batches94.size()==3,"independent bare stems form flower drifts in three restrained colours")
 var grounded := true
 for at in props.flower_points94: grounded=grounded and props._flower_support94(at)
 verify(grounded,"all flower roots avoid roads, water, steep slopes, rock footprints and tree trunks")
 verify(props.colonies94.size()==4 and props.colonies94.min()>5,"four irregular colonies have populated visible openings")
 verify(props.plants94.size()==props.plants87.size(),"all existing and new forest shrubs and ferns use reactive materials")
 var chosen: Dictionary={};var approach := Vector2.ZERO
 for plant in props.plants94:
  var pos: Vector3=plant.visual.position
  if Vector2(pos.x,pos.z).distance_to(g)>20.: continue
  var at := Vector2(pos.x+.4,pos.z)
  var cell: Vector2i=sample.navigation.nearest(at)
  if (sample.navigation.origin+Vector2(cell)*sample.navigation.CELL).distance_to(at)>.4: continue
  chosen=plant;approach=at;break
 verify(not chosen.is_empty(),"reachable fern selected for live interaction check")
 if not chosen.is_empty():
  sample.hero.controls_enabled=false;sample._teleport15(approach);await settle72(35)
  var pushed: Vector3=chosen.push
  verify(pushed.length()>.025,"nearby hero pushes the fern away")
  verify(pushed.x<0.,"fern moves away from the hero rather than toward the hero")
  verify(Vector3(chosen.visual.material_override.get_shader_parameter("push94")).distance_to(pushed)<.0001,"live deformation is delivered to the rendered fern shader")
  props.set_process(false)
  props.set_reactive94(false)
  var before := await snapshot();before.save_png("res://docs/captures/world_restart/woodland94_touch_off.png")
  props.set_reactive94(true)
  var after := await snapshot();after.save_png("res://docs/captures/world_restart/woodland94_touch_on.png")
  props.set_process(true)
  sample._teleport15(g+Vector2(0,4));await settle72(90)
  verify(Vector3(chosen.push).length()<.003,"fern returns gently to rest after the hero leaves")
  var root_pos: Vector3=chosen.visual.position
  sample.hero.set_physics_process(false)
  sample.hero.position=Vector3(root_pos.x+.4,root_pos.y+4.,root_pos.z);sample.hero.reset_physics_interpolation();await settle72(35)
  verify(Vector3(chosen.push).length()<.003,"hero on a different height layer does not push the fern")
  sample.hero.set_physics_process(true)
 verify(await walk_route72(sample,"junction_to_grove"),"original entrance remains walkable with flowers")
 verify(await walk_route72(sample,"woodland_return72"),"original return route remains walkable with flowers")
 verify(await path93(sample,g+Vector2(-8,-5),g+Vector2(-1,-5),true),"player walks through the main flower drift without new hard obstacles")
 var flower_mat: ShaderMaterial=props.flower_batches94[0].material_override
 sample._teleport15(props.flower_points94[0]);await settle72(10)
 verify(Vector3(flower_mat.get_shader_parameter("walker")).distance_to(sample.hero.position)<.2,"flower batches receive the moving hero position")
 verify(flower_mat.get_shader_parameter("trail").size()==8,"flower stems share the original grass contact trail")
 var data := {"checks":checks,"failures":failures,"stems":props.flower_points94.size(),"colonies":props.colonies94,"reactive_plants":props.plants94.size()}
 var file := FileAccess.open("res://docs/woodland94-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("WOODLAND94_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
