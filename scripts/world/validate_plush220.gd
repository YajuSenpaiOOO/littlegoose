extends SceneTree
var w: Node3D
var checks: Array[Dictionary]=[]
var metrics := {}
func _initialize() -> void:call_deferred("run")
func check(ok: bool,label: String) -> void:
 checks.append({"name":label,"pass":ok});print("220 ",ok," ",label)
func settle(n: int=4) -> void:
 for i in n:await physics_frame
func shot(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/plush220-"+tag+".png")
func key(code: int) -> void:
 var event=InputEventKey.new();event.pressed=true;event.physical_keycode=code;w._input(event)
func run() -> void:
 w=load("res://scenes/world/world220.tscn").instantiate();root.add_child(w);current_scene=w
 var deadline=Time.get_ticks_msec()+180000
 while not w.ready220 and Time.get_ticks_msec()<deadline:await process_frame
 if not w.ready220:check(false,"initialization");finish();return
 var cat=w.cat220
 w.auto114=false
 check(w.active114 and w.trial152 and w.context202,"native reward-free forest battle active")
 check(w.enemies.size()==3 and w.enemies[0]==cat,"cat and two bat targets use native weapon actor list")
 check(w.hero.get_script().resource_path.ends_with("hero192.gd"),"hero192 geometry retained")
 check(w.bats220.all(func(b):return b.dead and b.hit_area.collision_layer==0),"high bats excluded from autoaim and hits")
 check(w.memory_kit116.next_event119==w.progress_before220.next,"trial start preserves formal event index")
 # Pause verifies all encounter-controlled actors stop rather than only the HUD.
 await key(KEY_F6);var at: Vector3=cat.position;var clock: float=cat.clock220
 await create_timer(.2).timeout
 check(cat.position==at and cat.clock220==clock,"pause freezes cat state and locomotion")
 await key(KEY_F6)
 # Fixed source direction after windup; actual movement stops on map collision.
 cat.set_physics_process(false);cat.enter220("windup");var target: Vector2=cat.locked220
 w._teleport15(w.arena220+Vector2(-2.,1.))
 cat._physics_process(.2)
 check(cat.locked220==target,"roll target locks at telegraph instead of tracking")
 await shot("windup")
 cat.enter220("roll");var before: Vector3=cat.position
 cat._physics_process(.12)
 check(cat.position.distance_to(before)>.05 or cat.phase220=="recover","active roll translates or stops against scenery")
 await shot("roll")
 # Real existing firing path, not directly subtracting HP or calling receive_hit.
 cat.position=Vector3(w.arena220.x,w.floor_height(w.arena220),w.arena220.y);cat.enter220("chase")
 w._teleport15(w.arena220+Vector2(-2.5,0.));w.hero.set_physics_process(false)
 w.build170=8;w.apply_paper_build129()
 await settle()
 var hp: float=cat.hp
 for i in 12:
  w.fire_at(cat.hit_area.global_position)
  await create_timer(.09).timeout
 await create_timer(.7).timeout
 check(cat.hp<hp,"actual native player projectiles damage fat cat")
 metrics.cat_damage=hp-cat.hp
 # Native contact hurt / dodge / guard and roll parry.
 w._clear_combat_shots();w.hero.position=cat.position+Vector3(-1.1,0,0);w.invulnerability=0.;w.hero.dodge_invulnerability=0.;w.hero.guarding109=false;w.hero.parry_t=0.
 hp=w.player_hp;cat.enter220("recover");cat._physics_process(.01)
 check(w.player_hp<hp,"cat body contact causes battle damage")
 w.invulnerability=0.;w.hero.dodge_invulnerability=.3;hp=w.player_hp;cat._physics_process(.01)
 check(w.player_hp==hp,"contact respects dodge invulnerability")
 w.hero.dodge_invulnerability=0.;w.invulnerability=0.;w.hero.guarding109=true;hp=w.player_hp;cat._physics_process(.01)
 check(hp-w.player_hp<12.,"contact respects existing guard reduction")
 w.hero.guarding109=false;w.invulnerability=0.;w.hero.parried=false;w.hero.parry_t=.15;w.hero.dash_left=0.;cat.enter220("roll");var parry_before: int=cat.parried_count;cat._physics_process(.01)
 check(cat.phase220=="recover" and cat.parried_count>parry_before,"rolling attack can be parried into recovery")
 w.hero.cancel_guard109();w.hero.parry_t=0.;Engine.time_scale=1.;w.stop_until=0.
 # Arrange an actual delivery, then inspect its fall and untargetability.
 w._teleport15(w.arena220+Vector2(-2.5,0.));w.drop_wait220=0.
 await create_timer(1.15).timeout
 check(is_instance_valid(w.pig220) and w.dropped220>0,"sister flight releases a pig")
 if is_instance_valid(w.pig220):
  check(w.pig220.falling220 and w.pig220.visual.global_position.y>w.pig220.position.y+.1,"pig visibly descends from hammock")
  check(not w.enemies.any(func(actor):return actor.get_instance_id()==w.pig220.get_instance_id()) and w.pig220.body.collision_layer==0,"pig is untargetable and does not block shots/player")
  await shot("delivery")
  await create_timer(1.7).timeout
  check(w.cotton220.emitted[0]>0,"landed pig sprays real independent cotton")
  await shot("spray")
  var phase: String=w.pig220.phase219;await key(KEY_E)
  check(w.pig220.phase219==phase,"E no longer attacks or flattens pig")
 # Force only the phase transition; weapons have already been validated above.
 cat.receive_hit(9999.,Vector3.RIGHT)
 check(cat.dead and w.battle_phase220=="lower","cat defeat begins sister repair descent")
 check(w.cotton220.active.is_empty() and not is_instance_valid(w.pig220),"repair clears pig and cotton hazards")
 await create_timer(1.5).timeout
 check(w.battle_phase220=="repair" and w.bats220.all(func(b):return not b.dead and b.hit_area.collision_layer==8),"low bats enter native targeting during repair")
 await shot("repair")
 w.auto114=true;w.target114=null;w.aim_tick114=-1;w._refresh_aim114(Vector2.ZERO)
 check(w.target114 in w.bats220,"autoaim selects a low bat rather than disabled cat/pig")
 w.auto114=false
 var bat=w.bats220[0];var before_bat: float=bat.hp
 for i in 15:
  w.fire_at(bat.hit_area.global_position)
  await create_timer(.07).timeout
 check(bat.hp<before_bat,"real projectiles damage low bat")
 # Preserve HP across the next repair window.
 w._clear_combat_shots();await settle()
 var saved_bat: float=bat.hp
 w.phase_age220=6.1;await process_frame
 await create_timer(1.3).timeout
 check(w.battle_phase220=="fight" and not cat.dead and cat.hp==cat.max_hp110,"repair completes and cat rejoins battle")
 metrics.risen_bat={"hp":bat.hp,"saved":saved_bat,"dead":bat.dead,"layer":bat.hit_area.collision_layer}
 check(bat.hp<=saved_bat and bat.dead and bat.hit_area.collision_layer==0,"bat damage persists while high bats become untargetable")
 cat.receive_hit(9999.,Vector3.RIGHT);await create_timer(1.5).timeout
 bat.receive_hit(9999.,Vector3.RIGHT);await settle()
 check(not w.active114 and w.battle_phase220 in ["landing","ended"],"defeating one bat ends battle")
 await create_timer(1.6).timeout;await shot("ended")
 check(w.meadow.landmarks.grove==w.original_grove202 and w.navigation==w.original_navigation202 and not w.context202,"battle exit restores original forest context")
 check(w.memory_kit116.next_event119==w.progress_before220.next and w.memory_kit116.gel119==w.progress_before220.gel and w.memory_kit116.last_reward119==w.progress_before220.reward,"no formal event/material/reward progression")
 check(w.player_hp==w.saved_hp220,"trial restores pre-battle roaming HP")
 await key(KEY_F7);await settle()
 check(w.active114 and w.cat220.hp==120. and w.bats220.all(func(b):return b.hp==32.),"F7 restarts complete battle")
 w.auto114=true;w.target114=null;w.aim_tick114=-1;w.hero.set_physics_process(true);w.cat220.set_physics_process(false)
 await create_timer(2.).timeout
 check(w.cat220.hp<120.,"default automatic firing loop damages cat without simulated attack input")
 await key(KEY_F2);await settle()
 check(not w.active114 and not w.context202,"F2 exits cleanly")
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/plush220-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics},"\t"))
 print("220_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
