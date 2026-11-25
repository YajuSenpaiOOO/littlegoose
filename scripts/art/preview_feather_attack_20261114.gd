extends SceneTree
const FOLDER="res://art/concepts/black_goose_feather_attack_20261114/"
class Board:
 extends Node2D
 var textures: Array[Texture2D]=[]
 var regions: Array[Rect2]=[]
 var frame:=0
 var projectile:=false
 func _draw() -> void:
  var font:=ThemeDB.fallback_font
  draw_rect(Rect2(0,0,1200,600),Color("171d2b"))
  draw_string(font,Vector2(24,38),"FEATHER PROJECTILES / SHAPE STUDY" if projectile else "FRONT ATTACK / KEY-POSE LOOPS",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("f4e8d1"))
  for i in 3:
   var x:=float(i)*400.
   draw_style_box(panel(),Rect2(x+12,58,376,510))
   var names: Array=["A / Cream-lilac","B / Swept purple","C / Curled down"] if projectile else ["A / Finger flick","B / Palm nudge","C / Sleeve pluck"]
   draw_string(font,Vector2(x+30,94),names[i],HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("f4e8d1"))
   if projectile:
    var src: Rect2=regions[i];var size: Vector2=src.size*minf(310./src.size.x,200./src.size.y)
    draw_texture_rect_region(textures[i],Rect2(Vector2(x+200,230)-size*.5,size),src)
    draw_rect(Rect2(x+28,356,344,64),Color("e5e1d2"))
    draw_rect(Rect2(x+28,430,344,64),Color("101625"))
    for j in 3:
     var width: float=[24.,36.,48.][j];var small:=Vector2(width,width*src.size.y/src.size.x)
     for y in [388.,462.]:draw_texture_rect_region(textures[i],Rect2(Vector2(x+85+j*112,y)-small*.5,small),src)
     draw_string(font,Vector2(x+67+j*112,530),str(int(width))+" px",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("c4c3d6"))
   else:
    var size:=Vector2(768,512)*.76
    draw_texture_rect_region(textures[i],Rect2(Vector2(x+200-size.x*.5,112),size),Rect2((frame%2)*768,(frame/2)*512,768,512))
    draw_string(font,Vector2(x+30,541),["1 / prepare","2 / raise","3 / release","4 / recover"][frame],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("c4c3d6"))
  draw_string(font,Vector2(24,590),"Concept candidates / no game replacement",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a7acc0"))
 func panel() -> StyleBoxFlat:
  var s:=StyleBoxFlat.new();s.bg_color=Color("262b40");s.corner_radius_top_left=12;s.corner_radius_top_right=12;s.corner_radius_bottom_left=12;s.corner_radius_bottom_right=12;return s
func _initialize() -> void:call_deferred("run")
func capture(board: Board,name: String) -> void:
 board.queue_redraw()
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(FOLDER+name+".png")
func run() -> void:
 root.size=Vector2i(1200,600);root.content_scale_size=Vector2i(1200,600)
 var board:=Board.new();root.add_child(board)
 for key in ["A","B","C"]:board.textures.append(ImageTexture.create_from_image(Image.load_from_file(FOLDER+"action-"+key+".png")))
 for i in 4:board.frame=i;await capture(board,"preview-frame"+str(i))
 board.textures.clear();board.projectile=true
 var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(FOLDER+"manifest.json"))
 for key in ["A","B","C"]:
  board.textures.append(ImageTexture.create_from_image(Image.load_from_file(FOLDER+"projectile-"+key+".png")))
  var b: Array=manifest.files["projectile-"+key].alpha128_bbox
  board.regions.append(Rect2(b[0],b[1],b[2]-b[0],b[3]-b[1]))
 await capture(board,"projectile-comparison")
 print("FEATHER_CONCEPT_PREVIEW_DONE");quit()
