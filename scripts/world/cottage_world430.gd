extends "res://scripts/world/cottage_world429.gd"

func house_script421() -> Script:
 return preload("res://scripts/room/cottage430.gd")

func _ready() -> void:
 await super._ready()
 help367="430 · A 稿扫檐、厚瓦与石门套\nWASD 逛小院 / 推门 · F3 进出 · F8 屋顶对照 · F2 昼夜"
 DisplayServer.window_set_title("小白鹅 · 430 · 屋檐与石门套")
 refresh367()
 if "--capture430" in OS.get_cmdline_user_args():call_deferred("verify430")

func verify430() -> void:
 assert(house.roof_batches.size()==3 and house.jambs.size()==21)
 assert(house.front_glass.size()==3)
 await get_tree().create_timer(.45).timeout
 await shot430("outside")
 set_night355(true)
 await get_tree().create_timer(.3).timeout
 await shot430("night")
 set_night355(false)
 drive426(KEY_W,true)
 var deadline:=Time.get_ticks_msec()+5000
 while not inside and Time.get_ticks_msec()<deadline:await get_tree().physics_frame
 drive426(KEY_W,false)
 assert(inside and hero_steps==2)
 await get_tree().create_timer(1.0).timeout
 for block in house.jambs:assert(not block.visible)
 for batch in house.roof_batches:assert(not batch.visible)
 await shot430("inside")
 quick_cross(false)
 await get_tree().create_timer(1.0).timeout
 for block in house.jambs:assert(block.visible)
 for batch in house.roof_batches:assert(batch.visible)
 print("COTTAGE430_DONE")
 get_tree().quit()

func shot430(tag: String) -> void:
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage430-"+tag+".png")
