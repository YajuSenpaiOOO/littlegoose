extends Control
const PROFILE=preload("res://scripts/combat/balance_profile226.gd")
var world: Node3D
var draft := {}
var panel: PanelContainer
var capacity: Label
var feedback: Label
var detail: Label
var stats: Label
var cat_hp: SpinBox
var bat_hp: SpinBox
var rows := {}
var apply_button: Button
var restart_button: Button
var record_button: Button
var record_mode: OptionButton
func label226(words: String,size: int=17) -> Label:
 var node=Label.new();node.text=words;node.add_theme_font_size_override("font_size",size);node.add_theme_color_override("font_color",Color("efe4dc"));return node
func button226(words: String,action: Callable) -> Button:
 var node=Button.new();node.text=words;node.custom_minimum_size.y=36;node.pressed.connect(action);return node
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=Control.MOUSE_FILTER_STOP
 panel=PanelContainer.new();add_child(panel)
 var style=StyleBoxFlat.new();style.bg_color=Color(.105,.075,.13,.98);style.border_color=Color("b38da5");style.set_border_width_all(2);style.set_corner_radius_all(12)
 style.content_margin_left=20;style.content_margin_right=20;style.content_margin_top=16;style.content_margin_bottom=16;panel.add_theme_stylebox_override("panel",style)
 var column=VBoxContainer.new();column.add_theme_constant_override("separation",10);panel.add_child(column)
 var heading=HBoxContainer.new();column.add_child(heading)
 var title=label226("姐姐战 · 原地装配与统计",24);title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;heading.add_child(title)
 heading.add_child(button226("取消 / C",world.close_console226))
 column.add_child(label226("战斗已暂停 · 独立测试配置，不消耗碎片或改正式背包。",16))
 var presets=HBoxContainer.new();column.add_child(presets)
 for i in profile226().PRESETS.size():presets.add_child(button226(profile226().PRESETS[i].name,preset226.bind(i)))
 var middle=HBoxContainer.new();middle.size_flags_vertical=Control.SIZE_EXPAND_FILL;middle.add_theme_constant_override("separation",20);column.add_child(middle)
 var scroll=ScrollContainer.new();scroll.custom_minimum_size.x=450;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;middle.add_child(scroll)
 var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(list)
 for card in preload("res://scripts/combat/cards168.gd").POOL:
  var id: String=card.id
  if id in world.hidden_cards226():continue
  var row=HBoxContainer.new();list.add_child(row)
  var name_button=button226(str(card.name)+" · %d槽"%profile226().COSTS[id],focus226.bind(id));name_button.alignment=HORIZONTAL_ALIGNMENT_LEFT;name_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(name_button)
  var minus=button226("−",adjust226.bind(id,-1));row.add_child(minus)
  var count=label226("0");count.custom_minimum_size.x=22;count.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;row.add_child(count)
  var plus=button226("＋",adjust226.bind(id,1));row.add_child(plus)
  rows[id]={"count":count,"minus":minus,"plus":plus}
  if id in profile226().BLOCKED:plus.disabled=true;name_button.modulate=Color("9c849a")
 var right=VBoxContainer.new();right.size_flags_horizontal=Control.SIZE_EXPAND_FILL;right.custom_minimum_size.x=360;middle.add_child(right)
 capacity=label226("",23);right.add_child(capacity)
 detail=label226("点击碎片名称查看效果。",16);detail.custom_minimum_size.y=116;detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;right.add_child(detail)
 var hp_row=HBoxContainer.new();right.add_child(hp_row)
 hp_row.add_child(label226("下场猫血"));cat_hp=spin226(hp_row)
 hp_row.add_child(label226("蝙蝠血"));bat_hp=spin226(hp_row)
 right.add_child(label226("血量只在重开时应用；当前战斗保留血量与阶段。",14))
 var stats_scroll=ScrollContainer.new();stats_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;right.add_child(stats_scroll)
 stats=label226("",15);stats.size_flags_horizontal=Control.SIZE_EXPAND_FILL;stats.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;stats_scroll.add_child(stats)
 feedback=label226("",16);feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;column.add_child(feedback)
 var recording=HBoxContainer.new();column.add_child(recording)
 record_mode=OptionButton.new();record_mode.add_item("手打实战");record_mode.add_item("站桩对照（手动操作）");recording.add_child(record_mode)
 record_button=button226("开始记录 · 用草稿重开",record226);record_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;recording.add_child(record_button)
 recording.add_child(button226("打开记录目录",folder226))
 var actions=HBoxContainer.new();column.add_child(actions)
 actions.add_child(button226("清空草稿",clear226))
 actions.add_child(button226("导出当前统计",export226))
 apply_button=button226("原地应用 · 新统计片段",commit226.bind(false));actions.add_child(apply_button)
 restart_button=button226("用草稿重开一场",commit226.bind(true));restart_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;actions.add_child(restart_button)
 hide()
