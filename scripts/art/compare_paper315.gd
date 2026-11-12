extends SceneTree
func _initialize() -> void:
 call_deferred("run")

func label_at(words: String, at: Vector2, size: int) -> void:
 var label := Label.new()
 label.text = words
 label.position = at
 label.add_theme_font_size_override("font_size", size)
 root.add_child(label)

func source(path: String) -> Texture2D:
 return ImageTexture.create_from_image(Image.load_from_file(path))

func run() -> void:
 root.size = Vector2i(1440, 860)
 root.content_scale_size = Vector2i(1440, 860)
 var background := ColorRect.new()
 background.size = Vector2(1440, 860)
 background.color = Color("30363d")
 root.add_child(background)
 label_at("妹妹标准站姿重画 · 等高、脚底对齐", Vector2(45, 25), 28)
 label_at("原始图像等比显示，比较头宽、肩宽和身长", Vector2(45, 72), 23)
 var hero := AtlasTexture.new()
 hero.atlas = source("res://assets/hero_pixel/walk_source.png")
 hero.region = Rect2(633., 0., 600., 800.)
 var crying := AtlasTexture.new()
 crying.atlas = source("res://assets/paper_stage314/defeat_poses.png")
 crying.region = Rect2(768., 0., 768., 1024.)
 var entries := [
  {"name": "主角正面待机", "texture": hero, "foot": Vector2(300., 749.), "height": 675.},
  {"name": "妹妹当前哭哭帧", "texture": crying, "foot": Vector2(326.5, 937.), "height": 841.},
  {"name": "315 新标准站姿", "texture": source("res://assets/paper_girl315/idle_front.png"), "foot": Vector2(542., 1374.), "height": 1269.}]
 for i in entries.size():
  var entry: Dictionary = entries[i]
  var sprite := Sprite2D.new()
  sprite.texture = entry.texture
  sprite.centered = false
  sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
  var scale := 500. / float(entry.height)
  sprite.scale = Vector2.ONE * scale
  sprite.position = Vector2(250. + i * 470., 690.) - entry.foot * scale
  root.add_child(sprite)
  label_at(entry.name, Vector2(125. + i * 470., 745.), 25)
 var baseline := ColorRect.new()
 baseline.position = Vector2(30., 690.)
 baseline.size = Vector2(1380., 1.)
 baseline.color = Color("88939a")
 root.add_child(baseline)
 for i in 8:
  await process_frame
 await RenderingServer.frame_post_draw
 quit(root.get_texture().get_image().save_png("res://docs/castle-candidates/315-proportion-comparison.png"))
