extends SceneTree
var checks: Array[Dictionary]=[]
var world: Node3D
var rig: Node3D
var drops: Node3D
var metrics := {}
func _initialize() -> void: call_deferred("run")
func check(value: bool,label: String) -> void:
 checks.append({"name":label,"pass":value});print("211 ","PASS " if value else "FAIL ",label)
func snapshot(tag: String) -> void:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/sister211-"+tag+".png")
func screen_height(card: Sprite3D,bounds: Rect2i) -> float:
 var x=float(bounds.position.x)+bounds.size.x*.5
 var a=Vector3((x-card.texture.get_width()*.5+card.offset.x)*card.pixel_size,(card.texture.get_height()*.5-bounds.position.y+card.offset.y)*card.pixel_size,0.)
 var b=a-Vector3.UP*bounds.size.y*card.pixel_size
 return world.camera.unproject_position(card.to_global(a)).distance_to(world.camera.unproject_position(card.to_global(b)))
func run() -> void:
 world=load("res://scenes/world/world211.tscn").instantiate();root.add_child(world);current_scene=world
 var deadline=Time.get_ticks_msec()+180000
 while not world.ready206 and Time.get_ticks_msec()<deadline: await process_frame
 if not world.ready206:
  check(false,"world206 initialization");finish();return
 rig=world.transport206;drops=world.drops206;rig.manual=true;drops.manual206=true;rig.drop_enabled206=false
 var assets207={}
 for file in ["idle","seated"]:
  var sprite: Sprite3D=rig.standing if file=="idle" else rig.seated
  var bounds: Rect2i=rig.manifests[file]
  assets207[file]={"image_size":sprite.texture.get_size(),"alpha_bounds":bounds,"alpha_threshold":.6,"anchor":sprite.get_meta("anchor205"),"world_alpha_height":bounds.size.y*sprite.pixel_size,"display_plane":"fixed camera plane; upright foot-depth and light-sampling proxy","collision":"stable inherited ground footprint radius .29m, height .65m; no contact damage","shadow":"105 terrain contour + soft contact; no native cylinder caster","light":"native .82 albedo; world normal matches hero192; no emission or added lights"}
  check(sprite.texture.resource_path==("res://assets/sister211/idle.png" if file=="idle" else "res://assets/sister211/seated_character_v2.png"),file+" uses expected preview art")
  check(sprite.texture.get_image().get_pixel(0,0).a<.01,file+" transparent margin preserved")
 FileAccess.open("res://assets/sister211/manifest.json",FileAccess.WRITE).store_string(JSON.stringify(assets207,"\t"))
 rig._process(0.)
 var expected_normal=(world.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))).normalized()
 check((rig.standing.material_override.get_shader_parameter("receiver_normal207") as Vector3).is_equal_approx(expected_normal),"lighting normal matches upright hero192")
 check(not world.context202 and not world.active114,"no combat/context mutation")
 check(world.hero.get_script().resource_path.ends_with("hero192.gd"),"upright hero192 unchanged")
 check(world.clear_route206,"route avoids existing props and cliffs")
 rig.restart();rig._process(0.)
 var hero_bounds=rig.opaque_bounds(world.hero.visual.texture.get_image())
 var old_card_at: Vector3=rig.standing.global_position
 rig.set_process(false)
 var same_foot: Vector3=rig.hero_extent206()[1]
 rig.standing.global_position=same_foot+world.camera.global_basis.x*1.4
 rig.standing.material_override.set_shader_parameter("foot199",rig.standing.global_position)
 var ratio=screen_height(rig.standing,rig.manifests.idle)/screen_height(world.hero.visual,hero_bounds)
 metrics.screen_height_ratio=ratio;metrics.display_scale=rig.display_scale206
 check(ratio>1.02 and ratio<1.14,"sister only slightly taller in actual screen projection")
 await snapshot("proportion")
 rig.standing.global_position=old_card_at;rig.set_process(true)
 var viewport=world.get_viewport().get_visible_rect()
 rig.enter("approach");rig.age=0.;rig.evaluate();rig._process(0.)
 check(not viewport.intersects(rig.transport_rect206()),"whole empty rig starts beyond left screen edge")
 rig.enter("depart");rig.age=float(rig.durations206.depart)*.9999;rig.evaluate();rig._process(0.)
 check(not viewport.intersects(rig.transport_rect206()),"whole empty rig exits right screen edge before hiding")
 # Moving the camera should still produce a fully offscreen endpoint.
 var camera_at: Vector3=world.camera.global_position
 world.camera.global_position.x+=3.
 rig.evaluate();rig._process(0.)
 check(not viewport.intersects(rig.transport_rect206()),"exit adapts to a moved camera")
 world.camera.global_position=camera_at
 rig.restart();rig.enter("travel");rig.age=.9;rig.evaluate();rig.advance(.35);rig._process(0.)
 check(absf(rig.swing206)>.0001 and absf(rig.swing206)<.111,"bounded momentum-driven swing")
 for i in 2:
  var uv=Vector2(.089,.091) if i==0 else Vector2(.922,.091)
  var mount=rig.pixel_point(rig.hammock,rig.textures.hammock.get_size()*uv)
  check(rig.bats[i].global_position.distance_to(mount)<.001,"swing preserves bat "+str(i)+" attachment")
 rig.running=false;var angle=rig.swing206;var clock=rig.elapsed;rig.advance(2.)
 check(rig.swing206==angle and rig.elapsed==clock,"pause freezes swing and animation")
 rig.running=true
 await snapshot("swing")
 # After motion ceases the spring decays instead of perpetually wobbling.
 rig.enter("board");rig.age=.2;rig.evaluate();rig.previous_rig206=rig.rig_at
 rig.swing206=.08;rig.swing_speed206=0.
 for i in 60: rig.advance(1./120.)
 check(absf(rig.swing206)<.08,"damped swing decays while stationary")
 drops.clear206();rig.restart();rig.drop_enabled206=true;rig.enter("travel")
 rig.advance(1.8)
 check(drops.spawned206==2 and drops.records.size()==2,"attack mode drops at most two toys per trip")
 drops.clear206();rig.drop_enabled206=false;rig.restart();rig.enter("travel");rig.advance(2.)
 check(drops.records.is_empty(),"ordinary transport never spawns attacks")
 var at: Vector2=(rig.start_at+rig.end_at)*.5
 drops.spawn206(at,rig.ground(at)+Vector3.UP*1.6)
 drops.advance206(.7);drops._process(0.)
 check(drops.records[0].age<1. and not drops.records[0].resolved,"falling toy gives a full warning before threat")
 await snapshot("warning")
 drops.advance206(1.0)
 var locked: Vector2=drops.records[0].target
 drops.advance206(.3)
 check(drops.records[0].target.is_equal_approx(locked),"pounce target locks before attack")
 var hp: float=world.player_hp
 drops.invulnerability206=0.;world.hero.dodge_invulnerability=0.;world.hero.parry_t=0.;world.hero.guarding109=false
 var toy=drops.records[0];drops.resolve206(toy)
 check(world.preview_hearts206==4 and world.player_hp==hp,"hit only reduces preview hearts, never saved HP")
 toy.resolved=false;world.hero.dodge_invulnerability=.2;drops.resolve206(toy)
 check(drops.dodges206==1,"existing dodge invulnerability avoids toy")
 toy.resolved=false;world.hero.dodge_invulnerability=0.;world.hero.parry_t=.15;world.hero.dash_left=0.;world.invulnerability=0.
 drops.resolve206(toy)
 check(drops.parries206==1,"existing parry window counters toy")
 world.hero.cancel_guard109();world.hero.parry_t=0.
 drops.advance206(3.)
 check(drops.records.is_empty(),"spent toys leave no permanent clutter/collision")
 rig.restart();rig.drop_enabled206=false;rig.enter("travel");rig.advance(1.2);rig._process(0.)
 await snapshot("travel")
 world.time55.preview_at(20.);world.time55.visual_hour=20.;world.time55.apply_look();await create_timer(.4).timeout
 await snapshot("night")
 # Same scene, stationary sister, native map lights toggled for visual review.
 rig.enter("idle");rig.evaluate();rig._process(0.)
 world._teleport15(rig.start_at+Vector2(.85,.6))
 await create_timer(.4).timeout
 await snapshot("standing-night")
 var saved_energy207=[]
 for lamp in world.lighting191.lamps:
  saved_energy207.append(lamp.light_energy);lamp.light_energy=0.
 world.lighting191.set_process(false)
 await snapshot("standing-lamps-off")
 for i in world.lighting191.lamps.size(): world.lighting191.lamps[i].light_energy=saved_energy207[i]
 world.lighting191.set_process(true)
 var repeat_key=InputEventKey.new();repeat_key.pressed=true;repeat_key.physical_keycode=KEY_F7
 world._input(repeat_key)
 check(world.preview_hearts206==5 and drops.records.is_empty() and rig.state=="idle","F7 resets preview and clears all toys")
 finish()
func finish() -> void:
 var failures=checks.filter(func(item): return not item["pass"])
 FileAccess.open("res://docs/sister211-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"metrics":metrics,"failed":failures.size(),"scope":"206 world behavior/physics and GPU captures; animation art still subject to user review"},"\t"))
 print("211_RESULT ",checks.size()," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
