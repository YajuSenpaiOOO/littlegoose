extends "res://scripts/world/woodland_world341.gd"
var combat_hud342: Control
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 342 · 战斗血条 / 主动技能HUD")
func _ready() -> void:
 await super._ready()
 var layer:=CanvasLayer.new()
 layer.layer=24
 add_child(layer)
 combat_hud342=preload("res://scripts/combat/combat_hud342.gd").new()
 combat_hud342.battle=self
 layer.add_child(combat_hud342)
 state_hud288.hide()
 hint288.text="342 战斗血条 / 主动技能HUD"
func active_slot342() -> Dictionary:
 var slot: Dictionary={"id":"","name":"未装备主动","state":"empty","ratio":0.,"seconds":0.}
 if int(levels226.get("flashlight",0))>0:
  slot.id="flashlight";slot.name="光能变身";slot.state="ready";slot.ratio=1.
  if skill288 and transform288.playing and not ended288:
   slot.state="intro" if transform288.age<transform288.INTRO else ("red" if transform288.is_red() else "active")
   slot.seconds=maxf(0.,transform288.remaining());slot.ratio=clampf(slot.seconds/8.,0.,1.)
  elif cooldown288>0.:
   slot.state="cooldown";slot.seconds=cooldown288;slot.ratio=1.-cooldown288/COOLDOWN288
 elif int(levels226.get("hero_moment",0))>0 and is_instance_valid(moment161):
  slot.id="hero_moment";slot.name="主角时刻";slot.state="ready";slot.ratio=1.
  if moment161.left161>0.:
   slot.state="active";slot.seconds=moment161.left161;slot.ratio=slot.seconds/7.
  elif moment161.cooldown161>0.:
   slot.state="cooldown";slot.seconds=moment161.cooldown161;slot.ratio=1.-slot.seconds/20.
 elif int(levels226.get("homework",0))>0 and is_instance_valid(paper_memories146):
  slot.id="homework";slot.name="课堂笔记";slot.state="ready" if not paper_memories146.pages146.is_empty() else "collect"
  slot.ratio=paper_memories146.pages146.size()/3.
  if paper_memories146.writing146:slot.state="active";slot.ratio=clampf(paper_memories146.write_age146/.65,0.,1.)
 if slot.state=="ready" and (not active114 or player_hp<=0. or result_open):slot.state="unavailable"
 return slot
func report_stats226() -> Dictionary:
 var report:=super.report_stats226()
 report.runtime_preview=342
 if report.has("paper_theatre337"):report.paper_theatre337.preview=342
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(combat_hud342):
  state_hud288.hide()
  if is_instance_valid(moment161) and is_instance_valid(moment161.label161):moment161.label161.hide()
  if is_instance_valid(theatre314):guide206.text=guide206.text.replace("341 城防弹幕","342 城防弹幕")
