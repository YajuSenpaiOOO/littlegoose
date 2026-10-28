extends "res://scripts/world/station86_probe.gd"
class Sample89:
 extends "res://scripts/world/storybook_world89.gd"
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(_reposition := true) -> void: pass

func shot89(sample: Node3D,at: Vector2,label: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(35)
 for enabled in [false,true]:
  sample.set_look89(enabled);await settle72(8)
  var frame := await snapshot()
  frame.save_png("res://docs/captures/world_restart/storybook89_"+label+("_after" if enabled else "_before")+".png")

func run() -> void:
 var sample := Sample89.new();root.add_child(sample)
 while sample.soil_texture89==null: await physics_frame
 await settle72(20)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 verify(sample.soil_texture89.get_width()==192,"tree-driven litter field ready")
 verify(sample.ground_materials[0].shader.code.contains("forest_floor89(col"),"floor treatment reaches live terrain shader")
 verify(sample.grass_material.shader.code.contains("route_light89"),"live grass uses matching pigment")
 sample.set_look89(false)
 verify(is_zero_approx(float(sample.ground_materials[0].get_shader_parameter("floor_strength89"))),"comparison disables floor treatment")
 verify(is_zero_approx(float(sample.grass_material.get_shader_parameter("storybook89"))),"comparison disables grass pigment")
 sample.set_look89(true);sample.time55.apply_look()
 verify(is_equal_approx(float(sample.atmosphere41.focus_material.get_shader_parameter("radius_pixels")),2.5),"time updates preserve focus comparison")
 verify(await walk_route72(sample,"junction_to_grove"),"forest entry remains traversable")
 verify(await walk_route72(sample,"woodland_return72"),"return route remains traversable")
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot89(sample,g+Vector2(0,4.),"centre_day")
 await shot89(sample,g+Vector2(-18.,3.),"west_day")
 await shot89(sample,g+Vector2(-5.,-9.),"rear_day")
 await shot89(sample,sample.meadow.landmarks.home,"home_day")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot89(sample,g+Vector2(-18.,3.),"west_sunset")
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 await shot89(sample,g+Vector2(-18.,3.),"west_night")
 var data := {"checks":checks,"failures":failures}
 var file := FileAccess.open("res://docs/storybook89-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("STORYBOOK89_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
