extends "res://art/paper134/prepare_frames.gd"
func _init() -> void:
 var sheet := read134("res://art/paper135/right_sheet.png")
 var data := {"right":[]}
 var width := sheet.get_width()/2;var height := sheet.get_height()/2
 var factor := 0.
 for i in 4:
  var cell := sheet.get_region(Rect2i((i%2)*width,(i/2)*height,width,height))
  var box := bounds134(cell)
  if i==0: factor=37./box.size.y
  var path := "res://assets/paper135/right_%d.png"%i
  cell.save_png(path)
  data.right.append({"texture":path,"foot":[box.position.x+box.size.x*.5,box.position.y+box.size.y*.5+37./factor*.5],"scale":factor,"visible_width":box.size.x*factor,"visible_height":box.size.y*factor})
 var flat := read134("res://art/paper135/defeat.png")
 var box := bounds134(flat)
 factor=37./box.size.x
 flat.save_png("res://assets/paper135/defeat.png")
 data.defeat={"texture":"res://assets/paper135/defeat.png","foot":[box.position.x+box.size.x*.5,float(box.end.y)],"scale":factor,"visible_width":37.,"visible_height":box.size.y*factor}
 FileAccess.open("res://assets/paper135/animation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 print("PAPER135_PREPARED");quit()
