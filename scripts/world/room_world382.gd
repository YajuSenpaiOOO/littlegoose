extends "res://scripts/world/room_world381.gd"
# Directional anatomy order, retaining ordinary scene depth and all source pixels.
var hair382: Sprite3D
var fixed382:=true
func _ready() -> void:
 await super._ready()
 hair382=Sprite3D.new();hair382.name="BackHairForeground382";rig379.add_child(hair382)
 hair382.layers=body379.layers;hair382.texture_filter=body379.texture_filter
 hair382.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink=preload("res://scripts/combat/hero192.gd").make_receiver192();hair382.material_override=ink;hair382.shaded=true
 set_direction381(direction381)
 DisplayServer.window_set_title("小白鹅 · 382 · 翼根与手臂层序修正")
 help367="382 · 翼根与手臂层序修正\nB 新层序/381旧层序\nF8/F9 切方向 · P 暂停 · U 慢放 · V 逐帧\nO 悬浮呼吸 · I 原C · Y 悬浮/同基线\nK 重排 · N 近看 · F2 昼夜 · L 补光"
 refresh367()
func set_direction381(value: int) -> void:
 super.set_direction381(value)
 apply_order382()
func apply_order382() -> void:
 if not is_instance_valid(hair382):return
 hair382.visible=false
 if fixed382:
  if direction381==0 or direction381==2:
   # Both wings emerge from the back: the outer arm/sleeve occludes the root.
   wing379.position.z=-.018
  elif direction381==1:
   # Seen from behind, the wings are closer than the back, but below the hair.
   wing379.position=Vector3(0,.70,.018)
   var tex:=atlas381(preload("res://assets/black_goose_flight381/bodies.png"),Rect2(1024,0,512,570))
   hair382.texture=tex;hair382.pixel_size=body379.pixel_size
   hair382.offset=Vector2(0,930.-285.)
   hair382.material_override.albedo_texture=tex.atlas;hair382.visible=true
 align_hair382()
 update_shadow380()
func align_hair382() -> void:
 if not is_instance_valid(hair382) or not hair382.visible:return
 # Homothety towards camera preserves exact screen registration of source pixels.
 # This avoids the duplicate outline caused by simply moving the upper layer in Z.
 var camera_local: Vector3=rig379.to_local(camera.global_position)
 var ratio:=.04/maxf(.1,camera_local.z)
 hair382.position=camera_local*ratio;hair382.scale=Vector3.ONE*(1.-ratio)
func _process(delta: float) -> void:
 super._process(delta)
 align_hair382()
func _input(event: InputEvent) -> void:
 if is_instance_valid(hair382) and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_B:
  fixed382=not fixed382;set_direction381(direction381);get_viewport().set_input_as_handled();return
 super._input(event)
