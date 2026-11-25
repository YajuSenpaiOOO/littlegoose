extends "res://scripts/world/room_world372.gd"
func companion_script373() -> Script:return preload("res://scripts/combat/goose_follow373.gd")
var companion373: CharacterBody3D
func _ready() -> void:
 await super._ready()
 var old:=human372
 companion373=companion_script373().new();companion373.host=self;companion373.collision_layer=1;companion373.collision_mask=1;companion373.position=old.position;add_child(companion373)
 human_visual372.reparent(companion373);human_shadow372.reparent(companion373)
 var shape:=human_body372.get_child(0);shape.reparent(companion373)
 old.remove_child(human_body372);human_body372.free();human_body372=null
 remove_child(old);old.queue_free();human372=companion373;companion373.visual=human_visual372
 companion373.setup373()
 DisplayServer.window_set_title("小白鹅 · 373 · 小黑鹅移动与跟随")
 help367="373 · 小黑鹅四向移动与跟随
WASD 走动 · J 跟随/原地等候
H 到地毯站位并面向主角
N 双人近看 · F7 复位
F2 昼夜 · L 补光 · F12 镜头跟随
E 床边睡起 · F3 出门"
 refresh367()
func reset355() -> void:
 super.reset355()
 if is_instance_valid(companion373):companion373.velocity=Vector3.ZERO;companion373.reset_physics_interpolation();companion373.resume373()
func _input(event: InputEvent) -> void:
 if ready355 and is_instance_valid(companion373) and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_J:
   if companion373.mode373=="follow":companion373.hold373()
   else:companion373.resume373()
   get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_H:companion373.stage373(Vector3(0.,.05,0.));get_viewport().set_input_as_handled();return
 super._input(event)
func interact355() -> void:
 if sleeping362:set_sleep362(0);return
 var item: Dictionary=choose355()
 if not item.is_empty():
  match item.id:
   "exit":leave371();return
   "bed":set_sleep362(1);return
   "hourglass":pour355=1.5;message355="金色的时光沙，轻轻流下。"
   "wardrobe":message355="衣柜里，留着两份整整齐齐的换洗用品。"
   "tea":message355="一大一小，两只杯子。"
   _:message355=item.title
  message_left355=3.;return
 if is_instance_valid(companion373) and hero.global_position.distance_to(companion373.global_position)<.95:
  message355="小黑鹅 · J切换跟随/等候，H到地毯站位";message_left355=4.
