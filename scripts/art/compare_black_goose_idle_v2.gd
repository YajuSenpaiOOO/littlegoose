extends SceneTree
func _initialize() -> void:call_deferred("run")
func label_at(words: String,at: Vector2,size: int) -> void:
 var n:=Label.new();n.text=words;n.position=at;n.add_theme_font_size_override("font_size",size);root.add_child(n)
func source(path: String) -> Texture2D:return ImageTexture.create_from_image(Image.load_from_file(path))
func run() -> void:
 Engine.max_fps=30
 root.size=Vector2i(1680,1100);root.content_scale_size=Vector2i(1680,1100)
 var bg:=ColorRect.new();bg.size=Vector2(1680,1100);bg.color=Color("30343c");root.add_child(bg)
 label_at("主角 / 小黑鹅v1 / 小黑鹅v2 · 等高、脚底对齐",Vector2(45,22),30)
 label_at("三张原图均等比显示；下方为140px等高预览。未修改主角或压扁源图。",Vector2(45,68),22)
 var hero=preload("res://scripts/art/hero_frames.gd").new("hero_pixel","walk_backup.json")
 var entries: Array=[
 {"name":"主角 · 实际正面idle","tex":hero.idle,"foot":hero.idle_anchor,"height":hero.idle_height},
 {"name":"小黑鹅 v1 · 原版","tex":source("res://assets/black_goose_human_v1/idle_front.png"),"foot":Vector2(563,1365),"height":1268.},
 {"name":"小黑鹅 v2 · 头脸/衣裙重画","tex":source("res://assets/black_goose_human_v2/idle_front.png"),"foot":Vector2(550,1378),"height":1281.}]
 for i in 3:
  for small in [false,true]:
   var row: Dictionary=entries[i];var n:=Sprite2D.new();n.texture=row.tex;n.centered=false;n.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
   var factor: float=(140. if small else 580.)/row.height;n.scale=Vector2.ONE*factor;n.position=Vector2(280.+i*560.,1040. if small else 780.)-row.foot*factor;root.add_child(n)
  label_at(entries[i].name,Vector2(120.+i*560.,825.),25)
 for at in [780.,1040.]:
  var line:=ColorRect.new();line.position=Vector2(35,at);line.size=Vector2(1610,1);line.color=Color("7d8490");root.add_child(line)
 for i in 10:await process_frame
 await RenderingServer.frame_post_draw
 var error:=root.get_texture().get_image().save_png("res://assets/black_goose_human_v2/idle-comparison.png");print("GOOSE_V2_COMPARE ",error);quit(error)
