extends "res://scripts/world/combat111_compare.gd"
var totals := {}
var frames113 := 0
func record113(key: String,started: int) -> void:
 var entry: Vector2=totals.get(key,Vector2.ZERO);entry+=Vector2(Time.get_ticks_usec()-started,1);totals[key]=entry
func instrument113(parent: Node) -> void:
 for node in parent.get_children():
  instrument113(node)
  var script: Script=node.get_script()
  if script==null or (not node.is_processing() and not node.is_physics_processing()): continue
  var path := script.resource_path
  if path.is_empty() or path.contains("::") or not path.ends_with(".gd"): continue
  var source := "extends \"%s\"\n"%path
  if node.has_method("_process"):
   source+="func _process(delta: float) -> void:\n var t := Time.get_ticks_usec();super._process(delta);get_tree().root.get_meta(\"profiler113\").record113(\"%s:process\",t)\n"%path
  if node.has_method("_physics_process"):
   source+="func _physics_process(delta: float) -> void:\n var t := Time.get_ticks_usec();super._physics_process(delta);get_tree().root.get_meta(\"profiler113\").record113(\"%s:physics\",t)\n"%path
  var wrapper := GDScript.new();wrapper.source_code=source
  if wrapper.reload()!=OK: continue
  var saved := {}
  for prop in node.get_property_list():
   if (int(prop.usage)&PROPERTY_USAGE_SCRIPT_VARIABLE)!=0: saved[prop.name]=node.get(prop.name)
  var processing := node.is_processing();var physics := node.is_physics_processing()
  node.set_script(wrapper)
  for key in saved: node.set(key,saved[key])
  node.set_process(processing);node.set_physics_process(physics)
func measure113(s: Node3D,tag: String) -> Dictionary:
 await settle72(40);totals.clear()
 var previous := Time.get_ticks_usec();var times: Array[float]=[]
 for i in 240:
  root.warp_mouse(s.camera.unproject_position(s.enemies[0].position+Vector3.UP*.8))
  await process_frame
  var now := Time.get_ticks_usec();times.append((now-previous)/1000.);previous=now
 times.sort()
 var parts := {};var keys := totals.keys();keys.sort_custom(func(a: String,b: String) -> bool: return Vector2(totals[a]).x>Vector2(totals[b]).x)
 for key in keys: parts[key]={"ms_per_frame":Vector2(totals[key]).x/240000.,"calls":Vector2(totals[key]).y}
 var data := {"median_ms":times[120],"p95_ms":times[228],"parts":parts,"objects":Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS),"pairs":Performance.get_monitor(Performance.PHYSICS_3D_COLLISION_PAIRS)}
 print("DEEP113 ",tag," ",JSON.stringify(data));return data
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 root.set_meta("profiler113",self)
 var s := Battle111.new();await setup(s,"woodland_ready111");instrument113(s)
 s.shooting=false;var data := {};data.idle=await measure113(s,"idle")
 build(s,["forest_fireboy","three_player","eye_exercise","eye_exercise","snack","snack"])
 data.six=await measure113(s,"six")
 var file := FileAccess.open("res://docs/combat113-deep-profile.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));quit()
