extends "res://scripts/world/station86_probe.gd"
class Sample92:
 extends "res://scripts/world/woodland_world92.gd"
 var permit92 := false
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(reposition := true) -> void:
  if permit92: super.start_combat(reposition)

func shot92(sample: Node3D,at: Vector2,tag: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(35)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland92_"+tag+".png")

func run() -> void:
 var sample := Sample92.new();root.add_child(sample)
 while not sample.woodland_ready92: await physics_frame
 await settle72(20)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot92(sample,g+Vector2(14.,8.),"entry_day")
 await shot92(sample,g+Vector2(-18.,3.),"west_day")
 await shot92(sample,g+Vector2(-6.,-11.),"rear_day")
 await shot92(sample,g+Vector2(0,4.),"centre_day")
 sample.set_grass_layout92(false);await shot92(sample,g+Vector2(0,4.),"centre_old_grass")
 sample.set_grass_layout92(true)
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot92(sample,g+Vector2(-19.,-5.),"rim_sunset")
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 await shot92(sample,g+Vector2(14.,8.),"entry_night")
 verify(sample.composition_trees92>=3,"asymmetric entrance and boundary tree groups installed")
 var trees_safe := true
 for tree in sample.trees:
  if not tree.root.has_meta("composition92"): continue
  var at := Vector2(tree.root.position.x,tree.root.position.z)
  trees_safe=trees_safe and sample._tree_support92(at)
 verify(trees_safe,"composition tree trunks remain outside battle extent with ground support")
 verify(sample.forest87.understory92>=5,"grouped middle-height plants installed outside centre")
 verify(sample.grass_changed92>100 and sample._grass_growth92(g)<.65,"clearing has calm low-grass centre")
 verify(sample._grass_growth92(g+Vector2(-14.,8.))>1.,"edge pocket has taller grass rather than uniform lawn")
 var old_surface := preload("res://scripts/world/world_surface90.gd").new()
 var hill := g+Vector2(-12.,7.)
 verify(sample.floor_height(hill)-old_surface.height_at(hill.x,hill.y,true)>.3,"actual physics carries the low meadow swell")
 var roads_unchanged := true
 for route in sample.meadow.named_routes:
  for at in route.points:
   roads_unchanged=roads_unchanged and absf(sample.meadow.height_at(at.x,at.y,true)-old_surface.height_at(at.x,at.y,true))<.001
 verify(roads_unchanged,"all original road centre heights remain unchanged")
 verify(sample.rocks91.edge_grass92.multimesh.instance_count>50,"broken short-grass tufts soften rock rims")
 verify(absf(sample.rocks91.source_area91-sample.rocks91.rock_area91-sample.rocks91.grass_area91)<.001,"grass-rock split remains watertight in area")
 verify(sample.time55.guide.text.count("\n")<9,"review guide is compact by default")
 verify(not sample.navigation.path(g+Vector2(-14.,0),g+Vector2(14.,0)).is_empty(),"enemy route crosses field between edge groups")
 verify(await walk_route72(sample,"junction_to_grove"),"original entrance remains traversable")
 verify(await walk_route72(sample,"woodland_return72"),"original woodland return remains traversable")
 sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(-15.,3.));await settle72(8)
 var width_ok := await walk_to(sample,g+Vector2(0,3.));width_ok=width_ok and await walk_to(sample,g+Vector2(15.,3.))
 verify(width_ok,"full central battle width remains walkable")
 sample._teleport15(g+Vector2(0,12.));await settle72(8)
 var depth_ok := await walk_to(sample,g);depth_ok=depth_ok and await walk_to(sample,g+Vector2(0,-13.))
 verify(depth_ok,"full central battle depth remains walkable")
 sample.permit92=true;sample.start_combat(true);await settle72(90)
 verify(sample.wave_state=="fighting" and sample.enemies.size()>0,"existing combat starts within the new forest framing")
 var data := {"checks":checks,"failures":failures,"tree_groups":sample.composition_trees92,"middle_plants":sample.forest87.understory92,"grass_instances":sample.grass_changed92,"rim_tufts":sample.rocks91.edge_grass92.multimesh.instance_count}
 var file := FileAccess.open("res://docs/woodland92-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("WOODLAND92_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
