extends "res://scripts/world/woodland_world204.gd"
var transport205: Node3D
var ready205 := false
var guide205: Label
var shot205 := false
var watch205 := Vector2.ZERO
var clear_route205 := false
func _init() -> void:
 super._init();memory_save116="user://sister205_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 205 · 蝙蝠吊床接送姐姐")
func start_spider170() -> void:
 # Parent202 normally auto-starts the spider trial. This animation preview must
 # not replace grove/navigation, start combat or grant any progression reward.
 return
func _ready() -> void:
 await super._ready()
 var center: Vector2=FOREST188.CENTER
 var route=choose_route205()
 transport205=preload("res://scripts/art/sister_transport205.gd").new()
 transport205.world=self;transport205.start_at=route[0];transport205.end_at=route[1]
 add_child(transport205)
 watch205=(route[0]+route[1])*.5+Vector2(0.,2.2)
 _teleport15(watch205)
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("204 "):
     child.hide()
 var canvas=CanvasLayer.new();canvas.layer=15;add_child(canvas)
 guide205=Label.new();guide205.position=Vector2(24,195);guide205.add_theme_font_size_override("font_size",19)
 guide205.add_theme_color_override("font_shadow_color",Color.BLACK);guide205.add_theme_constant_override("shadow_outline_size",6);canvas.add_child(guide205)
 ready205=true
func choose_route205() -> Array[Vector2]:
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
    clear_route205=true;return [start,end]
 push_warning("205 did not find the expected clear demonstration corridor")
 return [FOREST188.CENTER+Vector2(5.,2.),FOREST188.CENTER+Vector2(8.5,2.)]
func _process(delta: float) -> void:
 super._process(delta)
 if not ready205: return
 guide205.text="205 蝙蝠吊床 · "+transport205.label()+"\nF6 暂停/继续 · F7 重播 · F8 回到观看点\nWASD 绕行 · F3 小院 · F10 调色 · F12 灯光"
 if not shot205 and "--capture205" in OS.get_cmdline_user_args() and transport205.state=="travel" and transport205.age>1.2:
  shot205=true
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("res://docs/sister205-travel.png")
  get_tree().quit()
func _input(event: InputEvent) -> void:
 if ready205 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  match event.physical_keycode:
   KEY_F6: transport205.running=not transport205.running;get_viewport().set_input_as_handled();return
   KEY_F7: transport205.restart();get_viewport().set_input_as_handled();return
   KEY_F8: _teleport15(watch205);get_viewport().set_input_as_handled();return
 super._input(event)
