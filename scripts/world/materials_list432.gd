extends Control

const VIEW:=Vector2(1000,625)
const LEFT=preload("res://assets/workshop432/material-list-paper.png")
const RIGHT=preload("res://assets/workshop432/material-list-pen-long.png")
const THOUGHT=preload("res://scripts/room/interaction_cloud432.gd")
const ITEMS:=[
 {"id":"twigs","name":"小树枝","source":"林间空地附近的树根旁。","icon":preload("res://assets/workshop432/forest-bark-forked.png")},
 {"id":"gel119","name":"蓝色弹性液滴","source":"团团退场时掉落，走近收取。","icon":preload("res://assets/collectibles119/blue_elastic_drop.png")},
 {"id":"homework_paper","name":"扯下的作业纸","source":"望海纸坪的小纸怪掉落。","icon":preload("res://assets/workshop432/torn-homework-drop.png")},
 {"id":"water_seed","name":"团团藏着的水宝宝","source":"小团团偶尔掉落。可以放进小屋右下方澡棚里的红澡盆。","icon":preload("res://assets/workshop432/water-baby-drop.tres")},
 {"id":"water_baby","name":"养大的水宝宝","source":"在红澡盆里泡到下一次早上七点，再去取。","icon":preload("res://assets/workshop432/fragments/snack.png")}
]
const INK:=Color("583827")
const FOCUS:=Color("9a562f")
const ROW_HEIGHT:=53.
const ROW_TOP:=64.

var world:Node3D
var lens:Camera3D
var source_lens:Camera3D
var blur:ShaderMaterial
var layout:Control
var sheet:Control
var pen:TextureRect
var pen_rest:=Vector2.ZERO
var paper:TextureRect
var pen_shadow:ShaderMaterial
var source_cloud:THOUGHT
var rows:Array[Button]=[]
var counts:Array[Label]=[]
var empty_note:Label
var row_names:Array[Label]=[]
var font:SystemFont
var previous_alpha:Dictionary={}
var amount:=0.
var clock:=0.
var press_left:=0.
var selected:=-1
var hovered:=-1
var opening:=false
var busy:=false
var hero_was_visible:=true
var reticle_was_visible:=true

func _ready() -> void:
 hide()
 mouse_filter=MOUSE_FILTER_STOP
 lens=Camera3D.new()
 lens.name="MaterialsReadingCamera"
 world.add_child(lens)
 var copy:=BackBufferCopy.new()
 copy.copy_mode=BackBufferCopy.COPY_MODE_VIEWPORT
 add_child(copy)
 var background:=ColorRect.new()
 background.mouse_filter=MOUSE_FILTER_IGNORE
 blur=ShaderMaterial.new()
 blur.shader=preload("res://scripts/art/materials_view_blur432.gdshader")
 background.material=blur
 add_child(background)
 background.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
 layout=Control.new()
 layout.mouse_filter=MOUSE_FILTER_IGNORE
 add_child(layout)
 layout.size=VIEW
 paper=paint(LEFT)
 sheet=Control.new()
 sheet.mouse_filter=MOUSE_FILTER_IGNORE
 layout.add_child(sheet)
 sheet.position=Vector2(268,114)
 sheet.rotation=-.115
 font=SystemFont.new()
 font.font_names=PackedStringArray(["KaiTi","STKaiti","FangSong","SimSun"])
 words(sheet,"手头的材料",Rect2(14,3,360,49),32)
 empty_note=words(sheet,"手头还没有材料。",Rect2(20,ROW_TOP,355,45),23)
 for index in ITEMS.size():
  var item:Dictionary=ITEMS[index]
  var row:=Button.new()
  row.flat=true
  row.focus_mode=FOCUS_NONE
  row.mouse_default_cursor_shape=CURSOR_POINTING_HAND
  row.accessibility_name=item.name
  var flat_style:=StyleBoxEmpty.new()
  for state in ["normal","hover","pressed"]:row.add_theme_stylebox_override(state,flat_style)
  sheet.add_child(row)
  rows.append(row)
  row.position=Vector2(11,ROW_TOP+index*ROW_HEIGHT)
  row.size=Vector2(375,ROW_HEIGHT)
  row.pressed.connect(select_row.bind(index))
  row.mouse_entered.connect(hover_row.bind(index))
  row.mouse_exited.connect(leave_row.bind(index))
  var icon:=TextureRect.new()
  icon.texture=item.icon
  icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.position=Vector2(2,7)
  icon.size=Vector2(45,34)
  icon.mouse_filter=MOUSE_FILTER_IGNORE
  row.add_child(icon)
  row_names.append(words(row,item.name,Rect2(62,0,242,47),25))
  var count:=words(row,"",Rect2(297,0,75,47),25)
  count.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
  counts.append(count)
  var line:=ColorRect.new()
  line.color=Color(.36,.24,.16,.19)
  line.mouse_filter=MOUSE_FILTER_IGNORE
  row.add_child(line)
  line.position=Vector2(0,48)
  line.size=Vector2(374,1)
 var shadow:=ColorRect.new()
 shadow.size=VIEW
 shadow.mouse_filter=MOUSE_FILTER_IGNORE
 pen_shadow=ShaderMaterial.new()
 pen_shadow.shader=preload("res://scripts/art/materials_pen_shadow432.gdshader")
 pen_shadow.set_shader_parameter("paper_alpha",LEFT)
 pen_shadow.set_shader_parameter("pen_alpha",RIGHT)
 shadow.material=pen_shadow
 layout.add_child(shadow)
 pen=paint(RIGHT)
 pen.size=RIGHT.get_size()*.367
 pen_rest=Vector2(646.,154.)
 source_cloud=THOUGHT.new()
 source_cloud.body_size=Vector2(174.,66.)
 source_cloud.left_of_anchor=true
 layout.add_child(source_cloud)
 source_cloud.label.add_theme_font_override("font",font)
 source_cloud.label.add_theme_font_size_override("font_size",18)
 var hint:=words(layout,"Tab / Esc  收起",Rect2(0,566,1000,35),19)
 hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 hint.add_theme_color_override("font_color",Color("fff1d8"))
 hint.add_theme_color_override("font_outline_color",Color("3f2b26"))
 hint.add_theme_constant_override("outline_size",4)

