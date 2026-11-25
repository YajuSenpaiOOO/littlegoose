extends Control

signal closed
signal craft_requested(id: String)
signal craft_preview_requested(id: String)

const BOOK_SIZE := Vector2(1100, 650)
const INDEX_SIZE := 20
const INK := Color("513a2c")
const PAGE_TURN=preload("res://scripts/combat/workshop_page_turn432.gd")
const PRINT_INK=preload("res://scripts/art/workshop_journal_print432.gdshader")
const CRAFT_FX=preload("res://scripts/combat/workshop_journal_craft432.gd")
const BODY_START:=.771
const LEFT_AREA:=Rect2(51,39,475,567)
const RIGHT_AREA:=Rect2(574,39,474,567)
var kit: RefCounted
var icons: Dictionary
var entries: Array
var book: Control
var content: Control
var feedback: Label
var page := -1
var index_group := 0
var turn: Tween
var sheet: PAGE_TURN
var left_page: Control
var right_page: Control
var ink_font: SystemFont
var bookmark_art: AtlasTexture
var on_table:=false
var close_ripple: Button
var diary_body: TextureRect
var photo_print: TextureRect
var craft_fx: CRAFT_FX
var skip_hint: Label
var material_count: Label

func _ready() -> void:
 ink_font=SystemFont.new()
 ink_font.font_names=PackedStringArray(["KaiTi","STKaiti","FangSong","SimSun"])
 bookmark_art=AtlasTexture.new()
 bookmark_art.atlas=load("res://assets/workshop432/journal-bookmark.png")
 bookmark_art.region=Rect2(32,142,1880,530)
 bookmark_art.filter_clip=true
 book=Control.new()
 book.size=BOOK_SIZE
 add_child(book)
 var portrait:=load("res://assets/workshop432/journal-pov-planted.png") as Texture2D
 var bodice:=AtlasTexture.new()
 bodice.atlas=portrait
 var image_size:=portrait.get_size()
 bodice.region=Rect2(0.,roundf(image_size.y*BODY_START),image_size.x,floorf(image_size.y*(1.-BODY_START)))
 bodice.filter_clip=true
 diary_body=TextureRect.new()
 diary_body.texture=bodice
 diary_body.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 diary_body.mouse_filter=Control.MOUSE_FILTER_IGNORE
 diary_body.z_index=1
 add_child(diary_body)
 craft_fx=CRAFT_FX.new()
 craft_fx.z_index=2
 add_child(craft_fx)
 craft_fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 skip_hint=Label.new()
 skip_hint.text="Esc · 跳过"
 skip_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 skip_hint.add_theme_font_override("font",ink_font)
 skip_hint.add_theme_font_size_override("font_size",22)
 skip_hint.add_theme_color_override("font_color",Color("ffe7ba"))
 skip_hint.add_theme_color_override("font_outline_color",INK)
 skip_hint.add_theme_constant_override("outline_size",5)
 skip_hint.mouse_filter=Control.MOUSE_FILTER_IGNORE
 skip_hint.z_index=3
 add_child(skip_hint)
 skip_hint.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
 skip_hint.offset_left=-170.
 skip_hint.offset_right=-28.
 skip_hint.offset_top=20.
 skip_hint.hide()
 close_ripple=Button.new()
 close_ripple.flat=true
 close_ripple.focus_mode=Control.FOCUS_NONE
 close_ripple.tooltip_text="合上日记"
 close_ripple.accessibility_name="合上日记"
 close_ripple.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 close_ripple.pressed.connect(func(): closed.emit())
 add_child(close_ripple)
 resized.connect(fit_book)
 fit_book()
 hide()

func _process(_delta:float) -> void:
 if not visible:return
 close_ripple.visible=book.visible and not craft_fx.busy()
 skip_hint.visible=craft_fx.busy()
 diary_body.visible=on_table and book.visible
 if diary_body.visible:
  var art_height:=size.x*2./3.
  diary_body.size=Vector2(size.x,art_height*(1.-BODY_START))
  diary_body.position=Vector2(size.x*.305,size.y-art_height*.174)
 if close_ripple.visible:
  var paper_width:=BOOK_SIZE.x*book.scale.x
  var right_edge:=book.position.x+paper_width
  var at:=Vector2(lerpf(right_edge,size.x,.48),book.position.y+BOOK_SIZE.y*book.scale.y*.31)
  close_ripple.size=Vector2(66,66)
  close_ripple.position=at-close_ripple.size*.5
 queue_redraw()

