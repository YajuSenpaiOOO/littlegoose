extends "res://scripts/world/woodland_world241.gd"
var contact242: Node
func _init() -> void:
 super._init();memory_save116="user://music242_preview.cfg"
func test_config_path226() -> String:return "user://boss_balance242.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 242 · 音符边角 / 轻命中声")
func _candy_script117() -> Script:return preload("res://scripts/combat/music_aim242.gd")
func _ready() -> void:
 await super._ready();contact242=preload("res://scripts/combat/music_contact242.gd").new();add_child(contact242)
func music_contact242(_kind: String) -> bool:
 if not music_enabled236() or not is_instance_valid(contact242):return false
 contact242.contact();return true
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var previous=Audio.contact_override242
 if music_enabled236():Audio.contact_override242=Callable(self,"music_contact242")
 super._apply_shot_hit(shot,hit)
 Audio.contact_override242=previous
func on_legacy_contact(actor: CharacterBody3D,at: Vector3,direction: Vector3,juice: bool) -> void:
 var previous=Audio.contact_override242
 if music_enabled236():Audio.contact_override242=Callable(self,"music_contact242")
 super.on_legacy_contact(actor,at,direction,juice)
 Audio.contact_override242=previous
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("241","242")
func report_stats226() -> Dictionary:
 if not recording226.final_report.is_empty() and recording226.final_report.has("music242"):return recording226.final_report.duplicate(true)
 var report=super.report_stats226()
 report["music242"]={"contact_requests":contact242.requests if is_instance_valid(contact242) else 0,"contact_played":contact242.played if is_instance_valid(contact242) else 0,"contact_merged":contact242.merged if is_instance_valid(contact242) else 0,"contact_gap_ms":70,"contact_db":-18,"damage_unchanged":true}
 return report
func reset_music236() -> void:
 super.reset_music236()
 if is_instance_valid(contact242):
  contact242.requests=0;contact242.played=0;contact242.merged=0;contact242.last=-1000000
  for player in contact242.voices:player.stop()
