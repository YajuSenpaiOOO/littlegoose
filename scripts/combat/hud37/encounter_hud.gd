extends Control
const Art = preload("res://scripts/combat/hud37/ui_art.gd")
const Gems = preload("res://scripts/combat/hud37/gems_bar.gd")
const ROSE := Color(.98,.77,.82)
const GOLD := Color(1.,.87,.51)
const BLUE := Color(.65,.90,1.)
var battle: Node3D
var gems: Control
var header: Label
var health_text: Label
var action_text: Label
var feedback_text: Label
var combo_text: Label
var footer: Label
var notice: Label
var notice_sub: Label
var mode_label: Label
var result: PanelContainer
var result_title: Label
var result_stats: Label
var retry: Button
var leave: Button
var notice_until := -1.
var response_until := -1.
var response_color := GOLD
var response_start := -1.
var fills := Vector2.ONE
var ready_pop := Vector2.ZERO

func _label(font_size: int,color := Color(.96,.93,.86)) -> Label:
	var node := Label.new()
	node.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	node.add_theme_font_size_override("font_size",font_size)
	node.add_theme_color_override("font_color",color)
	node.add_theme_color_override("font_outline_color",Color(.09,.13,.11,.85))
	node.add_theme_constant_override("outline_size",4)
	node.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(node)
	return node

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var ink := ShaderMaterial.new()
	ink.shader=preload("res://scripts/combat/hud37/gem_tint.gdshader")
	material=ink
	header=_label(16)
	gems=Gems.new(); gems.setup(5,180.)
	gems.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(gems)
	health_text=_label(13,ROSE)
	action_text=_label(13)
	feedback_text=_label(18)
	combo_text=_label(25,GOLD)
	footer=_label(14,Color(.94,.92,.84,.82))
	notice=_label(28); notice_sub=_label(16)
	mode_label=_label(13,Color(.94,.92,.84,.8))
	_build_result()
	reset_round()

func _build_result() -> void:
	result=PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color=Color(.055,.085,.075,.94)
	style.border_color=Color(.88,.82,.64,.38)
	style.set_border_width_all(1); style.set_corner_radius_all(10)
	style.content_margin_left=32.; style.content_margin_right=32.
	style.content_margin_top=26.; style.content_margin_bottom=26.
	result.add_theme_stylebox_override("panel",style)
	add_child(result)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",16)
	result.add_child(stack)
	result_title=Label.new(); result_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	result_title.add_theme_font_size_override("font_size",28)
	result_title.add_theme_color_override("font_color",Color(.98,.91,.74))
	stack.add_child(result_title)
	result_stats=Label.new(); result_stats.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	result_stats.add_theme_font_size_override("font_size",17)
	result_stats.add_theme_color_override("font_color",Color(.87,.89,.83))
	stack.add_child(result_stats)
	var buttons := HBoxContainer.new()
	buttons.alignment=BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation",16)
	stack.add_child(buttons)
	retry=Button.new(); retry.text="再试一次 · F5"
	retry.custom_minimum_size=Vector2(158,40); retry.focus_mode=Control.FOCUS_NONE
	retry.pressed.connect(func() -> void: battle.start_combat())
	buttons.add_child(retry)
	leave=Button.new(); leave.custom_minimum_size=Vector2(130,40); leave.focus_mode=Control.FOCUS_NONE
	leave.pressed.connect(battle.continue_exploring)
	buttons.add_child(leave)

func reset_round() -> void:
	result.hide(); notice_until=-1.; response_until=-1.; response_start=-1.
	fills=Vector2.ONE; ready_pop=Vector2.ZERO
	gems._initialized=false; gems._fragments.clear(); gems._breaking.clear()
	gems._shake_t=0.; gems._off=Vector2.ZERO
	gems.set_value(battle.player_hp,100.)

func announce(title: String,detail: String,hold := 2.) -> void:
	notice.text=title; notice_sub.text=detail
	notice_until=Time.get_ticks_msec()/1000.+hold

