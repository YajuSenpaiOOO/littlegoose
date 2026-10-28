extends "res://scripts/world/station86_probe.gd"
class Sample90:
 extends "res://scripts/world/terrace_world90.gd"
 var permit90 := false
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(reposition := true) -> void:
  if permit90: super.start_combat(reposition)

func shot90(sample: Node3D,at: Vector2,label90: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(35)
 var frame := await snapshot()
 frame.save_png("res://docs/captures/world_restart/terrace90_"+label90+".png")

func run() -> void:
 var sample := Sample90.new();root.add_child(sample)
 while not sample.terrace_ready90: await physics_frame
 await settle72(25)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot90(sample,g+Vector2(14.,8.),"entry_day")
 await shot90(sample,g+Vector2(-18.,3.),"west_day")
 await shot90(sample,g+Vector2(-6.,-11.),"rear_day")
 await shot90(sample,g+Vector2(0,4.),"centre_day")
 sample.set_review72(true);await settle72(20)
 var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/terrace90_overview.png")
 sample.set_review72(false)
 verify(sample.meadow.height_at(-76.,g.y,true)>4.4,"western shelf has broad real top")
 verify(sample.meadow.height_at(-50.,-75.,true)>6.,"rear shelf continues north with full-height top")
 var actual := sample.floor_height(Vector2(-76.,g.y))
 verify(absf(actual-sample.meadow.height_at(-76.,g.y,true))<.15,"real physics mesh carries western top")
 var central := true
 for offset in [Vector2(-17.,0),Vector2(17.,0),Vector2(0,-13.),Vector2(0,13.)]:
  central=central and absf(sample.floor_height(g+offset)-2.1)<.08
 verify(central,"central battle extent remains flat at approved level")
 var roots_ok := true
 for tree in sample.trees:
  var at := Vector2(tree.root.position.x,tree.root.position.z)
  if at.x> -28. or at.y> -27. or at.y< -82.: continue
  roots_ok=roots_ok and absf(tree.root.position.y-sample.meadow.height_at(at.x,at.y,true))<.04 and sample._safe_tree90(at)
 verify(roots_ok,"trees on modified shoulders have grounded supported roots")
 verify(sample.forest87.terrace_plants90>5,"grouped understory follows terrace feet")
 verify(sample.navigation.steep_cells72>0,"enemy navigation excludes steep rock faces")
 verify(not sample.navigation.path(g+Vector2(-14.,0),g+Vector2(14.,0)).is_empty(),"enemy navigation crosses battle field")
 for name90 in ["junction_to_grove","woodland_return72","junction_to_station","home_to_junction","junction_to_shore"]:
  verify(await walk_route72(sample,name90),"actual character traverses "+name90)
 sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(-15.,3.));await settle72(8)
 var width_ok := await walk_to(sample,g+Vector2(0,3.))
 width_ok=width_ok and await walk_to(sample,g+Vector2(15.,3.))
 verify(width_ok,"battle width remains traversable")
 sample._teleport15(g+Vector2(0,12.));await settle72(8)
 var depth_ok := await walk_to(sample,g)
 depth_ok=depth_ok and await walk_to(sample,g+Vector2(0,-13.))
 verify(depth_ok,"battle depth remains traversable")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot90(sample,g+Vector2(-18.,3.),"west_sunset")
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 await shot90(sample,g+Vector2(-6.,-11.),"rear_night")
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample.hero.controls_enabled=true;sample.permit90=true;sample.start_combat(true)
 await settle72(90)
 verify(sample.wave_state=="fighting" and sample.enemies.size()>0,"existing encounter starts on rebuilt terrain")
 var fighting_ok := true
 for enemy in sample.enemies:
  var at := Vector2(enemy.position.x,enemy.position.z)
  fighting_ok=fighting_ok and enemy.position.is_finite() and enemy.position.y>=sample.floor_height(at)-.18
 verify(fighting_ok,"active enemies remain above real ground")
 var fired: int=sample.fired_count
 sample.fire_at(sample.enemies[0].global_position+Vector3(0,.7,0));await settle72(12)
 verify(sample.fired_count>fired,"aimed shot works during existing encounter")
 var combat_frame := await snapshot();combat_frame.save_png("res://docs/captures/world_restart/terrace90_combat.png")
 var data := {"checks":checks,"failures":failures,"trees":sample.trees.size(),"moved_trees":sample.moved_trees90,"plants":sample.forest87.terrace_plants90}
 var file := FileAccess.open("res://docs/terrace90-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("TERRACE90_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
