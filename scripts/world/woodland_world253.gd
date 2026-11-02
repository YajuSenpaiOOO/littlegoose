extends "res://scripts/world/woodland_world252.gd"
var ready253 := false
var location253 := 0
var side253 := 1.
var originals253: Array[ShaderMaterial]=[]
var materials253: Array[ShaderMaterial]=[]
const LOCATIONS253=["森林入口","林外团团场","小屋灯边"]
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 253 · 主角与姐姐 / 受光并排查验")
func _ready() -> void:
 await super._ready()
 for card in [rig220.standing,rig220.seated]:originals253.append(card.material_override)
 ready253=true;finish251(false);rig220.reset_fall224();rig220.entering225=true;rig220.step225=false
 rig220.show();rig220.set_process(true);rig220.body.collision_layer=0
 go253(0)
func positions253() -> Array:
 return [FOREST188.CENTER+FOREST188.ENTRY+Vector2(-2.,0.),meadow.landmarks.grove+Vector2(0.,3.),FOREST188.CENTER+Vector2(-7.5,-5.5)]
func go253(index: int) -> void:
 location253=posmod(index,3)
 if active114:finish251(false)
 _teleport15(positions253()[location253]);hero.velocity=Vector3.ZERO;hero.combat_impulse=Vector2.ZERO
 forest_mood188.update188(0.);lighting191._process(0.)
 place_sister253(0.)
func place_sister253(delta: float) -> void:
 var from=Vector2(hero.position.x,hero.position.z)
 var right=Vector2(camera.global_basis.x.x,camera.global_basis.x.z).normalized()*side253
 var at=safe_goal247(from,from+right*1.7)
 if at.distance_to(from)<1.1:
  var other=safe_goal247(from,from-right*1.7)
  if other.distance_to(from)>at.distance_to(from):at=other
 rig220.entry_pose225(at,at,false,false,0.,delta)
 rig220._process(0.)
 # These helpers belong to the transport rig; the display here is a standing actor.
 rig220.hammock.hide();rig220.seated.hide()
 for bat in rig220.bats:bat.hide()
 rig220.standing.show()
func set_lighting252(mode: int) -> void:
 super.set_lighting252(mode)
 if not ready253:return
 materials253.clear()
 for i in 2:
  var card: Sprite3D=[rig220.standing,rig220.seated][i]
  if lighting_mode252==0:card.material_override=originals253[i];continue
  var ink: ShaderMaterial=originals253[i].duplicate()
  var shader=Shader.new();var code=originals253[i].shader.code
  code=code.replace("COLOR.rgb*.82","COLOR.rgb")
  if lighting_mode252==2:code=code.replace("render_mode cull_disabled;","render_mode cull_disabled, unshaded;")
  shader.code=code;ink.shader=shader
  # Shader replacement can discard cached parameters: preserve the authored paint/depth state.
  for uniform in originals253[i].shader.get_shader_uniform_list():
   var value=originals253[i].get_shader_parameter(uniform.name)
   if value!=null:ink.set_shader_parameter(uniform.name,value)
  card.material_override=ink;materials253.append(ink)
func swap253() -> void:
 var at=rig220.person_at;side253=-side253
 _teleport15(at);hero.velocity=Vector3.ZERO;place_sister253(0.)
func _input(event: InputEvent) -> void:
 if ready253 and event is InputEventKey and event.pressed and not event.echo:
  if not event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_F10:
   forest_mood188.enabled=not forest_mood188.enabled;forest_mood188.update188(0.);get_viewport().set_input_as_handled();return
  if not event.ctrl_pressed and not event.alt_pressed:
   match event.physical_keycode:
    KEY_F8:go253(location253+1)
    KEY_F5:swap253()
    KEY_F11:lighting191.stage_enabled=not lighting191.stage_enabled;lighting191._process(0.)
    KEY_F12:lighting191.enabled=not lighting191.enabled;lighting191._process(0.)
    _:super._input(event);return
   get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if ready253 and event is InputEventKey and event.physical_keycode in [KEY_F5,KEY_F8,KEY_F11,KEY_F12]:return
 super._unhandled_input(event)
func location_label253() -> String:return LOCATIONS253[location253]
func _process(delta: float) -> void:
 super._process(delta)
 if not ready253:return
 place_sister253(delta)
 guide206.text=guide206.text.replace("252 四时段 / 主角受光查验","253 主角＋姐姐 · "+location_label253()).replace("F9 材质对照：","F9 两人材质：").replace("当前192受光（0.82）","原材质（两人各自0.82）")
 guide206.text+="\nF8换场地 / F5交换站位\nF11舞台补光：%s / F12森林灯组：%s\nAlt+F10区域调色：%s"%["开" if lighting191.stage_enabled else "关","开" if lighting191.enabled else "关","开" if forest_mood188.enabled else "关"]
