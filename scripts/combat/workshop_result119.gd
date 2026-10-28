extends "res://scripts/combat/workshop_result116.gd"
var retry119: Button
var gel_icon119: TextureRect
func _ready() -> void:
 super._ready();retry119=Button.new();retry119.text="收好团团分享的液滴";retry119.custom_minimum_size.y=44;menu.get_child(0).add_child(retry119)
 retry119.pressed.connect(func(): battle.retry_reward119();show_menu(true));retry119.hide()
 gel_icon119=TextureRect.new();gel_icon119.texture=preload("res://scripts/combat/elastic_drop119.gd").texture119()
 gel_icon119.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;gel_icon119.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;gel_icon119.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 gel_icon119.custom_minimum_size=Vector2(80,66);gel_icon119.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;gel_icon119.mouse_filter=Control.MOUSE_FILTER_IGNORE
 menu.get_child(0).add_child(gel_icon119);menu.get_child(0).move_child(gel_icon119,1);gel_icon119.hide()
func show_menu(finished: bool) -> void:
 super.show_menu(finished)
 if not finished: return
 var won: bool=battle.won119
 gel_icon119.visible=won
 menu.get_child(0).get_child(0).text="大家玩累了，坐下来歇歇" if won else "先歇一会儿，下次再玩"
 stats.text=("五位团团都休息了。\n" if won else "这次没有结算材料。\n")+battle.reward_text119()+"\n口袋里：蓝色弹性液滴 %d 份"%battle.memory_kit116.gel119
 retry119.visible=won and battle.memory_kit116.last_reward119<battle.event119