func _draw() -> void:
 if not is_instance_valid(close_ripple) or not close_ripple.visible:return
 var at:=close_ripple.position+close_ripple.size*.5
 for offset in [0.,.5]:
  var pulse:=fmod(Time.get_ticks_msec()/1250.+offset,1.)
  draw_arc(at,lerpf(8.,29.,pulse),0.,TAU,40,Color(1.,.91,.72,(1.-pulse)*.78),1.5,true)

func fit_book() -> void:
 if on_table:return
 var ratio:=minf(size.x/1290.,size.y/720.)
 book.scale=Vector2.ONE*ratio
 book.position=(size-BOOK_SIZE*ratio)*.5

func open(memory_kit:RefCounted,art:Dictionary,table_view:=false) -> void:
 if turn:turn.kill()
 if sheet:sheet.hide()
 diary_body.hide()
 kit=memory_kit
 icons=art
 for id in ["slingshot","three_player","boarding_school","paper_racer","distract","east_west"]:
  icons[id]=load("res://assets/workshop432/fragments/"+id+".png")
 entries=kit.ORDER.duplicate()
 entries.append(kit.BOUNCY_BALL)
 index_group=0
 on_table=table_view
 book.visible=not on_table
 show()
 render(-1)
 fit_book()

func place_on_table(paper:Rect2,progress:float) -> void:
 book.visible=progress>=.94
 if not book.visible:return
 book.position=paper.position
 book.scale=paper.size/BOOK_SIZE
 book.modulate.a=smoothstep(.94,1.,progress)

func render(target:int) -> void:
 if content:
  book.remove_child(content)
  content.queue_free()
 page=target
 photo_print=null
 material_count=null
 content=Control.new()
 content.size=BOOK_SIZE
 book.add_child(content)
 left_page=page_clip(LEFT_AREA)
 right_page=page_clip(RIGHT_AREA)
 if page<0:
  render_index()
 else:
  render_spread()

func render_index() -> void:
 words("记忆目录",Rect2(113,51,390,45),32)
 var start:=index_group*INDEX_SIZE
 for i in range(start,mini(start+INDEX_SIZE,entries.size())):
  var cell:=i-start
  var index_on_page:=cell%10
  var x:=float(cell/10)*550.+85.
  var top:=108.+float(index_on_page)*43.
  var id:String=entries[i]
  var card:Dictionary=kit.card(id)
  index_entry(str(card.name),icons.get(id),Rect2(x,top,390,40),i)
 corner(false,index_group>0,"上一页",-1)
 corner(true,true,"下一页",1)
 words("目录 %d / %d"%[index_group+1,index_count()],Rect2(173,565,166,38),20,HORIZONTAL_ALIGNMENT_CENTER)

func index_entry(title:String,illustration:Texture2D,area:Rect2,target:int) -> void:
 var item:=Button.new()
 item.flat=true
 item.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 item.accessibility_name=title
 var empty:=StyleBoxEmpty.new()
 for state in ["normal","hover","pressed","focus"]:
  item.add_theme_stylebox_override(state,empty)
 place(item,area)
 var stamp:=TextureRect.new()
 stamp.texture=illustration
 stamp.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 stamp.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 stamp.mouse_filter=Control.MOUSE_FILTER_IGNORE
 stamp.position=Vector2(0,2)
 stamp.size=Vector2(39,36)
 item.add_child(stamp)
 var text:=Label.new()
 text.text=title
 text.mouse_filter=Control.MOUSE_FILTER_IGNORE
 text.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 text.clip_text=true
 text.add_theme_font_override("font",ink_font)
 text.add_theme_font_size_override("font_size",25)
 text.add_theme_color_override("font_color",INK)
 item.add_child(text)
 text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 text.offset_left=55.
 item.mouse_entered.connect(func():
  text.add_theme_color_override("font_color",Color("943f22"))
  text.add_theme_color_override("font_shadow_color",Color(.99,.74,.31,.75))
  text.add_theme_constant_override("shadow_offset_x",1)
  text.add_theme_constant_override("shadow_offset_y",1)
 )
 item.mouse_exited.connect(func():
  text.add_theme_color_override("font_color",INK)
  text.remove_theme_color_override("font_shadow_color")
 )
 item.pressed.connect(go_to.bind(target))

