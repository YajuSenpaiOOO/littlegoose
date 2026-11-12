extends Control
var poses284 := {}
var sprites284: Array[Sprite2D]=[]
var ghost284: Sprite2D
var choice284 := "raise_short"
var phase284 := 0.
var running284 := true
var state_label284: Label
var guide284: Label
var lines284: Node2D
func label284(words: String,at: Vector2,size: int=19) -> Label:
 var label=Label.new();label.text=words;label.position=at;label.add_theme_font_size_override("font_size",size);add_child(label);return label
func _ready() -> void:
 DisplayServer.window_set_title("小白鹅 · 284 · 变身两帧连续性查验")
 get_window().size=Vector2i(1400,900)
 var background=ColorRect.new();background.color=Color("302c38");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(background)
 var atlas=AtlasTexture.new();atlas.atlas=preload("res://assets/hero_pixel/walk_source.png");atlas.region=Rect2(633,0,600,800)
 poses284["original_front"]={"texture":atlas,"foot":Vector2(300,749),"scale":.75}
 # Both candidates share one canvas, anchor and scale. No per-frame eye rescaling.
 for key in ["stand_A","raise_short"]:
  poses284[key]={"texture":load("res://assets/hero_transform284/stand_closed.png" if key=="stand_A" else "res://assets/hero_transform284/raise_open.png"),"foot":Vector2(587,1229),"scale":.595*.75}
 poses284["stand_A"]["foot"]=Vector2(587,1230)
 poses284["raise_short"]["foot"]=Vector2(587,1230)
 poses284["raise_C"]=poses284["raise_short"]
 label284("284 · 原 idle / 闭眼凝神 / 睁眼举灯",Vector2(32,18),27)
 label284("无补间、无拉伸、无抬高整张图。看头发、脸、衣服在换帧时是否跳变。",Vector2(32,58),18)
 label284("原正面帧（固定）",Vector2(125,116))
 label284("闭眼站稳 ↔ 举灯候选",Vector2(570,116))
 label284("叠图：闭眼站稳 ＋ 当前举灯",Vector2(1010,116))
 for x in [235.,700.,1165.]:
  var sprite=Sprite2D.new();sprite.position=Vector2(x,745);sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(sprite);sprites284.append(sprite)
 apply284(sprites284[0],"original_front");apply284(sprites284[1],"stand_A");apply284(sprites284[2],"stand_A");sprites284[2].modulate.a=.45
 ghost284=Sprite2D.new();ghost284.position=Vector2(1165,745);ghost284.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;ghost284.modulate=Color(1.,1.,1.,.5);add_child(ghost284);apply284(ghost284,choice284)
 state_label284=label284("",Vector2(520,770),22)
 var x=35.
 for item in [["播放 / 暂停",toggle284],["站稳帧",show_stand284],["举灯帧",show_raise284]]:
  var button=Button.new();button.text=item[0];button.position=Vector2(x,820);button.size=Vector2(170,42);button.pressed.connect(item[1]);add_child(button);x+=185.
 guide284=label284("",Vector2(35,870),15)
 lines284=Node2D.new();add_child(lines284);lines284.draw.connect(draw_guides284)
 update284()
 queue_redraw()
func apply284(sprite: Sprite2D,key: String) -> void:
 var p=poses284[key];sprite.texture=p.texture;sprite.offset=Vector2(p.texture.get_width()*.5-p.foot.x,p.texture.get_height()*.5-p.foot.y);sprite.scale=Vector2.ONE*p.scale
func update284() -> void:
 var key="stand_A" if fmod(phase284,1.4)<.65 else choice284
 apply284(sprites284[1],key);apply284(ghost284,choice284)
 state_label284.text=("闭眼站稳" if key=="stand_A" else "睁眼举灯" if key=="raise_short" else "举灯稿")+(" · 循环中" if running284 else " · 暂停")
 guide284.text="共用缩放；按鞋底标脚锚。比较脸型、肤色与颗粒；闭睁眼和微侧身属于动作变化。尚未通过连续性验收。"
func _process(delta: float) -> void:
 if running284:phase284+=delta;update284()
func toggle284() -> void:running284=not running284;update284()
func show_stand284() -> void:running284=false;phase284=0.;update284()
func show_raise284() -> void:running284=false;phase284=.8;update284()
func choose_short284() -> void:choice284="raise_short";update284()
func choose_c284() -> void:choice284="raise_C";update284()
func draw_guides284() -> void:
 for x in [235.,700.,1165.]:
  lines284.draw_line(Vector2(x-200,745),Vector2(x+200,745),Color("93d9c0"),1.)
  lines284.draw_line(Vector2(x,155),Vector2(x,755),Color(.8,.8,.85,.15),1.)
