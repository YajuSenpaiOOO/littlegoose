extends "res://scripts/world/woodland_world115.gd"
var woodland_ready116 := false
var memory_kit116=preload("res://scripts/combat/memory_kit116.gd").new()
var workshop116: Node3D
var memory_ui116: Control
var workshop_hint116: Label
var memory_save116 := "user://memory_kit116.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 116 · 树墩魔法锅 / 记忆百宝盒")
func _trial_ui_script114() -> Script: return preload("res://scripts/combat/workshop_result116.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/hud116.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time116.gd")
func _workshop_script116() -> Script: return preload("res://scripts/art/memory_workshop116.gd")
func _memory_ui_script116() -> Script: return preload("res://scripts/combat/memory_ui116.gd")
func _workshop_hint_text116() -> String: return "F  整理记忆 · F5 林地试演"
func _ready() -> void:
 super._ready()
 while not woodland_ready115: await get_tree().physics_frame
 memory_kit116.load_from(memory_save116)
 workshop116=_workshop_script116().new();workshop116.world=self;add_child(workshop116)
 var layer := CanvasLayer.new();layer.layer=27;add_child(layer)
 memory_ui116=_memory_ui_script116().new();memory_ui116.world=self;layer.add_child(memory_ui116)
 workshop_hint116=Label.new();workshop_hint116.add_theme_font_size_override("font_size",20);workshop_hint116.add_theme_color_override("font_outline_color",Color(.07,.12,.09,.95));workshop_hint116.add_theme_constant_override("outline_size",5);workshop_hint116.mouse_filter=Control.MOUSE_FILTER_IGNORE;layer.add_child(workshop_hint116)
 woodland_ready116=true;home116();time55.update_guide();_title35();print("WOODLAND116_READY kit=",memory_kit116.equipped)
func _apply_kit116() -> void:
 buffs.levels.clear()
 for id in memory_kit116.equipped: buffs.levels[id]=1
 _apply_owned_buffs();_cancel_charge();aim_tick114=-1
func start_combat(reposition := true) -> void:
 if not woodland_ready116: return
 auto114=false;super.start_combat(reposition);_apply_kit116()
 encounter_hud.announce("林地试演",memory_kit116.summary(memory_kit116.equipped),2.2)
func home116() -> void:
 if not woodland_ready116: return
 if is_instance_valid(memory_ui116): memory_ui116.hide()
 active114=false;auto114=false;target114=null;_leave_encounter();combat_paused=false;result_dismissed=true
 trial_ui114.menu.hide();_travel_region("home");_apply_kit116();_title35()
func can_open_memory116() -> bool:
 return woodland_ready116 and not active114 and not trial_ui114.menu.visible and workshop116.near()
func open_memory116() -> bool:
 if not can_open_memory116() or memory_ui116.visible: return false
 _clear_combat_shots();_cancel_charge();hero.cancel_guard109();combat_paused=true;hero.controls_enabled=false;hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.combat_impulse=Vector2.ZERO
 memory_ui116.open116();return true
func close_memory116(commit: bool,trial := false) -> bool:
 if not is_instance_valid(memory_ui116) or not memory_ui116.visible: return false
 var spoken := ""
 if commit:
  var old: Array[String]=memory_kit116.equipped.duplicate()
  if not memory_kit116.commit(memory_ui116.working): memory_ui116.feedback.text="记忆口袋装不下了。";return false
  if memory_kit116.save_to(memory_save116)!=OK:
   memory_kit116.commit(old);memory_ui116.feedback.text="暂时没能收好，稍后再试一下。";return false
  for id in memory_kit116.equipped:
   if id not in old: spoken=memory_kit116.card(id).line
 memory_ui116.hide();combat_paused=false;hero.controls_enabled=true;fire_needs_release=Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
 if commit: _apply_kit116()
 if trial and commit: start_combat()
 elif not spoken.is_empty(): speech112.say_card(spoken)
 return true
func _input(event: InputEvent) -> void:
 if not woodland_ready116 or not event is InputEventKey or not event.pressed or event.echo or event.alt_pressed or event.ctrl_pressed: return
 if memory_ui116.visible:
  if event.physical_keycode==KEY_ESCAPE: close_memory116(false);get_viewport().set_input_as_handled()
  elif event.physical_keycode in [KEY_F,KEY_F2,KEY_F3,KEY_F5,KEY_F8]: get_viewport().set_input_as_handled()
  return
 if event.physical_keycode==KEY_F and can_open_memory116(): open_memory116();get_viewport().set_input_as_handled()
 elif event.physical_keycode==KEY_F3: home116();get_viewport().set_input_as_handled()
 elif event.physical_keycode in [KEY_F5,KEY_F8]: start_combat();get_viewport().set_input_as_handled()
 elif event.physical_keycode==KEY_F2: get_viewport().set_input_as_handled()
func _process(delta: float) -> void:
 super._process(delta)
 if not woodland_ready116: return
 draft_ui.visible=active114 and not memory_ui116.visible
 workshop_hint116.visible=can_open_memory116() and not memory_ui116.visible
 if workshop_hint116.visible:
  workshop_hint116.text=_workshop_hint_text116();workshop_hint116.reset_size()
  workshop_hint116.position=camera.unproject_position(workshop116.tin.global_position+Vector3(0,0,.45))-Vector2(workshop_hint116.size.x*.5,-5.)
func _travel_region(key: String) -> void:
 super._travel_region(key)
 if woodland_ready116:
  active114=false;trial_ui114.menu.hide();target114=null;combat_paused=false
