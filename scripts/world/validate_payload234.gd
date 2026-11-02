extends "res://scripts/world/validate_plush220.gd"
class OldWorld:
 extends "res://scripts/world/woodland_world234.gd"
 func _init() -> void:
  super._init();memory_save116="user://payload234_audit_preview.cfg"
 var replay_budget234 := 0.
 func emit_packet146(packet: Dictionary,origin: Vector3,target: Vector3,gain: float,generation := -1) -> void:
  var before=shots.size();super.emit_packet146(packet,origin,target,gain,generation)
  for i in range(before,shots.size()):replay_budget234+=damage_for_shot(shots[i])
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
   w.replay_budget234=0.
   w.paper_memories146.pages146.assign([page]);check(w.paper_memories146.request146(),"real Q request accepted")
   await create_timer(2.).timeout
   check(abs(saved_damage-live_damage)<.00001,"notes save complete charge/source budget")
   check(abs(w.replay_budget234-saved_damage*.45)<.0001,"real Q emitted budget equals saved damage x45 percent")
   if not geese:check(abs((before-w.cat220.hp)-saved_damage*.45)<.0001,"single source real Q hit equals saved damage x45 percent")
   rows.append({"geese":geese,"charge":ratio,"live_budget":live_damage,"stored_budget":saved_damage,"live_hit":-actual,"replay_hit":before-w.cat220.hp,"replay_budget":w.replay_budget234,"expected_ratio":.45})
 # Capture a real beam hit and its split descriptors, then let native113 flush.
 w._clear_combat_shots();w.levels226={"flashlight":1,"snack":1};w.apply_levels226()
 w.emit_stream110(target)
 var beam: Dictionary=w.shots[0];var damage=w.damage_for_shot(beam)
 w._apply_shot_hit(beam,{"collider":w.cat220.hit_area,"position":target,"normal":Vector3.LEFT})
 var pending=w.pending_splits110.duplicate(true);w._flush_splits113()
 var children=[]
 for shot in w.shots:
  if int(shot.get("split_depth110",0))>0:children.append({"stream":shot.get("stream110",false),"piercing":shot.get("piercing110",false),"damage":w.damage_for_shot(shot),"arc":shot.get("arc166",false)})
 # Both dispatchers must preserve first/second split identities and resolved damage.
 var split_rows=[]
 for native in [true,false]:
  for kind in ["flashlight","slingshot","balloon_sword"]:
   w._clear_combat_shots();w.use_native113=native;w.levels226={"snack":2};w.levels226[kind]=1;w.apply_levels226()
   w.hero.reset_actions();w.stop_until=0.;Engine.time_scale=1.
   if kind=="flashlight":w.emit_stream110(target)
   elif kind=="slingshot":w._release_charged(target,1.)
   else:w.fire_at(target)
   var parent: Dictionary=w.shots[0];var parent_damage=w.damage_for_shot(parent)
   var generation=w.stream_generation110
   var impact={"collider":w.cat220.hit_area,"position":target,"normal":Vector3.LEFT}
   w._apply_shot_hit(parent,impact)
   # Native flush and fallback step use the same inheritance hook via different paths.
   if native:w._flush_splits113()
   else:w._step_shots(0.)
   var first=[]
   for child in w.shots:
    if int(child.get("split_depth110",0))==1:first.append(child)
   check(first.size()==6,"six fragments / "+kind+" / native="+str(native))
   var valid=true;var ids={}
   for child in first:
    valid=valid and abs(w.damage_for_shot(child)-parent_damage*.5)<.000001 and child.get("arc166",false) and child.ignore_rids110.has(w.cat220.hit_area.get_rid())
    valid=valid and bool(child.get("stream110",false))==(kind=="flashlight") and bool(child.get("sword153",false))==(kind=="balloon_sword") and bool(child.get("charged",false))==(kind=="slingshot")
    if kind=="flashlight":ids[child.stream_generation110]=true
   check(valid,"payload, half damage, arc and source exclusion / "+kind+" / "+str(native))
   if kind=="flashlight":check(ids.size()==6 and w.stream_generation110==generation,"independent short beams preserve main ribbon generation")
   if not first.is_empty():
    # A distinct target is required for an actual second collision.
    var bat=w.bats220[0];bat.dead=false;bat.hp=100000.;bat.hit_area.collision_layer=8
    w._apply_shot_hit(first[0],{"collider":bat.hit_area,"position":bat.hit_area.global_position,"normal":Vector3.LEFT})
    if native:w._flush_splits113()
    else:w._step_shots(0.)
    var second=[]
    for child in w.shots:
     if int(child.get("split_depth110",0))==2:second.append(child)
    check(second.size()==4 and second.all(func(c):return abs(w.damage_for_shot(c)-parent_damage*.25)<.000001 and bool(c.get("stream110",false))==(kind=="flashlight")),"second split retains type and quarter damage / "+kind+" / "+str(native))
    bat.dead=true;bat.hit_area.collision_layer=0
   split_rows.append({"native":native,"kind":kind,"first":first.size()})
 w.use_native113=true
 w._clear_combat_shots();w.levels226={"flashlight":1,"snack":1};w.apply_levels226()
 w.emit_stream110(target);var visual_parent: Dictionary=w.shots[0]
 w._apply_shot_hit(visual_parent,{"collider":w.cat220.hit_area,"position":target,"normal":Vector3.LEFT});w._flush_splits113()
 # Let the fragments separate before pausing on their normal short arc.
 await create_timer(.16).timeout
 w.combat_paused=true
 await shot("payload234")
 metrics={"checks":checks,"splits":split_rows,"notes":rows,"beam_damage":damage,"split_descriptors":pending,"children":children}
 FileAccess.open("res://docs/payload234-validation.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t"))
 print("PAYLOAD234_VALIDATION ",JSON.stringify(metrics));w.stop225();quit(1 if checks.any(func(c):return not c["pass"]) else 0)