func paint(texture:Texture2D) -> TextureRect:
 var art:=TextureRect.new()
 art.texture=texture
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 art.stretch_mode=TextureRect.STRETCH_SCALE
 art.mouse_filter=MOUSE_FILTER_IGNORE
 layout.add_child(art)
 art.size=VIEW
 return art

func words(parent:Control,copy:String,area:Rect2,point_size:int) -> Label:
 var label:=Label.new()
 label.text=copy
 label.mouse_filter=MOUSE_FILTER_IGNORE
 label.add_theme_font_override("font",font)
 label.add_theme_font_size_override("font_size",point_size)
 label.add_theme_color_override("font_color",INK)
 label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 parent.add_child(label)
 label.position=area.position
 label.size=area.size
 return label

func select_row(index:int) -> void:
 if not opening or amount<.82:return
 selected=-1 if selected==index else index
 press_left=.21
 update_row_highlights()

func hover_row(index:int) -> void:
 hovered=index
 update_row_highlights()

func leave_row(index:int) -> void:
 if hovered==index:
  hovered=-1
  update_row_highlights()

func update_row_highlights() -> void:
 for row in row_names.size():
  row_names[row].add_theme_color_override("font_color",FOCUS if row==selected or row==hovered else INK)

func _gui_input(event:InputEvent) -> void:
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
  selected=-1
  update_row_highlights()
  accept_event()

func start() -> void:
 source_lens=get_viewport().get_camera_3d()
 if source_lens==null:return
 lens.global_transform=source_lens.global_transform
 lens.fov=source_lens.fov
 lens.cull_mask=source_lens.cull_mask
 lens.environment=source_lens.environment
 hero_was_visible=world.hero.visible
 reticle_was_visible=world.reticle.visible
 world.combat_paused=true
 world.hero.controls_enabled=false
 world.hero.velocity=Vector3.ZERO
 world.hero.locomotion=Vector2.ZERO
 world.hero.combat_impulse=Vector2.ZERO
 for widget in [world.hint288,world.state_hud288,world.home432.thought]:
  previous_alpha[widget]=widget.modulate.a
  widget.modulate.a=0.
 world.map_panel.hide()
 world.reticle.hide()
 refresh_rows()
 selected=-1
 hovered=-1
 press_left=0.
 pen.position=pen_rest+Vector2(12.,16.)
 source_cloud.present(1.,"",Vector2.ZERO)
 opening=true
 busy=true
 layout.modulate.a=0.
 blur.set_shader_parameter("amount",0.)
 lens.make_current()
 show()

