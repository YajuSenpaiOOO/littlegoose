extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world346.gd"
 func test_config_path226() -> String:return "res://.goose346-test.cfg"
 func export_stats226() -> Error:return OK
var failures: Array[String]=[]
var config: Dictionary={}
func _initialize() -> void:call_deferred("run")
func check(ok: bool, label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/hud342-"+tag+".png")
func run() -> void:
 var p=preload("res://scripts/combat/balance_profile346.gd")
 var old=preload("res://scripts/combat/balance_profile288.gd")
 check(p.cost({"forest_fireboy":1})==2 and p.cost({"three_player":1})==4,"goose costs two per extra goose")
 check(old.cost({"forest_fireboy":1})==1 and old.cost({"three_player":1})==2,"old previews retain original costs")
 check(p.error({"flashlight":1,"forest_fireboy":1,"bouncy_ball":1},5)=="","single goose plus torch and one slot fits five")
 check(p.error({"three_player":1,"exercise":1},5)=="","two geese plus one slot fits five")
 var rejected={"flashlight":1,"forest_fireboy":1,"snack":1}
 check(p.cost(rejected)==6 and p.error(rejected,5)!="","old torch snack goose build now costs six")
 check(p.error({"three_player":1,"flashlight":1},5)!="","two geese cannot also fit torch in five")
 check(p.error({"balloon_sword":1,"flashlight":1},5)!="" and p.error({"homework":1,"flashlight":1},5)!="","weapon and Q conflicts retained")
 for preset in p.PRESETS:check(p.error(preset.levels)=="","preset remains valid "+preset.name)
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg"):config[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var fixture:=ConfigFile.new();fixture.set_value("test","levels",rejected);fixture.set_value("test","determination_level",2)
 fixture.save("res://.goose346-test.cfg")
 var w=Trial.new();root.add_child(w);current_scene=w
 var limit:=Time.get_ticks_msec()+180000
 while not is_instance_valid(w.combat_hud342) and Time.get_ticks_msec()<limit:await process_frame
 if not is_instance_valid(w.combat_hud342):quit(1);return
 await process_frame
 check(w.levels226.is_empty() and w.reconfigure346==rejected,"overbudget save is not silently equipped or deleted")
 check(w.console226.visible and w.combat_paused and w.console226.draft==rejected,"old loadout opens as paused editable draft")
 check(w.console226.record_button.disabled and w.console226.apply_button.disabled,"invalid draft cannot start recording or apply")
 w.console226.focus226("forest_fireboy")
 check(w.console226.detail.text.contains("每份2槽") and w.console226.detail.text.contains("占2格"),"console detail and cost match")
 w.console226.focus226("three_player")
 check(w.console226.detail.text.contains("每份4槽") and w.console226.detail.text.contains("占4格"),"two goose detail and cost match")
 var error: String=w.commit_progress257(rejected,90.,32.,false,2)
 check(error!="" and w.levels226.is_empty(),"overbudget commit rejects without equipping")
 w.console226.adjust226("snack",-1)
 check(p.cost(w.console226.draft)==4 and not w.console226.apply_button.disabled,"removing a card makes draft legal")
 var kit=w.memory_kit116
 check(kit.used(["forest_fireboy"])==2 and kit.used(["three_player"])==4,"notebook counts updated goose costs")
 check(is_equal_approx(w.COPY_DAMAGE168,.4) and is_equal_approx(w.recovery_gap344(),.45) and w.CASTLE334==144. and w.CANNON334==16.,"damage and rhythm unchanged")
 var report: Dictionary=w.report_stats226()
 check(report.runtime_preview==346 and report.geese346.single_cost==2,"record reports new cost version")
 var after:=ConfigFile.new();after.load("res://.goose346-test.cfg")
 check(after.get_value("test","levels")==rejected,"saved loadout not overwritten")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"user config unchanged "+file)
 DirAccess.remove_absolute(ProjectSettings.globalize_path("res://.goose346-test.cfg"))
 FileAccess.open("res://docs/goose346-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures},"\t"))
 print("GOOSE346_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
