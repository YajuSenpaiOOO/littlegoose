extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world275.gd"
 func _init() -> void:
  super._init();memory_save116="user://elastic275-validation-preview.cfg"
 func test_config_path226() -> String:return "user://elastic275-validation.cfg"
 func reward_path273() -> String:return "user://elastic275-validation-reward.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false;w.ordinary264();w.hero.set_physics_process(false);w.levels226={"bouncy_ball":1};w.apply_levels226()
 check(w.loadout_error257({"bouncy_ball":1,"balloon_sword":1},1)!="","sticky sword and elastic projectile are mutually exclusive")
 check(w.loadout_error257({"bouncy_ball":1,"snack":1},1)=="","split and elastic fragments remain compatible")
 var live=w.live_minions260();var centre: Vector2=w.meadow.landmarks.grove
 for i in live.size():live[i].set_physics_process(false);live[i].position=Vector3(centre.x+2.+float(i)*3.,w.floor_height(centre)+.03,centre.y)
 await settle(3)
 var origin=Vector3(centre.x,w.floor_height(centre)+.8,centre.y)
 var shot=w.data_shot110(origin,Vector3.RIGHT*120.,1.4);shot.charged=true;shot.piercing110=true;shot.fixed_damage110=1.;shot.final_damage234=true
 var node=shot.node;var art=shot.art;var fired=w.fired_count
 w._step_shots(.02)
 check(w.shots.size()==1 and shot.node==node and shot.art==art and w.fired_count==fired,"collision redirects the original record node and art without emitting a new projectile")
 check(is_equal_approx(shot.velocity.length(),120.) and not shot.charged and not shot.piercing110,"heavy projectile retains full speed and stops piercing after rebound")
 check(shot.bounces275==1 and live[0].hp==5.,"original target takes its normal hit before one redirect")
 w._step_shots(.03)
 check(is_equal_approx(live[1].hp,5.3) and live[2].hp==6. and w.shots.is_empty(),"redirected projectile deals seventy percent and stops at the next target")
 w._clear_combat_shots()
 shot=w.data_shot110(origin+Vector3(0,2.,2.),Vector3.DOWN*14.,1.4);shot.packet146=true;shot.snack146=0;shot.fixed_damage110=1.;shot.final_damage234=true
 node=shot.node;w._step_shots(.3)
 check(w.shots.has(shot) and shot.node==node and shot.bounces275==1 and w.elastic_stats275.ground>0,"plane-style falling payload bounces from actual terrain using its original projectile")
 check(is_equal_approx(shot.velocity.length(),14.) and shot.velocity.y>-.1,"floor bounce preserves speed and redirects out of the floor")
 w.combat_paused=true;await self.shot("elastic275-ball");w.combat_paused=false
 w._clear_combat_shots();w.levels226={"bouncy_ball":1,"snack":1};w.apply_levels226()
 shot=w.data_shot110(origin,Vector3.RIGHT*10.,1.);shot.fixed_damage110=1.;shot.final_damage234=true;shot.split_depth110=0
 w._step_shots(.25)
 var children=w.shots.filter(func(s):return s!=shot)
 check(children.size()>0 and shot.bounces275==1,"first contact can split while the original projectile redirects")
 w._step_shots(0.)
 check(children.all(func(s):return s.elastic275 and s.bounces275==0),"each split descendant starts with its own single bounce budget")
 var child=children[0];child.bounces275=1;var before=w.pending_splits110.size()
 var hit={"collider":live[2].hit_area,"position":live[2].hit_area.global_position,"normal":Vector3.LEFT}
 w._apply_shot_hit(child,hit)
 check(w.pending_splits110.size()==before,"post-bounce contact cannot start a new split generation")
 w._clear_combat_shots();w.levels226={"bouncy_ball":1,"flashlight":1};w.apply_levels226()
 var wall=StaticBody3D.new();wall.collision_layer=2;var collision=CollisionShape3D.new();var box=BoxShape3D.new();box.size=Vector3(.2,2.,2.);collision.shape=box;collision.position.y=1.;wall.add_child(collision);w.add_child(wall);wall.position=origin+Vector3(0,-.8,3.)
 await settle(3)
 shot=w.data_shot110(origin,Vector3.BACK*20.,1.4);shot.stream110=true;shot.stream_lane110=0;shot.stream_generation110=1;shot.stream_sequence110=1;shot.stream_heavy110=false
 node=shot.node;w._step_shots(.2)
 check(shot.node==node and shot.velocity.z<0. and shot.has("stream_joint275"),"light stream sample reflects without replacement and retains a beam joint")
 w.skills110.build_chains110();check(not w.skills110.chains110.is_empty(),"reflected light remains rendered as a continuous beam segment")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/elastic275-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));f.close()
 print("ELASTIC275_VALIDATION ",ok);quit(0 if ok else 1)
