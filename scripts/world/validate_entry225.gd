extends "res://scripts/world/validate_plush220.gd"
func shot(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/entry225-"+tag+".png")
func run() -> void:
 w=load("res://scenes/world/world225.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready225:await process_frame
 check(w.stage225=="waiting" and not w.active114 and not w.context202,"preview starts waiting at cottage without automatic battle")
 check(not w.rig220.visible and not w.delivery225.visible,"sister and delivered cat stay hidden before knock")
 check(w.door225.distance_to(w.arena220)<9. and absf(w.floor_height(w.arena220)+2.2)<.15,"combat clearing is near this cottage on actual forest ground")
 metrics.coordinates={"door":w.door225,"arena":w.arena220}
 await shot("door")
 w._teleport15(w.door225+Vector2(0.,4.));check(not w.knock225(),"knock requires actual proximity to door")
 w._teleport15(w.wait_at225);var player_start=Vector2(w.hero.position.x,w.hero.position.z)
 await key(KEY_E)
 check(w.stage225=="knock" and not w.hero.controls_enabled,"E near cottage begins guarded intro")
 check(w.camera.unproject_position(w.air_start225).x< -200.,"cat delivery begins fully outside left screen margin")
 check(not w.knock225(),"repeated knock cannot restart running intro")
 var hp: float=w.player_hp;w.hurt_player(20.,w.door225);w.fire_at(Vector3(w.arena220.x,0,w.arena220.y))
 check(w.player_hp==hp and w.shots.is_empty(),"intro blocks damage and premature player fire")
 await key(KEY_F6);var clock: float=w.age225;await create_timer(.2).timeout
 check(w.age225==clock,"intro pause freezes stage clock")
 await key(KEY_F6)
 var captured={};var limit=Time.get_ticks_msec()+30000
 while w.stage225!="battle" and Time.get_ticks_msec()<limit:
  await process_frame
  var capture_after=1.15 if w.stage225=="cat_in" else (1.25 if w.stage225=="walk" else .25)
  if w.stage225 in ["walk","board","lift","cat_in","cat_lower","depart"] and w.age225>capture_after and not captured.has(w.stage225):
   captured[w.stage225]=true
   if w.stage225=="walk":check(w.rig220.standing.visible and not w.rig220.seated.visible,"sister emerges using standing art")
   if w.stage225=="lift":check(w.rig220.seated.visible and w.rig220.hammock.visible,"seated sister rises on original two-bat hammock")
   if w.stage225=="cat_in":
    check(w.delivery225.bats225.size()==4 and w.delivery225.straps225.all(func(s):return s.visible),"four bats carry cat on four visible anchored straps")
    check(w.delivery225.cat.collision_layer==0 and w.delivery225.cat.collision_mask==0,"airlift cat has no contact collision or target body")
   await shot(w.stage225)
   if w.stage225=="cat_lower":
    await key(KEY_F6)
    w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();await create_timer(.25).timeout;await shot("airlift-night")
    var energies: Array[float]=[]
    for lamp in w.lighting191.lamps:energies.append(lamp.light_energy);lamp.light_energy=0.
    await shot("airlift-lamps-off")
    for i in w.lighting191.lamps.size():w.lighting191.lamps[i].light_energy=energies[i]
    w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
    await key(KEY_F6)
 check(w.stage225=="battle" and w.active114,"intro reaches actual battle after carrier departure")
 check(w.intro_history225==["knock","walk","board","lift","fly","cat_in","cat_lower","unload","depart","battle"],"all intro stages run once in order")
 check(Vector2(w.hero.position.x,w.hero.position.z).distance_to(player_start)<.15,"normal intro does not teleport player at battle handoff")
 check(not w.delivery225.visible and w.cat220.visible and w.cat220.hp==120.,"presentation cat hands off to native boss actor without duplicate visible cats")
 check(w.delivery225.bats225.all(func(bat):return w.camera.unproject_position(bat.global_position).x>w.get_viewport().get_visible_rect().size.x+80.),"all four carrier bats leave right screen before battle starts")
 check(w.enemies.size()==3 and w.bats220.all(func(b):return b.dead),"only boss cat and two gated hammock bats enter enemy list")
 check(w.drop_wait220>3.5,"first pig leaves initial cat-only learning interval")
 w.auto114=false;w.pigs_enabled220=false;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 await shot("battle")
 # Actual map placement search, checking ray/terrain/body clearance and retry behavior.
 var points: Array[Vector2]=[w.arena220+Vector2(-3.,2.),w.arena220+Vector2(3.,2.),w.arena220+Vector2(0.,4.)]
 var chosen=Vector2.INF
 for at in points:
  w._teleport15(at);chosen=w.choose_drop220()
  if chosen.is_finite():break
 check(chosen.is_finite(),"placement search finds a valid real-map pig firing position")
 if chosen.is_finite():
  var dir=Vector2(1.,.4).normalized() if w.selected_mirror225 else Vector2(-1.,.4).normalized()
  check(w.safe_drop225(chosen,dir,2.4) and w.open_drop225(chosen),"chosen pig position has physical space, line and lateral escape")
  w.drop_goal220=chosen;w.release_pig220()
  check(is_instance_valid(w.pig220) and w.pig220.body.collision_layer==0,"actual release creates untargetable nonblocking pig")
  await create_timer(2.4).timeout
  check(w.cotton220.emitted[0]>0 and w.cotton220.emitted[1]>0,"valid drop lands and emits from both independent nostrils")
  await shot("pig")
  w.cotton220.clear219();w.pig220.phase219="gone";w.drop_wait220=0.;w.clear_pig220()
  check(w.drop_wait220>=2.,"cleared pig/cotton leaves an actual quiet interval")
 w._teleport15(w.door225+Vector2(0.,-2.));var invalid=w.choose_drop220()
 check(not invalid.is_finite(),"blocked cottage area defers pig instead of forcing unsafe placement")
 # Explicit mirrored variant verifies art and nose origin together, not only a direction variable.
 w._teleport15(w.arena220+Vector2(0.,4.));w.selected_mirror225=true
 var mirrored=Vector2.INF;var direction=Vector2(1.,.4).normalized()
 for at in points:
  if w.safe_drop225(at,direction,2.4):mirrored=at;break
 if mirrored.is_finite():
  w.drop_goal220=mirrored;w.release_pig220()
  check(w.pig220.mirrored225 and w.pig220.visual.flip_h and w.pig220.direction219.x>0.,"right-facing pig mirrors art and real spray direction together")
  var pig=w.pig220;var nose=pig.nose219(0);var center=pig.visual.global_position
  check((nose-center).dot(w.camera.global_basis.x)>0.,"mirrored nostril anchor moves to visible right side")
 else:check(false,"mirrored fixture placement found")
 w.clear_pig220();w.hero.set_physics_process(true)
 await key(KEY_F7)
 check(w.stage225=="waiting" and not w.active114 and not w.context202 and w.navigation==w.original_navigation202,"F7 returns to doorway and restores exploration context")
 await key(KEY_E);await create_timer(.9).timeout;await key(KEY_F2)
 check(w.stage225=="waiting" and not w.rig220.visible and not w.delivery225.visible,"F2 cancels midway through entry without leftover carriers")
 await key(KEY_F8)
 check(w.active114 and w.stage225=="battle" and w.hero.controls_enabled,"F8 skips entry directly into playable boss battle")
 await key(KEY_F8)
 check(w.active114 and w.stage225=="battle","repeated skip restart does not leave stage stuck waiting")
 w.auto114=false;w.pigs_enabled220=false;await key(KEY_F9);await create_timer(1.5).timeout;await key(KEY_F10);await create_timer(.9).timeout
 check(not w.active114 and w.stage225=="battle" and w.rig220.fall224,"new entry controller still permits inherited B landing after victory")
 await key(KEY_F7)
 check(w.stage225=="waiting" and not w.rig220.fall224 and not w.context202 and w.rig220.lost220==-1 and w.bats220.all(func(b):return b.hp==32. and b.dead),"doorway reset clears victory aftermath and restores healthy support bats")
 w.end220(false);finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/entry225-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics,"scope":"native entry/physics/pig emission lifecycle; staged pig placement checks are not difficulty or long-run balance verdict"},"\t"))
 print("ENTRY225_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
