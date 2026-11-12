extends "res://scripts/world/woodland_world298.gd"

func stage_script297() -> Script:
 return preload("res://scripts/art/paper_stage313.gd")

func preview_spawn297() -> Vector2:
 return meadow.landmarks.grove + Vector2(-24., -22.5)

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 313 · 城堡 C / 妹妹露台")

func preview_hint297() -> String:
 return "313 城堡 C · 妹妹露台\nF12 重播 / F3 回院\n演出后 F9 开心 / F10 生气"

func _process(delta: float) -> void:
 super._process(delta)
 if available297:
  camera.v_offset = 1.25 if mode264 == "away" else 0.
  guide206.text = "纸景落地 / 妹妹登台 · F12 重播"

func _input(event: InputEvent) -> void:
 if available297 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode in [KEY_F9, KEY_F10]:
   stage297.reaction313(4 if event.physical_keycode == KEY_F9 else 5)
   get_viewport().set_input_as_handled()
   return
 super._input(event)