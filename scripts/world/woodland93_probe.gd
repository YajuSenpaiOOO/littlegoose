extends "res://scripts/world/station86_probe.gd"
class Sample93:
 extends "res://scripts/world/woodland_world93.gd"
 var permit93 := false
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(reposition := true) -> void:
  if permit93: super.start_combat(reposition)

func shot93(sample: Node3D,at: Vector2,tag: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(35)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland93_"+tag+".png")

func path93(sample: Node3D,a: Vector2,b: Vector2,walk := false) -> bool:
 var route: PackedVector2Array=sample.navigation.path(a,b)
 if route.is_empty() or route[-1].distance_to(b)>1.1: return false
 if not walk: return true
 sample._teleport15(route[0]);await settle72(8);sample.hero.controls_enabled=true
 for at in route:
  if not await walk_to(sample,at):
   print("WALK93_STUCK target=",at," hero=",sample.hero.position);return false
 return true

func run() -> void:
 var sample := Sample93.new();root.add_child(sample)
 while not sample.woodland_ready93: await physics_frame
 await settle72(20)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot93(sample,g+Vector2(14,8),"entry_day")
 await shot93(sample,g+Vector2(0,4),"centre_day")
 await shot93(sample,g+Vector2(-18,3),"west_day")
 await shot93(sample,g+Vector2(-6,-11),"rear_day")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot93(sample,g+Vector2(0,4),"centre_sunset")
 verify(sample.fingers93.size()>=6,"two inward forest fingers have grounded tree groups")
 verify(sample.forest87.finger_rocks93>=2 and sample.forest87.finger_plants93>=20,"rock toes and middle-height foliage connect tree groups")
 var support := true
 for at in sample.fingers93: support=support and sample._support93(at)
 verify(support,"all inward trunks have stable terrain support and road clearance")
 verify(await walk_route72(sample,"junction_to_grove"),"original entrance can be walked")
 verify(await walk_route72(sample,"woodland_return72"),"original return route can be walked")
 verify(await path93(sample,g+Vector2(-17,3),g+Vector2(-9,12),true),"player can pass around the west finger into the front pocket")
 verify(await path93(sample,g+Vector2(16,-4),g+Vector2(6,-12),true),"player can pass around the rear finger into the rear pocket")
 verify(await path93(sample,g+Vector2(-16,2),g+Vector2(16,2),true),"main combat opening stays connected across the field")
 verify(await path93(sample,g+Vector2(0,12),g+Vector2(0,-12),true),"central north-south opening remains connected")
 sample.permit93=true;sample.start_combat(true);await settle72(100)
 for round in 3:
  var alive: Array=[]
  for enemy in sample.enemies:
   if is_instance_valid(enemy) and not enemy.dead: alive.append(enemy)
  verify(alive.size()==round+1,"round %d spawns expected live enemies"%(round+1))
  var reachable := true
  for enemy in alive:
   var at := Vector2(enemy.position.x,enemy.position.z)
   reachable=reachable and await path93(sample,at,Vector2(sample.hero.position.x,sample.hero.position.z))
  verify(reachable,"round %d enemies have complete paths to the player"%(round+1))
  for enemy in alive: enemy.receive_hit(999.,Vector3.RIGHT)
  if round<2:
   for frame in 180:
    await physics_frame
    if sample.draft_open: break
   await settle72(40)
   verify(sample.draft_open and sample.choose_buff(0),"round %d reward selection advances combat"%(round+1))
   await settle72(100)
 verify(sample.defeated_count==6 and sample.wave_state=="cleared","all six enemies and three rounds complete through real defeat/reward handlers")
 var data := {"checks":checks,"failures":failures,"finger_trees":sample.fingers93.size(),"finger_rocks":sample.forest87.finger_rocks93,"finger_plants":sample.forest87.finger_plants93}
 var file := FileAccess.open("res://docs/woodland93-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("WOODLAND93_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