func index_count() -> int:
 return ceili(float(entries.size())/INDEX_SIZE)

func flip_adjacent(direction:int) -> void:
 if page<0:
  var adjacent:=index_group+direction
  if adjacent>=0 and adjacent<index_count():turn_to(-1,adjacent,float(direction))
  elif direction>0:go_to(0)
 elif page==0 and direction<0:
  turn_to(-1,index_count()-1,-1.)
 else:
  go_to(page+direction)

func render_spread() -> void:
 var id:String=entries[page]
 var card:Dictionary=kit.card(id)
 var bookmark:=button("目录",Rect2(-64,88,112,35))
 var ribbon:=StyleBoxTexture.new()
 ribbon.texture=bookmark_art
 var hovered:=ribbon.duplicate() as StyleBoxTexture
 hovered.modulate_color=Color(1.17,1.12,1.06)
 for state in ["normal","hover","pressed"]:
  bookmark.add_theme_stylebox_override(state,hovered if state=="hover" else ribbon)
  bookmark.add_theme_color_override("font_color" if state=="normal" else "font_"+state+"_color",Color("fff0d2"))
 bookmark.pressed.connect(go_to.bind(-1))
 words(str(card.name),Rect2(113,49,387,52),34)
 if icons.has(id):
  taped_photo(icons[id],id)
 var owned:int=kit.owned.get(id,0)
 words("已有 %d 份"%owned,Rect2(99,353,400,36),19,HORIZONTAL_ALIGNMENT_CENTER)
 sticky_note("当时的事",Rect2(79,412,431,137),Color("dbc9a9"))
 for y in [488.,522.]:
  paper_line(Rect2(99,y,392,1.5),Color(.55,.46,.36,.25))
 sticky_note("它会做什么",Rect2(592,85,442,199),Color("e7c990"))
 words("占 %d 格"%kit.used([id]),Rect2(886,103,125,34),19,HORIZONTAL_ALIGNMENT_RIGHT)
 effect_note(kit.effect118(id))
 sticky_note("怎么做",Rect2(592,309,442,237),Color("e4b39b"))
 if id=="slingshot":
  var needed:int=kit.BALANCE119.SLINGSHOT_GEL
  material_count=words("蓝色弹性液滴  %d / %d\n小树枝  %d / %d"%[
   kit.gel119,needed,kit.twigs,kit.SLINGSHOT_TWIGS],Rect2(614,362,398,63),23)
  words("液滴在团团空地收集。树枝去林边找。",Rect2(614,431,396,38),19)
 elif id=="paper_plane":
  material_count=words("扯下的作业纸  %d / %d"%[kit.homework_paper,kit.PLANE_PAPER],Rect2(614,362,398,63),23)
  words("去望海纸坪，捡小纸怪落下的纸。",Rect2(614,431,396,38),19)
 elif id=="snack":
  material_count=words("养大的水宝宝  %d / %d"%[kit.water_baby,kit.SNACK_WATER],Rect2(614,354,398,53),23)
  words("团团掉的小珠子，在小屋右下方澡棚泡。\n下一次早上七点就能取。",Rect2(614,412,398,60),19)
 if not kit.recipe_cost(id).is_empty():
  if kit.unlocked.get(id,false):
   words("点照片写下记忆",Rect2(614,486,179,40),20)
  var preview_text:="重看合成演出" if int(kit.crafted.get(id,0))>0 else "预览合成演出"
  var preview:=button(preview_text,Rect2(801,479,208,42))
  preview.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
  preview.tooltip_text="只播放演出，不消耗材料"
  preview.pressed.connect(func(): craft_preview_requested.emit(id))
 elif id==kit.BOUNCY_BALL:
  words("首次战胜大团团后获得。",Rect2(614,370,395,57),22)
 else:
  var note:="配方待记录" if kit.unlocked.get(id,false) else "这段记忆尚未解锁"
  words(note,Rect2(614,370,395,57),22)
 feedback=words("",Rect2(613,551,396,32),18)
 corner(false,true,"上一页",-1)
 corner(true,page<entries.size()-1,"下一页",1)
 var folio:=page*2+index_count()*2+1
 words(str(folio),Rect2(225,566,68,36),20,HORIZONTAL_ALIGNMENT_CENTER)
 words(str(folio+1),Rect2(791,566,68,36),20,HORIZONTAL_ALIGNMENT_CENTER)

