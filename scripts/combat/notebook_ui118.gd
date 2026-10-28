extends Control
const PAGE_SIZE118 := 5
class Paper118:
 extends Control
 func _draw() -> void:
  var cover := StyleBoxFlat.new();cover.bg_color=Color("3d6a60");cover.border_color=Color("294d48");cover.set_border_width_all(4);cover.set_corner_radius_all(15)
  draw_style_box(cover,Rect2(16,28,1010,716))
  for i in range(0,984,16): draw_line(Vector2(30+i,37),Vector2(37+i,37),Color("a5b59a"),2.)
  for i in 4: draw_rect(Rect2(33,43+i*2,979,687),Color("c5b18a"),false,1.)
  var page := StyleBoxFlat.new();page.bg_color=Color("f6edcf");page.set_corner_radius_all(7)
  draw_style_box(page,Rect2(37,47,472,682));page.bg_color=Color("f0e5c5");draw_style_box(page,Rect2(514,47,494,682))
  draw_rect(Rect2(502,50,15,675),Color("d6c49e"));draw_line(Vector2(510,52),Vector2(510,725),Color("bda982"),2.)
  for y in range(77,714,21): draw_line(Vector2(505,y),Vector2(514,y+3),Color("faf1d5"),2.)
  for y in [95.,610.]:
   draw_circle(Vector2(61,y),4.,Color("b9906b"));draw_circle(Vector2(61,y),2.,Color("e4cbaa"))
  draw_colored_polygon(PackedVector2Array([Vector2(976,48),Vector2(1007,79),Vector2(976,79)]),Color("e1cba4"))
var world: Node3D
var book: Control
var working: Array[String]=[]
var working_owned := {}
var working_crafted := {}
var focused_id := "slingshot"
var tab118 := "recipe"
var pages118 := {"recipe":0,"equip":0}
var title118: Label
var sub118: Label
var detail_name: Label
var detail_effect: Label
var detail_line: Label
var stock118: Label
var capacity: Label
var packed: Label
var feedback: Label
var pager118: Label
var recipe_tab118: Button
var equip_tab118: Button
var craft_button118: Button
var add118: Button
var remove118: Button
var rows118: Array[Button]=[]
var slots118: Array[Button]=[]
var ids118: Array[String]=[]
func paper_style118(fill: Color,border := Color("c6b28b")) -> StyleBoxFlat:
 var s := StyleBoxFlat.new();s.bg_color=fill;s.border_color=border;s.set_border_width_all(2);s.set_corner_radius_all(6)
 s.content_margin_left=12;s.content_margin_right=12;s.content_margin_top=6;s.content_margin_bottom=6;return s
func words118(text: String,at: Vector2,size: Vector2,font := 20) -> Label:
 var node := Label.new();node.text=text;node.position=at;node.size=size;node.add_theme_font_size_override("font_size",font);node.add_theme_color_override("font_color",Color("544b3b"))
 node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;node.mouse_filter=Control.MOUSE_FILTER_IGNORE;book.add_child(node);return node
