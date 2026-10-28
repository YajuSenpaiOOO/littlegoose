extends "res://scripts/world/world_time62.gd"

func update_guide() -> void:
	super.update_guide()
	guide.text=guide.text.replace("62：Alt+5 古橡 / 6 银柳 / 7 花树","63：Alt+5 古橡 / 6 银柳 / 7 花树")
	guide.text+="\n环路20×17.6m · 车站坡度暂不定稿"
