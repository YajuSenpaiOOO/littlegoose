extends "res://scripts/world/combat113_compare.gd"
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var s := Battle113.new();await setup(s,"woodland_ready113")
 s.shooting=false;var data := {};data.idle=await compare_measure111(s,"113_idle_final")
 build(s,["forest_fireboy","three_player","eye_exercise","eye_exercise","snack","snack"])
 data.six=await compare_measure111(s,"113_six_final")
 build(s,["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","snack","snack","music_class","music_class","music_class"])
 data.maximum=await compare_measure111(s,"113_max_final")
 var file := FileAccess.open("res://docs/combat113-quick.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));quit()
