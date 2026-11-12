extends "res://scripts/world/validate_paper301.gd"
class Harness302:
 extends "res://scripts/world/woodland_world302.gd"
 func export_stats226() -> Error:return OK
func world_script301() -> Script:return Harness302
func report_path301() -> String:return "res://docs/paper302-validation.json"
func shot301(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper302-"+tag+".png")
func extra_checks301() -> void:
 w.restart301();w.set_physics_process(false);w.set_process(false);w.auto114=false
 var c=w.cards301[0];prepare301(c);c.hp=100.;c.max_hp110=100.;c.anchor_velocity302=Vector2.ZERO;c.angle302=Vector2.ZERO;c.angular302=Vector2.ZERO;c.render301()
 check(is_zero_approx(c.visual.rotation.x) and is_zero_approx(c.operator301.rotation.x),"card and operator stay upright")
 check(c.visual.position.y>=.6,"resting card visibly clears ground")
 check(is_equal_approx(c.visual.basis.x.length(),1.) and is_equal_approx(c.visual.pixel_size*float(c.spec301.span[1]),2.1),"source aspect and authored size retained")
 c.move301(Vector2(2.,0.),1./60.);c.render301()
 check(c.angle302.x<0. and c.angular302.x<0.,"accelerating support makes card lag behind")
 c.angle302=Vector2.ZERO;c.angular302=Vector2.ZERO;c.anchor_velocity302=Vector2.ZERO
 c.receive_hit(1.,Vector3.RIGHT);var normal=c.angular302.length()
 for i in 20:c.step302(1./120.,Vector2.ZERO)
 c.render301()
 check(c.angle302.x>.01 and c.visual.rotation.z>0.,"shot impulse causes directional pendulum swing")
 var tab=Vector3((float(c.spec301.tab[0])-float(c.spec301.foot[0]))*c.visual.pixel_size,(float(c.spec301.foot[1])-float(c.spec301.tab[1]))*c.visual.pixel_size,0.)
 var attachment=c.visual.transform*tab;var support=c.operator301.position+Vector3(0,.08,0)
 check(absf(attachment.distance_to(support)-c.rope_length302)<.001,"rope stays taut at actual card tab")
 check(c.hit_area.position.distance_to(c.visual.transform*Vector3(0,1.05,0))<.001 and is_equal_approx(c.hit_area.rotation.z,c.visual.rotation.z),"hit capsule follows actual swing and lean")
 check(c.attack_at301().distance_to(Vector2(c.hit_area.global_position.x,c.hit_area.global_position.z))<.001,"attack footprint follows swinging card")
 var energy=c.angular302.length_squared()+c.angle302.length_squared()*5.
 for i in 480:c.step302(1./120.,Vector2.ZERO)
 check(c.angular302.length_squared()+c.angle302.length_squared()*5.<energy*.1,"damping settles accumulated swing")
 c.angular302=Vector2(90.,90.);c.step302(.3,Vector2(100.,-100.))
 check(c.angle302.length()<=c.LIMIT302+.0001 and c.angular302.length()<=3.6001,"strong impulses and long frames remain bounded")
 c.enter301("attack");c.angular302=Vector2.ZERO;w.invulnerability=0.;w.hero.parried=false;w.hero.parry_t=.2;c.deflect(c.hit_area.global_position)
 check(c.state301=="stunned" and c.angular302.length()>normal+.5,"parry gives a larger swing and cancels attack")
 var angle=c.angle302;var speed=c.angular302;w.combat_paused=true;c._physics_process(.3)
 check(c.angle302==angle and c.angular302==speed,"pause freezes pendulum state")
 w.combat_paused=false;c.enter301("rest");c.angle302=Vector2.ZERO;c.angular302=Vector2.ZERO;c.render301()
 # Same upright planes, front/back overlap in the real Compatibility renderer.
 w.hero.cancel_guard109();w.player_hp=w.max_player_health();w.invulnerability=0.;w.hurt_flash=0.;w.reset_impact248();w.porch49._update_actor()
 await create_timer(1.2).timeout
 for item in [[.2,"front"],[-.2,"behind"]]:
  var at=Vector2(c.position.x,c.position.z+item[0]);w._teleport15(at);w.hero.visual.modulate=Color.WHITE
  w.camera.position=c.position+Vector3(0,7.5,12.9);w.camera.look_at(c.position+Vector3.UP*1.5);w.camera.fov=38.
  await shot301(item[1])
 w._teleport15(Vector2(c.position.x+2.,c.position.z+1.));w.camera.position=c.position+Vector3(0,7.5,12.9);w.camera.look_at(c.position+Vector3.UP*1.5)
 c.receive_hit(1.,Vector3.RIGHT)
 for i in 28:c.step302(1./120.,Vector2.ZERO)
 c.render301();await shot301("swing")
 for hour in [8.,12.,18.,22.]:
  w.time55.preview_at(hour);w.time55.visual_hour=hour;w.time55.apply_look();w._grade_combat111();w.porch49._update_actor()
  await shot301("hour"+str(int(hour)))
 check(is_zero_approx(c.visual.rotation.x) and is_zero_approx(w.hero.visual.rotation.x),"time-of-day lighting does not tilt actors")
 var started=Time.get_ticks_usec()
 for i in 12000:c.step302(1./120.,Vector2.ZERO)
 metrics["pendulum_12000_steps_usec"]=Time.get_ticks_usec()-started
 metrics["pendulum_substeps_per_second_per_actor"]=120
 metrics["comparison"]="front/behind/swing snapshots require visual review; no global prop migration"
