extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world273.gd"
 func _init() -> void:
  super._init();memory_save116="user://ball273-validation-preview.cfg"
 func test_config_path226() -> String:return "user://ball273-validation.cfg"
 func reward_path273() -> String:return "user://ball273-validation-reward.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.ball_owned273=false;w.auto114=false
 check(w.loadout_error257({"bouncy_ball":1},1)!="","fragment locked before first boss victory")
 w.ball_owned273=true
 check(w.loadout_error257({"bouncy_ball":1,"slingshot":1,"homework":1},1)=="" and w.balance_profile226().cost({"bouncy_ball":1})==1,"fragment costs one slot and fits an initial four-slot build")
 check(w.loadout_error257({"bouncy_ball":2},1)!="","fragment has only one valid level")
 w.toggle_console226();check(w.console226.rows.has("bouncy_ball"),"native console contains actual fragment row");w.close_console226()
 w.ordinary264();w.hero.set_physics_process(false);w.levels226={"bouncy_ball":1};w.apply_levels226()
 var live=w.live_minions260();var centre: Vector2=w.meadow.landmarks.grove
 for i in live.size():
  live[i].set_physics_process(false);live[i].position=Vector3(centre.x+2.+float(i)*2.,w.floor_height(centre)+.03,centre.y)
 await settle(3)
 var origin=Vector3(centre.x,w.floor_height(centre)+.8,centre.y);var shot=w.data_shot110(origin,Vector3.RIGHT*10.,1.);shot.fixed_damage110=1.;shot.final_damage234=true
 var hit=w._trace_shot(shot,origin,origin+Vector3.RIGHT*3.)
 check(not hit.is_empty() and hit.collider==live[0].hit_area,"native ray finds first enemy")
 w._apply_shot_hit(shot,hit)
 check(live[0].hp==5. and w.ball_pending273.size()==1,"original damage remains one and schedules exactly one rebound")
 check(shot.get("ball_spent273",false),"original piercing shot spends its rebound allowance once")
 w._retire_projectile110(shot);w.shots.erase(shot)
 var second_hp=live[1].hp
 w._step_shots(0.)
 var rebounds=w.shots.filter(func(s):return s.get("ball273",false))
 check(rebounds.size()==1 and rebounds[0].ignore_rids110.has(live[0].hit_area.get_rid()),"rebound physically excludes original target")
 w._step_shots(.25)
 check(is_equal_approx(live[1].hp,second_hp-.7) and live[0].hp==5.,"native rebound hits another enemy at seventy percent damage")
 check(w.ball_pending273.is_empty() and live[2].hp==6.,"rebound stops after one hop without recursively hitting a third enemy")
 w._clear_combat_shots()
 var wall=StaticBody3D.new();wall.collision_layer=2;var collision=CollisionShape3D.new();var box=BoxShape3D.new();box.size=Vector3(.2,2.,2.);collision.shape=box;collision.position.y=1.;wall.add_child(collision);w.add_child(wall);wall.position=origin+Vector3(0,-.8,3.)
 await settle(3)
 shot=w.data_shot110(origin,Vector3.BACK*10.,1.);var wall_hit=w._trace_shot(shot,origin,origin+Vector3.BACK*4.)
 check(not wall_hit.is_empty() and wall_hit.collider==wall,"native ray finds a real static obstacle")
 w._apply_shot_hit(shot,wall_hit)
 check(w.ball_pending273.size()==1 and w.ball_pending273[0].direction.z<0.,"wall contact creates a reflected trajectory")
 w._clear_combat_shots();shot=w.data_shot110(origin,Vector3.RIGHT*10.,1.);shot.stream110=true
 w._apply_shot_hit(shot,hit);check(w.ball_pending273.is_empty(),"flashlight stream does not branch into bounce shots")
 shot.stream110=false;shot.split_depth110=1;w._apply_shot_hit(shot,hit)
 check(w.ball_pending273.is_empty(),"split descendants cannot start rebound chains")
 wall.queue_free();w._clear_combat_shots();w.boss_unlocked264=true;w.boss264();w.boss247.set_physics_process(false);w.ball_owned273=false
 w.finish251(true)
 check(w.ball_owned273 and w.reward273.visible and w.mode264=="won","real boss victory grants reward and shows acquisition dialog")
 await self.shot("ball273-reward")
 var cfg=ConfigFile.new();check(cfg.load(w.reward_path273())==OK and cfg.get_value("reward","bouncy_ball",false),"reward is persisted in isolated preview reward storage")
 w.reward273.hide();w.combat_paused=false;w.boss264();w.boss247.set_physics_process(false);w.finish251(true)
 check(not w.reward273.visible and w.ball_owned273,"repeat victory does not grant another copy or popup")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/ball273-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));f.close()
 print("BALL273_VALIDATION ",ok);quit(0 if ok else 1)
