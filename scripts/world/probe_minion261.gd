extends "res://scripts/world/validate_plush220.gd"
class Probe:
 extends "res://scripts/world/woodland_world260.gd"
 func _init() -> void:
  super._init();memory_save116="user://minion261-probe-preview.cfg"
 func test_config_path226() -> String:return "user://minion261-probe.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func run() -> void:
 w=Probe.new();root.add_child(w);current_scene=w
 while not w.ready251 or not w.console226.has_method("draft_level257"):await process_frame
 w.hero.set_physics_process(false);w.hero.controls_enabled=false;w.auto114=false
 print("NAV261 ",w.navigation.get_script().resource_path," origin=",w.navigation.origin," grove=",w.meadow.landmarks.grove," hero=",w.hero.position)
 var previous={};var rows=[]
 for i in 40:
  await create_timer(.5).timeout
  for m in w.live_minions260():
   var p=Vector2(m.position.x,m.position.z);var key=str(m.get_instance_id())
   var row={"time":w.telemetry260.data.physics_seconds,"boss":w.boss247.phase247,"id":key,"state":m.state260,"phase":m.attack_phase,"hop":m.hopping,"clock":m.phase_clock,"at":str(p),"distance":p.distance_to(Vector2(w.hero.position.x,w.hero.position.z)),"travel":p.distance_to(previous.get(key,p)),"route":str(m.route)}
   previous[key]=p;rows.append(row);print("MINION261 ",row)
 var f=FileAccess.open("res://docs/minion261-probe.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close();quit()
