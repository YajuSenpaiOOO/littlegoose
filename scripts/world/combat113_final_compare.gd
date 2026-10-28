extends "res://scripts/world/combat113_compare.gd"
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var six := ["forest_fireboy","three_player","eye_exercise","eye_exercise","snack","snack"]
 var maximum := ["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","snack","snack","music_class","music_class","music_class"]
 var data := {}
 var old := Battle111.new();await setup(old,"woodland_ready111");build(old,six);data.old_six=await compare_measure111(old,"111_original_six")
 build(old,maximum);data.old_max=await compare_measure111(old,"111_original_max")
 root.remove_child(old);old.queue_free();await settle72(3)
 var s := Battle113.new();await setup(s,"woodland_ready113");build(s,six);data.new_six=await compare_measure111(s,"113_original_six")
 build(s,maximum);data.new_max=await compare_measure111(s,"113_original_max")
 s.slow_start113=true;build(s,six);data.slow_six=await compare_measure111(s,"113_slow_six")
 build(s,maximum);data.slow_max=await compare_measure111(s,"113_slow_max")
 var file := FileAccess.open("res://docs/combat113-final-comparison.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));quit()
