extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world223.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready220:await process_frame
 w.auto114=false;w.pigs_enabled220=false;w.cat220.set_physics_process(false)
 var rig=w.rig220;w.set_process(false);rig.set_process(false)
 var heights: Array[float]=[]
 var scale_before=Vector3.ZERO
 for time in [.85,2.55]:
  rig.elapsed=time;rig._process(0.)
  var card: Sprite3D=rig.seated;var anchor: Vector2=card.get_meta("anchor205")
  var anchor_world: Vector3=rig.pixel_point(card,anchor)
  scale_before=card.scale
  heights.append(card.texture.get_height()*card.pixel_size*card.global_basis.y.length())
  card.scale=Vector3.ONE
  check(rig.pixel_point(card,anchor).distance_to(anchor_world)<.00001,"breathing keeps registered foot anchor fixed at "+str(time))
  card.scale=scale_before
  var hook=rig.pixel_point(rig.hammock,rig.textures.hammock.get_size()*Vector2(.089,.091))
  var ring=rig.pixel_point(rig.bats[0],rig.bats[0].get_meta("anchor205"))
  check(hook.distance_to(ring)<.001,"seated breathing leaves bat/hammock ring registration intact")
 check(heights[0]>heights[1] and heights[0]/heights[1]<1.02,"actual seated geometry breathes gently without changing baseline proportion")
 rig._process(0.);rig._process(0.)
 check(rig.seated.scale.is_equal_approx(scale_before),"rendering same clock does not accumulate stretch")
 w.set_process(true);rig.set_process(true);w.combat_paused=true
 var clock: float=rig.elapsed;var paused_scale: Vector3=rig.seated.scale
 await create_timer(.25).timeout
 check(rig.elapsed==clock and rig.seated.scale.is_equal_approx(paused_scale),"pause freezes breathing with battle clock")
 w.combat_paused=false;await create_timer(.25).timeout
 check(rig.elapsed>clock and not rig.seated.scale.is_equal_approx(paused_scale),"resume advances breathing again")
 metrics={"measured_heights":heights,"period_seconds":3.4,"vertical_amplitude":.006,"runtime":"223 only, no new collapsed pose selected"}
 w.end220(false);finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/breath223-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics},"\t"))
 print("BREATH223_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
