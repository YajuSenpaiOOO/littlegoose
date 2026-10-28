extends "res://scripts/world/woodland_world203.gd"
func _init() -> void:
 super._init();memory_save116="user://forest204_preview.cfg"
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_ground204.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 204 · 纸飞机贴地辅助圈")
func _input(event: InputEvent) -> void:
 # Plain Q toggles the hero-moment skill since 161, so the 104 shadow-quality
 # switch is unreachable in this build; expose it on a free chord instead.
 if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed:
  if event.physical_keycode==KEY_S:
   set_shadow_quality104(not high_shadows104)
   if is_instance_valid(time55): time55.update_guide()
   get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F:
   # On a 300 Hz panel a cap that divides 300 evenly (150/100/75/60/50) gives
   # perfectly even pacing when the frame time is stable; cycle and compare.
   var caps := [0,100,60,50]
   cap_index204=(cap_index204+1)%caps.size()
   Engine.max_fps=caps[cap_index204]
   if is_instance_valid(encounter_hud):
    encounter_hud.announce("帧率上限 · "+("不限" if Engine.max_fps==0 else str(Engine.max_fps)+" FPS"),"Ctrl+Alt+F 继续切换（不限→100→60→50）",2.5)
   get_viewport().set_input_as_handled();return
 super._input(event)
var cap_index204 := 0
func _ready() -> void:
 await super._ready()
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("203 "): child.text=child.text.replace("203 毛絮受击 / 软软幽灵猫","204 纸飞机贴地辅助圈 · Ctrl+Alt+S 阴影档位 · Ctrl+Alt+F 帧率上限")
