extends "res://scripts/world/validate_plush220.gd"
var rig: Node3D
func shot(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/fall224-"+tag+".png")
func run() -> void:
 w=load("res://scenes/world/world224.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready220:await process_frame
 rig=w.rig220;w.auto114=false;w.pigs_enabled220=false
 check(rig.down224.resource_path.ends_with("sister224/collapsed_B.png"),"selected B loaded as independent runtime resource")
 check(not rig.fall224 and rig.seated.texture==rig.original222,"normal battle preserves original seated and repair system")
 await key(KEY_F9);await create_timer(1.5).timeout
 check(w.battle_phase220=="repair" and w.bats220.all(func(b):return b.enabled220),"normal low repair target window retained")
 var bat=w.bats220[0];bat.hp=1.
 w._teleport15(Vector2(bat.position.x-2.,bat.position.z));w.build170=8;w.apply_paper_build129();w.auto114=false
 w.fire_at(bat.hit_area.global_position)
 var limit=Time.get_ticks_msec()+2500
 while not rig.fall224 and Time.get_ticks_msec()<limit:await process_frame
 check(rig.fall224 and bat.hp==0. and not w.active114,"real final projectile starts soft landing and ends damage phase")
 check(w.shots.is_empty() and w.cotton220.active.is_empty() and not is_instance_valid(w.pig220),"landing clears battle projectiles and hazards")
 check(w.bats220.all(func(b):return not b.enabled220 and b.hit_area.collision_layer==0),"landing disables all bat targets")
 w.set_process(false);rig.set_process(false)
 for t in [0.,.25,.55,.85,1.4]:
  rig.fall_age224=t;rig._process(0.)
  check(rig.seated.texture==(rig.original222 if t<.65 else rig.down224),"pose selection at landing time "+str(t))
  await shot(str(t).replace(".","_"))
 check(rig.hammock.global_basis.get_scale().y<.20,"unsupported sling folds low instead of staying suspended")
 check(rig.bats[0].scale.is_equal_approx(Vector3.ONE),"dizzy bat keeps full body size while settling")
 check(rig.bats[0].global_position.y<rig.bats[1].global_position.y-.4,"dizzy bat rests low while surviving bat hovers")
 check(w.bats220[1].hp==32. and rig.stages223[1]==0,"surviving bat is not falsely knocked out")
 var foot: Vector3=rig.pixel_point(rig.seated,rig.seated.get_meta("anchor205"))
 check(absf(foot.y-w.floor_height(rig.ground_at224))<.025,"B registered ground contact lands on terrain")
 check(rig.body.collision_layer==0 and rig.cards.size()==5,"soft landing adds no blocking body or duplicate cards")
 check(rig.shadows[1].visual==rig.seated and rig.shadows[1].last_texture==rig.down224,"existing contour shadow switches to B artwork")
 rig._process(0.)
 var normal=(w.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))).normalized()
 check((rig.seated.material_override.get_shader_parameter("receiver_normal207") as Vector3).distance_to(normal)<.0001,"B retains existing native receiver normal")
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();await create_timer(.25).timeout;await shot("night")
 var energies: Array[float]=[]
 for lamp in w.lighting191.lamps:energies.append(lamp.light_energy);lamp.light_energy=0.
 await shot("lamps-off")
 for i in w.lighting191.lamps.size():w.lighting191.lamps[i].light_energy=energies[i]
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 w.set_process(true);rig.set_process(true);await key(KEY_F6)
 var clock: float=rig.fall_age224;var at: Vector3=rig.bats[0].position
 await create_timer(.25).timeout
 check(rig.fall_age224==clock and rig.bats[0].position==at,"F6 pauses ending even after active battle has ended")
 await key(KEY_F6);await create_timer(.25).timeout
 check(rig.fall_age224>clock,"ending resumes without re-entering battle")
 check(not w.context202 and w.navigation==w.original_navigation202 and w.player_hp==w.saved_hp220,"victory restores exploration navigation and original HP")
 check(w.memory_kit116.next_event119==w.progress_before220.next and w.memory_kit116.gel119==w.progress_before220.gel,"visual ending grants no formal progression or materials")
 await key(KEY_F7);await settle()
 check(not rig.fall224 and rig.seated.texture==rig.original222 and rig.lost220==-1,"restart restores original seated art and clears ending")
 check(w.bats220.all(func(b):return b.hp==32. and b.dead),"restart restores healthy high bats with targets disabled")
 # Other support side must produce the same B landing, with mirrored sling tilt.
 w.auto114=false;w.pigs_enabled220=false;await key(KEY_F9);await create_timer(1.5).timeout
 w.bats220[1].receive_hit(999.,Vector3.ZERO);await settle()
 check(rig.fall224 and rig.lost220==1,"right support loss also starts ending")
 w.set_process(false);rig.set_process(false);rig.fall_age224=1.4;rig._process(0.);await shot("right-loss")
 check(rig.seated.texture==rig.down224 and w.bats220[0].hp==32.,"right support loss uses B and preserves other bat health")
 w.set_process(true);rig.set_process(true);await key(KEY_F2);await settle()
 check(not rig.fall224 and rig.seated.texture==rig.original222,"manual exit clears collapsed override safely")
 metrics={"pose":"B","new_character_frames":1,"cut_to_B_seconds":.65,"settled_seconds":1.3,"bat_drops":"lost support only; surviving bat hovers","reward_free":true}
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/fall224-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics},"\t"))
 print("FALL224_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