func sticky_note(title:String,area:Rect2,paper_color:Color) -> void:
 var note:=Control.new()
 note.mouse_filter=Control.MOUSE_FILTER_IGNORE
 place(note,area)
 var w:=area.size.x
 var h:=area.size.y
 var edge:=PackedVector2Array([Vector2(0,3),Vector2(w-2,0),Vector2(w,h-13),Vector2(w-17,h),
  Vector2(w*.69,h-2),Vector2(w*.34,h+1),Vector2(4,h-2)])
 var shade:=Polygon2D.new()
 shade.polygon=edge
 shade.color=Color(.35,.21,.11,.15)
 shade.position=Vector2(2,4)
 note.add_child(shade)
 var paper:=Polygon2D.new()
 paper.polygon=edge
 paper.color=Color(paper_color,.50)
 note.add_child(paper)
 var fold:=Polygon2D.new()
 fold.polygon=PackedVector2Array([Vector2(w-18,h),Vector2(w-16,h-12),Vector2(w,h-13)])
 fold.color=Color(paper_color.lightened(.35),.72)
 note.add_child(fold)
 paper_line(Rect2(area.position+Vector2(18,49),Vector2(w-36,1.)),Color(.45,.28,.15,.25))
 words(title,Rect2(area.position+Vector2(21,15),Vector2(220,32)),24)

func paper_line(area:Rect2,color:Color) -> void:
 var line:=ColorRect.new()
 line.color=color
 line.mouse_filter=Control.MOUSE_FILTER_IGNORE
 place(line,area)

func effect_note(copy:String) -> void:
 var scroller:=ScrollContainer.new()
 scroller.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 place(scroller,Rect2(613,141,399,133))
 var note:=Label.new()
 note.text=copy
 note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 note.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 note.add_theme_font_override("font",ink_font)
 note.add_theme_font_size_override("font_size",21)
 note.add_theme_color_override("font_color",INK)
 scroller.add_child(note)

func taped_photo(illustration:Texture2D,id:String) -> void:
 var frame:=Panel.new()
 frame.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var matte:=style(Color(.80,.74,.63,.82),2)
 matte.set_border_width_all(1)
 matte.border_color=Color("cbb18a")
 matte.shadow_color=Color(.35,.19,.09,.20)
 matte.shadow_size=3
 matte.shadow_offset=Vector2(1,2)
 frame.add_theme_stylebox_override("panel",matte)
 place(frame,Rect2(128,110,304,234))
 frame.pivot_offset=frame.size*.5
 frame.rotation=-.035
 var print_image:=TextureRect.new()
 print_image.texture=illustration
 print_image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 print_image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 print_image.position=Vector2(19,13)
 print_image.size=Vector2(266,197)
 print_image.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var ink:=ShaderMaterial.new()
 ink.shader=PRINT_INK
 print_image.material=ink
 frame.add_child(print_image)
 photo_print=print_image
 add_tape(frame,Vector2(17,4),-.30)
 add_tape(frame,Vector2(224,210),-.28)
 if not kit.recipe_cost(id).is_empty():
  var photo:=Button.new()
  photo.flat=true
  photo.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
  photo.accessibility_name="写下这段记忆"
  photo.tooltip_text="写下这段记忆"
  frame.add_child(photo)
  photo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  photo.mouse_entered.connect(func():
   if kit.can_make_recipe(id) and not craft_fx.busy():
    frame.modulate=Color(1.11,1.06,.99)
  )
  photo.mouse_exited.connect(func(): frame.modulate=Color.WHITE)
  photo.pressed.connect(func(): craft_requested.emit(id))

func ready_to_craft(id:String) -> bool:
 return page>=0 and entries[page]==id and is_instance_valid(photo_print) and book.visible and not craft_fx.busy() and (not turn or not turn.is_running())

func advance_craft(delta:float) -> void:
 var playing:=craft_fx.busy()
 craft_fx.advance(delta)
 if playing and not craft_fx.busy():render(page)

func show_craft(light:Color) -> void:
 if is_instance_valid(photo_print):
  var photo_center:=photo_print.get_global_transform()* (photo_print.size*.5)
  craft_fx.place(photo_center,book.scale.x,light)

