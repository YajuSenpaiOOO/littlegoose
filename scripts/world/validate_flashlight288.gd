extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world288.gd"
 var held288 := false
 func _init() -> void:
  super._init();memory_save116="user://flashlight288-validation-preview.cfg"
 func test_config_path226() -> String:return "user://flashlight288-validation.cfg"
 func reward_path273() -> String:return "user://flashlight288-validation-reward.cfg"
 func export_stats226() -> Error:return OK
 func fire_input_held() -> bool:return held288
 func floor_height(at: Vector2) -> float:return 0. if at.x>400. else super.floor_height(at)
 func safe_goal247(start: Vector2,wanted: Vector2) -> Vector2:return wanted if start.x>400. else super.safe_goal247(start,wanted)
func equip(levels: Dictionary) -> void:
 w.levels226=levels.duplicate();w.apply_levels226();w._clear_combat_shots()
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.transform288):await process_frame
 w.auto114=false;w.set_process(false);w.set_physics_process(false)
 w.transform288.audio.set_enabled(false)
 check(not w.transform288.playing,"combat opens without automatic transform")
 check(w.loadout_error257({"flashlight":1,"hero_moment":1},1)!="" and w.loadout_error257({"flashlight":1,"homework":1},1)!="","Q active slot rejects both other actives")
 check(w.loadout_error257({"flashlight":1,"bouncy_ball":1,"exercise":1},1)=="","initial four slot flashlight preset valid")
 check(w.memory_kit116.card("flashlight").fx.contains("最后3秒"),"console card describes new active/red duration")
 w.boss_unlocked264=true;w.boss264();w.auto114=false;w.set_physics_process(false)
 var boss=w.boss247;boss.set_physics_process(false);w.hero.set_physics_process(false);w.goose.set_physics_process(false)
 equip({"flashlight":1})
 check(w.buffs.level("flashlight")==0,"equipped active no longer converts normal weapon while idle")
 w.fire_at(boss.hit_area.global_position)
 check(not w.shots.is_empty() and w.shots.all(func(s):return not s.get("stream110",false)),"idle fire produces ordinary projectiles")
 w._clear_combat_shots();var fov=w.camera.fov;var material=w.hero.visual.material_override;var previous=material.next_pass
 check(w.start288(),"Q can activate in battle")
 check(not w.start288(),"reentry denied during intro")
 var fx=w.transform288
 fx.age=3.14;w._physics_process(.02);w.project288()
 check(w.beam_active288() and w.buffs.level("flashlight")==1 and w.hero.controls_enabled,"reveal enables active weapon and movement")
 w.held288=true;w._step_fire_input(.01)
 check(w.beam_left110>0.,"holding fire after transform feeds native continuous beam")
 w.skills110.step110(1./60.)
 check(w.skills110.stream_sound110>.9 and w.shots.any(func(s):return s.get("stream110",false)),"active beam emits through native scheduler with energy audio replacing candy repeats")
 w.hero.dash_left=.1;w._step_fire_input(.01)
 check(w.beam_left110==0.,"dash interrupts beam emission without ending the form")
 w.hero.dash_left=0.;w.held288=false
 check(absf(fx.remaining()-7.99)<.001,"eight seconds start at reveal")
 fx.sample(4.);w.project288()
 check(not fx.outline.visible and material.next_pass==fx.outline_ink,"outline renders on native material pass, no duplicate card")
 w.hero.position.x+=.1;w.hero.render_pose();w.project288()
 check(w.hero.visual.material_override.next_pass==fx.outline_ink,"frame/motion update keeps same-mesh outline")
 var normal=w.flashlight_damage_gain110();fx.sample(fx.red_at()+.01)
 check(fx.remaining()>2.98 and fx.remaining()<3. and w.flashlight_red229() and w.player_hp==w.max_player_health(),"red phase begins with three seconds remaining at full HP")
 check(is_equal_approx(w.flashlight_damage_gain110()/normal,1.9/1.2),"red ratio is fixed without low HP stacking")
 w.player_hp=1.;check(is_equal_approx(w.flashlight_damage_gain110(),1.9),"low HP adds no second red multiplier");w.player_hp=w.max_player_health()
 # Native emitted packets, ray movement and actual boss collider damage over 200 pulses.
 w.hero.position=Vector3(500,.03,500);w.goose.position=Vector3(500,.65,500);boss.position=Vector3(503,.03,500);boss.max_hp110=10000.;boss.hp=10000.
 boss.hit_area.collision_layer=8;boss.dead=false;boss.enter247("rest");w.rebuild_cells110();await settle(4)
 var display_at=w.hero.position;var display_boss=boss.position
 # Return capture positions to the real arena after the isolated trace bench.
 display_at=Vector3(w.meadow.landmarks.grove.x,w.floor_height(w.meadow.landmarks.grove)+.03,w.meadow.landmarks.grove.y+3.)
 display_boss=Vector3(w.meadow.landmarks.grove.x,w.floor_height(w.meadow.landmarks.grove)+.03,w.meadow.landmarks.grove.y-2.)
 var health=boss.hp;var hit_count=w.skills110.beam_hits110;w._clear_combat_shots();var per_normal=0.;var per_red=0.
 for i in 200:
  fx.sample(fx.INTRO+float(i)*.04);w.sync_weapon288();w.combat_clock33+=.04
  w.emit_stream110(boss.hit_area.global_position)
  if i==0:per_normal=w.damage_for_shot(w.shots[-1])
  if i==150:per_red=w.damage_for_shot(w.shots[-1])
  w._step_shots(.04)
 for i in 12:w._step_shots(.04)
 var damage=health-boss.hp
 metrics["stationary_single_beam"]={"damage":damage,"boss_baseline":90.,"fraction":damage/90.,"pulse_normal":per_normal,"pulse_red":per_red,"new_beam_hits":w.skills110.beam_hits110-hit_count,"method":"200 actual emitted beam samples plus native trace/flight; stationary boss; no input/AI performance claim"}
 check(damage>35. and damage<65.,"single beam full window deals meaningful damage without deleting baseline boss")
 check(is_equal_approx(per_red/per_normal,1.9/1.2),"real emitted packet stores launch-time red scaling")
 w.hero.position=display_at;boss.position=display_boss;w.goose.position=display_at+Vector3(.9,.7,.3)
 w.hero.reset_physics_interpolation();boss.reset_physics_interpolation();w.goose.reset_physics_interpolation();w._update_camera(0.,true)
 fx.sample(9.);w.project288();await shot("flashlight288-red")
 var key=InputEventKey.new();key.physical_keycode=KEY_D;key.pressed=true;Input.parse_input_event(key)
 w.hero.set_physics_process(true)
 for i in 10:await physics_frame;w.project288()
 key=InputEventKey.new();key.physical_keycode=KEY_D;key.pressed=false;Input.parse_input_event(key);w.hero.set_physics_process(false)
 check(not fx.outline.visible and w.hero.visual.material_override.next_pass==fx.outline_ink,"real locomotion uses native interpolated mesh for outline")
 await shot("flashlight288-walk")
 # A real elastic redirect retains the active stream packet identity.
 w._clear_combat_shots();w.levels226["bouncy_ball"]=1;w.buffs.levels["bouncy_ball"]=1
 w.emit_stream110(boss.hit_area.global_position);var shot=w.shots[-1];w.prepare275(shot);var node=shot.node
 w.redirect275(shot,{"collider":null,"position":shot.node.at,"normal":Vector3.UP},w.damage_for_shot(shot))
 check(shot.node==node and shot.get("stream110",false) and shot.get("stream_joint275",Vector3.INF).is_finite(),"active beam still redirects in place with elastic fragment")
 fx.age=fx.END_BEGIN-.01;w._physics_process(.02)
 check(not w.beam_active288() and w.buffs.level("flashlight")==0 and w.shots.all(func(s):return not s.get("stream110",false)),"timeout retires stream samples and restores normal weapon")
 check(is_equal_approx(w.cooldown288,30.) and w.hero.controls_enabled,"cooldown begins at weapon end while outro stays movable")
 check(not w.start288(),"Q denied during cooldown")
 var cd=w.cooldown288;var age=fx.age;w.combat_paused=true;w._physics_process(.5)
 check(w.cooldown288==cd and fx.age==age,"pause freezes cooldown and state clock")
 w.combat_paused=false;w._physics_process(.5)
 check(is_equal_approx(w.cooldown288,29.5) and not fx.playing and material.next_pass==previous,"outro restores prior material pass and cooldown progresses")
 w.cooldown288=0.;check(w.start288(),"ready skill may activate again");w.cancel288()
 check(w.cooldown288==30. and not w.combat_paused and w.hero.visual.visible,"manual cancel consumes cooldown and restores control")
 equip({"flashlight":1});w.cooldown288=17.;check(w.start288(true),"F2 remains a cosmetic preview")
 fx.age=fx.INTRO+.1;fx.sample(fx.age);w.release288();w.sync_weapon288()
 check(not w.beam_active288() and w.buffs.level("flashlight")==0,"cosmetic preview grants no combat beam")
 w.cancel288();check(w.cooldown288==17.,"cosmetic preview cannot reset combat cooldown")
 check(w.hero.visual.material_override.next_pass==previous and is_equal_approx(w.camera.fov,fov),"cancel removes outline pass and restores camera")
 equip({"flashlight":1,"paper_plane":1})
 var packet=w.snapshot_packet146(boss.hit_area.global_position,false,0.,true,true)
 check(not packet.is_empty() and packet.plane and not packet.stream,"plane normal attacks retain ordinary payload outside transform")
 equip({"flashlight":1,"slingshot":1});w.cooldown288=0.;w.start288();fx.age=fx.INTRO+.1;fx.sample(fx.age);w.release288();w.sync_weapon288();w.held288=true;w._step_fire_input(.01)
 check(w.beam_left110>0. and not w.charge_active,"slingshot setup uses direct hold beam during transform")
 w.held288=false;w.cancel288();w.cooldown288=25.;w.yard264()
 check(w.cooldown288==0. and not fx.playing and w.hero.controls_enabled,"fresh encounter restores readiness and cancels prior form")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/flashlight288-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics,"visual_motion_acceptance":"same mesh pass implemented, user walking review pending","limits":"stationary collision damage test, not player boss win-rate test"},"  "));f.close()
 print("FLASHLIGHT288_VALIDATION ",ok);quit(0 if ok else 1)
