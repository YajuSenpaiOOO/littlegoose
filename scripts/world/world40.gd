extends "res://scripts/world/world39.gd"
var wave_reward_pending := false
var wave_reward_at := -1.

func _wave_return_radius40() -> float: return 21.

# Restore the full pre-portrait camera policy from world37, including resets.
func _base_zoom_delta() -> float:
	return LEGACY_BATTLE_ZOOM if wave_state=="fighting" else 0.
func _framing_gain(_delta: float) -> float:
	return (LEGACY_BASE_ZOOM+_base_zoom_delta())/LEGACY_BASE_ZOOM
func _preserve_framing_on_reset() -> bool: return false

func start_combat(reposition := true) -> void:
	wave_reward_pending=false; wave_reward_at=-1.
	super.start_combat(reposition)
	if is_instance_valid(encounter_hud): encounter_hud.announce("林地相遇","第一波 · 清完本波即选卡")
	print("WAVE40_START wave=1 owned=",buffs.summary())

func _ready() -> void:
	super._ready()
	while not buff39_ready: await get_tree().physics_frame
	print("WORLD40_EVERY_WAVE_DRAFT_READY")

func wave_unit() -> String: return "波"
func wave_progress() -> String:
	if wave_state!="fighting" or between_left>0. or result_open: return ""
	var remaining := 0
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.dead: remaining+=1
	return " · 剩 %d 只"%remaining

func enemy_defeated(enemy: CharacterBody3D) -> void:
	super.enemy_defeated(enemy)
	if wave_state=="cleared":
		print("WAVE40_CLEAR wave=",round_index+1," total=",defeated_count)
		return
	if wave_state!="fighting" or between_left<=0.: return
	wave_reward_pending=true
	wave_reward_at=Time.get_ticks_msec()/1000.+.55
	result_open=true
	encounter_hud.announce("本波清完","挑一片回忆，再继续",.55)
	print("WAVE40_CLEAR wave=",round_index+1," total=",defeated_count)

func _advance_breather(delta: float) -> void:
	if not wave_reward_pending: super._advance_breather(delta)

func _can_auto_leave_encounter() -> bool:
	# A cleared wave has already earned its reward. Walking beyond the trial
	# radius during the short finish beat must not silently cancel that reward.
	if wave_reward_pending or (wave_state=="cleared" and not result_dismissed): return false
	return super._can_auto_leave_encounter()

func _process(delta: float) -> void:
	super._process(delta)
	if not buff39_ready or not wave_reward_pending or draft_open or combat_paused: return
	if Time.get_ticks_msec()/1000.<wave_reward_at: return
	draft_choices=buffs.eligible()
	if draft_choices.is_empty(): _resume_wave()
	else:
		hero.controls_enabled=false; hero.locomotion=Vector2.ZERO; hero.combat_impulse=Vector2.ZERO
		hero.velocity.x=0.; hero.velocity.z=0.
		_open_draft()

func _open_draft() -> void:
	super._open_draft()
	print("WAVE40_DRAFT_OPEN wave=",round_index+1," cards=",draft_choices.size())

func draft_message() -> String:
	if wave_reward_pending:
		return "第 %d / 3 波清完 · 选择一张，进入下一波\n生命和本场统计继续保留"%(round_index+1)
	return "第三波清完 · 选择一张，带进下一场战斗"

func _continue_after_buff(card: Dictionary) -> void:
	print("WAVE40_PICK wave=",round_index+1," id=",card.id," level=",buffs.level(str(card.id)))
	if wave_reward_pending:
		_resume_wave()
		encounter_hud.announce(str(card.name),str(card.line),1.8)
	else: super._continue_after_buff(card)

func _resume_wave() -> void:
	wave_reward_pending=false; wave_reward_at=-1.
	draft_open=false; draft_choices.clear(); combat_paused=false
	result_open=false; result_at=-1.; result_dismissed=false
	draft_ui.close(); _cancel_charge(); _apply_owned_buffs()
	hero.controls_enabled=true; hero.combat_impulse=Vector2.ZERO
	cooldown=0.; fire_needs_release=fire_input_held()
	var center: Vector2=meadow.landmarks.grove
	if Vector2(hero.position.x,hero.position.z).distance_to(center)>_wave_return_radius40():
		_teleport15(center+Vector2(0,2.))
	_spawn_next_round()
	print("WAVE40_START wave=",round_index+1," owned=",buffs.summary())

func _spawn_next_round() -> void:
	super._spawn_next_round()
	encounter_hud.announce("第二波" if round_index==1 else "最后一波","清完本波即选卡",1.6)

func _leave_encounter() -> void:
	wave_reward_pending=false; wave_reward_at=-1.
	super._leave_encounter()

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 每波选卡40 · 原版镜头 · F5 重试 / F8 新局")

func _unhandled_input(event: InputEvent) -> void:
	if wave_reward_pending and not draft_open and event is InputEventKey and event.pressed and event.physical_keycode!=KEY_F8: return
	super._unhandled_input(event)

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界39","连续世界40")
