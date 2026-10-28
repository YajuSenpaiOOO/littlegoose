extends "res://scripts/combat/paper132.gd"
var animation134 := {}
var art134 := {}
var pose_key134 := "base"
func _ready() -> void:
 animation134=JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper134/animation.json"))
 for group in ["drift","attack"]:
  for i in 4: art134["%s%d"%[group,i]]=load(animation134[group][i].texture)
 art134["base"]=load(animation134.base.texture)
 super._ready()
func select_pose134() -> String:
 if dead: return "base"
 if paper_state129=="warning": return "attack0" if paper_clock129<.38 else "attack1"
 if paper_state129=="gust": return "attack2"
 if paper_state129=="coast" and paper_clock129<.55: return "attack3"
 var sequence := [0,1,2,3,2,1]
 return "drift%d"%sequence[int((age+float(role110)*.31)/.34)%sequence.size()]
func _render_legacy(lift: float) -> void:
 if not animation134.is_empty():
  pose_key134=select_pose134()
  var entry: Dictionary=animation134.base if pose_key134=="base" else animation134["attack" if pose_key134.begins_with("attack") else "drift"][int(pose_key134[-1])]
  # Every legacy pose key uses the selected authored frame, so art, soft response,
  # lighting and silhouette shadows always sample the same animation texture.
  for key in poses.keys(): poses[key]=entry;textures[key]=art134[pose_key134]
 super._render_legacy(lift)
 if not dead and visual.flip_h: visual.flip_h=false;visual.offset.x=-visual.offset.x

