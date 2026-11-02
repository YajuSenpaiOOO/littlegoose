extends "res://scripts/world/validate_plush220.gd"
var rig: Node3D
var ui: Control
func body_screen223(index: int) -> float:
 var bat: Sprite3D=rig.bats[index];var stage: int=rig.stages223[index]
 var center=Vector2(768,516);var width=500.
 if stage>0:
  var frame=rig.bat_frames223.find(bat.texture);var data: Dictionary=rig.bat_layout223.frames[frame]
  center=Vector2(data.body_center[0],data.body_center[1]);width=float(data.body_width)
 var left: Vector3=rig.pixel_point(bat,center-Vector2(width*.5,0.))
 var right: Vector3=rig.pixel_point(bat,center+Vector2(width*.5,0.))
 return w.camera.unproject_position(left).distance_to(w.camera.unproject_position(right))
func shot(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/bats223-"+tag+".png")
func run() -> void:
 w=load("res://scenes/world/world223.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready220:await process_frame
 rig=w.rig220;ui=w.candy117;w.auto114=false;w.pigs_enabled220=false
 var a=w.bats220[0];var b=w.bats220[1]
 check(rig.ready223 and rig.bat_frames223.size()==5,"five new expression frames loaded")
 check(rig.health_stage223(0)==0 and rig.health_stage223(1)==0,"full-HP high bats retain healthy faces despite disabled targets")
 check(a.dead and b.dead and a.hit_area.collision_layer==0 and b.hit_area.collision_layer==0,"high bats have no native targeting or shot areas")
 ui._process(0.)
 check(not ui.can_frame223(a) and not ui.can_frame223(b),"no high-altitude bat assistance frames")
 var hp: float=a.hp;a.receive_hit(5.,Vector3.RIGHT)
 check(a.hp==hp,"high-altitude bat rejects damage")
 w.auto114=true;w.aim_tick114=-1;w._refresh_aim114(Vector2.ZERO)
 check(w.target114==w.cat220,"normal battle native autoaim targets cat instead of high bats")
 w.auto114=false;await shot("high")
 await key(KEY_F9)
 check(not ui.can_frame223(a) and w.battle_phase220=="lower","descent alone does not expose target frame before repair")
 await create_timer(1.5).timeout
 check(w.battle_phase220=="repair" and a.enabled220 and b.enabled220,"both bats become targetable in repair window")
 w.auto114=true;w.aim_tick114=-1;w._refresh_aim114(Vector2.ZERO);ui._process(0.)
 check(w.target114 in w.bats220 and ui.can_frame223(w.target114),"native autoaim acquires low bat and enables assistance frame")
 w.auto114=false;w._clear_combat_shots();w.set_process(false);w.set_physics_process(false);rig.set_process(false);ui.set_physics_process(false)
 # Thresholds, independence and all wing/face combinations. No fake defeat path.
 var cases=[[32.,0],[22.,0],[21.,1],[11.,1],[10.,2],[1.,2]]
 for c in cases:
  a.hp=c[0];rig._process(0.)
  check(rig.stages223[0]==c[1] and rig.stages223[1]==0,"independent HP threshold "+str(c[0]))
 a.hp=32.
 var widths: Array[float]=[]
 for stage in 3:
  a.hp=[32.,20.,8.][stage]
  for wing in 2:
   rig.elapsed=float(wing)*.125+.01;rig._process(0.)
   var sprite: Sprite3D=rig.bats[0];var anchor: Vector2=sprite.get_meta("anchor205")
   widths.append(body_screen223(0))
   var ring: Vector3=rig.pixel_point(sprite,anchor)
   var hook: Vector3=rig.pixel_point(rig.hammock,rig.textures.hammock.get_size()*Vector2(.089,.091))
   check(ring.distance_to(hook)<.001,"ring remains on hammock hook stage/wing "+str(stage)+"/"+str(wing))
   if stage>0:check(sprite.texture==rig.bat_frames223[(stage-1)*2+wing],"correct damaged expression atlas frame")
   check(ui.frame_rect223(a).has_point(w.camera.unproject_position(ring)),"assistance frame covers actual rig ring instead of doubled target position")
 var min_width: float=widths.min();var max_width: float=widths.max()
 check(max_width/min_width<1.02,"projected round body diameter stays constant through all living stages and wing poses")
 a.hp=20.;b.hp=32.;rig._process(0.);await shot("size-healthy-medium")
 a.hp=8.;rig._process(0.);await shot("size-healthy-low")
 a.hp=20.;b.hp=8.;rig._process(0.)
 check(rig.stages223==[1,2],"two bats display different remaining-health expressions")
 w.auto114=true;w.aim_tick114=-1;w._refresh_aim114(Vector2.ZERO);w.auto114=false
 ui._process(0.);await shot("repair-medium-low")
 check(ui.drawn_bat223!=0 and ui.drawn_rect223.size.x>10.,"actual repair render draws acquired bat bracket")
 var image=root.get_texture().get_image()
 # canvas_items uses logical 1600x1000 coordinates in a 1440x900 framebuffer.
 var corner=root.get_final_transform()*(ui.get_global_transform_with_canvas()*(ui.drawn_rect223.position.round()+Vector2(5.,0.)))
 var gold=0
 # Acquired padding eases each render frame; sample the small line neighborhood
 # rather than requiring one exact antialiased raster pixel to match.
 for y in range(-5,6):
  for x in range(-4,5):
   var point=Vector2i(corner)+Vector2i(x,y)
   if Rect2i(Vector2i.ZERO,image.get_size()).has_point(point):
    var pixel=image.get_pixelv(point)
    if pixel.r>.65 and pixel.g>.55 and pixel.b>.3:gold+=1
 check(gold>=3,"GPU screenshot contains gold bracket pixels at actual bat")
 print("BRACKET223_DIAG image=",image.get_size()," rect=",ui.drawn_rect223," canvas=",ui.get_global_transform_with_canvas()," gold=",gold)
 check(ui.can_frame223(a) and ui.can_frame223(b),"both living low bats eligible for assistance")
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();await create_timer(.3).timeout;await shot("night")
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 w.combat_paused=true;var before=rig.elapsed;w.set_process(true);rig.set_process(true);await create_timer(.2).timeout
 check(rig.elapsed==before and rig.stages223==[1,2],"pause retains face and wing clock")
 w.combat_paused=false;w.set_physics_process(true);w.phase_age220=5.95;await create_timer(.35).timeout
 ui._process(0.)
 check(w.battle_phase220=="rise" and not ui.can_frame223(a) and not ui.can_frame223(b),"rising removes assistance immediately")
 await create_timer(1.25).timeout;rig._process(0.)
 check(rig.stages223==[1,2] and a.hp==20. and b.hp==8.,"damaged faces persist after repair and high flight")
 w.auto114=true;w.aim_tick114=-1;w._refresh_aim114(Vector2.ZERO)
 check(w.target114==w.cat220,"autoaim returns to cat after bat window closes")
 w.auto114=false;await shot("high-damaged")
 await key(KEY_F9);await create_timer(1.5).timeout
 w.set_process(false);rig.set_process(false)
 a.hp=11.;b.hp=8.;w._teleport15(Vector2(a.position.x-2.,a.position.z));w.build170=8;w.apply_paper_build129();w.auto114=false
 for i in 3:w.fire_at(a.hit_area.global_position);await create_timer(.12).timeout
 await create_timer(.35).timeout;rig._process(0.)
 check(a.hp<11. and rig.stages223[0]==2,"real projectiles cross low-health expression threshold")
 w._clear_combat_shots();a.hp=1.;w.fire_at(a.hit_area.global_position)
 await create_timer(.55).timeout;rig._process(0.);ui._process(0.)
 check(a.hp==0. and rig.stages223[0]==3 and rig.lost220==0,"real last hit selects dizzy face and folded wings")
 check(rig.bats[0].scale.is_equal_approx(Vector3.ONE),"knocked-out bat no longer has legacy .75 shrink")
 var other_frame=rig.bat_frames223.find(rig.bats[1].texture)
 check(absf(rig.bats[0].pixel_size*float(rig.bat_layout223.frames[4].body_width)-rig.bats[1].pixel_size*float(rig.bat_layout223.frames[other_frame].body_width))<.002,"knocked-out and living round bodies retain equal world diameter")
 check(not w.active114 and not ui.can_frame223(a) and not ui.can_frame223(b),"knocked-out bat ends fight and clears assistance eligibility")
 await shot("down")
 check(not w.context202 and w.navigation==w.original_navigation202,"exit restores forest context")
 w.set_process(true);rig.set_process(true);ui.set_physics_process(true);await key(KEY_F7);await settle()
 rig._process(0.)
 check(rig.stages223==[0,0] and w.bats220.all(func(bat):return bat.hp==32. and bat.dead),"restart restores healthy faces with high targeting disabled")
 metrics={"new_frames":5,"stages":4,"repair_window":6.,"thresholds":[2./3.,1./3.,0.],"high_frames":false,"only_selected_eligible_bat_gets_native_frame":true}
 w.end220(false);finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/bats223-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics},"\t"))
 print("BATS223_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