func button118(text: String,at: Vector2,size: Vector2) -> Button:
 var node := Button.new();node.text=text;node.position=at;node.size=size;node.add_theme_font_size_override("font_size",19)
 for state in ["normal","hover","pressed","focus","disabled"]:
  node.add_theme_stylebox_override(state,paper_style118(Color("e8d9b4") if state=="normal" else (Color("d8c79e") if state=="pressed" else (Color("f7efd9") if state=="hover" else Color("e5d9bd")))))
 for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: node.add_theme_color_override(state,Color("514736"))
 node.add_theme_color_override("font_disabled_color",Color("9e927a"));book.add_child(node);return node
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=Control.MOUSE_FILTER_STOP
 book=Paper118.new();book.size=Vector2(1130,780);book.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(book)
 title118=words118("",Vector2(83,70),Vector2(385,40),28)
 sub118=words118("",Vector2(83,114),Vector2(395,32),17)
 for i in PAGE_SIZE118:
  var row := button118("",Vector2(76,158+i*66),Vector2(402,59));row.alignment=HORIZONTAL_ALIGNMENT_LEFT;rows118.append(row);row.pressed.connect(row_select118.bind(i))
 var prev := button118("上一页",Vector2(76,517),Vector2(100,42));prev.pressed.connect(page118.bind(-1))
 pager118=words118("",Vector2(178,524),Vector2(197,30),18);pager118.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var next := button118("下一页",Vector2(378,517),Vector2(100,42));next.pressed.connect(page118.bind(1))
 detail_name=words118("",Vector2(551,93),Vector2(418,67),26)
 detail_effect=words118("",Vector2(551,173),Vector2(415,132),20)
 detail_line=words118("",Vector2(551,310),Vector2(415,78),18);detail_line.add_theme_color_override("font_color",Color("857658"))
 stock118=words118("",Vector2(551,403),Vector2(415,92),19)
 craft_button118=button118("试制一份",Vector2(551,506),Vector2(415,48));craft_button118.pressed.connect(craft118)
 add118=button118("再装一份  ＋",Vector2(551,402),Vector2(200,45));add118.pressed.connect(add_one118)
 remove118=button118("收回一份  －",Vector2(768,402),Vector2(198,45));remove118.pressed.connect(remove_one118)
 for i in 4:
  var slot := button118("",Vector2(551,469+i*40),Vector2(415,36));slot.add_theme_font_size_override("font_size",17);slots118.append(slot);slot.pressed.connect(slot_remove118.bind(i))
 capacity=words118("",Vector2(77,576),Vector2(400,35),22)
 packed=words118("",Vector2(77,614),Vector2(400,53),17)
 feedback=words118("",Vector2(551,567),Vector2(415,72),17)
 recipe_tab118=button118("配 方",Vector2(1005,108),Vector2(100,63));recipe_tab118.pressed.connect(switch118.bind("recipe"))
 equip_tab118=button118("装 配",Vector2(1005,185),Vector2(100,63));equip_tab118.pressed.connect(switch118.bind("equip"))
 var close := button118("×",Vector2(1042,48),Vector2(50,42));close.pressed.connect(func(): world.close_memory116(false))
 var cancel := button118("先合上，不改了",Vector2(77,681),Vector2(243,41));cancel.pressed.connect(func(): world.close_memory116(false))
 var save := button118("收好笔记本",Vector2(330,681),Vector2(298,41));save.pressed.connect(func(): world.close_memory116(true))
 var trial := button118("收好，去林地试演",Vector2(642,681),Vector2(324,41));trial.pressed.connect(func(): world.close_memory116(true,true))
 hide()
func open116() -> void:
 working.assign(world.memory_kit116.equipped);working_owned=world.memory_kit116.owned.duplicate();working_crafted=world.memory_kit116.crafted.duplicate()
 var hero: Node3D=world.hero;var props: Node3D=world.workshop116
 tab118="recipe" if hero.position.distance_squared_to(props.pot.position)<hero.position.distance_squared_to(props.tin.position) else "equip"
 focused_id=working[0] if not working.is_empty() else "slingshot";feedback.text="";refresh116();show()
func switch118(tab: String) -> void:
 tab118=tab;feedback.text=""
 if tab=="equip" and int(working_owned.get(focused_id,0))<=0:
  for id in world.memory_kit116.ORDER:
   if int(working_owned.get(id,0))>0: focused_id=id;break
 refresh116()
func page118(step: int) -> void:
 var total := maxi(1,ceili(float(ids118.size())/PAGE_SIZE118));pages118[tab118]=posmod(int(pages118[tab118])+step,total);refresh116()
func row_select118(row: int) -> void:
 var index := int(pages118[tab118])*PAGE_SIZE118+row
 if index<ids118.size(): select116(ids118[index])
func select116(id: String) -> void: focused_id=id;feedback.text="";refresh116()
func craft118() -> void:
 if world.memory_kit116.craft118(focused_id,working_owned,working_crafted):
  refresh116();feedback.text="新做了一份，已经记在本页。\n合上前按“收好”才会保存。"
func add_one118() -> void:
 var proposal := working.duplicate();proposal.append(focused_id)
 if not world.memory_kit116.valid(proposal,working_owned):
  feedback.text="这一份还没做出来，或口袋已经装满了。";return
 working.assign(proposal);feedback.text="";refresh116()
func remove_one118() -> void:
 working.erase(focused_id);feedback.text="";refresh116()
func slot_remove118(index: int) -> void:
 if index<working.size(): working.remove_at(index);feedback.text="";refresh116()
