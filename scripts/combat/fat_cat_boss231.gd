extends "res://scripts/combat/fat_cat_boss228.gd"
var down231: Texture2D
func _ready() -> void:
 super._ready()
 roll_data220=JSON.parse_string(FileAccess.get_file_as_string("res://assets/fat_cat231/runtime-frames.json"))
 roll_sheet220=load("res://assets/fat_cat231/roll-runtime.png")
 down231=load("res://assets/fat_cat231/down-runtime.png")
 rolls220.clear()
 for f in roll_data220.frames:rolls220.append(atlas220(roll_sheet220,f.region))
 _render_legacy(0.)
func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 if not ready220 or not is_instance_valid(down231) or phase220!="down":return
 var anchor: Array=roll_data220.rest231.anchor;var size=down231.get_size()
 visual.texture=down231;visual.pixel_size=3./502.
 visual.offset=Vector2(size.x*.5-float(anchor[0]),float(anchor[1])-size.y*.5)
 if visual.flip_h:visual.offset.x=-visual.offset.x
 ink220.set_shader_parameter("paint",down231)
 ink220.set_shader_parameter("alpha_cut220",.98)
