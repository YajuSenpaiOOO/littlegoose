@tool
extends Node2D
## A small editable art assembly; its owning WorldProp supplies sorting and collision.
@export_enum("Cabbage","Tomato") var crop := 0

func _ready() -> void:
	for y in [0,13,26]:
		for x in [-14,0,14]:
			var sprite := Sprite2D.new()
			var texture := AtlasTexture.new()
			texture.atlas = preload("res://assets/courtyard_v1/plants.png")
			texture.region = Rect2(96,128,32,32) if crop==0 else Rect2(64,96,32,32)
			texture.filter_clip = true
			sprite.texture = texture
			sprite.position = Vector2(x,-34+y)
			sprite.scale = Vector2.ONE*0.52
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			add_child(sprite)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-27,-45,54,48),Color("4c4630"))
	draw_rect(Rect2(-25,-44,50,44),Color("6e5435"))
	for y in range(-40,1,6): draw_rect(Rect2(-23,y,46,1),Color("7a6040"))
	# One-pixel timber rims ground the plot without hiding the crop silhouettes.
	draw_rect(Rect2(-27,-45,54,2),Color("aa8050"))
	draw_rect(Rect2(-27,-43,2,44),Color("987044"))
	draw_rect(Rect2(25,-43,2,44),Color("61472c"))
	draw_rect(Rect2(-27,1,54,3),Color("987044"))
