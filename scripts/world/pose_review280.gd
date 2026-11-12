extends Control
var poses280 := {}
var sprites280: Array[Sprite2D]=[]
var ghost280: Sprite2D
var choice280 := "raise_short"
var phase280 := 0.
var running280 := true
var state_label280: Label
var guide280: Label
var lines280: Node2D
func label280(words: String,at: Vector2,size: int=19) -> Label:
 var label=Label.new();label.text=words;label.position=at;label.add_theme_font_size_override("font_size",size);add_child(label);return label
func _ready() -> void:
 DisplayServer.window_set_title("小白鹅 · 280 · 变身两帧连续性查验")
 get_window().size=Vector2i(1400,900)
 var background=ColorRect.new();background.color=Color("302c38");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(background)
 var atlas=AtlasTexture.new();atlas.atlas=preload("res://assets/hero_pixel/walk_source.png");atlas.region=Rect2(633,0,600,800)
 poses280["original_front"]={"texture":atlas,"foot":Vector2(300,749),"scale":.75}
 # Both candidates share one canvas, anchor and scale. No per-frame eye rescaling.
 for key in ["stand_A","raise_short"]:
  poses280[key]={"texture":load("res://assets/hero_transform280/"+("stand" if key=="stand_A" else "raise")+".png"),"foot":Vector2(587,1229),"scale":.595*.75}
 poses280["raise_C"]=poses280["raise_short"]
 label280("280 · 同画布、同缩放的局部改稿查验",Vector2(32,18),27)
 label280("无补间、无拉伸、无抬高整张图。看头发、脸、衣服在换帧时是否跳变。",Vector2(32,58),18)
 label280("原正面帧（固定）",Vector2(125,116))
 label280("新站稳 ↔ 举灯候选",Vector2(570,116))
 label280("叠图：新站稳 ＋ 当前举灯",Vector2(1010,116))
 for x in [235.,700.,1165.]:
  var sprite=Sprite2D.new();sprite.position=Vector2(x,745);sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(sprite);sprites280.append(sprite)
 apply280(sprites280[0],"original_front");apply280(sprites280[1],"stand_A");apply280(sprites280[2],"stand_A");sprites280[2].modulate.a=.45
 ghost280=Sprite2D.new();ghost280.position=Vector2(1165,745);ghost280.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;ghost280.modulate=Color(1.,1.,1.,.5);add_child(ghost280);apply280(ghost280,choice280)
 state_label280=label280("",Vector2(520,770),22)
 var x=35.
 for item in [["播放 / 暂停",toggle280],["站稳帧",show_stand280],["举灯帧",show_raise280]]:
  var button=Button.new();button.text=item[0];button.position=Vector2(x,820);button.size=Vector2(170,42);button.pressed.connect(item[1]);add_child(button);x+=185.
 guide280=label280("",Vector2(35,870),15)
 lines280=Node2D.new();add_child(lines280);lines280.draw.connect(draw_guides280)
 update280()
 queue_redraw()
func apply280(sprite: Sprite2D,key: String) -> void:
 var p=poses280[key];sprite.texture=p.texture;sprite.offset=Vector2(p.texture.get_width()*.5-p.foot.x,p.texture.get_height()*.5-p.foot.y);sprite.scale=Vector2.ONE*p.scale
func update280() -> void:
 var key="stand_A" if fmod(phase280,1.4)<.65 else choice280
 apply280(sprites280[1],key);apply280(ghost280,choice280)
 state_label280.text=("新站稳" if key=="stand_A" else "新举灯" if key=="raise_short" else "举灯稿")+(" · 循环中" if running280 else " · 暂停")
 guide280.text="两帧共用脚锚与缩放，原始 PNG 未程序修绘。局部生成仍非逐像素锁定；请看头、裙摆、亮度与颗粒是否跳变。"
func _process(delta: float) -> void:
 if running280:phase280+=delta;update280()
func toggle280() -> void:running280=not running280;update280()
func show_stand280() -> void:running280=false;phase280=0.;update280()
func show_raise280() -> void:running280=false;phase280=.8;update280()
func choose_short280() -> void:choice280="raise_short";update280()
func choose_c280() -> void:choice280="raise_C";update280()
func draw_guides280() -> void:
 for x in [235.,700.,1165.]:
  lines280.draw_line(Vector2(x-200,745),Vector2(x+200,745),Color("93d9c0"),1.)
  lines280.draw_line(Vector2(x,155),Vector2(x,755),Color(.8,.8,.85,.15),1.)
