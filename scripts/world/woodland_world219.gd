extends "res://scripts/world/woodland_world216.gd"
var pig219: Node3D
var cotton219: Node3D
var ready219 := false
var hearts219 := 5
var text219 := ""
var notice_clock219 := 0.
func _init() -> void:
 super._init();memory_save116="user://pig219_preview.cfg"
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 219 · 猪猪双鼻孔喷棉絮试演")
func _ready() -> void:
 await super._ready()
 ready216=false;cat216.free()
 pig219=preload("res://scripts/art/pig_spray219.gd").new();pig219.world=self
 pig219.position=Vector3(spawn216.x,floor_height(spawn216),spawn216.y);add_child(pig219)
 cotton219=preload("res://scripts/combat/cotton_stream219.gd").new();cotton219.world=self;cotton219.pig=pig219;add_child(cotton219);pig219.stream=cotton219
 watch206=spawn216+pig219.direction219*2.3
 _teleport15(watch206)
 ready219=true
func notice219(value: String) -> void:
 text219=value;notice_clock219=2.
func _process(delta: float) -> void:
 super._process(delta)
 if not ready219:return
 if cotton219.running:notice_clock219=maxf(0.,notice_clock219-delta)
 var count=cotton219.counts219()
 var phase_name={"idle":"准备喷棉花","spray":"噗噗喷棉花","flat":"猪猪瘪掉了","gone":"暂时退场"}[pig219.phase219]
 guide206.text="219 猪猪 · 双鼻孔喷棉絮循环 · "+phase_name+"\n试演心心 "+str(hearts219)+"/5 · 大棉团 "+str(count.x)+" / 碎絮 "+str(count.y)+"\nWASD / Shift闪避 / 右键防御弹反 · E近身拍瘪（临时）\nF5 重播 / F6 暂停 / F7 重开恢复心心 / F8观看点\nF4 棉絮开关 / F9 三倍压力 "+("开" if cotton219.stress219 else "关")+" · F3小院\n棉团更新 "+str(cotton219.update_us)+"μs / 上传 "+str(cotton219.upload_us)+"μs"+("\n"+text219 if notice_clock219>0. else "")
 if not cotton219.running:guide206.text+="\n【已暂停】"
 if Vector2(hero.position.x,hero.position.z).distance_to(spawn216)>18.:
  cotton219.running=false;pig219.running219=false;cotton219.clear219()
func _input(event: InputEvent) -> void:
 if ready219 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  match event.physical_keycode:
   KEY_F4:
    cotton219.enabled219=not cotton219.enabled219;cotton219.clear219()
   KEY_F5: pig219.reset219();cotton219.running=true
   KEY_F6:
    cotton219.running=not cotton219.running;pig219.running219=cotton219.running
   KEY_F7:
    pig219.reset219();cotton219.running=true;hearts219=5;_teleport15(watch206)
   KEY_F8:_teleport15(watch206)
   KEY_F9:cotton219.stress219=not cotton219.stress219;pig219.reset219();cotton219.running=true
   KEY_E:
    if cotton219.running and Vector2(hero.position.x,hero.position.z).distance_to(spawn216)<1.25 and absf(hero.position.y-pig219.position.y)<.6:
     pig219.flatten219();notice219("猪猪被拍软了 · 已喷出的棉团继续飘散")
   KEY_V:return
   _:
    super._input(event);return
  get_viewport().set_input_as_handled();return
 super._input(event)
