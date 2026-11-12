extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world274.gd"
 func _init() -> void:
  super._init();memory_save116="user://ball274-validation-preview.cfg"
 func test_config_path226() -> String:return "user://ball274-validation.cfg"
 func reward_path273() -> String:return "user://ball274-validation-reward.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false
 check(w.ball_owned273 and w.loadout_error257({"bouncy_ball":1},1)=="","fragment immediately available without any Boss victory")
 w.ball_owned273=false
 check(w.loadout_error257({"bouncy_ball":1},1)=="","console validity no longer depends on acquisition state")
 w.ball_owned273=true;w.toggle_console226();w.console226.adjust226("bouncy_ball",1)
 check(w.console226.rows.has("bouncy_ball"),"native console offers fragment row");w.close_console226()
 w.ordinary264();w.hero.set_physics_process(false);w.levels226={"bouncy_ball":1};w.apply_levels226()
 var live=w.live_minions260();var centre: Vector2=w.meadow.landmarks.grove
 for i in live.size():
  live[i].set_physics_process(false);live[i].position=Vector3(centre.x+2.+float(i)*12.,w.floor_height(centre)+.03,centre.y)
 await settle(3)
 var origin=Vector3(centre.x,w.floor_height(centre)+.8,centre.y)
 var shot=w.data_shot110(origin,Vector3.RIGHT*10.,1.);shot.fixed_damage110=1.;shot.final_damage234=true
 w._step_shots(.25)
 check(live[0].hp==5. and w.ball_pending273.size()==1,"actual projectile update hits lone enemy and schedules return without another nearby target")
 check(w.ball_pending273[0].direction.x<0.,"lone enemy reflects projectile away from contact")
 w._step_shots(.04)
 var rebounds=w.shots.filter(func(s):return s.get("ball273",false))
 check(rebounds.size()==1 and rebounds[0].velocity.x<0.,"actual native update creates a moving return segment")
 check(rebounds[0].art.modulate.g<1. and rebounds[0].art.scale_gain>1.,"return segment has visible gold tint and enlarged art")
 var before=rebounds[0].node.at;w._step_shots(.1)
 check(rebounds[0].node.at.x<before.x and live[0].hp==5. and w.ball_pending273.is_empty(),"return visibly travels while excluding original victim and further recursion")
 w._clear_combat_shots();w.boss_unlocked264=true;w.boss264();w.boss247.set_physics_process(false);w.finish251(true)
 check(not w.reward273.visible,"testing build has no acquisition popup blocking repeat testing")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/ball274-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));f.close()
 print("BALL274_VALIDATION ",ok);quit(0 if ok else 1)
