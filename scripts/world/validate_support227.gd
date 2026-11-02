extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world227.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready227:await process_frame
 w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false
 check(not w.called227 and not is_instance_valid(w.support227),"no support on first cat round")
 for i in 5:
  w.start_battle225(false);await settle(2)
  check(w.rig220.visible and w.rig220.seated.visible and w.rig220.hammock.visible,"active F8 restart restores sister and hammock %d"%i)
 w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 w.hero.velocity=Vector3(4,0,0)
 check(is_equal_approx(w.pig_target225().distance_to(Vector2(w.hero.position.x,w.hero.position.z)),1.6),"pig predicts escape lane without homing spray")
 w.hero.velocity=Vector3.ZERO
 var route_found=false;var obstacle_rejected=false
 var origin=Vector2(w.cat220.position.x,w.cat220.position.z)
 for offset in [Vector2(4,0),Vector2(-4,0),Vector2(0,4),Vector2(0,-4),Vector2(-5,-3),Vector2(5,-3)]:
  var route=w.cat_path227(origin,origin+offset)
  if route.size()>1:route_found=true
  if not w.cat_can_roll227(origin,origin+offset):obstacle_rejected=true
 check(route_found,"cat-sized navigation has usable routes in cottage clearing")
 check(obstacle_rejected,"blocked direct roll rejected so cat can continue pathing")
 var fixture=false;var saved_cat=w.cat220.position;var saved_hero=w.hero.position
 for cell in w.cat_nav227.grid.region.size.y:
  if fixture:break
  for x in range(3,w.cat_nav227.grid.region.size.x-3):
   var left=Vector2i(x-3,cell);var right=Vector2i(x+3,cell)
   if not w.cat_nav227.grid.is_point_solid(Vector2i(x,cell)) or w.cat_nav227.grid.is_point_solid(left) or w.cat_nav227.grid.is_point_solid(right):continue
   var a=w.cat_nav227.origin+Vector2(left)*w.cat_nav227.CELL;var b=w.cat_nav227.origin+Vector2(right)*w.cat_nav227.CELL
   var path=w.cat_path227(a,b);var length=0.
   for i in range(1,path.size()):length+=path[i].distance_to(path[i-1])
   if path.size()<4 or length<a.distance_to(b)+.5:continue
   w.cat220.position=Vector3(a.x,w.floor_height(a),a.y);w.hero.position=Vector3(b.x,w.floor_height(b),b.y)
   if w.cat_can_roll227(a,b):continue
   w.cat220.enter220("chase");w.cat220.next_roll220=0.;w.cat220.path_clock=0.;w.invulnerability=1000.
   for i in 180:w.cat220._physics_process(1./60.);await physics_frame
   check(Vector2(w.cat220.position.x,w.cat220.position.z).distance_to(a)>.8,"physical cat makes progress around a real blocked navigation segment")
   fixture=true;break
 check(fixture,"real obstructed navigation fixture found")
 w.cat220.position=saved_cat;w.hero.position=saved_hero
 w.cat220.receive_hit(99999.,Vector3.ZERO);await create_timer(1.5).timeout
 check(w.repairs220==1 and not w.called227,"first repair does not call spider")
 w.phase_age220=6.1;await create_timer(.1).timeout;w.phase_age220=1.3;await create_timer(.1).timeout
 w.cat220.receive_hit(99999.,Vector3.ZERO);await create_timer(1.5).timeout
 check(w.repairs220==2 and w.called227 and is_instance_valid(w.support227),"second repair calls exactly one support spider")
 var spider=w.support227;var count=w.enemies.size();w.spawn_support227()
 check(w.enemies.size()==count and w.support227==spider,"support is not repeatedly spawned")
 spider.prepare170(Vector2(w.hero.position.x,w.hero.position.z));await create_timer(1.95).timeout
 check(not w.pads172.is_empty() and w.pads172[0].live172,"support completes native web weaving")
 check(w.silk171.is_empty(),"support has no old high-damage silk projectile attack")
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/support227-weave.png")
 spider.receive_hit(1.,Vector3.RIGHT)
 check(spider.hp<8.,"support is damageable through native enemy interface")
 w.stop225();await settle()
 check(not is_instance_valid(w.support227) and w.pads172.is_empty() and w.silk171.is_empty() and not w.context202,"reset clears support webs and forest trial context")
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/support227-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size()},"\t"))
 print("SUPPORT227_RESULT ",checks.size()," checks ",failures.size()," failures");quit(0 if failures.is_empty() else 1)
