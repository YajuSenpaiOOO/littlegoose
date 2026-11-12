extends SceneTree
## Native Godot layout of unchanged source textures, not an image-generated comparison.
func _initialize() -> void:call_deferred("run")
func label_at(words: String,at: Vector2,size: int=22) -> void:
 var l=Label.new();l.text=words;l.position=at;l.add_theme_font_size_override("font_size",size);root.add_child(l)
func run() -> void:
 root.size=Vector2i(1440,860);root.content_scale_size=Vector2i(1440,860)
 var bg=ColorRect.new();bg.color=Color("30363d");bg.size=Vector2(1440,860);root.add_child(bg)
 label_at("原图等身高对照 · 只做等比缩放，脚底对齐",Vector2(60,20),28)
 label_at("左：294旧稿   中：主角真实正面待机   右：295比例修订",Vector2(60,63),21)
 var sheet=ImageTexture.create_from_image(Image.load_from_file("res://assets/hero_pixel/walk_source.png"))
 var hero=AtlasTexture.new();hero.atlas=sheet;hero.region=Rect2(633,0,600,800)
 var specs=[
  {"name":"294 · 旧稿","path":"res://assets/paper_girl294/idle_front.png","foot":Vector2(588,1264),"height":1204.,"x":260.},
  {"name":"主角 · 正面待机","texture":hero,"foot":Vector2(300,749),"height":674.,"x":720.},
  {"name":"295 · 比例修订","path":"res://assets/paper_girl295/idle_front.png","foot":Vector2(542.5,1387),"height":1268.,"x":1180.}]
 var report=[]
 for spec in specs:
  var tex: Texture2D=spec.get("texture")
  if tex==null:tex=ImageTexture.create_from_image(Image.load_from_file(spec.path))
  var sprite=Sprite2D.new();sprite.texture=tex;sprite.centered=false;sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
  var factor=520./float(spec.height);sprite.scale=Vector2.ONE*factor;sprite.position=Vector2(spec.x,680)-spec.foot*factor;root.add_child(sprite)
  label_at(spec.name,Vector2(spec.x-110,730),25)
  report.append({"name":spec.name,"source_height":spec.height,"uniform_scale":factor,"screen_foot":[spec.x,680],"display_height":520.})
 var lines=Line2D.new();lines.width=1.;lines.default_color=Color("82909a");lines.add_point(Vector2(35,680));lines.add_point(Vector2(1405,680));root.add_child(lines)
 label_at("相同有效高 520 px；原始贴图与比例均保留，没有单独放大头、压缩身体或重新生成主角。",Vector2(60,795),19)
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper296-comparison.png")
 FileAccess.open("res://docs/paper296-comparison.json",FileAccess.WRITE).store_string(JSON.stringify({"comparison":"native Sprite2D unchanged textures, uniform scale and common baseline","items":report},"  "))
 quit()