func spin226(parent: Node) -> SpinBox:
 var spin=SpinBox.new();spin.min_value=10;spin.max_value=10000;spin.step=1;spin.custom_minimum_size.x=105;parent.add_child(spin);return spin
func open226() -> void:
 draft=world.levels226.duplicate(true);cat_hp.value=world.cat_health226;bat_hp.value=world.bat_health226
 feedback.text="取消不会应用草稿。原地应用保留位置、当前血量和战斗阶段。";show();refresh226();focus226("eye_exercise")
func clear226() -> void:draft.clear();refresh226()
func preset226(index: int) -> void:
 draft=profile226().PRESETS[index].levels.duplicate(true);feedback.text="草稿："+profile226().PRESETS[index].name;refresh226()
func adjust226(id: String,amount: int) -> void:
 var proposal=draft.duplicate(true);proposal[id]=int(proposal.get(id,0))+amount
 if proposal[id]<=0:proposal.erase(id)
 var error=profile226().error(proposal)
 if error!="":feedback.text=error;return
 draft=proposal;feedback.text="草稿已修改，尚未应用。";refresh226();focus226(id)
func focus226(id: String) -> void:
 if id=="boarding_school":detail.text="住校 · 第二地区碎片，本轮不开放。";return
 if id=="music_class" and id in profile226().BLOCKED:detail.text="乐器课 · 节奏Perfect版本待制作，本轮不使用旧概率音符效果。";return
 if id=="paper_racer":detail.text="纸赛车 · 漂移过弯版本待制作，本轮不使用旧常驻移速效果。";return
 if id=="east_west":detail.text="东南西北 · 制作制下的新效果待设计。";return
 var card=world.memory_kit116.card(id)
 detail.text=str(card.name)+" · 每份%d槽\n"%profile226().COSTS[id]+world.memory_kit116.effect118(id,int(draft.get(id,1)))
func refresh226() -> void:
 capacity.text="草稿 %d / 6槽 · 决心上限14"%profile226().cost(draft)
 for id in rows:
  var count=int(draft.get(id,0));rows[id].count.text=str(count);rows[id].minus.disabled=count<=0
 var error=profile226().error(draft);apply_button.disabled=error!="";restart_button.disabled=error!=""
 record_button.disabled=error!=""
 stats.text=world.summary_stats226()
func commit226(restart: bool) -> void:
 var error=world.commit_console226(draft,cat_hp.value,bat_hp.value,restart)
 if error!="":feedback.text=error
func export226() -> void:
 feedback.text=("统计已导出："+ProjectSettings.globalize_path("user://boss_balance226_last.json")) if world.export_stats226()==OK else "导出失败，原统计仍保留。"
func _process(_delta: float) -> void:
 if not visible:return
 var viewport=get_viewport_rect().size
 panel.position=Vector2(24,24);panel.size=viewport-Vector2(48,48)
func _draw() -> void:draw_rect(get_viewport_rect(),Color(0,0,0,.62))

func record226() -> void:
 var error=world.start_recording226(draft,cat_hp.value,bat_hp.value,record_mode.get_item_text(record_mode.selected))
 if error!="":feedback.text=error
func folder226() -> void:
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(world.recording226.folder))
 OS.shell_open(ProjectSettings.globalize_path(world.recording226.folder))

func profile226() -> Script:return world.balance_profile226()
