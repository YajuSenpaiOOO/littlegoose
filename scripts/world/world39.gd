extends "res://scripts/world/camera39.gd"
var buffs=preload("res://scripts/combat/buff_book39.gd").new()
var draft_ui: Control
var draft_open := false
var draft_choices: Array[Dictionary]=[]
var reward_offered := false
var charge_active := false
var charge_age := 0.
var charge_ready := false
var fire_needs_release := false
var draft_input_at := 0.
var buff39_ready := false
var releasing_charge := false

func _ready() -> void:
	cup_phone_enabled=false
	super._ready()
	while not encounter37_ready: await get_tree().physics_frame
	var layer := CanvasLayer.new()
	layer.layer=16; layer.name="MemoryDraft39"
	add_child(layer)
	draft_ui=preload("res://scripts/combat/draft39.gd").new()
	draft_ui.battle=self
	layer.add_child(draft_ui)
	_apply_owned_buffs()
	buff39_ready=true
	_title35()
	print("WORLD39_MEMORY_DRAFT_READY")

func _apply_owned_buffs() -> void:
	set_cup_phone(buffs.level("cup_phone")>0)

func start_combat(reposition := true) -> void:
	var preserve_motion: bool=not reposition and is_instance_valid(hero) and wave_state=="waiting" and hero.controls_enabled
	var walk_velocity: Vector3=hero.velocity if is_instance_valid(hero) else Vector3.ZERO
	var walk_motion: Vector2=hero.locomotion if is_instance_valid(hero) else Vector2.ZERO
	draft_open=false; draft_choices.clear(); reward_offered=false
	_cancel_charge()
	if is_instance_valid(draft_ui): draft_ui.close()
	super.start_combat(reposition)
	# Walking across the encounter boundary must not apply the trial restart's
	# forced braking; that pause reads as a camera hitch even with smooth FOV.
	if preserve_motion:
		hero.velocity=walk_velocity; hero.locomotion=walk_motion
	_apply_owned_buffs()
	fire_needs_release=fire_input_held()

func new_run() -> void:
	buffs.levels.clear()
	start_combat()

func _leave_encounter() -> void:
	draft_open=false; draft_choices.clear()
	_cancel_charge()
	if is_instance_valid(draft_ui): draft_ui.close()
	super._leave_encounter()

func _process(delta: float) -> void:
	super._process(delta)
	if not buff39_ready: return
	if result_open and wave_state=="cleared" and not reward_offered:
		reward_offered=true
		draft_choices=buffs.eligible()
		if not draft_choices.is_empty(): _open_draft()
		else:
			encounter_hud.result_title.text="回忆已收集齐了"
			encounter_hud.result_stats.text+="\nF5 保留碎片继续试战 · F8 新的一局"

func _open_draft() -> void:
	draft_open=true; combat_paused=true
	draft_input_at=Time.get_ticks_msec()/1000.+.25
	_cancel_charge(); _clear_combat_shots()
	encounter_hud.result.hide()
	draft_ui.open(draft_choices)

func battle_hud_visible() -> bool:
	return not draft_open and super.battle_hud_visible()

func draft_message() -> String:
	return "林地清场 · 弹反 %d / 完美闪避 %d\n选择一张，带进下一场战斗"%[parry_count,perfect_dodges]

func choose_buff(index: int) -> bool:
	if not draft_open or Time.get_ticks_msec()/1000.<draft_input_at or index<0 or index>=draft_choices.size(): return false
	var card: Dictionary=draft_choices[index]
	if not buffs.apply(str(card.id)): return false
	draft_open=false; combat_paused=false
	Audio.play("pick")
	_continue_after_buff(card)
	return true

func _continue_after_buff(card: Dictionary) -> void:
	start_combat()
	encounter_hud.announce(str(card.name),str(card.line),2.)

func attack_cooldown() -> float:
	return super.attack_cooldown()/buffs.rate()

func charge_time() -> float:
	return .72/buffs.rate()*(.85 if buffs.level("slingshot")>=2 else 1.)

func charge_ratio() -> float:
	return clampf(charge_age/charge_time(),0.,1.) if charge_active else 0.

func _cancel_charge() -> void:
	charge_active=false; charge_age=0.; charge_ready=false
	if is_instance_valid(goose) and is_instance_valid(goose.visual): goose.visual.modulate=Color.WHITE

func _step_fire_input(delta: float) -> void:
	var held := fire_input_held()
	if not held: fire_needs_release=false
	if wave_state!="fighting" or result_open or between_left>0. or player_hp<=0. or fire_needs_release:
		_cancel_charge(); return
	if buffs.level("slingshot")==0:
		super._step_fire_input(delta)
		return
	if held:
		if not charge_active and cooldown<=0.:
			charge_active=true; charge_age=0.; charge_ready=false
			Audio.play("charge")
		if charge_active:
			charge_age+=delta
			if charge_ratio()>=1. and not charge_ready: charge_ready=true; Audio.play("pick")
	elif charge_active:
		_release_charged(aim_at_screen(get_viewport().get_mouse_position()),maxf(.05,charge_ratio()))
		_cancel_charge(); cooldown=.25

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_instance_valid(goose) and charge_active:
		goose.visual.modulate=Color.WHITE.lerp(Color(1.,.25,.25),charge_ratio())

