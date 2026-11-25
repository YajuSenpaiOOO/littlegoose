extends "res://scripts/world/room_world377.gd"
# Isolated front-flight rig: body stays still; only the two back wings move.
var rig378: Node3D
var body378: Sprite3D
var wings378: Array[Node3D]=[]
var phase378:=0.0
var flap378:=true
var slow378:=false
var reference378:=false
func refresh367() -> void:
 if is_instance_valid(label367):label367.text=help367
func part378(rect: Rect2i, pivot: Vector2, density: float, parent: Node3D) -> Sprite3D:
 var atlas:=AtlasTexture.new();atlas.atlas=preload("res://assets/black_goose_flight378/parts.png");atlas.region=Rect2(rect)
 var s:=Sprite3D.new();s.texture=atlas
 s.pixel_size=density;s.offset=Vector2(rect.size.x*.5-pivot.x,pivot.y-rect.size.y*.5)
 s.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 s.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;s.layers=1|(1<<19)
 var ink=preload("res://scripts/combat/hero192.gd").make_receiver192();ink.albedo_texture=s.texture;s.material_override=ink;s.shaded=true
 parent.add_child(s)
 var shadow=preload("res://scripts/combat/actor_shadow105.gd").new();shadow.battle=self;shadow.visual=s;shadow.opacity_scale=.7;rig378.add_child(shadow)
 return s
func _ready() -> void:
 await super._ready()
 flight377.texture=room.source356("res://assets/black_goose_flight378/selected-C.png")
 flight377.material_override.albedo_texture=flight377.texture
 rig378=Node3D.new();rig378.name="SeparateFlightParts378";add_child(rig378)
 body378=part378(Rect2i(0,0,550,1024),Vector2(300,935),1.44/860.,rig378)
 body378.name="StaticBody"
 for side in 2:
  var pivot:=Node3D.new();pivot.name="LeftWingRoot" if side==0 else "RightWingRoot";rig378.add_child(pivot);wings378.append(pivot)
  pivot.position=Vector3(-.25 if side==0 else .25,.68,-.025)
  part378(Rect2i(560 if side==0 else 1040,320,464,380),Vector2(410 if side==0 else 65,205),.0017,pivot)
 DisplayServer.window_set_title("小白鹅 · 378 · C拆翼拍动试演")
 help367="378 · C拆翼拍动试演\n左主角 / 中站姿 / 右飞姿\nP 拍翼暂停 · U 慢放 · I 原C/拆件\nY 悬浮/同基线 · K 重排 · N 近看\nF2 昼夜 · L 补光 · 本体保持静态\n仅原地独立双翼试演，未接飞行移动"
 refresh367();pose378()
func pose378() -> void:
 if not is_instance_valid(rig378):return
 rig378.position=flight_root377.position+Vector3(0,.4 if lift377 else 0.,0)
 rig378.visible=not reference378;flight377.visible=reference378
 for side in 2:
  var sign378: float=1. if side==0 else -1.
  wings378[side].rotation=Vector3(0,sign378*(.3+.45*sin(phase378)),sign378*.24*sin(phase378))
func _process(delta: float) -> void:
 super._process(delta)
 if flap378:phase378+=delta*TAU*(.45 if slow378 else 1.8)
 pose378()
func _input(event: InputEvent) -> void:
 if is_instance_valid(rig378) and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_P:flap378=not flap378;get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_U:slow378=not slow378;get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_I:reference378=not reference378;pose378();get_viewport().set_input_as_handled();return
 super._input(event)
