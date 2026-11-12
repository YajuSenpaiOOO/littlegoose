extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world269.gd"
 var contacts269 := 0
 func _init() -> void:
  super._init();memory_save116="user://roller269-validation-preview.cfg"
 func test_config_path226() -> String:return "user://roller269-validation.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:contacts269+=1
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false;w.ordinary264();w.hero.set_physics_process(false)
 var m=w.live_minions260()[0];var centre: Vector2=w.meadow.landmarks.grove
 check(m.bloom268==null and m.textures.idle!=w.combat_textures.idle,"flower and body share a single composed texture without a separate flower sprite")
 var source=w.combat_poses.duplicate(true)
 var helper=preload("res://scripts/art/flower_composite270.gd")
 for kind in ["elite","boss"]:
  var merged=helper.build(w.combat_poses,w.combat_textures,kind)
  var valid=true
  for key in w.combat_textures:
   if not source.has(key) or not source[key].has("foot"):continue
   var pose=source[key];var combined=merged.poses[key]
   valid=valid and pose.scale==combined.scale and pose.visible_height==combined.visible_height and pose.visible_width==combined.visible_width
   var image=w.combat_textures[key].get_image();var rect=image.get_used_rect()
   var pixel=Vector2i(rect.position.x+rect.size.x/2,rect.end.y-5)
   var shift=Vector2i(roundi(combined.foot[0]-pose.foot[0]),roundi(combined.foot[1]-pose.foot[1]))
   valid=valid and image.get_pixelv(pixel).is_equal_approx(merged.textures[key].get_image().get_pixelv(pixel+shift))
  check(valid,kind+" all pose scales silhouettes and body foot pixels remain anchored")
  check(helper.build(w.combat_poses,w.combat_textures,kind).textures.idle==merged.textures.idle,kind+" runtime composition is cached")
 check(w.combat_poses==source,"shared source metadata is not modified")
 check(w.live_minions260().size()==1 and w.roster264.TOTAL==1,"single actor standalone trial")
 m.set_physics_process(false);m.enter269("charge");var direction=m.direction269
 w.hero.position.x+=3.;m._physics_process(.4)
 check(m.direction269==direction and m.roll_state269=="charge","charge locks direction and gives readable anticipation")
 w.combat_paused=true;var clock=m.timer269;m._physics_process(.4)
 check(m.timer269==clock,"pause freezes roller state")
 w.combat_paused=false
 var wall=StaticBody3D.new();wall.collision_layer=2;var shape=CollisionShape3D.new();var box=BoxShape3D.new();box.size=Vector3(.3,2.,5.);shape.shape=box;shape.position.y=1.;wall.add_child(shape);w.add_child(wall);wall.position=Vector3(centre.x+1.,w.floor_height(centre),centre.y)
 m.position=Vector3(centre.x-1.,w.floor_height(centre)+.03,centre.y);m.velocity=Vector3.ZERO;m.enter269("charge");m.direction269=Vector2.RIGHT;m.enter269("rolling");m.set_physics_process(true)
 var deadline=Time.get_ticks_msec()+2000
 while m.bounces269==0 and Time.get_ticks_msec()<deadline:await physics_frame
 check(m.bounces269==1 and m.direction269.x<0.,"real static wall collision reflects horizontal motion")
 w.combat_paused=true;await shot("roller269-bounce");w.combat_paused=false
 wall.queue_free();await settle(3)
 deadline=Time.get_ticks_msec()+4000
 while m.roll_state269!="dizzy" and Time.get_ticks_msec()<deadline:await physics_frame
 check(m.roll_state269=="dizzy" and m.timer269<.2,"bounded roll naturally ends in dizziness")
 w.combat_paused=true;await shot("roller269-dizzy");w.combat_paused=false
 var hp=m.hp;m.receive_hit(1.,Vector3.RIGHT)
 check(m.hp==hp-1. and m.roll_state269=="dizzy","dizzy actor remains damageable without cancelling punish window")
 m.set_physics_process(false);m.enter269("charge");m.direction269=Vector2.RIGHT;m.enter269("rolling");w.hero.position=m.position+Vector3(.7,0,0);w.hero.cancel_guard109();w.hero.parry_cd=0.;w.hero.request_parry();m._physics_process(.01)
 check(m.direction269.x<0. and m.reflected269 and m.distance269>=10.,"parry reverses roll and shortens remaining travel")
 var contacts=w.contacts269;w.hero.position=m.position;m._physics_process(.05)
 check(w.contacts269==contacts,"reflected return cannot immediately injure player")
 m.direction269=Vector2.ZERO;m.stuck269=.4;m._physics_process(.01)
 check(m.roll_state269=="dizzy","blocked roller has a bounded wall-corner escape")
 check(w.report_stats226().roller269.parries==1,"capture includes roller counters")
 m.receive_hit(100.,Vector3.RIGHT);await settle(5)
 check(w.mode264=="ready" and w.roster264.defeated==1,"single real defeat finishes trial")
 w.yard264();check(w.live_minions260().size()==1,"retry restores one actor")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/roller269-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));f.close()
 print("ROLLER269_VALIDATION ",ok);quit(0 if ok else 1)
