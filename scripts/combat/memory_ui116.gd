extends Control
var world: Node3D
var panel: PanelContainer
var detail_name: Label
var detail_effect: Label
var detail_line: Label
var capacity: Label
var packed: Label
var feedback: Label
var toggle: Button
var working: Array[String]=[]
var focused_id := "slingshot"
var entries := {}
func style116(color: Color) -> StyleBoxFlat:
 var s := StyleBoxFlat.new();s.bg_color=color;s.border_color=Color("b3ab85");s.set_border_width_all(1);s.set_corner_radius_all(12)
 s.content_margin_left=20;s.content_margin_right=20;s.content_margin_top=14;s.content_margin_bottom=14;return s
func label116(words: String,size: int) -> Label:
 var node := Label.new();node.text=words;node.add_theme_font_size_override("font_size",size);node.add_theme_color_override("font_color",Color("eee8d4"));return node
func button116(words: String) -> Button:
 var node := Button.new();node.text=words;node.custom_minimum_size.y=48;node.add_theme_font_size_override("font_size",19)
 node.add_theme_stylebox_override("normal",style116(Color("25463f")));node.add_theme_stylebox_override("hover",style116(Color("395d4e")));node.add_theme_stylebox_override("pressed",style116(Color("52694d")))
 return node
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=Control.MOUSE_FILTER_STOP
 panel=PanelContainer.new();panel.add_theme_stylebox_override("panel",style116(Color(.06,.105,.085,.98)));add_child(panel)
 var column := VBoxContainer.new();column.add_theme_constant_override("separation",14);panel.add_child(column)
 var heading := HBoxContainer.new();column.add_child(heading)
 var title := label116("饼干铁盒 · 带哪些记忆出门",28);title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;heading.add_child(title)
 var close := button116("×");heading.add_child(close);close.pressed.connect(func(): world.close_memory116(false))
 column.add_child(label116("把今天想带的记忆收好。回到小院，还可以换一种搭配。",18))
 var row := HBoxContainer.new();row.add_theme_constant_override("separation",24);column.add_child(row)
 var list := VBoxContainer.new();list.custom_minimum_size.x=300;list.add_theme_constant_override("separation",9);row.add_child(list)
 for id in world.memory_kit116.ORDER:
  var button := button116("");button.alignment=HORIZONTAL_ALIGNMENT_LEFT;list.add_child(button);entries[id]=button
  button.pressed.connect(select116.bind(id))
 var right := VBoxContainer.new();right.custom_minimum_size.x=540;right.size_flags_horizontal=Control.SIZE_EXPAND_FILL;right.add_theme_constant_override("separation",14);row.add_child(right)
 detail_name=label116("",25);right.add_child(detail_name)
 detail_effect=label116("",20);detail_effect.custom_minimum_size=Vector2(530,90);detail_effect.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;right.add_child(detail_effect)
 detail_line=label116("",19);detail_line.custom_minimum_size=Vector2(530,75);detail_line.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;detail_line.modulate=Color("e4cd91");right.add_child(detail_line)
 toggle=button116("");right.add_child(toggle);toggle.pressed.connect(toggle116)
 capacity=label116("",22);column.add_child(capacity)
 packed=label116("",18);packed.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;packed.custom_minimum_size.y=44;column.add_child(packed)
 feedback=label116("",18);feedback.custom_minimum_size.y=26;column.add_child(feedback)
 var actions := HBoxContainer.new();actions.add_theme_constant_override("separation",14);column.add_child(actions)
 var cancel := button116("先不改了");actions.add_child(cancel);cancel.pressed.connect(func(): world.close_memory116(false))
 var save := button116("收好，准备出门");save.size_flags_horizontal=Control.SIZE_EXPAND_FILL;actions.add_child(save);save.pressed.connect(func(): world.close_memory116(true))
 var trial := button116("收好并去林地试演");actions.add_child(trial);trial.pressed.connect(func(): world.close_memory116(true,true))
 hide()
func open116() -> void:
 working.assign(world.memory_kit116.equipped);feedback.text="";select116(working[0] if not working.is_empty() else "slingshot");show()
func select116(id: String) -> void:
 focused_id=id;refresh116()
func toggle116() -> void:
 var proposal := working.duplicate()
 if focused_id in proposal: proposal.erase(focused_id)
 else: proposal.append(focused_id)
 if not world.memory_kit116.valid(proposal): feedback.text="口袋装不下了，先收回一段记忆吧。";return
 working.assign(proposal);feedback.text="";refresh116()
func refresh116() -> void:
 var kit: RefCounted=world.memory_kit116;var card: Dictionary=kit.card(focused_id)
 for id in entries: entries[id].text=("✓ " if id in working else "   ")+str(kit.card(id).name)+"   · %d格"%kit.COSTS[id]
 detail_name.text=card.name+"   · %d格"%kit.COSTS[focused_id];detail_effect.text=("按住开火蓄力，松开发射可以贯穿演员的重弹。" if focused_id=="slingshot" else str(card.fx));detail_line.text="小黑鹅：\n“"+str(card.line)+"”"
 if focused_id in ["slingshot","flashlight"] and "slingshot" in working and "flashlight" in working:
  detail_effect.text+="\n\n一起携带：按住蓄力，松开发出可以挥扫的光束。"
 toggle.text="收回铁盒" if focused_id in working else "放进记忆口袋"
 capacity.text="记忆口袋   %d / %d"%[kit.used(working),kit.CAPACITY];packed.text="今天带上："+kit.summary(working)
func _process(_delta: float) -> void:
 if not visible: return
 panel.reset_size();panel.position=(get_viewport_rect().size-panel.size)*.5
func _draw() -> void:
 if visible: draw_rect(get_viewport_rect(),Color(0,.02,.01,.32))
