extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world291.gd"
 func export_stats226() -> Error:return OK
func input_key291(code: int,pressed: bool) -> void:
 var e=InputEventKey.new();e.physical_keycode=code;e.keycode=code;e.pressed=pressed;Input.parse_input_event(e)
 await process_frame
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.transform288):await process_frame
 w.auto114=false;w.set_process(false);w.set_physics_process(false);w.hero.set_physics_process(false);w.transform288.audio.set_enabled(false)
 var baseline=OS.get_cmdline_user_args().has("--baseline")
 var h=w.hero;var f=w.transform288;var front=h.directions.down;var expected=1.6/float(front.idle_height)
 var cases=[];var small=0
 for item in [[KEY_W,"up"],[KEY_A,"left"],[KEY_S,"down"],[KEY_D,"right"]]:
  await input_key291(item[0],true)
  for index in 4:
   h.controls_enabled=true;h.moving=true;h.phase=float(index)/4.;h.facing=item[1];h.render_pose()
   check(w.start288(true),"preview accepted: %s frame %d"%[item[1],index])
   var ratio=f.pixel/expected
   cases.append({"direction":item[1],"frame":index,"pixel":f.pixel,"ratio":ratio,"render_facing":h.facing})
   if ratio<.99:small+=1
   if not baseline:
    check(is_equal_approx(f.pixel,expected) and h.facing=="down" and not h.moving,"fixed front scale from held %s frame %d"%[item[1],index])
    for age in [.2,.7,2.2]:
     f.sample(age)
     check(is_equal_approx(f.actor.pixel_size,expected*(.595 if age<1.98 else 1.)),"fixed pose pixel at %.1f from %s frame %d"%[age,item[1],index])
    check(h.visual.texture==front.idle and not h.controls_enabled,"neutral native front is frozen during intro")
   w.cancel288();check(h.controls_enabled,"cancel restores player control")
  await input_key291(item[0],false)
 if baseline:check(small>0,"original intermittent shrink reproduced with held movement")
 else:
  w.boss_unlocked264=true;w.boss264();w.set_physics_process(false);w.boss247.set_physics_process(false);w.boss247.set_process(false)
  w.levels226={"flashlight":1};w.apply_levels226();w.cooldown288=0.
  await input_key291(KEY_D,true);h.moving=true;h.phase=.25;h.facing="right";h.render_pose()
  check(w.start288(),"real Q starts while walking")
  check(is_equal_approx(f.pixel,expected),"real Q uses same fixed front calibration")
  f.sample(3.16);w.release288();await input_key291(KEY_D,false)
  check(h.controls_enabled and h.visual.visible and w.beam_active288(),"reveal restores native hero and activates beam")
  h.moving=false;h.facing="down";h.render_pose();check(is_equal_approx(h.visual.pixel_size,expected),"post intro native front matches preview scale")
  w.cancel288();check(is_equal_approx(w.cooldown288,30.),"cancel still consumes active cooldown")
 var data={"checks":checks,"cases":cases,"shrunken_cases":small,"expected_pixel":expected}
 var file="res://docs/transform-scale291-"+("baseline" if baseline else "validation")+".json"
 FileAccess.open(file,FileAccess.WRITE).store_string(JSON.stringify(data,"  "))
 quit(0 if checks.all(func(c):return c.pass) else 1)
