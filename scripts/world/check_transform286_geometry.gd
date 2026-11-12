extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var host=Node3D.new();root.add_child(host)
 var fx=preload("res://scripts/art/flashlight_transform286.gd").new();host.add_child(fx)
 fx.idle_texture=fx.STAND;fx.start()
 fx.sample(1.06);var high=fx.strips[10].get_aabb().position.y
 fx.sample(1.2);var low=fx.strips[10].get_aabb().position.y
 fx.sample(4.);var rest=fx.last_cape[-1].y
 fx.motion_target=Vector3(4,0,0);fx.advance(.4);var moving=fx.last_cape[-1].y
 var ok=high>1. and low<.03 and moving>rest+.1
 var f=FileAccess.open("res://docs/transform286-geometry.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"fall_start_height":high,"fall_end_height":low,"cape_rest_tip":rest,"cape_moving_tip":moving},"  "));f.close()
 print("TRANSFORM286_GEOMETRY ",ok);quit(0 if ok else 1)
