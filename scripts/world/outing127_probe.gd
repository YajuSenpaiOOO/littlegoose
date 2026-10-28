extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world127.gd"
 func _hero_script() -> Script: return Fighter
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://outing127_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 var a: CharacterBody3D=s.enemies[0];var b: CharacterBody3D=s.enemies[1]
 var g: Vector2=s.meadow.landmarks.grove
 for i in range(2,s.enemies.size()): s.enemies[i].hide()
 a.play119();b.play119();a.set_physics_process(false);b.set_physics_process(false)
 a.position=Vector3(g.x,s.floor_height(g)+.05,g.y);b.position=a.position+Vector3(.9,0.,0.)
 s.jelly_fx.clear();a.begin_quarrel123(b);b.begin_quarrel123(a)
 a._physics_process(.66);b._physics_process(.66)
 verify(a.visual.texture==a.textures.shove124 and a.visual.texture.resource_path.ends_with("shove127_annoyed.png"),"new mildly angry face is used during shoving")
 var combo: int=s.combo;var feedback: int=s.feedback_count;var count: int=s.defeated_count
 a._physics_process(.63);b._physics_process(.63)
 verify(s.shove_bursts127==1 and s.jelly_fx.drops.size()==2,"mutual contact emits one shared original jelly burst, not two copies")
 for i in 5: a._physics_process(.016);b._physics_process(.016)
 verify(s.shove_bursts127==1,"continuous contact does not emit juice every frame")
 verify(s.combo==combo and s.feedback_count==feedback and s.defeated_count==count,"peer juice does not award player combo, hit feedback or defeats")
 s.combat_paused=true;s.shove_juice127(a,b)
 verify(s.shove_bursts127==1,"pause suppresses peer contact effects")
 s.combat_paused=false;s.combat_clock33+=.7;a.position=b.position+Vector3(-2.5,0,0)
 a._physics_process(.63)
 verify(s.shove_bursts127==1,"out of reach shoving emits no contact burst")
 a.position=b.position+Vector3(-.9,0,0);a.play_state123="shove";a.play_clock123=.6;a.shove_tick123=0
 a._physics_process(.03)
 verify(s.shove_bursts127==2,"the next real shove can emit juice after its pair cooldown")
 s._teleport15(g+Vector2(0.,5.));await settle72(25)
 # Freeze the contact moment for a clean expression/juice capture.
 s.jelly_fx.clear();s.combat_clock33+=1.;s.shove_juice127(a,b);s.jelly_fx._process(.055)
 a._render_legacy(0.);b._render_legacy(0.);a.visual.reset_physics_interpolation();b.visual.reset_physics_interpolation()
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/outing127_shove.png")
 var data := {"checks":checks,"failures":failures}
 FileAccess.open("res://docs/outing127-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 s.home116();await settle72(2);DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("OUTING127_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
