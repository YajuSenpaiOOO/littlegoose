extends "res://scripts/combat/paper134.gd"
var extra135 := {}
var left_frames135: Array = []
var left_art135: Array = []
var right_art135: Array = []
var defeat_art135: Texture2D
var face_right135 := false
var previous_state135 := ""
func _ready() -> void:
 extra135=JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper135/animation.json"))
 for entry in extra135.right: right_art135.append(load(entry.texture))
 defeat_art135=load(extra135.defeat.texture)
 super._ready()
 left_frames135=animation134.attack.duplicate(true)
 for i in 4: left_art135.append(art134["attack%d"%i])
func _render_legacy(lift: float) -> void:
 if extra135.is_empty() or left_frames135.is_empty():
  super._render_legacy(lift);return
 # Lock screen-side facing during the warning; a curved pass never flips midway.
 if not dead and paper_state129=="warning" and previous_state135!="warning":
  var side: float=Vector3(paper_direction129.x,0.,paper_direction129.y).dot(battle.camera.global_basis.x)
  if absf(side)>.12: face_right135=side>0.
 previous_state135=paper_state129
 animation134.attack=extra135.right if face_right135 else left_frames135
 for i in 4: art134["attack%d"%i]=right_art135[i] if face_right135 else left_art135[i]
 if dead:
  animation134.base=extra135.defeat
  art134.base=defeat_art135
 super._render_legacy(lift)
 if dead:
  # Authored foreshortening supplies the flat floor pose; only a small settling
  # sway remains. Keep inherited landing timing, corpse fade and silhouette.
  visual.scale=Vector3.ONE
  visual.rotation.z=sin(defeat_age*10.)*.09*maxf(0.,1.-defeat_age/.6)
  if visual.flip_h: visual.flip_h=false;visual.offset.x=-visual.offset.x
