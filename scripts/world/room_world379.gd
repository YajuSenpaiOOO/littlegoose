extends "res://scripts/world/room_world377.gd"
# One wing-pair sprite, shared fixed canvas and root; no procedural wing rotation.
var rig379: Node3D
var body379: Sprite3D
var wing379: Sprite3D
var frames379: Array[Texture2D]=[]
var age379:=0.0
var playing379:=true
var slow379:=false
var reference379:=false
var index379:=0
const ROOTS379=[Vector2(384,304),Vector2(384,304),Vector2(384,272),Vector2(384,272)]
func refresh367() -> void:
 if is_instance_valid(label367):label367.text=help367
func sprite379(texture: Texture2D, anchor: Vector2, density: float) -> Sprite3D:
 var s:=Sprite3D.new();s.texture=texture;s.pixel_size=density
 s.offset=Vector2(texture.get_width()*.5-anchor.x,anchor.y-texture.get_height()*.5)
 s.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 s.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;s.layers=1|(1<<19)
 var ink=preload("res://scripts/combat/hero192.gd").make_receiver192();ink.albedo_texture=texture.atlas if texture is AtlasTexture else texture;s.material_override=ink;s.shaded=true;rig379.add_child(s)
 var shadow=preload("res://scripts/combat/actor_shadow105.gd").new();shadow.battle=self;shadow.visual=s;shadow.opacity_scale=.7;rig379.add_child(shadow)
 return s
func _ready() -> void:
 await super._ready()
 flight377.texture=preload("res://assets/black_goose_flight378/selected-C.png");flight377.material_override.albedo_texture=flight377.texture
 rig379=Node3D.new();rig379.name="AnchoredFlight379";add_child(rig379)
 var body_tex:=AtlasTexture.new();body_tex.atlas=preload("res://assets/black_goose_flight378/parts.png");body_tex.region=Rect2(0,0,550,1024)
 body379=sprite379(body_tex,Vector2(300,935),1.44/860.);body379.name="StaticBody"
 var sheet=preload("res://assets/black_goose_flight379/wings.png")
 for i in 4:
  var frame:=AtlasTexture.new();frame.atlas=sheet;frame.region=Rect2((i%2)*768,(i/2)*512,768,512);frames379.append(frame)
 wing379=sprite379(frames379[0],ROOTS379[0],.0019);wing379.name="AnimatedBackWings"
 wing379.position=Vector3(-25.*1.44/860.,.70,-.025)
 DisplayServer.window_set_title("小白鹅 · 379 · 独立双翼逐帧动画")
 help367="379 · 独立双翼逐帧动画\n本体静态 / 双翼固定背部挂点\nP 暂停 · U 慢放 · V 暂停逐帧\nI 原C/新动画 · Y 悬浮/同基线\nK 重排 · N 近看 · F2 昼夜 · L 补光\n仅正面原地试演，未接移动或侧背方向"
 refresh367();pose379()
func show_frame379(i: int) -> void:
 index379=posmod(i,4);wing379.texture=frames379[index379];wing379.material_override.albedo_texture=frames379[index379].atlas
 wing379.offset=Vector2(384.-ROOTS379[index379].x,ROOTS379[index379].y-256.)
func pose379() -> void:
 if not is_instance_valid(rig379):return
 rig379.position=flight_root377.position+Vector3(0,.4 if lift377 else 0.,0)
 rig379.visible=not reference379;flight377.visible=reference379
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(wing379) and playing379:
  age379+=delta*(.25 if slow379 else 1.);show_frame379(int(age379/.14)%4)
 pose379()
func _input(event: InputEvent) -> void:
 if is_instance_valid(rig379) and event is InputEventKey and event.pressed and not event.echo:
  match event.physical_keycode:
   KEY_P:playing379=not playing379
   KEY_U:slow379=not slow379
   KEY_V:playing379=false;show_frame379(index379+1)
   KEY_I:reference379=not reference379;pose379()
   _:super._input(event);return
  get_viewport().set_input_as_handled();return
 super._input(event)
