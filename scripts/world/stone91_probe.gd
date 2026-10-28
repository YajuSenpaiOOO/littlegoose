extends "res://scripts/world/station86_probe.gd"
class Sample91:
 extends "res://scripts/world/stone_world91.gd"
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(_reposition := true) -> void: pass

func shot91(sample: Node3D,at: Vector2,tag: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(30)
 for enabled in [false,true]:
  sample.rocks91.set_enabled91(enabled);await settle72(8)
  var frame := await snapshot()
  frame.save_png("res://docs/captures/world_restart/stone91_"+tag+("_after" if enabled else "_before")+".png")

func run() -> void:
 var sample := Sample91.new();root.add_child(sample)
 while not sample.stone_ready91: await physics_frame
 await settle72(20)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 var rock: Node3D=sample.rocks91
 verify(rock.rock_triangles91>100,"cliff side triangles use independent rock material")
 verify(absf(rock.rock_area91+rock.grass_area91-rock.source_area91)<.001,"clipped grass and rock surfaces preserve total terrain area")
 verify(rock.clean91.get_surface_count()==sample.meadow.chunks.size(),"ground material slots and path chunk bindings retained")
 var grass_code: String=sample.ground_materials[0].shader.code
 verify(grass_code.contains("Clean grass is continuous") and not grass_code.contains("vec3 litter"),"brown leaf stipple and muddy clearing overlay removed")
 verify(not rock.rock91.material_override.shader.code.contains("unshaded") and rock.rock91.material_override.shader.code.contains("SPECULAR=.12"),"rock receives actual lighting with rough material")
 var collider: Shape3D=sample.floor_collider.shape
 var before: float=sample.floor_height(g+Vector2(-17,0))
 rock.set_enabled91(false)
 verify(sample.ground.mesh==rock.original91 and not rock.rock91.visible,"same-camera comparison restores original90 surfaces")
 rock.set_enabled91(true)
 verify(sample.floor_collider.shape==collider and absf(sample.floor_height(g+Vector2(-17,0))-before)<.001,"visual partition preserves original physical terrain")
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot91(sample,g+Vector2(-18.,3.),"west_day")
 await shot91(sample,g+Vector2(-6.,-11.),"rear_day")
 await shot91(sample,g+Vector2(-19.,-5.),"grass_rim")
 await shot91(sample,g+Vector2(0,4.),"centre_day")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot91(sample,g+Vector2(-18.,3.),"west_sunset")
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 await shot91(sample,g+Vector2(-6.,-11.),"rear_night")
 verify(await walk_route72(sample,"junction_to_grove"),"actual character reaches woodland through original entry")
 verify(await walk_route72(sample,"woodland_return72"),"actual character returns through original path")
 var original_count: int=rock.rock_triangles91
 sample._assign_ground_materials()
 verify(sample.rocks91.rock_triangles91==original_count,"material rebuild retains independent cliff faces")
 var data := {"checks":checks,"failures":failures,"source_triangles":sample.rocks91.source_triangles91,"rock_triangles":sample.rocks91.rock_triangles91,"area_error":absf(sample.rocks91.rock_area91+sample.rocks91.grass_area91-sample.rocks91.source_area91)}
 var file := FileAccess.open("res://docs/stone91-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("STONE91_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
