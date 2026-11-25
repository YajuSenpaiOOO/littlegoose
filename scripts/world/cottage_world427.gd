extends "res://scripts/world/cottage_world426.gd"

func house_script421() -> Script:
 return preload("res://scripts/room/cottage427.gd")

func _ready() -> void:
 await super._ready()
 help367="427 · 手绘墙石与通透窗\nWASD 逛小院 / 推门 · F3 进出 · F8 屋顶对照 · F2 昼夜"
 DisplayServer.window_set_title("小白鹅 · 427 · 小屋材质与透明窗")
 refresh367()
 if "--capture427" in OS.get_cmdline_user_args():call_deferred("verify427")

func verify427() -> void:
 assert(house.front_glass.size()==3)
 assert(house.facade_layers.size()>6 and house.plant_cards.size()>16)
 await get_tree().create_timer(.5).timeout
 await shot427("outside")
 for data in [[-4.75,1.47,2.1],[4.75,1.47,2.1],[-.28,3.92,3.2]]:
  var ray:=PhysicsRayQueryParameters3D.create(Vector3(data[0],data[1],data[2]+.5),Vector3(data[0],data[1],data[2]-.65),1)
  # Lower windows have invisible actor blocking below the sill clearance.
  # Check visual render in the viewport; the decorative loft uses no blocker.
  if data[1]>3.:assert(get_world_3d().direct_space_state.intersect_ray(ray).is_empty())
 set_night355(true)
 await get_tree().create_timer(.3).timeout
 await shot427("night")
 set_night355(false)
 drive426(KEY_W,true)
 var deadline:=Time.get_ticks_msec()+5000
 while not inside and Time.get_ticks_msec()<deadline:await get_tree().physics_frame
 drive426(KEY_W,false)
 assert(inside and hero_steps==2)
 await get_tree().create_timer(1.0).timeout
 assert(not house.front_glass[0].visible)
 await shot427("inside")
 print("COTTAGE427_DONE")
 get_tree().quit()

func shot427(tag: String) -> void:
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage427-"+tag+".png")
