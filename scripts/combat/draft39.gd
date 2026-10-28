extends Control
var battle: Node3D
var veil: ColorRect
var heading: Label
var subtitle: Label
var hint: Label
var owned: Label
var panels: Array[Button]=[]
var choices: Array[Dictionary]=[]
var card_style: StyleBoxTexture

func _label(parent: Node,text: String,point_size: int,color: Color) -> Label:
	var node := Label.new()
	node.clip_text=true
	node.size=Vector2(220,28)
	node.text=text; node.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	node.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	node.add_theme_font_size_override("font_size",point_size)
	node.add_theme_color_override("font_color",color)
	node.mouse_filter=Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	var texture := AtlasTexture.new()
	texture.atlas=load("res://assets/buffs39/card_v1.png")
	texture.region=Rect2(50,55,990,1340); texture.filter_clip=true
	card_style=StyleBoxTexture.new(); card_style.texture=texture
	owned=_label(self,"",13,Color(.96,.91,.79))
	owned.add_theme_color_override("font_outline_color",Color(.1,.13,.1,.9))
	owned.add_theme_constant_override("outline_size",4)
	veil=ColorRect.new(); veil.color=Color(.035,.055,.045,.55)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter=Control.MOUSE_FILTER_STOP
	add_child(veil)
	heading=_label(self,"留下一片回忆",30,Color(1.,.93,.80))
	subtitle=_label(self,"",17,Color(.91,.90,.82))
	hint=_label(self,"点击卡片，或按对应数字选择 · F8 开始新的一局",15,Color(.91,.88,.78))
	close()

func open(cards: Array[Dictionary]) -> void:
	close(); choices=cards.duplicate(true)
	veil.show(); heading.show(); subtitle.show(); hint.show()
	subtitle.text=battle.draft_message()
	for i in cards.size():
		var card: Dictionary=cards[i]
		var panel := Button.new()
		panel.name="MemoryChoice%d"%(i+1)
		for state in ["normal","hover","pressed","focus"]: panel.add_theme_stylebox_override(state,card_style)
		panel.focus_mode=Control.FOCUS_NONE
		panel.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		panel.size=Vector2(270,360)
		panel.pressed.connect(battle.choose_buff.bind(i))
		panel.mouse_entered.connect(func() -> void: panel.self_modulate=Color(1.06,1.04,1.02))
		panel.mouse_exited.connect(func() -> void: panel.self_modulate=Color.WHITE)
		add_child(panel); panels.append(panel)
		var ordinal := _label(panel,str(i+1),17,Color("986777"))
		ordinal.position=Vector2(0,43); ordinal.size=Vector2(270,28)
		var title := _label(panel,str(card.name),22,Color("684557"))
		title.position=Vector2(22,82); title.size=Vector2(226,61)
		var rule := ColorRect.new(); rule.color=Color("d1a381")
		rule.position=Vector2(115,153); rule.size=Vector2(40,2)
		rule.mouse_filter=Control.MOUSE_FILTER_IGNORE; panel.add_child(rule)
		var description := _label(panel,str(card.desc)+"\n\n"+battle.buffs.description(card),15,Color("58485e"))
		description.position=Vector2(28,170); description.size=Vector2(214,135)
		description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		var level: int=battle.buffs.level(str(card.id))
		var status := _label(panel,"首次获得" if level==0 else "升级至 Ⅱ",13,Color("986777"))
		status.position=Vector2(25,311); status.size=Vector2(220,25)
		panel.modulate.a=0.
		var tween := panel.create_tween()
		tween.tween_interval(float(i)*.06)
		tween.tween_property(panel,"modulate:a",1.,.20)
	_layout()

func close() -> void:
	for panel in panels:
		remove_child(panel); panel.queue_free()
	panels.clear(); choices.clear()
	if is_instance_valid(veil): veil.hide(); heading.hide(); subtitle.hide(); hint.hide()

func _layout() -> void:
	var screen := get_viewport_rect().size
	var width := float(panels.size())*270.+float(maxi(0,panels.size()-1))*24.
	var factor := minf(1.,minf((screen.x-70.)/maxf(1.,width),(screen.y-230.)/360.))
	for i in panels.size():
		panels[i].scale=Vector2.ONE*factor
		panels[i].position=Vector2((screen.x-width*factor)*.5+float(i)*294.*factor,(screen.y-360.*factor)*.5+18.)
	heading.position=Vector2(20,screen.y*.12); heading.size=Vector2(screen.x-40,50)
	subtitle.position=Vector2(20,screen.y*.12+54); subtitle.size=Vector2(screen.x-40,66)
	hint.position=Vector2(20,screen.y*.84); hint.size=Vector2(screen.x-40,38)
	owned.position=Vector2(22,screen.y-70.); owned.size=Vector2(screen.x-44,25)

func _process(_delta: float) -> void:
	_layout()
	owned.text=battle.buffs.summary()
	owned.visible=not owned.text.is_empty() and not battle.draft_open
	queue_redraw()

func _draw() -> void:
	if battle.draft_open or not battle.charge_active or not is_instance_valid(battle.goose): return
	var at: Vector3=battle.goose.muzzle()
	if battle.camera.is_position_behind(at): return
	var center: Vector2=battle.camera.unproject_position(at)+Vector2(-12,-16)
	var ratio: float=battle.charge_ratio()
	draw_arc(center,7.,0.,TAU,24,Color(1.,.9,.8,.25),1.2,true)
	draw_arc(center,7.,-PI*.5,-PI*.5+TAU*ratio,24,Color(1.,.84,.4) if ratio>=1. else Color(1.,.48,.43),1.8,true)
