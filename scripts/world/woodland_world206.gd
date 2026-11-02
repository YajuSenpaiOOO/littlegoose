extends "res://scripts/world/woodland_world204.gd"
var transport206: Node3D
var ready206 := false
var guide206: Label
var shot206 := false
var watch206 := Vector2.ZERO
var clear_route206 := false
var drops206: Node3D
var preview_hearts206 := 5
var notice_text206 := ""
var notice_time206 := 0.
func _init() -> void:
 super._init();memory_save116="user://sister206_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 206 · 轻晃吊床 / 玩偶投放")
func start_spider170() -> void:
 # Parent202 normally auto-starts the spider trial. This animation preview must
 # not replace grove/navigation, start combat or grant any progression reward.
 return
func _ready() -> void:
 await super._ready()
 var center: Vector2=FOREST188.CENTER
 var route=choose_route206()
 transport206=preload("res://scripts/art/sister_transport206.gd").new()
 transport206.world=self;transport206.start_at=route[0];transport206.end_at=route[1]
 add_child(transport206)
 drops206=preload("res://scripts/combat/plush_drop206.gd").new();drops206.world=self;drops206.rig=transport206;add_child(drops206)
 watch206=(route[0]+route[1])*.5+Vector2(0.,2.2)
 _teleport15(watch206)
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("204 "):
     child.hide()
 var canvas=CanvasLayer.new();canvas.layer=15;add_child(canvas)
 guide206=Label.new();guide206.position=Vector2(24,195);guide206.add_theme_font_size_override("font_size",19)
 guide206.add_theme_color_override("font_shadow_color",Color.BLACK);guide206.add_theme_constant_override("shadow_outline_size",6);canvas.add_child(guide206)
 for i in 3: await get_tree().physics_frame
 transport206.calibrate206()
 ready206=true
func choose_route206() -> Array[Vector2]:
 var sphere=SphereShape3D.new();sphere.radius=.34
 var query=PhysicsShapeQueryParameters3D.new();query.shape=sphere;query.collision_mask=1;query.exclude=[hero.get_rid()]
 for row in [2.,0.,-2.]:
  for column in [4.,5.,6.]:
   var start: Vector2=FOREST188.CENTER+Vector2(column,row)
   var end: Vector2=start+Vector2(3.5,0.)
   var clear=true
   for i in 15:
    var p: Vector2=start.lerp(end,float(i)/14.)
    var h: float=floor_height(p)
    query.transform.origin=Vector3(p.x,h+.5,p.y)
    if absf(h+2.2)>.2 or not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():
     clear=false;break
   if clear:
    clear_route206=true;return [start,end]
 push_warning("206 did not find the expected clear demonstration corridor")
 return [FOREST188.CENTER+Vector2(5.,2.),FOREST188.CENTER+Vector2(8.5,2.)]
func _process(delta: float) -> void:
 super._process(delta)
 if not ready206: return
 if transport206.running: notice_time206=maxf(0.,notice_time206-delta)
 guide206.text="206 轻晃吊床 · "+transport206.label()+"\nF5 玩偶投放 "+("开" if transport206.drop_enabled206 else "关")+" · F6 暂停 · F7 重播 · F8 观看点\nWASD移动 / Shift闪避 / 右键防御 · 试演心心 "+str(preview_hearts206)+"/5\nF3小院 / F10调色 / F12灯光"+("\n"+notice_text206 if notice_time206>0. else "")
 if not shot206 and "--capture206" in OS.get_cmdline_user_args() and transport206.state=="travel" and transport206.age>1.2:
  shot206=true
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("res://docs/sister206-travel.png")
  get_tree().quit()
func _input(event: InputEvent) -> void:
 if ready206 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  match event.physical_keycode:
   KEY_F5:
    transport206.drop_enabled206=not transport206.drop_enabled206
    if not transport206.drop_enabled206: transport206.attack_trip206=false
    drops206.clear206();notice206("切换后从下一次运输开始投放");get_viewport().set_input_as_handled();return
   KEY_F6: transport206.running=not transport206.running;get_viewport().set_input_as_handled();return
   KEY_F7: transport206.restart();drops206.clear206();preview_hearts206=5;get_viewport().set_input_as_handled();return
   KEY_F8: _teleport15(watch206);get_viewport().set_input_as_handled();return
 super._input(event)
func notice206(value: String) -> void:
 notice_text206=value;notice_time206=2.
