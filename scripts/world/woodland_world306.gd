extends "res://scripts/world/woodland_world305.gd"

const HEAVY_PARRY_DAMAGE306 := 2.
var parry_threat306 := 0.
var ground_cues306 := false

func card_script301() -> Script:
 return preload("res://scripts/combat/paper_card306.gd")

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 306 · 纸偶读招 / 重弹反")

func _ready() -> void:
 await super._ready()
 hint288.text = "306 纸偶读招 / 重弹反\nF8混合 / F9恐龙 / F10怪兽 / F11骑士"

func heavy_parry_feedback() -> bool:
 return parry_threat306 >= HEAVY_PARRY_DAMAGE306

func parry_success(contact: Vector3, outward: Vector3) -> void:
 var before := parry_count
 super.parry_success(contact, outward)
 if parry_count == before or not heavy_parry_feedback():
  return
 heavy_parry_beat306()

func heavy_parry_beat306() -> void:
 impact_clock.cancel_pending("parry")
 impact_clock.cancel_pending("heavy306")
 hitstop(.15, true)
 impact_clock.add(.25, .28, .15, "heavy306")
 punch = maxf(punch, 1.35)

func _process(delta: float) -> void:
 super._process(delta)
 if ready301:
  guide206.text = guide206.text.replace("305 纸偶定位", "306 纸偶读招")
  guide206.text += "\nDelete 地面预告：" + ("开" if ground_cues306 else "关")

func _input(event: InputEvent) -> void:
 if ready301 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_DELETE and not console226.visible:
  ground_cues306 = not ground_cues306
  for card in live301():
   card.render301()
  get_viewport().set_input_as_handled()
  return
 super._input(event)