func craft_result(filled_glass:Texture2D) -> void:
 craft_fx.start(photo_print,filled_glass)

func skip_craft() -> void:
 if not craft_fx.busy():return
 craft_fx.finish()
 render(page)

func highlight_material() -> void:
 if not is_instance_valid(material_count):return
 material_count.self_modulate=Color(1.62,.76,.57)
 create_tween().tween_property(material_count,"self_modulate",Color.WHITE,.85)

func add_tape(frame:Control,at:Vector2,angle:float) -> void:
 var tape:=Polygon2D.new()
 tape.position=at
 tape.rotation=angle
 tape.polygon=PackedVector2Array([Vector2(-11,-7),Vector2(65,-9),Vector2(62,-3),
  Vector2(65,1),Vector2(62,5),Vector2(66,10),Vector2(-12,12),Vector2(-8,6),Vector2(-12,0)])
 tape.color=Color(.96,.82,.55,.40)
 frame.add_child(tape)
 var shine:=Line2D.new()
 shine.points=PackedVector2Array([Vector2(-5,-5),Vector2(59,-7)])
 shine.width=1.4
 shine.default_color=Color(1.,.96,.77,.58)
 tape.add_child(shine)

func go_to(target:int) -> void:
 if target<-1 or target>=entries.size() or target==page:return
 var group:=page/INDEX_SIZE if target==-1 else index_group
 turn_to(target,group,1. if target>page else -1.)

func turn_to(target:int,group:int,direction:float) -> void:
 if craft_fx.busy() or (turn and turn.is_running()):return
 turn=create_tween()
 turn.tween_method(func(t:float):
  if sheet:sheet.show_turn(t,direction)
  content.modulate.a=1.-ease(t*2.,1.5)*.78
 ,0.,.5,.19)
 turn.tween_callback(func():
  index_group=group
  render(target)
  content.modulate.a=.22
 )
 turn.tween_method(func(t:float):
  if sheet:sheet.show_turn(t,direction)
  content.modulate.a=lerpf(.22,1.,smoothstep(.5,1.,t))
 ,.5,1.,.23)

func page_clip(area:Rect2) -> Control:
 var clip:=Control.new()
 clip.position=area.position
 clip.size=area.size
 clip.clip_contents=true
 clip.mouse_filter=Control.MOUSE_FILTER_IGNORE
 content.add_child(clip)
 return clip

func place(node:Control,area:Rect2) -> void:
 var host:=content
 if area.position.x>=0.:
  host=left_page if area.get_center().x<550. else right_page
 node.position=area.position-host.position
 node.size=area.size
 host.add_child(node)

func corner(right:bool,enabled:bool,description:String,direction:int) -> void:
 var control:=Button.new()
 control.tooltip_text=description
 control.accessibility_name=description
 control.flat=true
 control.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 control.disabled=not enabled
 control.position=Vector2(995. if right else 34.,540.)
 control.size=Vector2(70,89)
 control.pressed.connect(flip_adjacent.bind(direction))
 content.add_child(control)

func words(copy:String,area:Rect2,font_size:int,alignment:=HORIZONTAL_ALIGNMENT_LEFT) -> Label:
 var label:=Label.new()
 label.text=copy
 label.horizontal_alignment=alignment
 label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 label.clip_text=true
 label.add_theme_font_override("font",ink_font)
 label.add_theme_font_size_override("font_size",font_size)
 label.add_theme_color_override("font_color",INK)
 place(label,area)
 return label

func button(copy:String,area:Rect2) -> Button:
 var control:=Button.new()
 control.text=copy
 control.clip_text=true
 control.add_theme_font_override("font",ink_font)
 control.add_theme_font_size_override("font_size",20)
 for state in ["normal","hover","pressed","disabled"]:
  control.add_theme_color_override("font_color" if state=="normal" else "font_"+state+"_color",INK if state!="disabled" else Color("957d63"))
  control.add_theme_stylebox_override(state,style(Color(.82,.62,.35,.43) if state=="hover" else Color(.76,.58,.35,.21),6))
 place(control,area)
 return control

func style(color:Color,radius:int) -> StyleBoxFlat:
 var box:=StyleBoxFlat.new()
 box.bg_color=color
 box.set_corner_radius_all(radius)
 box.content_margin_left=8.
 box.content_margin_right=8.
 return box
