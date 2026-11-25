extends "res://scripts/world/room_world369.gd"
var fill370: DirectionalLight3D
var soft370:=true
func room_script355() -> Script:return preload("res://scripts/room/room_shell370.gd")
func _ready() -> void:
 await super._ready()
 hero.visual.layers|=1<<19
 fill370=DirectionalLight3D.new();fill370.name="SoftRoomBounce370";fill370.rotation_degrees=Vector3(-20.,0.,0.);fill370.light_color=Color("f6e8d7");fill370.shadow_enabled=false;fill370.light_cull_mask=1<<19;add_child(fill370)
 DisplayServer.window_set_title("小白鹅 · 370 · 盖被遮挡与室内补光")
 help367="370 · 盖被遮挡与室内补光\nE 睡下/起床 · C 近看 · Q 掀被\nT 严格盖被/369遮挡对照\nL 柔和补光开关 · F2 昼夜\nF12 跟随 · F10 右位预留\nR 368旧睡姿 · B 旧2D床"
 refresh367()
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_T:room.strict370=not room.strict370;get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_L:soft370=not soft370;get_viewport().set_input_as_handled();return
 super._input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if sleeping362 and not legacy_sleep368:prompt.text="E 起床 · 370盖被 · Q掀被 · L补光"
 if is_instance_valid(fill370):
  fill370.light_energy=(.32 if not night355 else .14) if soft370 else 0.
  # Sleeping actor uses the room's controlled painted-material grading rather than PBR.
  if is_instance_valid(room.pose_material369):
   room.pose_material369.set_shader_parameter("bounce",(Vector3(.055,.045,.035) if not night355 else Vector3(.025,.022,.018)) if soft370 else Vector3.ZERO)
