extends SceneTree
func read231(path: String) -> Image:
 var image=Image.new();image.load_png_from_buffer(FileAccess.get_file_as_bytes(path));image.convert(Image.FORMAT_RGBA8);return image
func bounds231(image: Image) -> Rect2i:
 var lo=Vector2i(image.get_width(),image.get_height());var hi=Vector2i.ZERO
 for y in image.get_height():
  for x in image.get_width():
   if image.get_pixel(x,y).a>=.98:lo=lo.min(Vector2i(x,y));hi=hi.max(Vector2i(x,y))
 return Rect2i(lo,hi-lo+Vector2i.ONE)
func place231(source: Image,width: int,canvas: Vector2i,sole: int) -> Dictionary:
 var bounds=bounds231(source);var cut=source.get_region(bounds)
 var height=roundi(float(cut.get_height())*width/cut.get_width())
 cut.resize(width,height,Image.INTERPOLATE_NEAREST)
 var at=Vector2i((canvas.x-width)/2,sole-height)
 var output=Image.create(canvas.x,canvas.y,false,Image.FORMAT_RGBA8);output.fill(Color.TRANSPARENT)
 output.blit_rect(cut,Rect2i(Vector2i.ZERO,cut.get_size()),at)
 return {"image":output,"bounds":[at.x,at.y,width,height],"anchor":[canvas.x*.5,sole],"source_bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]}
func _initialize() -> void:
 var atlas=read231("res://assets/fat_cat220/roll_sheet.png")
 var sheet=read231("res://assets/fat_cat231/roll-keyposes.png")
 var data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/fat_cat220/roll_frames.json"))
 for i in 3:
  var result=place231(sheet.get_region(Rect2i(i*724,0,724,724)),502,Vector2i(512,512),470)
  var cell=Vector2i(((i+2)%3)*512,((i+2)/3)*512)
  atlas.blit_rect(result.image,Rect2i(0,0,512,512),cell)
  data.frames[i+2]={"region":[cell.x,cell.y,512,512],"anchor":result.anchor,"bounds":result.bounds,"source_bounds":result.source_bounds}
 atlas.save_png("res://assets/fat_cat231/roll-runtime.png")
 var rest=place231(read231("res://assets/fat_cat231/rest-spread-v1.png"),530,Vector2i(640,512),470)
 rest.image.save_png("res://assets/fat_cat231/down-runtime.png");rest.erase("image");data.rest231=rest
 FileAccess.open("res://assets/fat_cat231/runtime-frames.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 print("PACK_CAT231_OK");quit()
