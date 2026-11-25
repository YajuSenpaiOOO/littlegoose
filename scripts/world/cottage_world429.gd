extends "res://scripts/world/cottage_world428.gd"

func house_script421() -> Script:
 return preload("res://scripts/room/cottage429.gd")

func _ready() -> void:
 await super._ready()
 var bedside: Dictionary=room.item356("bedside")
 house.card(bedside.root,house.left_pot,Vector3(-.19,.727,.20),.26,false)
 help367="429 · A 稿手绘墙面与装饰\nWASD 逛小院 / 推门 · F3 进出 · F8 屋顶对照 · F2 昼夜"
 DisplayServer.window_set_title("小白鹅 · 429 · 手绘小屋")
 refresh367()
 if "--capture429" in OS.get_cmdline_user_args():call_deferred("verify429")

func verify429() -> void:
 assert(house.front_glass.size()==3 and house.facade_layers.size()>6)
 assert(house.plant_cards.size()==6 and house.potted_colliders.size()==2)
 await get_tree().create_timer(.45).timeout
 await shot429("outside")
 set_night355(true)
 await get_tree().create_timer(.3).timeout
 await shot429("night")
 set_night355(false)
 drive426(KEY_W,true)
 var deadline:=Time.get_ticks_msec()+5000
 while not inside and Time.get_ticks_msec()<deadline:await get_tree().physics_frame
 drive426(KEY_W,false)
 assert(inside and hero_steps==2)
 await get_tree().create_timer(1.0).timeout
 for sprite in house.plant_cards:
  assert(sprite.visible==(sprite.get_parent()==house.terrace))
 await shot429("inside")
 print("COTTAGE429_DONE")
 get_tree().quit()

func shot429(tag: String) -> void:
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage429-"+tag+".png")
