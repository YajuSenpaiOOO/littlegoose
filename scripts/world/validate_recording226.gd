extends "res://scripts/world/validate_plush220.gd"
func run() -> void:
 w=load("res://scenes/world/world227.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready227:await process_frame
 var cfg_path="user://boss_balance226.cfg"
 var exists=FileAccess.file_exists(cfg_path)
 var backup=FileAccess.get_file_as_bytes(cfg_path) if exists else PackedByteArray()
 w.toggle_console226();await settle()
 check(w.console226.record_button.visible and not w.console226.record_button.disabled,"console exposes enabled recording button")
 var kit=w.levels226.duplicate(true)
 # Invoke the button's connected action; keep automated samples out of player history.
 w.console226.record_mode.select(1)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/recording226-console.png")
 await click_record()
 w.recording226.folder="user://boss_records_validation"
 var original="user://boss_records/"+w.recording226.id+".json"
 if FileAccess.file_exists(original):DirAccess.remove_absolute(ProjectSettings.globalize_path(original))
 check(w.active114 and w.recording226.active and not w.console226.visible and w.levels226==kit,"record button applies draft and restarts full fight")
 w.auto114=false;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 var first_id=w.recording226.id
 var hp=w.cat220.hp
 w.cat220.receive_hit(3.,Vector3.ZERO)
 await create_timer(.2).timeout
 var report=w.report_stats226()
 check(is_equal_approx(report.cat_damage,3.) and report.recording.hit_events_cat==1 and report.recording.cat_phase_dps>0.,"native cat damage and phase DPS recorded")
 check(report.loadout==kit and not report.cards.is_empty() and report.recording.accuracy==null,"records named loadout and explicitly unsupported accuracy")
 w.toggle_console226();var age=w.recording226.elapsed
 await create_timer(.15).timeout
 check(w.recording226.elapsed==age,"console pause excluded from sampling clock")
 w.close_console226()
 w.recording226.checkpoint=5.;await settle(3)
 check(FileAccess.file_exists(w.recording226.folder+"/"+first_id+".json"),"periodic checkpoint creates sample file")
 # Native kill starts the normal lower/repair window.
 w.cat220.receive_hit(hp,Vector3.ZERO);await create_timer(1.6).timeout
 check(w.battle_phase220=="repair","native cat defeat opens normal repair phase")
 w.bats220[0].receive_hit(2.,Vector3.ZERO);await create_timer(.15).timeout
 report=w.report_stats226()
 check(report.recording.bat_targetable_seconds>0. and report.recording.hit_events_bats==1 and report.recording.bat_phase_dps>0.,"bat window uses separate clock and hit events")
 w.start_battle225(false)
 var path="user://boss_records_validation/"+first_id+".json"
 var archived=JSON.parse_string(FileAccess.get_file_as_string(path))
 check(archived.recording.result=="重开中止" and not archived.recording.active and not w.recording226.active and w.recording226.id=="","F8 archives old run before resetting metrics")
 w.toggle_console226();w.console226.record_button.pressed.emit()
 original="user://boss_records/"+w.recording226.id+".json"
 w.recording226.folder="user://boss_records_validation"
 if FileAccess.file_exists(original):DirAccess.remove_absolute(ProjectSettings.globalize_path(original))
 check(w.recording226.id!=first_id,"new recording has unique id and cannot overwrite previous sample")
 var second=w.recording226.id
 w.stop225()
 archived=JSON.parse_string(FileAccess.get_file_as_string("user://boss_records_validation/"+second+".json"))
 check(archived.recording.result=="中止" and FileAccess.file_exists(path),"return to door archives sample and preserves prior run")
 if exists:FileAccess.open(cfg_path,FileAccess.WRITE).store_buffer(backup)
 else:DirAccess.remove_absolute(ProjectSettings.globalize_path(cfg_path))
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/recording226-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size()},"\t"))
 print("RECORDING226_RESULT ",checks.size()," checks ",failures.size()," failures");quit(0 if failures.is_empty() else 1)

func click_record() -> void:
 var at=w.console226.record_button.get_global_rect().get_center()
 for pressed in [true,false]:
  var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.position=at;event.global_position=at;event.pressed=pressed;root.push_input(event,true)
  await process_frame
