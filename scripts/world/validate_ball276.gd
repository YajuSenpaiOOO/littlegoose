extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world276.gd"
 func _init() -> void:
  super._init();memory_save116="user://ball276-validation-preview.cfg"
 func test_config_path226() -> String:return "user://ball276-validation.cfg"
 func reward_path273() -> String:return "user://ball276-validation-reward.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false;w.ordinary264();w.hero.set_physics_process(false);w.levels226={"bouncy_ball":1};w.apply_levels226()
 var live=w.live_minions260();var centre: Vector2=w.meadow.landmarks.grove
 for i in live.size():live[i].set_physics_process(false);live[i].position=Vector3(centre.x+3.+i*3.,w.floor_height(centre)+.03,centre.y-3.)
 await settle(3)
 var visual=w.elastic_visual275
 check(visual.ball276!=null and visual.source276.size.x>0.,"generated ball texture loaded with explicit visible bounds")
 var original=w.data_shot110(w.hero.position+Vector3(-.8,.8,-.5),Vector3.RIGHT*10.,1.)
 var reflected=w.data_shot110(w.hero.position+Vector3(.8,.8,-.5),Vector3.LEFT*10.,1.)
 w.prepare275(original);w.prepare275(reflected);reflected.bounces275=1
 check(visual.palette276(original)==visual.palette276(reflected) and visual.palette276(original)==Color.WHITE,"original and reflected states use the same unmodified texture colors")
 check(original.art.modulate.a==0. and reflected.art.modulate.a==0.,"old candy sprites remain suppressed in both states")
 visual.hit275(w.hero.position+Vector3(0,.8,-1.3));w.combat_paused=true;await shot("ball276-same-color");w.combat_paused=false
 var node=original.node;var speed=original.velocity.length()
 w.redirect275(original,{"collider":null,"position":original.node.at,"normal":Vector3.LEFT},1.)
 check(original.node==node and is_equal_approx(original.velocity.length(),speed),"visual replacement leaves original projectile identity and speed intact")
 check(w.loadout_error257({"bouncy_ball":1,"balloon_sword":1},1)!="","sword incompatibility remains intact")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/ball276-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));f.close()
 print("BALL276_VALIDATION ",ok);quit(0 if ok else 1)
