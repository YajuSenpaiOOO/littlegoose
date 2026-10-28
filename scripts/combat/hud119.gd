extends "res://scripts/combat/hud109.gd"
# Avoid two text reshapes per frame from the historical 3-wave/held-guard overrides.
func _place(node: Control,at: Vector2,extent: Vector2) -> void:
	if node.position!=at: node.position=at
	if node.size!=extent: node.size=extent

func _process(delta: float) -> void:
	if not is_instance_valid(battle.hero): return
	var now := Time.get_ticks_msec()/1000.
	var screen := get_viewport_rect().size
	var middle := screen.x*.5
	var active: bool=battle.active114
	visible=active
	if not active: return
	gems.set_value(battle.player_hp,100.)
	gems.warning=battle.player_hp>0. and battle.player_hp<=20.
	if not gems.warning: gems.modulate.a=1.
	var next_fills := Vector2(1.-clampf(battle.hero.dash_cd/.55,0.,1.),1.-clampf(battle.hero.parry_cd,0.,1.))
	for i in 2:
		if next_fills[i]>=1. and fills[i]<1.: ready_pop[i]=1.
		ready_pop[i]=maxf(0.,ready_pop[i]-delta*3.)
	fills=next_fills
	var state: String="林间约玩 · "+("伙伴正赶来" if battle.notice119>=0. else "和团团玩一会儿")
	if battle.combat_paused: state="已暂停 · F7 继续"
	header.text=state
	health_text.text="生命 %d / 100"%roundi(battle.player_hp)
	action_text.text="抱头蹲防 · 减伤40% · 松开后开始冷却" if battle.hero.guarding109 else "Shift 闪避     右键按住蹲防 · 按下瞬间弹反"
	if battle.hero.guarding109: fills.y=1. if battle.hero.can_parry() else .20;ready_pop.y=0.
	combo_text.text="×%d 连击"%battle.combo if battle.combo>=3 else ""
	footer.text="WASD 移动 · 左键射击 · F3 回小院 · F5 邀请团团 · Esc 先休息"
	if result.visible:
		combo_text.text=""
		footer.text="F5 再试一次   ·   Esc "+("继续探索" if battle.wave_state=="cleared" else "回小院")
	mode_label.text="纸杯电话 · 自由飞行" if battle.cup_phone_enabled else "小黑鹅 · 贴身跟随"
	_place(header,Vector2(middle-200,10),Vector2(400,24))
	_place(gems,Vector2(middle-90,35),Vector2(180,44))
	_place(health_text,Vector2(middle+99,47),Vector2(110,24))
	_place(action_text,Vector2(middle-160,108),Vector2(320,23))
	_place(feedback_text,Vector2(middle-160,139),Vector2(320,28))
	_place(combo_text,Vector2(screen.x-230,32),Vector2(200,42))
	_place(mode_label,Vector2(20,20),Vector2(190,24))
	_place(footer,Vector2(20,screen.y-34),Vector2(screen.x-40,24))
	_place(notice,Vector2(middle-300,screen.y*.18),Vector2(600,44))
	_place(notice_sub,Vector2(middle-300,screen.y*.18+48),Vector2(600,28))
	var notice_alpha := clampf((notice_until-now)/.4,0.,1.)
	notice.modulate.a=notice_alpha; notice_sub.modulate.a=notice_alpha
	feedback_text.modulate.a=clampf((response_until-now)/.25,0.,1.)
	if result.visible:
		result.size=Vector2(450,0)
		result.position=Vector2(middle-result.size.x*.5,screen.y*.56)
	queue_redraw()
