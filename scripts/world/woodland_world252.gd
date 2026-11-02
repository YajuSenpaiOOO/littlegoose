extends "res://scripts/world/woodland_world251.gd"
var lighting_mode252 := 0
var compare252: StandardMaterial3D
const LIGHT_LABELS252=["当前192受光（0.82）","原生受光·白色基底对照","无原生受光对照"]
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 252 · 四时段查验 / 主角受光对照")
func set_lighting252(mode: int) -> void:
 lighting_mode252=posmod(mode,3)
 if lighting_mode252==0:compare252=null;hero.visual.material_override=hero.receiver192;return
 compare252=hero.receiver192.duplicate();compare252.albedo_color=Color.WHITE
 if lighting_mode252==2:compare252.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 apply_lighting252()
func apply_lighting252() -> void:
 if not is_instance_valid(hero) or compare252==null:return
 compare252.albedo_texture=hero.visual.texture.atlas if hero.visual.texture is AtlasTexture else hero.visual.texture
 hero.visual.material_override=compare252
func _input(event: InputEvent) -> void:
 if ready251 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and event.physical_keycode==KEY_F9:
  set_lighting252(lighting_mode252+1);get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if ready251 and event is InputEventKey and event.physical_keycode==KEY_F9:return
 super._unhandled_input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if not ready251:return
 apply_lighting252()
 guide206.text=guide206.text.replace("251 团团Boss · 246战斗基线","252 四时段 / 主角受光查验")
 guide206.text+="\nAlt+1晨 / 2午 / 3夕 / 4夜 · Alt+0自然\nF9 材质对照："+LIGHT_LABELS252[lighting_mode252]
