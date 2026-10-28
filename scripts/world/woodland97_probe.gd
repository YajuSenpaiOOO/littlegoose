extends "res://scripts/world/woodland95_probe.gd"
class Sample97:
 extends "res://scripts/world/woodland_world97.gd"
 var permit97 := false
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(reposition := true) -> void:
  if permit97: super.start_combat(reposition)

func shot97(sample: Node3D,at: Vector2,tag: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(45)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland97_"+tag+".png")

func run() -> void:
 var sample := Sample97.new();root.add_child(sample)
 while not sample.woodland_ready97: await physics_frame
 await settle72(20)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot97(sample,g+Vector2(-1,5),"park_day")
 await shot97(sample,g+Vector2(-12,2.5),"overlook_day")
 await shot97(sample,g+Vector2(8,-2),"swing_day")
 await shot97(sample,g+Vector2(-4,13),"play_day")
 await shot97(sample,g+Vector2(-18,3),"west_day")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot97(sample,g+Vector2(-1,5),"park_sunset")
 verify(is_instance_valid(sample.park97.swing97) and sample.park97.stumps97.size()==5,"swing, balance log, stepping stumps, bench and overlook are installed")
 verify(sample.park97.rail_bodies97.size()>10,"park timber and guard rails have actual collision bodies")
 var west_high := true
 for z in [-20.,-10.,0.,10.]: west_high=west_high and sample.floor_height(g+Vector2(-26,z))>9.
 verify(west_high,"western void is backed by a high continuous wooded escarpment")
 var top_trees := 0
 for tree in sample.trees:
  if tree.root.position.y>9. and tree.root.position.x<g.x-21.: top_trees+=1
 verify(top_trees>=4,"high western crest carries grounded trees")
 verify(await walk_route72(sample,"nature_park97"),"entire park loop is physically walkable")
 sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(sample.PARK97.STAIR_X,3.5));await settle72(10)
 var stairs := true
 for z in [2.,.5,-1.,-2.8,-4.4]: stairs=stairs and await walk_to(sample,g+Vector2(sample.PARK97.STAIR_X,z))
 verify(stairs and sample.hero.position.y>4.1,"hero climbs the stone flight and reaches the overlook")
 for z in [-2.8,-1.,.5,2.,3.5]: stairs=stairs and await walk_to(sample,g+Vector2(sample.PARK97.STAIR_X,z))
 verify(stairs and sample.hero.position.y<2.6,"hero descends from the overlook without getting trapped")
 verify(await walk_route72(sample,"junction_to_grove"),"existing entrance now joins the park loop")
 verify(await walk_route72(sample,"woodland_return72"),"existing return route remains usable")
 verify(await path93(sample,g+Vector2(-8,2),g+Vector2(8,2),true),"central lawn keeps a clear east-west combat lane")
 verify(await path93(sample,g+Vector2(0,6),g+Vector2(0,-5),true),"central lawn keeps a clear north-south combat lane")
 sample.permit97=true;sample.start_combat(true);await settle72(90)
 for round in 3:
  var alive: Array=[]
  for enemy in sample.enemies:
   if is_instance_valid(enemy) and not enemy.dead: alive.append(enemy)
  verify(alive.size()==round+1,"park combat round %d has correct enemy count"%(round+1))
  var reachable := true
  for enemy in alive: reachable=reachable and await path93(sample,Vector2(enemy.position.x,enemy.position.z),Vector2(sample.hero.position.x,sample.hero.position.z))
  verify(reachable,"park combat round %d enemies reach the player on complete paths"%(round+1))
  for enemy in alive: enemy.receive_hit(999.,Vector3.RIGHT)
  if round<2:
   for frame in 180:
    await physics_frame
    if sample.draft_open: break
   await settle72(40)
   verify(sample.draft_open and sample.choose_buff(0),"park round %d reward selection advances"%(round+1));await settle72(100)
 verify(sample.defeated_count==6 and sample.wave_state=="cleared","all three park combat rounds complete")
 var data := {"checks":checks,"failures":failures,"crest_trees":top_trees,"park_bodies":sample.park97.rail_bodies97.size(),"plants":sample.forest87.plants87.size(),"flowers":sample.forest87.flower_points94.size()}
 var file := FileAccess.open("res://docs/woodland97-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("WOODLAND97_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
