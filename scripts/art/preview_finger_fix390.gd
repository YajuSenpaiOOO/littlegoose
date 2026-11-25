extends SceneTree
class Board:
 extends Node2D
 var tex: Texture2D
 const REGIONS=[Rect2(25,1390,80,110),Rect2(202,1390,90,110),Rect2(310,1390,90,110),Rect2(505,1390,78,110),Rect2(600,1390,95,110),Rect2(798,1390,89,110)]
 func _draw() -> void:
  draw_rect(Rect2(0,0,1200,850),Color("c6c3c1"))
  var font:=ThemeDB.fallback_font
  for i in 6:
   var origin:=Vector2((i%3)*400+30,(i/3)*410+55)
   draw_string(font,origin-Vector2(0,15),["Left: far hand","Left: near hand","Right: near hand","Right: far hand","Back: left hand","Back: right hand"][i],HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("291d2f"))
   draw_texture_rect_region(tex,Rect2(origin,REGIONS[i].size*3.1),REGIONS[i])
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(1200,850);root.content_scale_size=root.size
 var b:=Board.new();root.add_child(b);b.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 b.tex=ImageTexture.create_from_image(Image.load_from_file("res://assets/black_goose_charge390/poses-five-fingers.png"))
 b.queue_redraw()
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/finger390-five-qa.png")
 print("FINGER390_QA_RENDERED");quit()
