extends "res://scripts/ground_lab_probe.gd"
class Sample:
	extends "res://scripts/world/world39.gd"
	var held := false
	func fire_input_held() -> bool: return held

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.buff39_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.start_combat()
	sample.set_physics_process(false); sample.hero.set_physics_process(false)
	for enemy in sample.enemies: enemy.set_physics_process(false)
	sample.wave_state="cleared"; sample.result_at=Time.get_ticks_msec()/1000.-1.
	sample._process(1./60.)
	var until := Time.get_ticks_msec()+600
	while Time.get_ticks_msec()<until: await process_frame
	verify(sample.draft_open and sample.draft_ui.panels.size()==3,"layout fixture opens three old-style cards")
	var contained := true
	var opaque := true
	for panel in sample.draft_ui.panels:
		opaque=opaque and panel.modulate.a>.99
		for child in panel.get_children():
			if child is Label:
				contained=contained and child.position.x>=0. and child.position.y>=0. and child.position.x+child.size.x<=270.1 and child.position.y+child.size.y<=360.1
	verify(contained,"all wrapped descriptions and labels fit within their card bounds")
	verify(opaque,"the card entrance finishes at full readable opacity")
	verify(not sample.encounter_hud.visible,"combat HUD is hidden while the reward is being read")
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/buffs39_draft_layout.png")
	sample.held=true
	# Real UI signal: selected card starts a new encounter with that upgrade.
	sample.draft_ui.panels[0].pressed.emit()
	verify(sample.buffs.level("slingshot")==1 and not sample.draft_open,"clicking the visible first card resumes with its granted ability")
	sample._step_fire_input(.4)
	verify(sample.fire_needs_release and not sample.charge_active and sample.shots.is_empty(),"selecting while fire is held requires release before combat input resumes")
	print("DRAFT39_LAYOUT ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
