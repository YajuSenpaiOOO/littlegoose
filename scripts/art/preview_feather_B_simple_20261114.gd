extends SceneTree
const FOLDER="res://art/concepts/black_goose_feather_B_simple_20261114/"
class Board:
 extends Node2D
 var textures: Array[Texture2D]=[]
 var regions: Array[Rect2]=[]
 var phase:=0.0
 func sprite_at(index: int,center: Vector2,limit: Vector2) -> void:
  var src: Rect2=regions[index];var size:=src.size*minf(limit.x/src.size.x,limit.y/src.size.y)
  draw_texture_rect_region(textures[index],Rect2(center-size*.5,size),src)
 func _draw() -> void:
  var font:=ThemeDB.fallback_font
  draw_rect(Rect2(0,0,1000,620),Color("171d2b"))
  draw_rect(Rect2(18,60,468,510),Color("262b40"));draw_rect(Rect2(504,60,478,510),Color("262b40"))
  draw_string(font,Vector2(22,35),"B / ONE FIRING POSE + PROCEDURAL RECOIL",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("f4e8d1"))
  var t:=phase
  var kick:=sin(minf(t/.08,1.)*PI*.5)*exp(-t*11.)
  draw_set_transform(Vector2(267+kick*14,320+kick*3),kick*.035,Vector2(1.+kick*.035,1.-kick*.025))
  sprite_at(0,Vector2.ZERO,Vector2(390,438))
  draw_set_transform(Vector2.ZERO)
  if t<.43:
   draw_set_transform(Vector2(186-t*480,309-t*24),PI)
   sprite_at(3,Vector2.ZERO,Vector2(30,30));draw_set_transform(Vector2.ZERO)
  draw_string(font,Vector2(38,548),"One drawn pose / face held for review",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("c4c3d6"))
  for row in 3:
   var y:=150.+row*158.
   var names: Array=["Existing candy core","Previous smooth feather","New pixel feather study"]
   draw_string(font,Vector2(526,y-58),names[row],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("f4e8d1"))
   sprite_at(row+1,Vector2(625,y),Vector2(164,90))
   draw_rect(Rect2(746,y-37,214,74),Color("e5e1d2"))
   sprite_at(row+1,Vector2(798,y),Vector2(24,24));sprite_at(row+1,Vector2(900,y),Vector2(40,40))
   draw_string(font,Vector2(773,y+57),"24px         40px",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("c4c3d6"))
  draw_string(font,Vector2(22,598),"Concept test: recoil/return uses code, no extra hand-drawn motion frames. Game stays 385.",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a7acc0"))
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(1000,620);root.content_scale_size=Vector2i(1000,620)
 var b:=Board.new();b.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;root.add_child(b)
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(FOLDER+"manifest.json"))
 var old: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/concepts/black_goose_feather_attack_20261114/manifest.json"))
 var files: Array=[FOLDER+"release-smile.png","res://assets/candy_bullets_v1/pearl_core_v2.png","res://art/concepts/black_goose_feather_attack_20261114/projectile-A.png",FOLDER+"feather-pixel.png"]
 var boxes: Array=[data.files["release-smile.png"].bbox,[692,257,1082,647],old.files["projectile-A"].alpha128_bbox,data.files["feather-pixel.png"].bbox]
 for i in 4:
  b.textures.append(ImageTexture.create_from_image(Image.load_from_file(files[i])))
  var box: Array=boxes[i];b.regions.append(Rect2(box[0],box[1],box[2]-box[0],box[3]-box[1]))
 for i in 12:
  b.phase=float(i)*.06;b.queue_redraw()
  for j in 3:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(FOLDER+"preview-"+str(i)+".png")
 print("SIMPLE_B_PREVIEW_DONE");quit()
