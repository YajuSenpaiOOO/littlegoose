extends "res://scripts/world/forest192_capture.gd"
func world_script192() -> Script: return preload("res://scripts/world/woodland_world193.gd")
func result_prefix192() -> String: return "forest193"
func actor_color193(actor: Node3D,image: Image) -> Color:
 var p: Vector2=sample.camera.unproject_position(actor.global_position+Vector3.UP*.65)
 var sum := Color(0,0,0,0)
 for y in range(-12,13):
  for x in range(-12,13): sum+=image.get_pixel(clampi(roundi(p.x)+x,0,image.get_width()-1),clampi(roundi(p.y)+y,0,image.get_height()-1))
 return sum/625.
func extra_checks192() -> void:
 var art: Node3D=sample.forest188
 verify(art.ropes193.size()==12 and art.anchors193.size()==2,"both hammock knots have ropes to fixed tree anchors")
 var anchors: Array=art.anchors193.duplicate()
 await settle(35)
 verify(art.anchors193==anchors,"hammock suspension anchors stay fixed during sway")
 sample._teleport15(Vector2(-44.,27.));await hour(22.);await picture("hammock_night")
 verify(sample.lighting191.lamps[0].omni_range>6.5,"existing local lamps have broader warm reach without added fixtures")
 sample._teleport15(Vector2(-4.7,-2.6))
 var actors: Array=[]
 for i in 2:
  sample.paper_trial129=i==1
  var at := Vector2(-4.7+(2. if i==0 else -2.),-2.4)
  var actor: CharacterBody3D=sample.make_actor119(70+i,at)
  sample.enemies.append(actor);actor.active_ai=false;actor.set_physics_process(false);actor.set_process(false);actor._render_legacy(0.);actors.append(actor)
 sample.paper_trial129=false
 await hour(12.);var day := await picture("actors_day")
 await hour(22.);var night := await picture("actors_night")
 for i in 2:
  var actor: Node3D=actors[i];var a := actor_color193(actor,day);var b := actor_color193(actor,night)
  metrics["actor%d_day"%i]=str(a);metrics["actor%d_night"%i]=str(b)
  verify(actor.soft_ink.shader.get_meta("enemy_grade193",false),"actor%d uses shared 159 environment grade"%i)
  verify(a.r+a.g+a.b>(b.r+b.g+b.b)*1.2,"actor%d rendered pixels become darker at night"%i)
  actor.soft_ink.shader=preload("res://scripts/combat/soft_body123.gdshader");actor.soft_ink.set_shader_parameter("tint",Color(1.,.4,.5,.7));sample.enemy_grade193.enroll(actor)
  var after: Color=actor.soft_ink.get_shader_parameter("tint")
  verify(after.is_equal_approx(Color(1.,.4,.5,.7)),"actor%d roll grade preserves hit tint and alpha"%i)
  actor.soft_ink.shader=preload("res://scripts/combat/soft_fade124.gdshader");actor.soft_ink.set_shader_parameter("tint",Color(1.,1.,1.,.37));sample.enemy_grade193.enroll(actor)
  verify(is_equal_approx(float(actor.soft_ink.get_shader_parameter("tint").a),.37),"actor%d fade grade preserves partial transparency"%i)
 for actor in actors: sample.enemies.erase(actor);actor.queue_free()
 sample._teleport15(Vector2(-44.,27.));await hour(22.);await picture("final_hammock")
