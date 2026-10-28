extends "res://scripts/world/station86_probe.gd"
class Sample87:
 extends "res://scripts/world/world87.gd"
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(_reposition := true) -> void: pass
func shot87(sample: Node3D,at: Vector2,label: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(45)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/forest87_"+label+".png")
func run() -> void:
 var sample := Sample87.new();root.add_child(sample)
 while not is_instance_valid(sample.forest87): await physics_frame
 await settle72(25)
 var art: Node3D=sample.forest87;var g: Vector2=sample.meadow.landmarks.grove
 verify(art.rocks87.size()>=5 and art.plants87.size()>=20,"painted rocks and planted margins installed in original world")
 var clear := true
 for rock in art.rocks87:
  for offset in [Vector2(-.43,0),Vector2(.43,0),Vector2(0,-.21),Vector2(0,.21)]:
   clear=clear and ((rock.at+offset*rock.width-g)/Vector2(20.,15.)).length()>=1.035
 verify(clear,"all rock footprint extrema remain outside central battle ellipse")
 verify(not sample.time55.noon_enabled85 and sample.time55.vignette_enabled86,"accepted old noon and enlarged vignette remain defaults")
 verify(sample.ground_materials[0].shader.code.contains("moss_tone87"),"ground variations apply on existing terrain rather than raised patches")
 verify(await walk_route72(sample,"junction_to_grove"),"existing entry road reaches battle clearing")
 verify(await walk_route72(sample,"woodland_return72"),"woodland return road remains open")
 sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(-12.,4.));await settle72(10)
 var cross_ok := await walk_to(sample,g+Vector2(0.,4.))
 cross_ok=cross_ok and await walk_to(sample,g+Vector2(12.,4.))
 verify(cross_ok,"central left to right combat movement remains open")
 sample._teleport15(g+Vector2(0,10.));await settle72(10)
 verify(await walk_to(sample,g+Vector2(0,-10.)),"central front to back combat movement remains open")
 var rock: Dictionary=art.rocks87[0]
 var at := Vector2(rock.at.x,rock.at.y+rock.width*.19+1.)
 var pos := await press85(sample,at,Vector2.UP)
 verify(pos.z>rock.at.y+rock.width*.18,"actual character is stopped at painted rock footprint")
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot87(sample,g+Vector2(17.,10.),"entry_day")
 await shot87(sample,g+Vector2(-18.,3.),"west_day")
 await shot87(sample,g+Vector2(-5.,-9.),"rear_day")
 await shot87(sample,g+Vector2(0,4.),"centre_day")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot87(sample,g+Vector2(-18.,3.),"west_sunset")
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 await shot87(sample,g+Vector2(-18.,3.),"west_night")
 var data := {"checks":checks,"failures":failures,"rocks":art.rocks87.size(),"plants":art.plants87.size(),"tree_groups":sample.forest_trees87}
 var file := FileAccess.open("res://docs/forest87-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("FOREST87_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
