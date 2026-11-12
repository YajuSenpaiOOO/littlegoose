extends Control
var poses283 := {}
var sprites283: Array[Sprite2D]=[]
var ghost283: Sprite2D
var choice283 := "raise_short"
var phase283 := 0.
var running283 := true
var state_label283: Label
var guide283: Label
var lines283: Node2D
func label283(words: String,at: Vector2,size: int=19) -> Label:
 var label=Label.new();label.text=words;label.position=at;label.add_theme_font_size_override("font_size",size);add_child(label);return label
func _ready() -> void:
 DisplayServer.window_set_title("小白鹅 · 283 · 变身两帧连续性查验")
 get_window().size=Vector2i(1400,900)
 var background=ColorRect.new();background.color=Color("302c38");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(background)
 var atlas=AtlasTexture.new();atlas.atlas=preload("res://assets/hero_pixel/walk_source.png");atlas.region=Rect2(633,0,600,800)
 poses283["original_front"]={"texture":atlas,"foot":Vector2(300,749),"scale":.75}
 # Both candidates share one canvas, anchor and scale. No per-frame eye rescaling.
 for key in ["stand_A","raise_short"]:
  poses283[key]={"texture":load("res://assets/hero_transform280/stand.png" if key=="stand_A" else "res://assets/hero_transform283/raise.png"),"foot":Vector2(587,1229),"scale":.595*.75}
 poses283["raise_short"]["foot"]=Vector2(587,1232)
 poses283["raise_C"]=poses283["raise_short"]
 label283("283 · 原 idle / 站稳 / 像素举灯查验",Vector2(32,18),27)
 label283("无补间、无拉伸、无抬高整张图。看头发、脸、衣服在换帧时是否跳变。",Vector2(32,58),18)
 label283("原正面帧（固定）",Vector2(125,116))
 label283("新站稳 ↔ 举灯候选",Vector2(570,116))
 label283("叠图：新站稳 ＋ 当前举灯",Vector2(1010,116))
 for x in [235.,700.,1165.]:
  var sprite=Sprite2D.new();sprite.position=Vector2(x,745);sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(sprite);sprites283.append(sprite)
 apply283(sprites283[0],"original_front");apply283(sprites283[1],"stand_A");apply283(sprites283[2],"stand_A");sprites283[2].modulate.a=.45
 ghost283=Sprite2D.new();ghost283.position=Vector2(1165,745);ghost283.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;ghost283.modulate=Color(1.,1.,1.,.5);add_child(ghost283);apply283(ghost283,choice283)
 state_label283=label283("",Vector2(520,770),22)
 var x=35.
 for item in [["播放 / 暂停",toggle283],["站稳帧",show_stand283],["举灯帧",show_raise283]]:
  var button=Button.new();button.text=item[0];button.position=Vector2(x,820);button.size=Vector2(170,42);button.pressed.connect(item[1]);add_child(button);x+=185.
 guide283=label283("",Vector2(35,870),15)
 lines283=Node2D.new();add_child(lines283);lines283.draw.connect(draw_guides283)
 update283()
 queue_redraw()
func apply283(sprite: Sprite2D,key: String) -> void:
 var p=poses283[key];sprite.texture=p.texture;sprite.offset=Vector2(p.texture.get_width()*.5-p.foot.x,p.texture.get_height()*.5-p.foot.y);sprite.scale=Vector2.ONE*p.scale
func update283() -> void:
 var key="stand_A" if fmod(phase283,1.4)<.65 else choice283
 apply283(sprites283[1],key);apply283(ghost283,choice283)
 state_label283.text=("新站稳" if key=="stand_A" else "新举灯" if key=="raise_short" else "举灯稿")+(" · 循环中" if running283 else " · 暂停")
 guide283.text="共用缩放；按鞋底标脚锚。比较像素颗粒与描边；微侧身属于动作变化。尚未通过连续性验收。"
func _process(delta: float) -> void:
 if running283:phase283+=delta;update283()
func toggle283() -> void:running283=not running283;update283()
func show_stand283() -> void:running283=false;phase283=0.;update283()
func show_raise283() -> void:running283=false;phase283=.8;update283()
func choose_short283() -> void:choice283="raise_short";update283()
func choose_c283() -> void:choice283="raise_C";update283()
func draw_guides283() -> void:
 for x in [235.,700.,1165.]:
  lines283.draw_line(Vector2(x-200,745),Vector2(x+200,745),Color("93d9c0"),1.)
  lines283.draw_line(Vector2(x,155),Vector2(x,755),Color(.8,.8,.85,.15),1.)
