extends "res://scripts/world/validate_plush220.gd"
var rig: Node3D
func key(code: int) -> void:
 var event=InputEventKey.new();event.pressed=true;event.physical_keycode=code;w._input(event)
func shot(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/repair222-"+tag+".png")
func run() -> void:
 w=load("res://scenes/world/world222.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready220:await process_frame
 rig=w.rig220;w.auto114=false;w.pigs_enabled220=false
 check(rig.ready222 and rig.frames222.size()==6,"six repair frames loaded in actual battle rig")
 check(rig.seated.texture==rig.original222,"normal flying keeps approved original seated art")
 check(w.cat220.get_script().resource_path.ends_with("fat_cat_boss221.gd") and not w.cat220.show_lane221,"latest cat pressure and hidden cue retained")
 check(w.hero.get_script().resource_path.ends_with("hero192.gd"),"hero192 unchanged")
 await key(KEY_F9)
 check(w.battle_phase220=="lower" and w.cat220.dead,"F9 uses ordinary cat-down transition for animation preview")
 await create_timer(1.5).timeout
 check(w.battle_phase220=="repair" and w.bats220.all(func(b):return b.enabled220 and b.hit_area.collision_layer==8),"repair animation shares existing vulnerable bat window")
 check(w.rig_at220.y<w.cat220.position.z and w.rig_at220.x>w.cat220.position.x,"sister repairs behind cat with visible side offset")
 check(not is_instance_valid(w.pig220) and w.cotton220.active.is_empty(),"repair clears pig and cotton hazards")
 # Freeze phase progression only for image/anchor inspection.
 w.set_process(false);rig.set_process(false)
 var foot=Vector3.INF;var highest=0.;var lowest=INF
 for index in 6:
  w.battle_phase220="repair";w.phase_age220=[0.,.1,.5,.7,.9,5.8][index]
  if index==0:w.battle_phase220="lower";w.phase_age220=1.2
  rig._process(0.)
  check(rig.frame222==index,"battle phase selects repair frame "+str(index))
  check(rig.seated.texture==rig.frames222[index] and rig.seated.material_override.get_shader_parameter("paint")==rig.sheet222,"sprite and lit shader share atlas frame "+str(index))
  var anchor: Vector2=rig.seated.get_meta("anchor205");var at: Vector3=rig.pixel_point(rig.seated,anchor)
  if foot==Vector3.INF:foot=at
  check(at.distance_to(foot)<.001,"registered foot remains stable frame "+str(index))
  var height: float=rig.layout222.frames[index].bounds[3]*rig.seated.pixel_size
  highest=maxf(highest,height);lowest=minf(lowest,height)
  await shot("frame"+str(index))
 check(highest-lowest<.15 and highest<1.8,"repair art retains original seated scale with only head bow")
 check(rig.body.collision_layer==0 and rig.cards.size()==5,"animation reuses existing cards and adds no physical body")
 check(rig.shadows[1].visual==rig.seated and rig.shadows[1].last_texture==rig.seated.texture,"contour shadow follows current repair atlas")
 rig._process(0.)
 var normal=(w.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))).normalized()
 check((rig.seated.material_override.get_shader_parameter("receiver_normal207") as Vector3).distance_to(normal)<.0001,"repair frames retain hero192 lighting normal")
 w.phase_age220=.9;rig._process(0.)
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();await create_timer(.3).timeout;await shot("night")
 var energies: Array[float]=[]
 for lamp in w.lighting191.lamps:energies.append(lamp.light_energy);lamp.light_energy=0.
 await shot("lamps-off")
 for i in w.lighting191.lamps.size():w.lighting191.lamps[i].light_energy=energies[i]
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 w.battle_phase220="repair";w.phase_age220=2.;rig._process(0.)
 var prior=rig.frame222;w.combat_paused=true;w.set_process(true);rig.set_process(true)
 await create_timer(.3).timeout
 check(rig.frame222==prior and w.phase_age220==2.,"pause freezes repair progress and selected pose")
 w.combat_paused=false
 # Native weapon targeting must still refer to the bat visuals on the same rig.
 var bat=w.bats220[0];var hp: float=bat.hp
 w._teleport15(Vector2(bat.position.x-2.,bat.position.z));w.build170=8;w.apply_paper_build129();w.auto114=false
 for i in 3:w.fire_at(bat.hit_area.global_position);await create_timer(.12).timeout
 await create_timer(.4).timeout
 check(bat.hp<hp and bat.visual==rig.bats[0],"real player projectiles damage bat on animated repair rig")
 w._clear_combat_shots();var damaged: float=bat.hp;w.phase_age220=5.95
 await create_timer(.35).timeout
 check(w.battle_phase220=="rise" and w.bats220.all(func(b):return not b.enabled220),"six-second repair closes bat targeting")
 await create_timer(1.25).timeout
 check(w.battle_phase220=="fight" and w.cat220.hp==120. and rig.seated.texture==rig.original222,"repair restores cat and original seated flying pose")
 check(is_equal_approx(bat.hp,damaged),"bat damage persists across animated repair")
 await key(KEY_F9);await create_timer(1.5).timeout
 w.bats220[0].receive_hit(999.,Vector3.ZERO);await settle()
 check(not w.active114 and rig.seated.texture==rig.original222,"defeating a bat interrupts sewing immediately")
 check(not w.context202 and w.navigation==w.original_navigation202,"animated trial exit restores navigation context")
 metrics={"height_min":lowest,"height_max":highest,"frames":6,"window_seconds":6.,"bat_hp_after_weapon":damaged}
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/repair222-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics,"scope":"phase/atlas/anchors/native bat weapon lifecycle; appearance assessed in captured map frames"},"\t"))
 print("REPAIR222_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
