extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world250.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready247 or not is_instance_valid(w.projection250):await process_frame
 var b=w.boss247;var p=w.projection250
 w.auto114=false;w.invulnerability=1000.;b.set_physics_process(false);w.hero.set_physics_process(false)
 await settle();await process_frame;p._process(0.)
 check(p.is_processing() and p.get_script()==w._actor_shadow_script105() and p.visual==b.visual,"boss uses ordinary actor silhouette factory")
 check(p in w.actor_shadows and p.get_parent()==b,"projection registered with world and owned by boss")
 check(not b.shadow.visible and p.visible,"one silhouette shadow, no ellipse overlap")
 check(not w.show_landing249 and not b.marker247.visible,"landing circle remains off")
 var initial=w.actor_shadows.size()
 w.time55.visual_hour=12.;w.time55.apply_look();await settle();await process_frame;p._process(0.)
 check(p.light_direction.is_equal_approx(-w.sun.global_basis.z.normalized()),"noon projection follows world sun")
 b.enter247("rest");b.render247();await shot("boss250-ground-noon")
 var ground_pose=b.visual.global_transform
 b.enter247("flight");b.from247=Vector2(b.position.x,b.position.z);b.goal247=b.from247+Vector2(2.,0.);b._physics_process(.20)
 await settle();await process_frame;p._process(0.)
 check(not b.shadow.visible and p.visible,"flight does not re-enable ellipse")
 check(b.visual.global_position.y>ground_pose.origin.y+1.,"body rises for airborne projection")
 if p.gpu113:
  var submitted: Transform3D=p.ink.get_shader_parameter("visual_world113")
  check(absf(submitted.origin.y-b.visual.get_global_transform_interpolated().origin.y)<.01,"GPU projection receives actual airborne sprite transform")
 else:check(p.mesh!=null,"CPU projection generates terrain mesh")
 check(p.last_texture==b.visual.texture,"projection samples current body pose")
 await shot("boss250-air-noon")
 b.enter247("angry");b._physics_process(.1);await settle();await process_frame;p._process(0.)
 check(p.last_texture==b.textures.shove124,"angry expression and silhouette share same source")
 var daytime=p.opacity_scale
 w.time55.visual_hour=23.;w.time55.apply_look();await settle();await process_frame;p._process(0.)
 check(p.light_direction.is_equal_approx(-w.sun.global_basis.z.normalized()) and p.opacity_scale<daytime,"night direction and opacity use existing world palette")
 await shot("boss250-night")
 w.time55.visual_hour=12.;w.time55.apply_look()
 p.enabled=false;await settle();await process_frame;p._process(0.);check(not p.visible,"world projector enabled switch honored")
 p.enabled=true;await settle();await process_frame;p._process(0.);check(p.visible,"world projector resumes")
 b.enter247("flight");b.from247=Vector2(b.position.x,b.position.z)-Vector2.RIGHT;b.goal247=Vector2(b.position.x,b.position.z)
 w.invulnerability=0.;w.hero.position=b.position;w.hero.parry_t=.15;w.hero.parried=false;w.hero.dodge_invulnerability=0.
 b.land247();await settle();await process_frame;p._process(0.)
 check(b.phase247=="deflected" and b.reverse_pending249 and not b.shadow.visible,"parry still arms single reverse bounce with no ellipse")
 await shot("boss250-parry")
 w.finish247(false);var old_id=p.get_instance_id();w.begin247();b=w.boss247;p=w.projection250;b.set_physics_process(false);await settle();await process_frame;p._process(0.)
 check(p.get_instance_id()!=old_id and w.actor_shadows.size()==initial,"restart replaces projection without stale registrations")
 b.receive_hit(10000.,Vector3.RIGHT);await create_timer(.25).timeout
 check(not w.active114 and b.dead and not b.shadow.visible,"defeat keeps legacy ellipse disabled")
 b.visual.modulate.a=.4;p._process(0.)
 check(absf(float(p.ink.get_shader_parameter("opacity"))-.27*.4*p.opacity_scale)<.001,"projection follows actor fade opacity")
 w.clear247();await process_frame
 check(not is_instance_valid(p),"actor cleanup removes owned projector")
 var ok=checks.all(func(c):return c.pass)
 var file=FileAccess.open("res://docs/boss250-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));file.close()
 print("BOSS250_VALIDATION ",ok," checks=",checks.size());quit(0 if ok else 1)