func _release_charged(target: Vector3,ratio: float) -> void:
	var before := shots.size()
	releasing_charge=true
	super.fire_at(target)
	releasing_charge=false
	if shots.size()==before: return
	var shot: Dictionary=shots[-1]
	shot.charged=true; shot.hit_rids=[]
	shot.damage_multiplier=1.+(11.+2.*float(buffs.level("slingshot")-1))*ratio
	shot.velocity=shot.velocity.normalized()*((320.+430.*ratio)/Profile.PPM)
	shot.life=1.2
	shot.shadow.mesh.size=Vector2(.28,.18)*lerpf(1.2,2.2,ratio)
	if shot.has("art") and is_instance_valid(shot.art): shot.art.scale_gain=lerpf(1.2,2.2,ratio)
	Audio.play("slingshot"); hitstop(.06,true)
	trauma=minf(1.,trauma+.18); punch=maxf(punch,.22)
	goose.spring_velocity-=Vector2(shot.velocity.x,shot.velocity.z).normalized()*Profile.RECOIL*1.2

func weapon_spread_radians() -> float:
	return 0. if releasing_charge else super.weapon_spread_radians()

func _step_shots(delta: float) -> void:
	if buffs.level("eye_exercise")>0:
		for shot in shots: _steer_shot(shot,delta)
	super._step_shots(delta)

func _steer_shot(shot: Dictionary,delta: float) -> void:
	var at: Vector3=shot.node.position
	var forward := Vector2(shot.velocity.x,shot.velocity.z)
	if forward.length_squared()<.0001: return
	var chosen: CharacterBody3D
	var closest := 240./Profile.PPM
	var cone := 1.4 if buffs.level("eye_exercise")==1 else 1.9
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.dead: continue
		if enemy.hit_area.get_rid() in shot.get("hit_rids",[]): continue
		var toward := Vector2(enemy.position.x-at.x,enemy.position.z-at.z)
		if toward.length()>=closest or absf(forward.angle_to(toward))>=cone: continue
		chosen=enemy; closest=toward.length()
	if not is_instance_valid(chosen): return
	var desired := (chosen.position+Vector3.UP*.65-at).normalized()
	var rate := 2.5 if buffs.level("eye_exercise")==1 else 4.
	var turn := clampf(forward.angle_to(Vector2(desired.x,desired.z)),-rate*delta,rate*delta)
	var flat := forward.normalized().rotated(turn)
	var speed: float=shot.velocity.length()
	var vy: float=lerpf(shot.velocity.y,desired.y*speed,minf(1.,rate*delta))
	shot.velocity=Vector3(flat.x*sqrt(maxf(0.,speed*speed-vy*vy)),vy,flat.y*sqrt(maxf(0.,speed*speed-vy*vy)))

func _trace_shot(shot: Dictionary,start: Vector3,end: Vector3) -> Dictionary:
	if not shot.get("charged",false): return super._trace_shot(shot,start,end)
	var excluded: Array[RID]=[hero.get_rid()]
	for rid: RID in shot.hit_rids: excluded.append(rid)
	for i in 16:
		var query := PhysicsRayQueryParameters3D.create(start,end,1|2|8,excluded)
		query.collide_with_areas=true; query.hit_from_inside=true
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty() or not hit.collider.has_meta("enemy"): return hit
		var rid: RID=hit.collider.get_rid()
		excluded.append(rid); shot.hit_rids.append(rid)
		_apply_shot_hit(shot,hit)
	return {}

func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
	super._apply_shot_hit(shot,hit)
	if shot.get("charged",false) and hit.collider.has_meta("enemy"):
		var enemy: CharacterBody3D=hit.collider.get_meta("enemy")
		if is_instance_valid(enemy): enemy.impulse=(enemy.impulse*2.4).limit_length(Profile.KNOCK_MAX*2.4)

func _shot_expired(shot: Dictionary) -> void:
	if not shot.get("charged",false) or shot.get("hit_rids",[]).is_empty(): super._shot_expired(shot)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_F8: new_run(); return
		if draft_open:
			if event.physical_keycode in [KEY_1,KEY_2,KEY_3]: choose_buff(event.physical_keycode-KEY_1)
			return
		if event.physical_keycode==KEY_BACKSPACE and buffs.level("cup_phone")==0: return
	super._unhandled_input(event)

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 记忆碎片39 · F5 本场重试 / F8 新的一局")

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界38","连续世界39")
