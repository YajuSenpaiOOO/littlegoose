extends "res://scripts/world/world33.gd"
const ParryImpact = preload("res://scripts/combat/legacy/parry_impact.gd")
var show_attack_cue := false
var parry_ready := false
var parry_count := 0
var parry_chain := 0
var parry_chain_last := -10.
var parry_last_tier := 0
var parry_tier_beats := 0
var reflected_fans := 0

func _hero_script() -> Script: return preload("res://scripts/combat/hero34.gd")
func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan34.gd") if legacy_feel else super._enemy_script()

func _ready() -> void:
	super._ready()
	while not encounter_ready: await get_tree().physics_frame
	ParryImpact._load_frames()
	var meter := preload("res://scripts/combat/parry_meter34.gd").new()
	meter.battle=self
	battle_label.get_parent().add_child(meter)
	parry_ready=true
	_title34()
	print("WORLD34_PARRY_READY")

func try_parry_lunge(enemy: CharacterBody3D,before: Vector3) -> bool:
	if not hero.can_parry() or enemy.attack_phase!="lunge" or enemy.attack_connected: return false
	var t: float=aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(enemy.global_position.x,enemy.global_position.z),Vector2(hero.global_position.x,hero.global_position.z),hero.PARRY_REACH)
	if t==INF or absf(enemy.global_position.y-hero.global_position.y)>1.: return false
	var contact: Vector3=hero.global_position.lerp(enemy.global_position,.5)+Vector3.UP*.65
	enemy.deflect(contact)
	return true

func heavy_parry_feedback() -> bool:
	return false

func parry_success(contact: Vector3,outward: Vector3) -> void:
	if combat_paused or player_hp<=0.: return
	hero.consume_parry(); parry_count+=1
	var now := Time.get_ticks_msec()/1000.
	if now-parry_chain_last<1.2: parry_chain+=1
	else: parry_chain=1; parry_last_tier=0
	parry_chain_last=now
	var tier := mini(parry_chain,3)
	var tier_up := tier!=parry_last_tier
	parry_last_tier=tier
	if tier_up:
		parry_tier_beats+=1
		hitstop([0.,.09,.12,.14][tier],true)
		punch=maxf(punch,[0.,.6,.75,1.][tier]); trauma=minf(1.,trauma+.4)
		impact_clock.cancel_pending("parry")
		impact_clock.add(.15 if tier==3 else .3,.35 if tier==3 else .22,.22 if tier==3 else .2,"parry")
	else: trauma=minf(1.,trauma+.12)
	var node := anchor(contact,.5)
	if node!=null:
		var origin: Vector3=hero.global_position+Vector3.UP*(10./Profile.PPM)
		var delta_screen: Vector2=camera.unproject_position(origin)-camera.unproject_position(contact)
		var gain: float=maxf(.001,node.scale.x)
		ParryImpact.spawn(node,node.global_position+delta_screen/gain,node.global_position,screen_direction(contact,outward),tier)
	combo+=1; max_combo=maxi(combo,max_combo); miss_streak=0; combo_last=now
	hp_shake_left=.25; hp_shake_amp=7.*(1.+.4*(tier-1) if tier_up else .6)
	var heavy_sound := heavy_parry_feedback() or (tier==3 and tier_up)
	Audio.play("parry_big" if heavy_sound else "parry",1. if heavy_sound else 1.+.12*(tier-1))
	if tier==3 and tier_up: _parry_fan34(contact)

func _parry_fan34(contact: Vector3) -> void:
	var aim := Vector3.FORWARD
	var closest := INF
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.dead: continue
		var distance: float=enemy.global_position.distance_to(contact)
		if distance<closest: closest=distance; aim=(enemy.global_position+Vector3.UP*.8-contact).normalized()
	for i in 3:
		var direction := aim.rotated(Vector3.UP,deg_to_rad(20.*(i-1)))
		var before := shots.size()
		super.fire_at(projectile_origin()+direction*3.)
		if shots.size()==before: continue
		var shot: Dictionary=shots[-1]
		shot.node.global_position=contact+direction*.08
		shot.velocity=direction*projectile_speed(); shot.damage_multiplier=1.5; shot.life=1.2
		if shot.has("art") and is_instance_valid(shot.art): shot.art.modulate=Color(1.,.85,.45)
	reflected_fans+=1

func _reset_impact_state() -> void:
	super._reset_impact_state()
	parry_count=0; parry_chain=0; parry_chain_last=-10.; parry_last_tier=0
	parry_tier_beats=0; reflected_fans=0

func _title34() -> void:
	DisplayServer.window_set_title("小白鹅 · 弹反34 · 右键弹反 · Delete 地面提示 "+("开" if show_attack_cue else "关"))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_DELETE:
		show_attack_cue=not show_attack_cue
		for enemy in enemies:
			if is_instance_valid(enemy) and enemy.has_method("set_cue_enabled"): enemy.set_cue_enabled(show_attack_cue)
		_title34()
		return
	super._unhandled_input(event)
	if event is InputEventKey and event.pressed and event.physical_keycode in [KEY_END,KEY_HOME,KEY_INSERT]: _title34()

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界33","连续世界34")
		var hint := "\n右键 弹反 · Delete 地面提示 · 动作读招默认无箭头"
		if not label.text.contains(hint): label.text+=hint
