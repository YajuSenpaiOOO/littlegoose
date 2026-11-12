extends Control
var poses279 := {}
var sprites279: Array[Sprite2D]=[]
var ghost279: Sprite2D
var choice279 := "raise_short"
var phase279 := 0.
var running279 := true
var state_label279: Label
var guide279: Label
var lines279: Node2D
func label279(words: String,at: Vector2,size: int=19) -> Label:
 var label=Label.new();label.text=words;label.position=at;label.add_theme_font_size_override("font_size",size);add_child(label);return label
func _ready() -> void:
 DisplayServer.window_set_title("小白鹅 · 279 · 变身两帧连续性查验")
 get_window().size=Vector2i(1400,900)
 var background=ColorRect.new();background.color=Color("302c38");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(background)
 var data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/hero_transform278/alignment-study.json"))
 var atlas=AtlasTexture.new();atlas.atlas=preload("res://assets/hero_pixel/walk_source.png");atlas.region=Rect2(633,0,600,800)
 for key in data:
  var tex: Texture2D=atlas if key=="original_front" else load("res://assets/hero_transform277/"+key+".png") if key!="raise_short" else preload("res://assets/hero_transform278/raise_short.png")
  poses279[key]={"texture":tex,"foot":Vector2(data[key].foot_estimated[0],data[key].foot_estimated[1]),"scale":float(data[key].scale_to_front_by_eye_span)*.75}
 label279("同脚点 · 同眼距 · 硬切查验",Vector2(32,18),27)
 label279("无补间、无拉伸、无抬高整张图。看头发、脸、衣服在换帧时是否跳变。",Vector2(32,58),18)
 label279("原正面帧（固定）",Vector2(125,116))
 label279("站稳 A ↔ 举灯候选",Vector2(570,116))
 label279("叠图：站稳 A ＋ 当前举灯",Vector2(1010,116))
 for x in [235.,700.,1165.]:
  var sprite=Sprite2D.new();sprite.position=Vector2(x,745);sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(sprite);sprites279.append(sprite)
 apply279(sprites279[0],"original_front");apply279(sprites279[1],"stand_A");apply279(sprites279[2],"stand_A");sprites279[2].modulate.a=.45
 ghost279=Sprite2D.new();ghost279.position=Vector2(1165,745);ghost279.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;ghost279.modulate=Color(1.,1.,1.,.5);add_child(ghost279);apply279(ghost279,choice279)
 state_label279=label279("",Vector2(520,770),22)
 var x=35.
 for item in [["播放 / 暂停",toggle279],["站稳帧",show_stand279],["举灯帧",show_raise279],["短臂候选",choose_short279],["旧高举 C",choose_c279]]:
  var button=Button.new();button.text=item[0];button.position=Vector2(x,820);button.size=Vector2(170,42);button.pressed.connect(item[1]);add_child(button);x+=185.
 guide279=label279("",Vector2(35,870),15)
 lines279=Node2D.new();add_child(lines279);lines279.draw.connect(draw_guides279)
 update279()
 queue_redraw()
func apply279(sprite: Sprite2D,key: String) -> void:
 var p=poses279[key];sprite.texture=p.texture;sprite.offset=Vector2(p.texture.get_width()*.5-p.foot.x,p.texture.get_height()*.5-p.foot.y);sprite.scale=Vector2.ONE*p.scale
func update279() -> void:
 var key="stand_A" if fmod(phase279,1.4)<.65 else choice279
 apply279(sprites279[1],key);apply279(ghost279,choice279)
 state_label279.text=("站稳 A" if key=="stand_A" else "短臂举灯候选" if key=="raise_short" else "旧高举 C")+(" · 循环中" if running279 else " · 暂停")
 guide279.text="绿色基线固定鞋底；尺度只按眼距归一化。数据为初步测量，头部内部画稿并不相同；这不是已接入战斗的变身动画。"
func _process(delta: float) -> void:
 if running279:phase279+=delta;update279()
func toggle279() -> void:running279=not running279;update279()
func show_stand279() -> void:running279=false;phase279=0.;update279()
func show_raise279() -> void:running279=false;phase279=.8;update279()
func choose_short279() -> void:choice279="raise_short";update279()
func choose_c279() -> void:choice279="raise_C";update279()
func draw_guides279() -> void:
 for x in [235.,700.,1165.]:
  lines279.draw_line(Vector2(x-200,745),Vector2(x+200,745),Color("93d9c0"),1.)
  lines279.draw_line(Vector2(x,155),Vector2(x,755),Color(.8,.8,.85,.15),1.)