func toggle116() -> void: add_one118()
func refresh116() -> void:
 var kit: RefCounted=world.memory_kit116;var recipe := tab118=="recipe"
 ids118.clear()
 for id in kit.ORDER:
  if recipe or int(working_owned.get(id,0))>0: ids118.append(id)
 var total := maxi(1,ceili(float(ids118.size())/PAGE_SIZE118));pages118[tab118]=clampi(pages118[tab118],0,total-1)
 title118.text="我的魔法配方簿" if recipe else "今天带什么出门"
 sub118.text="配方摘记 · 童年的小魔法" if recipe else "已装配 / 拥有 · 同种记忆可带几份"
 pager118.text="%d / %d 页"%[int(pages118[tab118])+1,total]
 for i in PAGE_SIZE118:
  var index := int(pages118[tab118])*PAGE_SIZE118+i;var row := rows118[i];row.visible=index<ids118.size()
  if not row.visible: continue
  var id: String=ids118[index];var is_open: bool=kit.unlocked[id]
  row.text=str(kit.card(id).name)+("  · 试制" if is_open else "  · 未解锁") if recipe else str(kit.card(id).name)+"  ×%d / %d"%[working.count(id),working_owned[id]]
  row.add_theme_stylebox_override("normal",paper_style118(Color("ead1a9") if id==focused_id else Color("eee3c5")))
 detail_name.text=str(kit.card(focused_id).name)+"\n每份占 %d 格"%kit.COSTS[focused_id]
 detail_effect.text=kit.effect118(focused_id,maxi(1,working.count(focused_id)))
 detail_line.text="小黑鹅：\n“"+str(kit.card(focused_id).line)+"”"
 if not recipe and int(kit.card(focused_id).max)>1 and working.count(focused_id)>int(kit.card(focused_id).max): detail_effect.text+="\n超出旧效果等级的份数暂不增加收益。"
 stock118.visible=recipe;craft_button118.visible=recipe;add118.visible=not recipe;remove118.visible=not recipe
 packed.visible=recipe;feedback.position=Vector2(551,567) if recipe else Vector2(77,623);feedback.size=Vector2(415,72) if recipe else Vector2(400,43)
 if recipe:
  var is_open: bool=kit.unlocked[focused_id]
  stock118.text=("解锁：已开放试制" if is_open else "解锁：等待演员与配方设计")+"\n已制作 %d 份 · 拥有 %d 份 · 装配 %d 份"%[working_crafted[focused_id],working_owned[focused_id],working.count(focused_id)]+"\n材料与制作方法：待设计"
  craft_button118.disabled=not is_open or working_owned[focused_id]>=999
  if feedback.text.is_empty(): feedback.text="当前6种配方可免费试制。\n材料掉落与正式消耗尚未接入。"
 else:
  var proposed := working.duplicate();proposed.append(focused_id);add118.disabled=not kit.valid(proposed,working_owned);remove118.disabled=not focused_id in working
  feedback.text=""
 for i in 4:
  slots118[i].visible=not recipe and i<=working.size()
  if not recipe:
   slots118[i].disabled=i>=working.size()
   slots118[i].text=(str(kit.card(working[i]).name)+"  · %d格  × 收回"%kit.COSTS[working[i]]) if i<working.size() else ("口袋已经装满了" if kit.used(working)>=kit.CAPACITY else "还空着 %d 格"%(kit.CAPACITY-kit.used(working)))
 capacity.text="记忆口袋    %d / %d 格"%[kit.used(working),kit.CAPACITY]
 packed.text="每份分别占格。盒中数量包含已装配的份数。\n制作和装配都在“收好”时保存。"
 for tab in [recipe_tab118,equip_tab118]:
  var selected: bool=(tab==recipe_tab118)==recipe
  tab.add_theme_stylebox_override("normal",paper_style118(Color("e4a28a") if selected else Color("92b5a0"),Color("bca781")))
func _process(_delta: float) -> void:
 if not visible: return
 var factor := minf(1.,minf(get_viewport_rect().size.x/1170.,get_viewport_rect().size.y/825.))
 book.scale=Vector2.ONE*factor;book.position=(get_viewport_rect().size-book.size*factor)*.5
func _draw() -> void:
 if visible: draw_rect(get_viewport_rect(),Color(.02,.04,.035,.65))
