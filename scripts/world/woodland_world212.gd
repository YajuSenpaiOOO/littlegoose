extends "res://scripts/world/woodland_world211.gd"
var ready212 := false
func _init() -> void:
 super._init();memory_save116="user://sister212_preview.cfg"
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 212 · 蜘蛛姐姐Boss节奏试演")
func _ready() -> void:
 await super._ready()
 ready206=false
 var a: Vector2=transport206.start_at
 var b: Vector2=transport206.end_at
 drops206.free();transport206.free()
 transport206=preload("res://scripts/art/sister_boss212.gd").new()
 transport206.world=self;transport206.start_at=a;transport206.end_at=b;add_child(transport206)
 drops206=preload("res://scripts/combat/plush_boss212.gd").new()
 drops206.world=self;drops206.rig=transport206;add_child(drops206)
 transport206.calibrate206();transport206.restart()
 _teleport15(a+Vector2(0.,1.8))
 ready206=true;ready212=true
func _process(delta: float) -> void:
 super._process(delta)
 if not ready212: return
 guide206.text="212 蜘蛛姐姐 · "+transport206.label()+"\n姐姐耐力 "+str(transport206.hp212)+"/6 · 小鹅试演心心 "+str(preview_hearts206)+"/5"+"\nWASD移动 / Shift闪避 / 右键防御与弹反 / E近身轻拍（临时反击）\nF6暂停 / F7重开 / F8观看点 / F3退出到小院"+("\n"+notice_text206 if notice_time206>0. else "")
 if not transport206.running: guide206.text+="\n【已暂停】"
 # Leaving the demonstration also stops attacks; no forest context was replaced.
 if Vector2(hero.position.x,hero.position.z).distance_to(watch206)>18.:
  transport206.running=false;drops206.clear206()
func _input(event: InputEvent) -> void:
 if ready212 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_E:
   transport206.counter212();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F5:
   get_viewport().set_input_as_handled();return
 super._input(event)
