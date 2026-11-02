extends "res://scripts/world/world36.gd"
const ROUND_OFFSETS := [
	[Vector2(0,-3.)],
	[Vector2(-4.,-2.),Vector2(4.,-3.)],
	[Vector2(-5.,-4.),Vector2(0,-5.),Vector2(5.,-3.)],
]
const ROUND_GAPS := [1.05,.90,.68]
const BREATHER := 2.2
var round_index := 0
var between_left := 0.
var encounter_elapsed := 0.
var result_at := -1.
var result_open := false
var result_dismissed := false
var last_attacker: WeakRef
var encounter_hud: Control
var encounter37_ready := false
var hud_tick37 := 0.
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/hud37/encounter_hud.gd")

func _ready() -> void:
	super._ready()
	while not parry_ready: await get_tree().physics_frame
	var layer := CanvasLayer.new()
	layer.name="EncounterHUD37"; layer.layer=15
	add_child(layer)
	encounter_hud=_encounter_hud_script37().new()
	encounter_hud.battle=self
	layer.add_child(encounter_hud)
	_hide_trial_hud()
	encounter37_ready=true
	if wave_state=="fighting": encounter_hud.announce("林地相遇", "第一轮 · 一只团团怪")
	_title35()
	print("WORLD37_COMPLETE_ENCOUNTER_READY")

func spawn_offsets() -> Array:
	return ROUND_OFFSETS[0].duplicate()

func _hide_trial_hud() -> void:
	health_track.hide(); battle_label.hide()
	if is_instance_valid(cup_chip): cup_chip.hide()
	for node in battle_label.get_parent().get_children():
		if node.get_script() in [preload("res://scripts/combat/dash_meter30.gd"),preload("res://scripts/combat/parry_meter34.gd")]: node.hide()

func battle_hud_visible() -> bool:
	return wave_state!="waiting" and not result_dismissed

func wave_unit() -> String: return "轮"
func wave_progress() -> String: return ""

func start_combat(reposition := true) -> void:
	round_index=0; between_left=0.; encounter_elapsed=0.
	result_at=-1.; result_open=false; result_dismissed=false; last_attacker=null
	super.start_combat(reposition)
	_prune_actor_shadows()
	# One continuous six-enemy encounter: only the final kill owns the old
	# end-of-wave closeup. Intermediate rounds never reset HP or combat stats.
	total_enemies=6
	for enemy in enemies: enemy.phase_clock=-.8
	if reposition:
		_teleport15(meadow.landmarks.grove+Vector2(0,2.))
		if is_instance_valid(goose): goose.update_follow(0.,aim_at_screen(get_viewport().get_mouse_position()),true)
	if is_instance_valid(encounter_hud):
		encounter_hud.reset_round()
		encounter_hud.announce("林地相遇","第一轮 · 一只团团怪")
	_title35()

func _spawn_next_round() -> void:
	if wave_state!="fighting" or player_hp<=0.: return
	round_index+=1; between_left=0.; last_attacker=null
	_clear_combat_shots()
	_prune_actor_shadows()
	for previous in enemies:
		if is_instance_valid(previous) and previous.dead: previous.hit_area.collision_layer=0
	var center: Vector2=meadow.landmarks.grove
	var offsets: Array=ROUND_OFFSETS[round_index]
	var occupied: Array[Vector2]=[]
	for i in offsets.size():
		var wanted: Vector2=center+offsets[i]
		var at := _safe_spawn(wanted,occupied)
		occupied.append(at)
		var enemy: CharacterBody3D=_enemy_script().new()
		enemy.name="Round%dTuantuan%d"%[round_index+1,i+1]
		enemy.battle=self; enemy.poses=combat_poses; enemy.textures=combat_textures
		enemy.home=center; enemy.rest=.8+float(i)*.18
		enemy.position=Vector3(at.x,floor_height(at)+.06,at.y)
		add_child(enemy); enemy.reset_physics_interpolation(); enemies.append(enemy)
		_add_actor_shadow(enemy,enemy.visual)
	next_attack33=combat_clock33+.8
	if is_instance_valid(encounter_hud):
		encounter_hud.announce("第二轮" if round_index==1 else "最后一轮","两只 · 轮流进攻" if round_index==1 else "三只 · 留意交错扑跳")

func _safe_spawn(wanted: Vector2,occupied: Array[Vector2]) -> Vector2:
	var player := Vector2(hero.position.x,hero.position.z)
	var best := Vector2.INF
	var score := INF
	# Use the baked walkable cells; never appear under the hero or stack bodies.
	for y in range(10,navigation.grid.region.size.y-10):
		for x in range(10,navigation.grid.region.size.x-10):
			var cell := Vector2i(x,y)
			if navigation.grid.is_point_solid(cell): continue
			var at: Vector2=navigation.origin+Vector2(cell)*navigation.CELL
			if at.distance_to(player)<3.5: continue
			var blocked := false
			for other in occupied:
				if at.distance_to(other)<1.2: blocked=true; break
			if blocked: continue
			var distance := at.distance_squared_to(wanted)
			if distance<score: score=distance; best=at
	if best.is_finite(): return best
	# The clearing has ample candidates; keep a valid baked cell as fallback.
	return navigation.origin+Vector2(navigation.nearest(wanted))*navigation.CELL

