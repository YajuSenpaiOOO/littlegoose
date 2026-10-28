extends "res://scripts/world/combat111_compare.gd"
class Battle113:
 extends "res://scripts/world/woodland_world113.gd"
 var permit := false
 var shooting := false
 var immortal := true
 func _ready() -> void:
  slow_start113=false;super._ready()
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return shooting
 func start_combat(reposition := true) -> void:
  if permit: super.start_combat(reposition)
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if immortal and player_hp>0.: player_hp=100.
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var six := ["forest_fireboy","three_player","eye_exercise","eye_exercise","snack","snack"]
 var data := {}
 var old := Battle111.new();await setup(old,"woodland_ready111");build(old,six);data.old_six=await compare_measure111(old,"111_six")
 root.remove_child(old);old.queue_free();await settle72(3)
 var sample := Battle113.new();await setup(sample,"woodland_ready113");build(sample,six);data.new_six=await compare_measure111(sample,"113_six")
 build(sample,["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","snack","snack","music_class","music_class","music_class"])
 data.new_max=await compare_measure111(sample,"113_max")
 var file := FileAccess.open("res://docs/combat113-first-comparison.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));quit()
