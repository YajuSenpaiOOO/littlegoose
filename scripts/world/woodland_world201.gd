extends "res://scripts/world/woodland_world200.gd"
var accent_lamps201: Array[OmniLight3D]=[]
func _init() -> void:
 super._init();memory_save116="user://forest201_preview.cfg"
func _forest_art_script188() -> Script: return preload("res://scripts/art/forest_art201.gd")
func _lighting_script191() -> Script: return preload("res://scripts/art/forest_lighting201.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 201 · 彩带短栅栏 / 暖灯与布偶角")
func _ready() -> void:
 await super._ready()
 for entry in forest188.decor201:
  if entry.kind=="fence": relations199.bind_card199(entry.node,entry.node.global_position,false)
  elif entry.kind=="stump_lantern":
   var core: Vector3=lighting191.core(entry.node,Vector2(.5,.78))+camera.global_basis.z*.4
   for light in lighting191.lamps:
    if light.global_position.distance_to(core)<.05:
     light.set_meta("energy191",.16);light.omni_range=4.2;accent_lamps201.append(light)
 for at in forest188.light_seeds201:
  var light: OmniLight3D=lighting191.lamp(at,.18,3.8)
  light.name="DecorationAmberPool201";light.light_color=Color("ffd09a");accent_lamps201.append(light)
 lighting191._process(0.)
 _teleport15(preload("res://scripts/world/forest_plan188.gd").CENTER+Vector2(7.6,-1.8))
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("200 "):
     child.text=child.text.replace("200 整树避让 / 遮挡判定修正","201 彩带短栅栏 / 暖灯与布偶角")
