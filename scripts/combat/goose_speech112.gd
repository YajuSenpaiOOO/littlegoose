extends CanvasLayer
# Original yard bubble art; project a live 3D goose into a separate UI canvas.
const REGIONS = preload("res://assets/speech112/bubble_atlas_clean_v2.png")
var battle: Node3D
var pending: Array[Dictionary]=[]
var live: Node2D
var wait_left := 0.
var history: Array[Dictionary]=[]
class Bubble:
 extends Node2D
 var anchor: WeakRef
 var camera: Camera3D
 var words := ""
 var duration := 3.
 var age := 0.
 var snapped := false
 var body: Label
 var frame: StyleBoxTexture
 var tail: AtlasTexture
 var box := Vector2(100,48)
 func _ready() -> void:
  var regions: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/speech112/regions.json"))
  var texture := AtlasTexture.new();texture.atlas=REGIONS
  var r: Array=regions.bubble_frame.region;texture.region=Rect2(r[0],r[1],r[2],r[3])
  frame=StyleBoxTexture.new();frame.texture=texture
  for side in 4: frame.set_texture_margin(side,float(regions.bubble_frame.margins[side]))
  tail=AtlasTexture.new();tail.atlas=REGIONS;r=regions.bubble_tail.region;tail.region=Rect2(r[0],r[1],r[2],r[3])
  body=Label.new();body.text=words;body.mouse_filter=Control.MOUSE_FILTER_IGNORE
  body.add_theme_font_size_override("font_size",20);body.add_theme_color_override("font_color",Color(.38,.24,.45))
  body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.size=Vector2(300,0);add_child(body)
  body.visible_characters=0
  var font := ThemeDB.fallback_font
  box.x=clampf(font.get_string_size(words,HORIZONTAL_ALIGNMENT_LEFT,-1,20).x+38.,90.,338.)
  body.size.x=box.x-38.
 func _process(delta: float) -> void:
  age+=delta
  var goose: Node3D=anchor.get_ref() if anchor!=null else null
  if not is_instance_valid(goose) or not goose.is_inside_tree() or not is_instance_valid(camera): queue_free();return
  if age>=duration: queue_free();return
  var at := goose.global_position+Vector3.UP*.45
  visible=not camera.is_position_behind(at)
  if not visible: return
  var screen := camera.unproject_position(at)
  visible=get_viewport().get_visible_rect().grow(60.).has_point(screen)
  if not visible: return
  var wanted := screen+Vector2(76,-44)
  position=wanted if not snapped else position.lerp(wanted,minf(1.,delta*9.));snapped=true
  box.y=maxf(44.,body.get_minimum_size().y+24.)
  var extent := get_viewport().get_visible_rect().size
  position.x=clampf(position.x,box.x*.5+8.,maxf(box.x*.5+8.,extent.x-box.x*.5-8.))
  position.y=clampf(position.y,box.y+10.,extent.y-14.)
  var pop := clampf(age/.18,0.,1.);scale=Vector2.ONE*(.6+.4*sin(pop*PI*.5))
  body.position=Vector2(-box.x*.5+19.,-box.y+12.)
  body.visible_characters=int(age*22.)
  modulate.a=clampf((duration-age)/.15,0.,1.)
  queue_redraw()
 func _draw() -> void:
  draw_set_transform(Vector2.ZERO,0.,Vector2.ONE*.035)
  draw_style_box(frame,Rect2(Vector2(-box.x*.5,-box.y)/.035,box/.035))
  draw_set_transform(Vector2.ZERO,0.)
  draw_texture_rect(tail,Rect2(-box.x*.5+12.,-3.,12.,14.),false)
func _ready() -> void:
 layer=14;name="GooseSpeech112"
func dismiss() -> void:
 pending.clear();wait_left=0.
 if is_instance_valid(live): live.queue_free()
 live=null
func say_card(words: String) -> void:
 dismiss()
 if words.is_empty(): return
 var geese: Array=[battle.goose]
 if is_instance_valid(battle.skills110): geese.append_array(battle.skills110.geese110)
 var segments := words.split("小黑鹅",false)
 if segments.size()<=1:
  pending.append({"anchor":weakref(battle.goose),"text":words})
 else:
  for i in segments.size():
   var segment: String=segments[i];var colon := segment.find("：")
   var text := segment.substr(colon+1) if colon>=0 else segment
   pending.append({"anchor":weakref(geese[mini(i,geese.size()-1)]),"text":text})
 _advance()
func _advance() -> void:
 if pending.is_empty(): return
 var next: Dictionary=pending.pop_front();var anchor: Node=next.anchor.get_ref()
 if not is_instance_valid(anchor) or not anchor.is_inside_tree(): _advance();return
 if is_instance_valid(live): live.queue_free()
 var bubble := Bubble.new();bubble.anchor=next.anchor;bubble.camera=battle.camera;bubble.words=next.text
 bubble.duration=maxf(3.,float(bubble.words.length())/22.+1.3)
 add_child(bubble);live=bubble;wait_left=bubble.duration
 history.append({"anchor":anchor.get_instance_id(),"text":bubble.words})
 if history.size()>16: history.pop_front()
func _process(delta: float) -> void:
 if battle.draft_open: dismiss();return
 wait_left-=delta
 if wait_left<=0. and not pending.is_empty(): _advance()
