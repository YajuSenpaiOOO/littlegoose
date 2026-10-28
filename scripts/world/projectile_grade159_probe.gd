extends "res://scripts/world/balloon_sword153_probe.gd"
class Trial159:
 extends "res://scripts/world/woodland_world159.gd"
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func close159(a: Color,b: Color) -> bool:
 return absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)<.005
func time159(s: Node3D,hour: float) -> void:
 s.time55.preview_at(hour);s.time55.visual_hour=hour;s.time55.apply_look()
 await settle72(3);await process_frame
func shot159(tag: String) -> void:
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/projectile_grade159_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial159.new();s.memory_save116="user://grade159_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.swords153): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0,4.));await settle72(12)
 for actor in s.enemies: actor.hide();actor.hit_area.collision_layer=0
 s.build153=1;s.apply_paper_build129();var m: Node3D=s.swords153;var layer: Node3D=s.effects159
 verify(m.get_parent()==layer and s.paper_memories146.get_parent()==layer,"sword, glue end, planes and notebook live under the common 3D combat visual root")
 s.set_physics_process(false)
 var tip: Vector3=s.hero.position+Vector3(0,0,-3.);tip.y=s.floor_height(Vector2(tip.x,tip.z))+.08
 m.attach153(null,tip,Vector3.DOWN);var entry: Dictionary=m.resting153[0]
 var test_sprite := Sprite3D.new();test_sprite.texture=m.texture153;test_sprite.pixel_size=.9/m.texture153.get_height();test_sprite.position=tip+Vector3(-1.8,.8,0.);test_sprite.billboard=BaseMaterial3D.BILLBOARD_ENABLED;test_sprite.modulate=Color(.8,.7,1.,.45);layer.add_child(test_sprite)
 var cube := MeshInstance3D.new();cube.mesh=BoxMesh.new();cube.position=tip+Vector3(1.8,.4,0.)
 var material := StandardMaterial3D.new();material.albedo_color=Color(.7,.4,.2,.6);cube.material_override=material;layer.add_child(cube)
 var ignored := Sprite3D.new();ignored.texture=m.texture153;ignored.set_meta("environment_grade159",false);layer.add_child(ignored)
 await time159(s,12.);var noon: Color=layer.tint159
 print("COLOR159 noon=",noon," pad=",entry.pad158.modulate," sprite=",test_sprite.modulate," cube=",cube.material_override.albedo_color," counts=",layer.sprites159.size(),"/",layer.materials159.size())
 verify(close159(entry.pad158.modulate,noon) and m.ink154(entry.node).shader.code.contains("world_effect_grade159"),"default glue sprite and custom blade shader share the existing 2D combat tint")
 verify(close159(test_sprite.modulate,Color(.8*noon.r,.7*noon.g,noon.b)) and is_equal_approx(test_sprite.modulate.a,.45),"a newly added generic sprite automatically preserves its own RGB and alpha while inheriting the scene tint")
 verify(close159(cube.material_override.albedo_color,Color(.7*noon.r,.4*noon.g,.2*noon.b)) and cube.material_override!=material and is_equal_approx(material.albedo_color.a,.6),"a standard material enrolls automatically without modifying shared source resources")
 await shot159("noon")
 await time159(s,18.8);var dusk: Color=layer.tint159;await shot159("dusk")
 await time159(s,23.);var night: Color=layer.tint159;await shot159("night")
 verify(not close159(noon,dusk) and not close159(dusk,night) and night.get_luminance()<noon.get_luminance()*.8,"live noon, dusk and night produce distinct tints with darker night projectiles")
 verify(close159(entry.pad158.modulate,night),"existing glue visuals update alongside the globally graded blade when time changes")
 var born := Sprite3D.new();born.texture=m.texture153;born.modulate.a=.32;layer.add_child(born);await process_frame;await process_frame
 verify(close159(born.modulate,night) and is_equal_approx(born.modulate.a,.32),"a fresh projectile born at night immediately inherits the current tint without manual registration")
 entry.pad158.modulate.a=.37;test_sprite.modulate.a=.2;layer._process(0.)
 verify(is_equal_approx(entry.pad158.modulate.a,.37) and is_equal_approx(test_sprite.modulate.a,.2),"environment updates do not overwrite independently animated fade alpha")
 var before: Color=test_sprite.modulate
 for i in 30: layer._process(0.)
 verify(close159(before,test_sprite.modulate),"repeated updates do not compound the day-night multiplier")
 verify(close159(ignored.modulate,Color.WHITE),"an explicitly opted-out effect can keep its own emission look")
 var material_count: int=layer.materials159.size();cube.queue_free();born.queue_free();await process_frame;layer._process(0.)
 verify(layer.materials159.size()<material_count,"released effect references and material copies are pruned")
 await time159(s,12.);verify(close159(entry.pad158.modulate,noon),"returning to noon restores the original tint rather than retaining accumulated night color")
 var report := {"checks":checks,"failures":failures,"noon":str(noon),"dusk":str(dusk),"night":str(night),"note":"Shared automatic environment grade checks; no repeated map or battle-balance suite."}
 FileAccess.open("res://docs/projectile-grade159-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("PROJECTILE_GRADE159_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