func refresh_rows() -> void:
 var kit=world.memory_kit116
 kit.remember_materials()
 var slot:=0
 for i in ITEMS.size():
  var item:Dictionary=ITEMS[i]
  var row:=rows[i]
  row.visible=kit.discovered_materials.has(item.id)
  if not row.visible:continue
  row.position.y=ROW_TOP+slot*ROW_HEIGHT
  counts[i].text=str(kit.get(item.id))
  row_names[i].add_theme_color_override("font_color",INK)
  slot+=1
 empty_note.visible=slot==0

func close() -> void:
 opening=false

func restore() -> void:
 if not busy:return
 if is_instance_valid(source_lens):source_lens.make_current()
 world.set_pov_actor_mask432(false)
 world.hero.visible=hero_was_visible
 world.hero.controls_enabled=true
 world.combat_paused=false
 world.fire_needs_release=Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
 world.reticle.visible=reticle_was_visible
 for widget in previous_alpha:
  if is_instance_valid(widget):widget.modulate.a=previous_alpha[widget]
 previous_alpha.clear()
 opening=false
 busy=false
 amount=0.
 hide()

func advance(delta:float) -> void:
 if not busy:return
 amount=move_toward(amount,float(opening),delta/(.49 if opening else .35))
 if not opening and amount==0.:
  restore()
  return
 clock+=delta
 var ease:=smoothstep(0.,1.,amount)
 var feet:Vector3=world.hero.global_position
 var forward:Vector3=-source_lens.global_basis.z
 forward.y=0.
 forward=forward.normalized()
 var eye_height:=2.70 if not world.home432.inside else 1.95
 var eye:=feet+Vector3.UP*eye_height-forward*.24
 var reading:=Transform3D(Basis.IDENTITY,eye).looking_at(eye+forward*1.10-Vector3.UP*1.55)
 lens.global_transform=source_lens.global_transform.interpolate_with(reading,ease)
 lens.fov=lerpf(source_lens.fov,55.,ease)
 world.hero.visible=hero_was_visible and amount<.56
 lens.set_cull_mask_value(20,amount<.56)
 world.set_pov_actor_mask432(amount>=.56)
 blur.set_shader_parameter("amount",ease*.88)
 var viewport:=get_viewport_rect().size
 var scale_factor:=minf(viewport.x/VIEW.x,viewport.y/VIEW.y)
 layout.scale=Vector2.ONE*scale_factor
 var reveal:=smoothstep(.15,.90,amount)
 layout.position=(viewport-VIEW*scale_factor)*.5+Vector2(sin(clock*1.25)*1.8,(1.-reveal)*82.+sin(clock*1.7)*1.9)*scale_factor
 layout.modulate.a=reveal
 var look:Dictionary=world.time55.palette.sample(world.time55.visual_hour)
 var tone:Color=world.palm432.shade_for(look,.76).lerp(Color.WHITE,.22)
 paper.modulate=tone
 pen.modulate=tone
 sheet.modulate=tone.lerp(Color.WHITE,.54)
 var source_text:String=ITEMS[selected].source if selected>=0 and opening else ""
 var row_y:=rows[selected].position.y if selected>=0 else ROW_TOP
 var anchor:=sheet.get_transform()*Vector2(-53.,row_y+ROW_HEIGHT*.5)
 source_cloud.present(delta,source_text,anchor)
 press_left=maxf(0.,press_left-delta)
 var tap:=sin(press_left/.21*PI)
 var indicated:=hovered if hovered>=0 else selected
 var reach:=Vector2(-3.,((rows[indicated].position.y-ROW_TOP)/ROW_HEIGHT-1.)*31.) if indicated>=0 else Vector2(12.,16.)
 pen.position=pen.position.lerp(pen_rest+reach+Vector2(-8.,3.)*tap,1.-exp(-delta*13.))
 pen_shadow.set_shader_parameter("pen_rect",Vector4(pen.position.x,pen.position.y,pen.size.x,pen.size.y))
 pen_shadow.set_shader_parameter("strength",lerpf(.20,.32,float(look.daylight)))
