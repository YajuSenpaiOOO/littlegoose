extends SceneTree
class SampleWorld:
 extends Node
 var recording226=preload("res://scripts/combat/balance_recording226.gd").new()
 var buffs=preload("res://scripts/combat/buff_book146.gd").new()
 var pigs_enabled220=true
 var player_hp=0.
 func report_stats226() -> Dictionary:
  return recording226.enrich(self,{"cat_damage":10.,"bat_damage":[0.,0.],"loadout":{}})
func _initialize() -> void:
 var w=SampleWorld.new();root.add_child(w)
 w.recording226.id="snapshot_test";w.recording226.folder="user://boss_records_validation";w.recording226.active=true
 w.recording226.finish(w,"失败")
 w.player_hp=14.;w.pigs_enabled220=false
 w.recording226.save(w)
 var report=JSON.parse_string(FileAccess.get_file_as_string("user://boss_records_validation/snapshot_test.json"))
 var valid=report.recording.player_hp_at_export==0. and report.recording.pigs_enabled_at_export and report.recording.result=="失败"
 print("RECORDING_SNAPSHOT226 ",valid);quit(0 if valid else 1)
