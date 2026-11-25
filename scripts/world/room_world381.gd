extends "res://scripts/world/room_world380.gd"
var far381: Sprite3D
var direction381:=0
var initialized381:=false
var near_frames381: Array[Texture2D]=[]
var far_frames381: Array[Texture2D]=[]
var front_frames381: Array[Texture2D]=[]
var front_body381: Texture2D
var body_anchor381:=Vector2.ZERO
const DIRECTIONS381=["左面","背面","右面","正面"]
func atlas381(sheet: Texture2D, rect: Rect2) -> AtlasTexture:
 var tex:=AtlasTexture.new();tex.atlas=sheet;tex.region=rect;return tex
func _ready() -> void:
 await super._ready()
 front_frames381.assign(frames379);front_body381=body379.texture
 far381=sprite379(frames379[0],ROOTS379[0],.0019);far381.name="FarWing381"
 for child in rig379.get_children():
  if child is MeshInstance3D and child.get("visual")!=null:child.enabled=false;child.visible=false
 ink380.shader=preload("res://scripts/art/flight_shadow381.gdshader")
 initialized381=true;set_direction381(0)
 DisplayServer.window_set_title("小白鹅 · 381 · 左右背面飞行")
 help367="381 · 左右背面飞行\nF8 切下一方向 · F9 切上一方向\nO 悬浮呼吸 · P 暂停 · U 慢放 · V 逐帧\nI 原正面C对照 · Y 悬浮/同基线\nK 重排 · N 近看 · F2 昼夜 · L 补光\n左右分别作画，角色右腿微微后翘"
 refresh367();update_shadow380()
func set_direction381(value: int) -> void:
 direction381=posmod(value,4);near_frames381.clear();far_frames381.clear()
 var side: bool=direction381==0 or direction381==2
 if direction381==3:
  body379.texture=front_body381;body379.offset=Vector2(-25,423);body379.pixel_size=1.44/860.
  frames379.assign(front_frames381);wing379.pixel_size=.0019;wing379.position=Vector3(-25.*1.44/860.,.70,-.025)
 else:
  var col: int=0 if direction381==0 else (2 if direction381==1 else 1)
  body379.texture=atlas381(preload("res://assets/black_goose_flight381/bodies.png"),Rect2(col*512,0,512,1024));body379.pixel_size=1.44/830.;body379.offset=Vector2(0,418)
  var sheet: Texture2D=load("res://assets/black_goose_flight381/"+(["left-wings.png","back-wings.png","right-wings.png"][direction381]))
  frames379.clear()
  for i in 4:
   if side:
    near_frames381.append(atlas381(sheet,Rect2((i%2)*768+4,(i/2)*512+4,376,504)))
    far_frames381.append(atlas381(sheet,Rect2((i%2)*768+388,(i/2)*512+4,376,504)))
    frames379.append(near_frames381[-1])
   else:frames379.append(atlas381(sheet,Rect2((i%2)*768,(i/2)*512,768,512)))
  wing379.pixel_size=.0021 if side else .0019
  wing379.position=Vector3(.055 if direction381==0 else (-.035 if direction381==2 else 0.),.65 if side else .68,.018 if side else -.025)
 body379.material_override.albedo_texture=body379.texture.atlas
 far381.visible=side
 if side:
  far381.pixel_size=.0021;far381.position=Vector3(wing379.position.x+(-.075 if direction381==0 else .075),.73,-.04)
 show_frame379(index379);update_shadow380();refresh367()
func refresh367() -> void:
 if is_instance_valid(label367):label367.text=help367+("\n当前："+DIRECTIONS381[direction381] if initialized381 else "")
func show_frame379(i: int) -> void:
 if not initialized381:super.show_frame379(i);return
 index379=posmod(i,4);wing379.texture=frames379[index379];wing379.material_override.albedo_texture=wing379.texture.atlas
 if direction381==3:wing379.offset=Vector2(0,ROOTS379[index379].y-256.);return
 var y: float=304. if index379<2 else 272.
 if direction381==1:wing379.offset=Vector2(0,y-256.);return
 var nx: float=70. if direction381==0 else 355.
 var fx: float=70. if direction381==0 else 276.
 wing379.offset=Vector2(188.-(nx-4.),y-4.-252.)
 far381.texture=far_frames381[index379];far381.material_override.albedo_texture=far381.texture.atlas
 far381.offset=Vector2(188.-(fx-4.),y-4.-252.)
func update_shadow380() -> void:
 super.update_shadow380()
 if not initialized381:return
 bind_shadow380("far",far381)
 ink380.set_shader_parameter("far_weight",1. if far381.visible else 0.)
 # Far wing is shorter than near wing; margin covers its small shoulder offset.
 shadow380.mesh.size+=Vector2(.25,.25)
func _input(event: InputEvent) -> void:
 if initialized381 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F8 or event.physical_keycode==KEY_F9:
   set_direction381(direction381+(1 if event.physical_keycode==KEY_F8 else -1));get_viewport().set_input_as_handled();return
 super._input(event)
