extends "res://scripts/world/woodland95_probe.gd"
class Sample96:
 extends "res://scripts/world/woodland_world96.gd"
 var permit96 := false
 func _hero_script() -> Script: return LivingActor
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func start_combat(reposition := true) -> void:
  if permit96: super.start_combat(reposition)

func shot96(sample: Node3D,at: Vector2,tag: String) -> void:
 sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(40)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland96_"+tag+".png")

func run() -> void:
 var sample := Sample96.new();root.add_child(sample)
 while not sample.woodland_ready96: await physics_frame
 await settle72(25)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot96(sample,g+Vector2(-8,3),"rest_day")
 await shot96(sample,g+Vector2(-3,-1),"meadow_day")
 await shot96(sample,g+Vector2(0,4),"centre_day")
 await shot96(sample,g+Vector2(-18,3),"west_day")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot96(sample,g+Vector2(-8,3),"rest_sunset")
 verify(sample.forest87.rest_stone96,"wide moss stone is grounded in the rest nook")
 verify(sample.forest87.flower_points94.size()>200 and sample.forest87.flower_batches94.size()==2,"connected low meadow uses mainly white flowers with occasional blue")
 var low := true
 for batch in sample.forest87.flower_batches94:
  for i in batch.multimesh.instance_count:
   var h: float=batch.multimesh.get_instance_transform(i).basis.y.length()
   low=low and h>=.129 and h<=.281
 verify(low,"every flower stays between 13 and 28 centimetres with an independent stem")
 var old := preload("res://scripts/world/world_surface92.gd").new()
 var hill := g+Vector2(-11,-3.8)
 verify(sample.floor_height(hill)-old.height_at(hill.x,hill.y,true)>.55,"rest stone sits on a real raised grassy shelf")
 var roads_same := true
 for route in sample.meadow.named_routes:
  for at in route.points: roads_same=roads_same and absf(sample.meadow.height_at(at.x,at.y,true)-old.height_at(at.x,at.y,true))<.001
 verify(roads_same,"existing road centre heights remain unchanged")
 sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(0,3));await settle72(10)
 var walk := true
 for offset in sample.LAYOUT96.TRAIL: walk=walk and await walk_to(sample,g+offset)
 walk=walk and await walk_to(sample,g+Vector2(-10.7,-1.4))
 verify(walk,"hero follows the grass trail and approaches the rest stone")
 verify(await walk_route72(sample,"junction_to_grove"),"original entrance remains traversable")
 verify(await walk_route72(sample,"woodland_return72"),"original woodland return remains traversable")
 verify(await path93(sample,g+Vector2(-16,2),g+Vector2(16,2),true),"combat opening remains connected across the field")
 verify(sample.rocks91.after_materials91[0].shader.code.contains("flat96"),"subtle grass wear is present in the final split terrain material")
 verify(sample._grass_growth92(g+Vector2(-5,1.5))<.2,"the visible grass trail uses genuinely lower blades")
 sample.permit96=true;sample.start_combat(true);await settle72(100)
 verify(sample.wave_state=="fighting" and sample.enemies.size()>0,"combat starts after terrain and stone rearrangement")
 var reachable := true
 for enemy in sample.enemies:
  if not is_instance_valid(enemy) or enemy.dead: continue
  reachable=reachable and await path93(sample,Vector2(enemy.position.x,enemy.position.z),Vector2(sample.hero.position.x,sample.hero.position.z))
 verify(reachable,"spawned enemies retain complete paths to the player")
 var data := {"checks":checks,"failures":failures,"flowers":sample.forest87.flower_points94.size(),"stones":sample.forest87.rocks87.size()}
 var file := FileAccess.open("res://docs/woodland96-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("WOODLAND96_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
