extends "res://scripts/world/cottage_world427.gd"

func house_script421() -> Script:
 return preload("res://scripts/room/cottage428.gd")

func _ready() -> void:
 await super._ready()
 help367="428 · A 稿外墙与点缀\nWASD 逛小院 / 推门 · F3 进出 · F8 屋顶对照 · F2 昼夜"
 DisplayServer.window_set_title("小白鹅 · 428 · A 稿外墙与点缀")
 refresh367()
 if "--capture428" in OS.get_cmdline_user_args():call_deferred("verify428")

func verify428() -> void:
 assert(house.facade_layers.is_empty() and house.stone_blocks>=20 and house.ceramics.size()==2)
 assert(house.front_glass.size()==3)
 await get_tree().create_timer(.45).timeout
 await shot428("outside")
 set_night355(true)
 await get_tree().create_timer(.3).timeout
 await shot428("night")
 set_night355(false)
 drive426(KEY_W,true)
 var deadline:=Time.get_ticks_msec()+5000
 while not inside and Time.get_ticks_msec()<deadline:await get_tree().physics_frame
 drive426(KEY_W,false)
 assert(inside and hero_steps==2)
 await get_tree().create_timer(1.).timeout
 for pane in house.front_glass:assert(not pane.visible)
 await shot428("inside")
 print("COTTAGE428_DONE")
 get_tree().quit()

func shot428(tag: String) -> void:
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage428-"+tag+".png")