func respond(text: String,color: Color) -> void:
	feedback_text.text=text; feedback_text.add_theme_color_override("font_color",color)
	response_color=color; response_start=Time.get_ticks_msec()/1000.; response_until=response_start+.65

func hurt(amount: float) -> void:
	gems.hit_shake(amount/20.)
	respond("受击 −%d"%roundi(amount),ROSE)

func show_result() -> void:
	var cleared: bool=battle.wave_state=="cleared"
	notice_until=-1.
	# The old draining animation uses gameplay time and can lag behind a death
	# slow-motion beat. The settled result must show the actual remaining HP.
	gems.displayed=battle.player_hp; gems._breaking.clear(); gems.queue_redraw()
	result_title.text="林间又安静了" if cleared else "歇一歇，再来一次"
	result_stats.text="击倒 %d / 6    ·    用时 %.1f 秒\n弹反 %d    ·    完美闪避 %d\n最长连击 ×%d    ·    受击 %d 次\n射击命中 %d / %d"%[battle.defeated_count,battle.encounter_elapsed,battle.parry_count,battle.perfect_dodges,battle.max_combo,battle.hurt_count,battle.landed_hits,battle.fired_count]
	leave.text="继续探索" if cleared else "回小院"
	result.show()

func dismiss_result() -> void:
	result.hide(); notice_until=-1.; response_until=-1.

func _place(node: Control,at: Vector2,extent: Vector2) -> void:
	node.position=at; node.size=extent

func _process(delta: float) -> void:
	if not is_instance_valid(battle.hero): return
	var now := Time.get_ticks_msec()/1000.
	var screen := get_viewport_rect().size
	var middle := screen.x*.5
	var active: bool=battle.battle_hud_visible()
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
	var state: String="林地 · 第 %d / 3 %s"%[battle.round_index+1,battle.wave_unit()]+battle.wave_progress()
	if battle.between_left>0.: state="喘口气 · 下一%s %d 只"%[battle.wave_unit(),battle.round_index+2]
	if battle.wave_state=="cleared": state="林地 · 已清场"
	elif battle.wave_state=="defeated": state="林地 · 暂时倒下"
	if battle.combat_paused: state="已暂停 · F7 继续"
	header.text=state
	health_text.text="生命 %d / 100"%roundi(battle.player_hp)
	action_text.text="Shift 闪避               右键 弹反"
	combo_text.text="×%d 连击"%battle.combo if battle.combo>=3 else ""
	footer.text="WASD 移动   ·   左键射击   ·   滚轮缩放   ·   F5 重试   ·   F7 暂停"
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

func _draw() -> void:
	if not is_instance_valid(battle.hero): return
	var screen := get_viewport_rect().size
	var middle := screen.x*.5
	# Same old atlas and blue/gold language, with bottom-up recharge.
	for i in 2:
		var center := Vector2(middle-65.+float(i)*130.,93)
		Art.draw_gem(self,Rect2(center-Vector2(11,11),Vector2(22,22)),fills[i],BLUE if i==0 else GOLD,true)
		if ready_pop[i]>0.:
			draw_arc(center,14.+4.*(1.-ready_pop[i]),0.,TAU,20,Color(BLUE if i==0 else GOLD,ready_pop[i]*.6),1.,true)
	# Old gold pulse / hurt frame, kept light and away from the aim point.
	var now := Time.get_ticks_msec()/1000.
	var flash := clampf((response_start+.35-now)/.35,0.,1.)
	if flash>0.:
		var tint := Color(response_color,flash*.7)
		for x in [12.,screen.x-12.]:
			var direction := 1. if x<screen.x*.5 else -1.
			draw_line(Vector2(x,12),Vector2(x+direction*75.,12),tint,2.)
			draw_line(Vector2(x,12),Vector2(x,55),tint,2.)
