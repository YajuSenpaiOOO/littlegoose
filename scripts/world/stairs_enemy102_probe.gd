extends "res://scripts/world/woodland102_probe.gd"
func run() -> void:
 var sample := Sample102.new();root.add_child(sample)
 while not sample.woodland_ready102: await physics_frame
 await settle72(30)
 sample.details101.audio.set_enabled(false)
 var g: Vector2=sample.meadow.landmarks.grove
 sample._teleport15(g+sample.PARK99.DECK+Vector2(0,-.4))
 sample.permit99=true;sample.start_combat(false)
 for frame in 240:
  await physics_frame
  if not sample.enemies.is_empty(): break
 if sample.enemies.is_empty():
  verify(false,"first enemy is spawned for stair pursuit");quit(1);return
 var enemy: CharacterBody3D=sample.enemies[0]
 var foot: Vector2=g+sample.PARK99.from_stair99(Vector2(sample.PARK99.STAIR_X,2.1))
 enemy.position=Vector3(foot.x,sample.floor_height(foot)+.03,foot.y);enemy.velocity=Vector3.ZERO;enemy.home=g;enemy.rest=0.;enemy.attack_phase="approach";enemy.phase_clock=0.;enemy.path_clock=0.;enemy.hopping=false
 sample._teleport15(g+sample.PARK99.DECK+Vector2(0,-.4));sample.hero.controls_enabled=false
 var highest := enemy.position.y;var penetration := 0.
 for frame in 900:
  await physics_frame
  highest=maxf(highest,enemy.position.y)
  var support: float=sample.park99.support102(Vector2(enemy.position.x,enemy.position.z))
  if is_finite(support): penetration=maxf(penetration,support-enemy.position.y)
  if highest>3.61 and enemy.position.distance_to(sample.hero.position)<2.4: break
 verify(highest>3.61,"actual enemy pursuit climbs the new solid stair flight")
 verify(penetration<.04,"enemy body does not sink through the solid tread faces")
 verify(sample.details101.cones102[0].collision_layer==32,"loose pinecones use their own layer rather than the enemy body layer")
 var data := {"checks":checks,"failures":failures,"enemy_highest":highest,"enemy_end":str(enemy.position),"penetration":penetration}
 var f := FileAccess.open("res://docs/enemy-stairs102-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify(data,"\t"));print("ENEMY_STAIRS102 ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
