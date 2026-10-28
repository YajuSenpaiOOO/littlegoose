extends "res://scripts/world/woodland95_probe.gd"
class GuardFixture:
 extends "res://scripts/combat/hero109.gd"
 var wish := Vector2.ZERO
 func movement_input() -> Vector2: return Vector2.ZERO if guarding109 else wish
 func parry_key_down() -> bool: return false
 func dash_key_down() -> bool: return false
class Sample109:
 extends "res://scripts/world/woodland_world109.gd"
 var permit99 := false
 func _hero_script() -> Script: return GuardFixture
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(reposition := true) -> void:
  if permit99: super.start_combat(reposition)

func shot99(sample: Node3D,at: Vector2,tag: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(45)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland109_"+tag+".png")

func extra_checks99(_sample: Node3D) -> void: pass

func run() -> void:
 var sample := Sample109.new();root.add_child(sample)
 while not sample.woodland_ready109: await physics_frame
 await settle72(20)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 await extra_checks99(sample)
 var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot99(sample,g+Vector2(0,2.5),"park_day")
 var old_distance: float=sample.camera_distance;sample.camera_distance=10.;sample._update_camera(0.,true)
 await shot99(sample,g+Vector2(0,2.5),"park_detail_day")
 sample.camera_distance=old_distance;sample._update_camera(0.,true)
 await shot99(sample,g+Vector2(-9,2.5),"overlook_day")
 await shot99(sample,g+Vector2(5,-1),"swing_day")
 await shot99(sample,g+Vector2(-3,10),"play_day")
 await shot99(sample,g+Vector2(-18,3),"west_day")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot99(sample,g+Vector2(0,2.5),"park_sunset")
 verify(sample.park99.tilted99.size()==5 and sample.park99.embedded_stones99>8,"leaning stump geometry and embedded step shoulders exist")
 var swing_tree: Dictionary=sample.swing_tree99
 var correct_root: bool=swing_tree.extra_id=="swing_oak99"
 for piece in sample.root_pieces:
  if piece.sprite==swing_tree.visual: correct_root=correct_root and piece.cut>.74 and piece.cut<.77
 verify(correct_root,"swing oak uses its own root profile and a continuous lower silhouette")
 verify(sample.floor_height(g+Vector2(-9.,-7.0))>4.8,"mountain shoulder encloses the rear of the lookout")
 verify(not sample.swing_tree99.is_empty() and sample.park99.anchors99.size()==2,"dedicated branching oak and measured rope attachment points exist")
 verify(is_instance_valid(sample.park99.swing97) and sample.park99.stumps97.size()==5,"swing, balance log, stepping stumps, bench and overlook are installed")
 verify(sample.park99.rail_bodies97.size()>10,"park timber and guard rails have actual collision bodies")
 var west_high := true
 for z in [-20.,-10.,0.,10.]: west_high=west_high and sample.floor_height(g+Vector2(-26,z))>9.
 verify(west_high,"western void is backed by a high continuous wooded escarpment")
 var top_trees := 0
 for tree in sample.trees:
  if tree.root.position.y>9. and tree.root.position.x<g.x-21.: top_trees+=1
 verify(top_trees>=4,"high western crest carries grounded trees")
 verify(await walk_route72(sample,"nature_park99"),"entire park loop is physically walkable")
 sample.hero.controls_enabled=true;sample._teleport15(g+sample.PARK99.from_stair99(Vector2(sample.PARK99.STAIR_X,3.5)));await settle72(10)
 var stairs := true
 for z in [2.,.5,-1.,-2.8,-4.4]: stairs=stairs and await walk_to(sample,g+sample.PARK99.from_stair99(Vector2(sample.PARK99.STAIR_X,z)))
 verify(stairs and sample.hero.position.y>sample.PARK99.DECK_Y-.25,"hero climbs the stone flight and reaches the overlook")
 for z in [-2.8,-1.,.5,2.,3.5]: stairs=stairs and await walk_to(sample,g+sample.PARK99.from_stair99(Vector2(sample.PARK99.STAIR_X,z)))
 verify(stairs and sample.hero.position.y<2.6,"hero descends from the overlook without getting trapped")
 verify(await walk_route72(sample,"junction_to_grove"),"existing entrance now joins the park loop")
 verify(await walk_route72(sample,"woodland_return72"),"existing return route remains usable")
 verify(await path93(sample,g+Vector2(-4,1),g+Vector2(4,1),true),"central lawn keeps a clear east-west combat lane")
 verify(await path93(sample,g+Vector2(0,4),g+Vector2(0,-3),true),"central lawn keeps a clear north-south combat lane")
 sample.permit99=true;sample.start_combat(true);await settle72(90)
 for round in 3:
  var alive: Array=[]
  for enemy in sample.enemies:
   if is_instance_valid(enemy) and not enemy.dead: alive.append(enemy)
  verify(alive.size()==round+1,"park combat round %d has correct enemy count"%(round+1))
  var reachable := true
  for enemy in alive:
   var complete := await path93(sample,Vector2(enemy.position.x,enemy.position.z),Vector2(sample.hero.position.x,sample.hero.position.z))
   if not complete: print("UNREACHABLE99 enemy=",enemy.position," hero=",sample.hero.position)
   reachable=reachable and complete
  verify(reachable,"park combat round %d enemies reach the player on complete paths"%(round+1))
  for enemy in alive: enemy.receive_hit(999.,Vector3.RIGHT)
  if round<2:
   for frame in 180:
    await physics_frame
    if sample.draft_open: break
   await settle72(40)
   verify(sample.draft_open and sample.choose_buff(0),"park round %d reward selection advances"%(round+1));await settle72(109)
 verify(sample.defeated_count==6 and sample.wave_state=="cleared","all three park combat rounds complete")
 var data := {"checks":checks,"failures":failures,"crest_trees":top_trees,"park_bodies":sample.park99.rail_bodies97.size(),"plants":sample.forest87.plants87.size(),"flowers":sample.forest87.flower_points94.size()}
 var file := FileAccess.open("res://docs/woodland109-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("WOODLAND109_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