func reserve_attack(enemy: CharacterBody3D) -> bool:
	if combat_paused or wave_state!="fighting" or between_left>0. or combat_clock33<next_attack33: return false
	var busy := 0
	for other in enemies:
		if is_instance_valid(other) and not other.dead and other.attack_phase in ["windup","lunge"]: busy+=1
	if busy>=(2 if round_index==2 else 1): return false
	if last_attacker!=null and last_attacker.get_ref()==enemy:
		for other in enemies:
			if not is_instance_valid(other) or other==enemy or other.dead or not other.active_ai: continue
			if other.attack_phase=="approach" and not other.hopping and other.phase_clock>=0. and other.position.distance_to(hero.position)<4.6: return false
	last_attacker=weakref(enemy)
	next_attack33=combat_clock33+ROUND_GAPS[round_index]
	return true

func enemy_defeated(enemy: CharacterBody3D) -> void:
	super.enemy_defeated(enemy)
	if wave_state=="cleared":
		result_at=Time.get_ticks_msec()/1000.+1.25
		return
	for other in enemies:
		if is_instance_valid(other) and not other.dead: return
	between_left=BREATHER
	if is_instance_valid(encounter_hud): encounter_hud.announce("喘口气","下一轮 · %d 只团团怪"%(round_index+2),1.6)

func hurt_player(damage: float,from: Vector2) -> void:
	var before := player_hp
	super.hurt_player(damage,from)
	if player_hp>=before: return
	if is_instance_valid(encounter_hud): encounter_hud.hurt(before-player_hp)
	if player_hp<=0.: between_left=0.; result_at=Time.get_ticks_msec()/1000.+.8

func parry_success(contact: Vector3,outward: Vector3) -> void:
	var before := parry_count
	super.parry_success(contact,outward)
	if parry_count>before and is_instance_valid(encounter_hud): encounter_hud.respond("弹反",Color(1.,.87,.51))

func perfect_dodge() -> void:
	var before := perfect_dodges
	super.perfect_dodge()
	if perfect_dodges>before and is_instance_valid(encounter_hud): encounter_hud.respond("完美闪避",Color(.65,.90,1.))

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not combat_ready or combat_paused: return
	_advance_breather(delta)
	if wave_state in ["fighting","cleared"] and _can_auto_leave_encounter():
		var at := Vector2(hero.position.x,hero.position.z)
		if at.distance_to(meadow.landmarks.grove)>_encounter_leave_radius37(): _leave_encounter()

func _advance_breather(delta: float) -> void:
	if wave_state=="fighting" and between_left>0.:
		between_left=maxf(0.,between_left-delta)
		if between_left<=0.: _spawn_next_round()

func _can_auto_leave_encounter() -> bool:
	return not result_open

func _encounter_leave_radius37() -> float: return 22.

func _process(delta: float) -> void:
	super._process(delta)
	var now := Time.get_ticks_msec()/1000.
	if wave_state=="fighting" and not combat_paused and hud_tick37>0.: encounter_elapsed+=now-hud_tick37
	hud_tick37=now
	if result_at>=0. and now>=result_at and not result_open and not result_dismissed and not combat_paused:
		result_open=true
		hero.controls_enabled=false; hero.locomotion=Vector2.ZERO; hero.combat_impulse=Vector2.ZERO
		hero.velocity.x=0.; hero.velocity.z=0.
		_clear_combat_shots()
		if is_instance_valid(encounter_hud): encounter_hud.show_result()

func fire_at(target: Vector3) -> void:
	if result_open or wave_state!="fighting" or between_left>0.: return
	super.fire_at(target)

func continue_exploring() -> void:
	if wave_state=="defeated":
		_travel_region("home")
		return
	result_open=false; result_dismissed=true; result_at=-1.
	hero.controls_enabled=true
	if is_instance_valid(encounter_hud): encounter_hud.dismiss_result(); encounter_hud.hide()

func _leave_encounter() -> void:
	for enemy in enemies:
		if is_instance_valid(enemy): remove_child(enemy); enemy.queue_free()
	enemies.clear(); _clear_combat_shots(); _reset_impact_state()
	_prune_actor_shadows()
	wave_state="waiting"; between_left=0.; result_at=-1.; result_open=false; result_dismissed=false
	player_hp=max_player_health(); invulnerability=0.; hero.controls_enabled=true
	hero.combat_impulse=Vector2.ZERO; hero.locomotion=Vector2.ZERO
	if is_instance_valid(encounter_hud): encounter_hud.dismiss_result(); encounter_hud.hide()

func _prune_actor_shadows() -> void:
	for i in range(actor_shadows.size()-1,-1,-1):
		if not is_instance_valid(actor_shadows[i]) or not actor_shadows[i].is_inside_tree(): actor_shadows.remove_at(i)

func _travel_region(key: String) -> void:
	if combat_ready: _leave_encounter()
	super._travel_region(key)

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林地遭遇37 · 射击 / 闪避 / 弹反 · F5 重试")

func _unhandled_input(event: InputEvent) -> void:
	# F12 swaps in the pre-tactical enemy class. Keep that historical audition
	# in world36 rather than mixing it into the structured encounter lifecycle.
	if event is InputEventKey and event.pressed and event.physical_keycode==KEY_F12: return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F7:
		if result_open: return
		combat_paused=not combat_paused
		if combat_paused:
			impact_clock.clear(); stop_until=0.; stop_gate=0.; stop_duration=0.
		_status()
		return
	if event is InputEventKey and event.pressed and not event.echo and result_open:
		if event.physical_keycode==KEY_F7: return
		if event.physical_keycode==KEY_ESCAPE: continue_exploring(); return
	super._unhandled_input(event)

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界36","连续世界37")
