extends SceneTree
func bounds134(art: Image) -> Rect2i:
 var lo := Vector2i(art.get_width(),art.get_height());var hi := Vector2i.ZERO
 for y in art.get_height():
  for x in art.get_width():
   if art.get_pixel(x,y).a>=.5: lo=lo.min(Vector2i(x,y));hi=hi.max(Vector2i(x,y))
 return Rect2i(lo,hi-lo+Vector2i.ONE)
func read134(path: String) -> Image:
 var result := Image.new();result.load_png_from_buffer(FileAccess.get_file_as_bytes(path));return result
func _init() -> void:
 var data := {}
 for group in ["drift","attack"]:
  var sheet := read134("res://art/paper134/%s_sheet.png"%group)
  var cells: Array[Image]=[];var regions: Array[Rect2i]=[]
  var width := sheet.get_width()/2;var height := sheet.get_height()/2
  for i in 4:
   var cell := sheet.get_region(Rect2i((i%2)*width,(i/2)*height,width,height));cells.append(cell);regions.append(bounds134(cell))
  var reference := float(regions[0].size.y);var factor := 37./reference
  data[group]=[]
  for i in 4:
   var path := "res://assets/paper134/%s_%d.png"%[group,i]
   cells[i].save_png(path)
   var box: Rect2i=regions[i]
   data[group].append({"texture":path,"foot":[float(box.position.x)+float(box.size.x)*.5,float(box.position.y)+float(box.size.y)*.5+reference*.5],"scale":factor,"visible_width":box.size.x*factor,"visible_height":box.size.y*factor})
 var base := read134("res://assets/paper134/base_C.png");var box := bounds134(base);var factor := 37./box.size.y
 data["base"]={"texture":"res://assets/paper134/base_C.png","foot":[float(box.position.x)+float(box.size.x)*.5,float(box.end.y)],"scale":factor,"visible_width":box.size.x*factor,"visible_height":37.}
 FileAccess.open("res://assets/paper134/animation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 print("PAPER134_PREPARED drift=4 attack=4 base=1");quit()
