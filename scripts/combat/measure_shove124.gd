extends SceneTree
func _init() -> void:
 var art: Image= load("res://assets/tuantuan_v2/shove_angry124.png").get_image()
 var lo := Vector2i(art.get_width(),art.get_height());var hi := Vector2i.ZERO
 for y in art.get_height():
  for x in art.get_width():
   if art.get_pixel(x,y).a>=.5:
    lo=lo.min(Vector2i(x,y));hi=hi.max(Vector2i(x,y))
 print("BOUNDS124 ",lo," ",hi," raw=",art.get_used_rect())
 var width := hi.x-lo.x+1;var height := hi.y-lo.y+1;var pixels := 32./width
 var data := {"foot":[(lo.x+hi.x)*.5,hi.y+1],"scale":pixels,"visible_width":32.,"visible_height":height*pixels}
 FileAccess.open("res://assets/tuantuan_v2/shove_angry124.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 quit()

