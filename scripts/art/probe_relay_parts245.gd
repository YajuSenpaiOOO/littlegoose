extends SceneTree
const DIR="D:/work/Agent/workplace/小白鹅大冒险/art_workbench/red_banner245/parts-v1/"
var layer: Node2D
var shader: Shader
func _initialize() -> void:call_deferred("run")
func label245(words: String,at: Vector2,size := 24) -> void:
 var label=Label.new();label.text=words;label.position=at;label.add_theme_font_size_override("font_size",size);label.add_theme_color_override("font_color",Color("4f3c54"));layer.add_child(label)
func add245(file: String,where: Vector2,gain: float,region := Rect2()) -> void:
 var image=Image.load_from_file(DIR+file)
 var sprite=Sprite2D.new();sprite.texture=ImageTexture.create_from_image(image);sprite.centered=false;sprite.position=where;sprite.scale=Vector2.ONE*gain;sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 if region.size!=Vector2.ZERO:sprite.region_enabled=true;sprite.region_rect=region
 var material=ShaderMaterial.new();material.shader=shader;sprite.material=material;layer.add_child(sprite)
func run() -> void:
 root.size=Vector2i(1600,1000);root.content_scale_size=Vector2i(1600,1000)
 var scene=Node2D.new();root.add_child(scene);current_scene=scene;layer=scene
 var bg=ColorRect.new();bg.color=Color("e9e0d5");bg.size=Vector2(1600,1000);layer.add_child(bg)
 shader=Shader.new();shader.code="shader_type canvas_item; void fragment(){vec4 c=texture(TEXTURE,UV)*COLOR;if(c.a<0.5){discard;}COLOR=vec4(c.rgb,1.0);}"
 label245("接力旗 · 拆分与组合预览",Vector2(55,35),32)
 label245("组合",Vector2(260,120));label245("铅笔",Vector2(735,180));label245("挂旗与绳结",Vector2(1020,180));label245("画中鹅",Vector2(1340,230))
 var data=JSON.parse_string(FileAccess.get_file_as_string(DIR+"assembly.json"))
 var origin=Vector2(-120,110);var gain=.8
 for key in ["pencil","banner","goose"]:
  var part=data[key];add245(part.file,origin+Vector2(part.position[0],part.position[1])*gain,float(part.scale)*gain)
 add245("pencil.png",Vector2(680,230),.54,Rect2(319,77,405,819))
 add245("banner.png",Vector2(975,250),.50,Rect2(352,96,524,761))
 add245("goose-idle.png",Vector2(1290,310),.45,Rect2(447,289,525,521))
 var foot=origin+Vector2(data.shared_foot_anchor[0],data.shared_foot_anchor[1])*gain
 label245("↑ 共享笔尖落点",foot+Vector2(-30,18),18)
 label245("透明源图保持原样；组合靠独立层的统一缩放与挂点注册。",Vector2(65,900),22)
 label245("本图没有地面贴片。泥土 / 石屑 / 纸屑 / 接触影由场景处理。",Vector2(65,936),22)
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(DIR+"assembly-preview.png")
 print("RELAY245_ASSEMBLY_PREVIEW ",DIR);quit()
