extends "res://scripts/combat/notebook_ui118.gd"
var working_gel119 := 0
var gel_icon119: TextureRect
func _ready() -> void:
 super._ready()
 gel_icon119=TextureRect.new();gel_icon119.texture=preload("res://scripts/combat/elastic_drop119.gd").texture119()
 gel_icon119.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;gel_icon119.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 gel_icon119.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;gel_icon119.mouse_filter=Control.MOUSE_FILTER_IGNORE
 gel_icon119.position=Vector2(910,405);gel_icon119.size=Vector2(56,56);book.add_child(gel_icon119);gel_icon119.hide()
func open116() -> void:
 working_gel119=world.memory_kit116.gel119;super.open116();refresh116()
func craft118() -> void:
 var remaining: int=world.memory_kit116.try_craft119(focused_id,working_owned,working_crafted,working_gel119)
 if remaining<0: feedback.text="液滴还不够，去和团团玩一场吧。";return
 working_gel119=remaining;refresh116();feedback.text="做出一把弹弓！\n按“收好”保存材料和制作结果。"
func refresh116() -> void:
 super.refresh116()
 if is_instance_valid(gel_icon119): gel_icon119.visible=tab118=="recipe" and focused_id=="slingshot"
 for row in rows118: row.text=row.text.replace("试制","配方")
 if tab118!="recipe": return
 craft_button118.text="制作一份"
 if focused_id=="slingshot":
  stock118.text="蓝色弹性液滴：%d / %d\n已制作 %d 份 · 拥有 %d 份\n已装配 %d 份 · 配方已学会"%[working_gel119,world.memory_kit116.BALANCE119.SLINGSHOT_GEL,working_crafted.slingshot,working_owned.slingshot,working.count("slingshot")]
  craft_button118.disabled=working_gel119<world.memory_kit116.BALANCE119.SLINGSHOT_GEL or working_owned.slingshot>=999
  feedback.text="团团喜欢收集的蓝色弹性液滴。\n每把消耗%d份液滴；点“收好”才保存。"%world.memory_kit116.BALANCE119.SLINGSHOT_GEL
 else:
  craft_button118.disabled=true;feedback.text="这份配方还在等一次新的冒险。\n本次先完成蓝色液滴与弹弓的故事。"
