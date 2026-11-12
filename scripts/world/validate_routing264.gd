extends SceneTree
class Routing:
 extends "res://scripts/world/woodland_world264.gd"
 var calls264 := []
 func yard264() -> void:calls264.append("yard")
 func boss264() -> void:calls264.append("boss")
 func ordinary264() -> void:calls264.append("ordinary")
func _initialize() -> void:
 var world=Routing.new();world.ready264=true;world.boss_unlocked264=true
 var checks=[]
 world.mode264="ready";world.begin251();checks.append({"name":"F7 or console restart after first clear cannot skip first boss dialogue","pass":world.calls264==["yard"]})
 world.calls264.clear();world.mode264="boss_failed";world.begin251();checks.append({"name":"earned boss retry bypasses ordinary replay","pass":world.calls264==["boss"]})
 world.calls264.clear();world.mode264="ordinary_failed";world.begin251();checks.append({"name":"ordinary retry resets yard then starts ordinary encounter","pass":world.calls264==["yard","ordinary"]})
 world.calls264.clear();world.mode264="ambient";world.start_battle225(false);checks.append({"name":"console record starts ordinary encounter before arming its recorder","pass":world.calls264==["yard","ordinary"]})
 world.free();var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/encounter264-routing-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));f.close()
 print("ROUTING264_VALIDATION ",ok);quit(0 if ok else 1)
