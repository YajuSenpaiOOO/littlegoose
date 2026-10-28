extends Control
var battle: Node3D
var menu: PanelContainer
var stats: Label
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=Control.MOUSE_FILTER_IGNORE
 menu=PanelContainer.new();add_child(menu)
 var style := StyleBoxFlat.new();style.bg_color=Color(.06,.10,.085,.97);style.set_corner_radius_all(12);style.content_margin_left=28;style.content_margin_right=28;style.content_margin_top=24;style.content_margin_bottom=24;menu.add_theme_stylebox_override("panel",style)
 var box := VBoxContainer.new();box.add_theme_constant_override("separation",16);menu.add_child(box)
 var title := Label.new();title.text="这场演出结束了";title.add_theme_font_size_override("font_size",27);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;box.add_child(title)
 stats=Label.new();stats.add_theme_font_size_override("font_size",19);stats.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;box.add_child(stats)
 for action in ["再演一场","回小院整理记忆"]:
  var button := Button.new();button.text=action;button.custom_minimum_size=Vector2(480,52);button.add_theme_font_size_override("font_size",21);box.add_child(button)
  if action=="再演一场": button.pressed.connect(func(): battle.start_combat())
  else: button.pressed.connect(func(): battle.home116())
 menu.hide()
func show_menu(finished: bool) -> void:
 if not finished: menu.hide();return
 stats.text="陪演 %d 位 · 命中 %d 次 · 受击 %d 次\n这次带着：%s"%[battle.defeated_count,battle.landed_hits,battle.hurt_count,battle.memory_kit116.summary(battle.memory_kit116.equipped)]
 menu.show()
func _process(_delta: float) -> void:
 if menu.visible: menu.reset_size();menu.position=(get_viewport_rect().size-menu.size)*.5
