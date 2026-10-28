extends "res://scripts/world/combat111_probe.gd"
func run() -> void:
 var sample := Battle111.new();root.add_child(sample)
 while not sample.woodland_ready111: await physics_frame
 sample.permit=true;sample.start_combat();sample.hero.controls_enabled=true
 var g: Vector2=sample.meadow.landmarks.grove;sample._teleport15(g+Vector2(0,2))
 for id in ["forest_fireboy","three_player","flashlight","eye_exercise","snack"]: sample.buffs.apply(id)
 sample._apply_owned_buffs();sample.beam_left110=.8;await settle72(5)
 verify(sample.skills110.geese110.size()==3,"multi-buff fixture has four geese before restart")
 var key := InputEventKey.new();key.pressed=true;key.physical_keycode=KEY_F5;sample._unhandled_input(key);await settle72(3)
 verify(sample.buffs.levels.is_empty() and sample.skills110.geese110.is_empty(),"actual F5 clears all cards and extra geese")
 verify(sample.shots.is_empty() and sample.beam_left110==0. and sample.round_index==0,"F5 clears bullets and jets and restarts at act one")
 sample.buffs.apply("paper_racer");sample.start_combat();verify(sample.buffs.levels.is_empty(),"result-screen restart entry also clears cards")
 sample.buffs.apply("red_banner");sample._spawn_wave110(1);verify(sample.buffs.level("red_banner")==1,"advancing an act preserves the selected card")
 sample.draft_open=true;sample._unhandled_input(key);await settle72(2)
 verify(not sample.draft_open and sample.buffs.levels.is_empty(),"F5 also restarts cleanly while the draft is open")
 sample.start_combat();disable_enemies(sample);sample._teleport15(g+Vector2(0,2));sample.hero.controls_enabled=true
 var tints := {}
 for hour in [6.,12.,18.,22.]:
  sample.time55.preview_at(hour);sample.time55.visual_hour=hour;sample.time55.apply_look();sample._grade_combat111()
  tints[str(hour)]=sample.combat_tint111.color
 verify(tints["22.0"].r<tints["12.0"].r*.75 and tints["22.0"].b>tints["22.0"].r,"night grades the shared combat canvas darker and cooler")
 verify(tints["18.0"].r>tints["18.0"].b*1.15,"dusk grades projectiles and combat particles warm")
 sample.buffs.apply("flashlight");sample._apply_owned_buffs();sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look();sample._grade_combat111()
 var invalid_before: int=sample.shots.size();sample.emit_stream110(Vector3.INF)
 verify(sample.shots.size()==invalid_before,"invalid aim positions cannot generate zero-length or non-finite water particles")
 var origin: Vector3=sample.projectile_origin();sample.emit_stream110(origin+Vector3(0,0,-8));sample.emit_stream110(origin+Vector3(0,0,-8));sample.skills110.build_chains110()
 var width: float=sample.skills110.chains110[0].pixel
 sample.shots[0].node.position+=Vector3(0,0,-7);sample.skills110.build_chains110()
 verify(absf(sample.skills110.chains110[0].pixel-width)<.00001,"oldest-particle depth cannot change the whole beam width")
 for hour in [12.,18.,22.]:
  sample._clear_combat_shots();sample.time55.preview_at(hour);sample.time55.visual_hour=hour;sample.time55.apply_look();sample._grade_combat111()
  sample.emit_stream110(sample.hero.position+Vector3(0,.8,-7));sample.beam_left110=.5;root.warp_mouse(sample.camera.unproject_position(sample.hero.position+Vector3(0,.8,-7)));await settle72(8)
  sample.label.get_parent().hide();sample.frames66.panel.hide();sample.time55.guide.hide();var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/combat111_beam_"+str(int(hour))+".png")
 sample._clear_combat_shots();sample.beam_left110=0.;sample.set_physics_process(false)
 # Legacy fragments: six first-generation, four second-generation, birth grace.
 sample.set_physics_process(false);sample._clear_combat_shots()
 sample.pending_splits110.append({"at":sample.hero.position+Vector3.UP*.8,"damage":.5,"depth":1,"velocity111":Vector3.RIGHT*12.,"life111":.43,"piercing111":false})
 sample._step_shots(1./60.)
 verify(sample.shots.size()==6 and sample.shots[0].spawn_grace111==.06,"legacy first split creates six outward fragments with birth grace")
 verify(absf(sample.shots[0].life-.43)<.0001 and absf(sample.shots[0].velocity.length()-12.)<.0001,"fragment speed and remaining lifetime come from its parent")
 sample._clear_combat_shots();sample.pending_splits110.append({"at":sample.hero.position+Vector3.UP*.8,"damage":.25,"depth":2,"velocity111":Vector3.RIGHT*22.,"life111":.35,"piercing111":true});sample._step_shots(1./60.)
 verify(sample.shots.size()==4 and sample.shots[0].piercing110,"legacy second split is four-way and inherits penetration")
 sample._clear_combat_shots()
 var random := RandomNumberGenerator.new();random.seed=1110111
 var misses := [];var clears := 0;var hits := 0
 for i in 6000:
  if i%100==0: sample.grid111.rebuild()
  sample.grid111.births=0
  var at := g+Vector2(random.randf_range(-15.,15.),random.randf_range(-15.,15.));var height: float=sample.floor_height(at)
  var start := Vector3(at.x,height+random.randf_range(.05,3.),at.y)
  var end := start+Vector3(random.randf_range(-.8,.8),random.randf_range(-.7,.5),random.randf_range(-.8,.8))
  var query := PhysicsRayQueryParameters3D.create(start,end,1|2|8,[sample.hero.get_rid()]);query.collide_with_areas=true;query.hit_from_inside=true
  var native: Dictionary=sample.space110.intersect_ray(query);var possible: bool=sample.grid111.might_hit(start,end)
  if not native.is_empty(): hits+=1
  if not possible:
   clears+=1
   if not native.is_empty() and misses.size()<8: misses.append({"from":str(start),"to":str(end),"body":str(native.collider)})
 verify(clears>300,"broad phase rejects demonstrably empty flight segments")
 verify(misses.is_empty(),"6000 native comparison rays have zero broad-phase false negatives")
 var seat: Node3D=sample.park99.seat_body100;sample.grid111.rebuild()
 verify(sample.grid111.might_hit(seat.global_position-Vector3(1,0,0),seat.global_position+Vector3(1,0,0)),"moving swing always retains native collision queries")
 var data := {"checks":checks,"failures":failures,"native_comparison_rays":6000,"native_hits":hits,"empty_culled":clears,"false_negatives":misses,"tints":tints}
 var file := FileAccess.open("res://docs/combat111-visual-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("VISUAL111 ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
