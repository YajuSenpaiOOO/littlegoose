extends SceneTree
func _initialize() -> void:call_deferred("run")
func label_at(words: String,at: Vector2,size: int) -> void:
 var n:=Label.new();n.text=words;n.position=at;n.add_theme_font_size_override("font_size",size);root.add_child(n)
func run() -> void:
 Engine.max_fps=30
 root.size=Vector2i(1440,1000);root.content_scale_size=Vector2i(1440,1000)
 var bg:=ColorRect.new();bg.size=Vector2(1440,1000);bg.color=Color("30343c");root.add_child(bg)
 label_at("主角 / 小黑鹅 idle v1 · 等高、脚底对齐",Vector2(45,24),30)
 label_at("原图等比显示；未拉宽、压扁或重画。大图比较比例，右侧比较小尺寸读形。",Vector2(45,72),21)
 var hero=preload("res://scripts/art/hero_frames.gd").new("hero_pixel","walk_backup.json")
 var goose:=ImageTexture.create_from_image(Image.load_from_file("res://assets/black_goose_human_v1/idle_front.png"))
 var entries: Array=[
 {"tex":hero.idle,"foot":hero.idle_anchor,"height":hero.idle_height,"at":Vector2(300,805),"pixels":600.},
 {"tex":goose,"foot":Vector2(563,1365),"height":1268.,"at":Vector2(790,805),"pixels":600.},
 {"tex":hero.idle,"foot":hero.idle_anchor,"height":hero.idle_height,"at":Vector2(1170,560),"pixels":170.},
 {"tex":goose,"foot":Vector2(563,1365),"height":1268.,"at":Vector2(1340,560),"pixels":170.}]
 for row in entries:
  var n:=Sprite2D.new();n.texture=row.tex;n.centered=false;n.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
  var factor: float=row.pixels/row.height;n.scale=Vector2.ONE*factor;n.position=row.at-row.foot*factor;root.add_child(n)
 label_at("主角 · 实际正面idle帧",Vector2(150,855),26)
 label_at("小黑鹅 · 第一版",Vector2(665,855),26)
 label_at("170px 等高预览",Vector2(1130,605),22)
 for row in [[Vector2(45,805),Vector2(990,1)],[Vector2(1080,560),Vector2(340,1)]]:
  var line:=ColorRect.new();line.position=row[0];line.size=row[1];line.color=Color("7d8490");root.add_child(line)
 for i in 10:await process_frame
 await RenderingServer.frame_post_draw
 var error:=root.get_texture().get_image().save_png("res://assets/black_goose_human_v1/idle-comparison.png")
 print("GOOSE_IDLE_COMPARISON ",error);quit(error)
