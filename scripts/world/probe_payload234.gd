extends "res://scripts/world/validate_plush220.gd"
class OldWorld:
 extends "res://scripts/world/woodland_world234.gd"
 func _init() -> void:
  super._init();memory_save116="user://payload234_audit_preview.cfg"
 var aim234 := Vector3.ZERO
 func paper_aim146() -> Vector3:return aim234
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
func place234(target: Vector3) -> bool:
 for dir in [Vector2.LEFT,Vector2.RIGHT,Vector2.DOWN,Vector2.UP]:
  var at=Vector2(target.x,target.z)+dir*3.
  if not w.open_drop225(at):continue
  var origin=Vector3(at.x,w.floor_height(at)+.55,at.y)
  var query=PhysicsRayQueryParameters3D.create(origin,target,1|2,[w.hero.get_rid()])
  if w.get_world_3d().direct_space_state.intersect_ray(query).is_empty():w._teleport15(at);return true
 return false
func run() -> void:
 w=OldWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 var target: Vector3=w.cat220.hit_area.global_position
 w.aim234=target
 check(place234(target),"clear native target line")
 var rows=[]
 for geese in [false,true]:
  for ratio in [.25,1.]:
   w._clear_combat_shots();w.levels226={"homework":1,"slingshot":1}
   if geese:w.levels226.three_player=1
   w.apply_levels226();w.hero.reset_actions();w.cooldown=0.;w.stop_until=0.;Engine.time_scale=1.
   var before=w.cat220.hp;w._release_charged(target,ratio)
   var live_damage=0.
   for shot in w.shots:live_damage+=w.damage_for_shot(shot)
   var page: Dictionary=w.paper_memories146.pages146[-1].duplicate(true)
   var saved_damage=0.
   for spec in page.specs:saved_damage+=float(spec.damage)
   await create_timer(.5).timeout
   var actual=w.cat220.hp-before;before=w.cat220.hp
   w.paper_memories146.pages146.assign([page]);check(w.paper_memories146.request146(),"real Q request accepted")
   await create_timer(1.3).timeout
   rows.append({"geese":geese,"charge":ratio,"live_budget":live_damage,"stored_budget":saved_damage,"live_hit":-actual,"replay_hit":before-w.cat220.hp,"expected_ratio":.45})
 # Capture a real beam hit and its split descriptors, then let native113 flush.
 w._clear_combat_shots();w.levels226={"flashlight":1,"snack":1};w.apply_levels226()
 w.emit_stream110(target)
 var beam: Dictionary=w.shots[0];var damage=w.damage_for_shot(beam)
 w._apply_shot_hit(beam,{"collider":w.cat220.hit_area,"position":target,"normal":Vector3.LEFT})
 var pending=w.pending_splits110.duplicate(true);w._flush_splits113()
 var children=[]
 for shot in w.shots:
  if int(shot.get("split_depth110",0))>0:children.append({"stream":shot.get("stream110",false),"piercing":shot.get("piercing110",false),"damage":w.damage_for_shot(shot),"arc":shot.get("arc166",false)})
 metrics={"notes":rows,"beam_damage":damage,"split_descriptors":pending,"children":children}
 FileAccess.open("res://docs/payload234-audit.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t"))
 print("PAYLOAD234_AUDIT ",JSON.stringify(metrics));w.stop225();quit()
