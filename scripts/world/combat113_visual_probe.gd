extends "res://scripts/world/combat113_compare.gd"
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var s := Battle113.new();root.add_child(s)
 while not s.woodland_ready113: await physics_frame
 s.permit=true;s.start_combat();await settle72(15);disable_enemies(s);s.set_physics_process(false);s.hero.set_physics_process(false)
 var rng := RandomNumberGenerator.new();rng.seed=113001;var largest := 0.
 var bounds: Rect2=s.shadow_field113.bounds.grow(-.01)
 var points: Array[Vector2]=[];var fast: Array[float]=[]
 s.floor_recent105.clear();s.floor_previous105.clear()
 for i in 8000:
  var at := bounds.position+Vector2(rng.randf(),rng.randf())*bounds.size
  points.append(at);fast.append(s.floor_height(at))
  largest=maxf(largest,absf(fast[-1]-s.shadow_field113.sample(at)))
 verify(largest<.0001,"GPU height texture reproduces 8000 actual adaptive collider samples; error="+str(largest))
 s.fast_floor113=false;s.floor_recent105.clear();s.floor_previous105.clear();var floor_error := 0.
 for i in points.size(): floor_error=maxf(floor_error,absf(fast[i]-s.floor_height(points[i])))
 verify(floor_error<.0001,"fast support/terrain lookup matches independent legacy floor queries; error="+str(floor_error))
 s.fast_floor113=true;s.floor_recent105.clear();s.floor_previous105.clear()
 var legacy := projectile_run113(s,false);var native := projectile_run113(s,true);var bullet_error := 0.
 for i in legacy.size(): bullet_error=maxf(bullet_error,legacy[i].distance_to(native[i]))
 verify(legacy.size()==400 and native.size()==400 and bullet_error<.0001,"200 native tracked projectiles match script positions/velocities after 40 ticks; error="+str(bullet_error))
 s._clear_combat_shots();s.buffs.levels.clear();s.slow_start113=true;s.start_combat();disable_enemies(s)
 verify(absf(s.attack_cooldown()-.34)<.0001,"slow start begins at 0.34 seconds per basic shot")
 var normal: CharacterBody3D=s.enemies[-1]
 verify(absf(normal.hp-4.)<.0001,"first-wave normal takes four unbuffed basic hits")
 for i in 3: normal.receive_hit(1.,Vector3.RIGHT)
 verify(not normal.dead and absf(normal.hp-1.)<.0001,"three basic hits leave the slow-start normal alive")
 normal.receive_hit(1.,Vector3.RIGHT);verify(normal.dead,"fourth basic hit defeats the slow-start normal")
 s.buffs.apply("snack");s.start_combat();disable_enemies(s)
 verify(s.buffs.levels.is_empty() and s.slow_start113,"retry clears cards and retains selected pace")
 var event := InputEventKey.new();event.pressed=true;event.ctrl_pressed=true;event.alt_pressed=true;event.physical_keycode=KEY_F11
 s._unhandled_input(event);disable_enemies(s)
 verify(not s.slow_start113 and absf(s.attack_cooldown()-.14)<.0001 and absf(s.enemies[-1].hp-12.)<.0001,"pace toggle restores original fire interval and enemy health together")
 s._unhandled_input(event);disable_enemies(s)
 verify(s.slow_start113 and absf(s.attack_cooldown()-.34)<.0001,"pace toggle returns to slow start")
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look();await settle72(8)
 s.label.get_parent().hide();s.frames66.panel.hide();s.time55.guide.hide();s.encounter_hud.hide();s.draft_ui.hide()
 s.process_mode=Node.PROCESS_MODE_DISABLED
 s.gpu_shadows113=false
 for shadow in s.actor_shadows:
  if is_instance_valid(shadow): shadow._process(0.)
 for i in 5: await process_frame
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/shadow113_cpu.png")
 s.gpu_shadows113=true;var gpu_count := 0
 for shadow in s.actor_shadows:
  if is_instance_valid(shadow): shadow._process(0.);gpu_count+=int(shadow.gpu113)
 for i in 5: await process_frame
 frame=await snapshot();frame.save_png("res://docs/captures/world_restart/shadow113_gpu.png")
 verify(gpu_count>=4,"hero and enemies use GPU shadow projection in the forest")
 var old=preload("res://scripts/combat/material_fx105.gd").new();old.battle=s;s.add_child(old);old.set_process(false)
 var current: Node3D=s.jelly_fx
 old.drops.assign([{"at":s.hero.position+Vector3(.3,1.,.2),"size":.17,"variant":2}])
 old.marks.assign([{"at":s.hero.position+Vector3(.4,0.,.1),"size":.4,"angle":.6,"age":.8,"life":2.}])
 old.bits.assign([{"at":s.hero.position+Vector3(.2,.7,.4),"size":.2,"angle":.7,"variant":1,"settled":false,"life":.7,"rest":0.},{"at":s.hero.position+Vector3(-.4,0.,.2),"size":.16,"angle":-.3,"variant":3,"settled":true,"life":.7,"rest":.2}])
 current.drops=old.drops.duplicate(true);current.marks=old.marks.duplicate(true);current.bits=old.bits.duplicate(true)
 old._sync();old._sync_sugar();current._sync();current._sync_sugar()
 var buffers_equal := true
 for name in ["airborne","ground","shadows","sugar","sugar_shadows"]:
  var reference: MultiMesh=old.get(name).multimesh;var actual: MultiMesh=current.get(name).multimesh
  buffers_equal=buffers_equal and reference.visible_instance_count==actual.visible_instance_count
  for i in reference.visible_instance_count:
   buffers_equal=buffers_equal and reference.get_instance_transform(i).is_equal_approx(actual.get_instance_transform(i))
   buffers_equal=buffers_equal and reference.get_instance_color(i).is_equal_approx(actual.get_instance_color(i))
   if reference.use_custom_data: buffers_equal=buffers_equal and reference.get_instance_custom_data(i).is_equal_approx(actual.get_instance_custom_data(i))
 verify(buffers_equal,"all five FX batches retain exact native transforms, colors and atlas variants")
 var file := FileAccess.open("res://docs/combat113-visual-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"checks":checks,"failures":failures,"height_max_error":largest},"\t"));print("VISUAL113_DONE checks=",checks," failures=",failures);quit(0 if failures.is_empty() else 1)

func projectile_run113(s: Node3D,native: bool) -> Array[Vector3]:
 s._clear_combat_shots();s.use_native113=native;s.buffs.levels.clear();s.buffs.apply("eye_exercise");s.buffs.apply("eye_exercise")
 var random := RandomNumberGenerator.new();random.seed=113881;var clock: float=s.combat_clock33
 for i in 200:
  var at: Vector3=s.hero.position+Vector3(random.randf_range(-3,3),20,random.randf_range(-3,3))
  var velocity := Vector3(random.randf_range(-10,10),random.randf_range(-1,1),random.randf_range(-10,10))
  var shot: Dictionary=s.data_shot110(at,velocity,2.);shot.split_depth110=1
 for tick in 40: s.combat_clock33=clock+tick/60.;s._step_shots(1./60.)
 var result: Array[Vector3]=[]
 for shot in s.shots: result.append(shot.node.at);result.append(shot.velocity)
 s.combat_clock33=clock;return result
