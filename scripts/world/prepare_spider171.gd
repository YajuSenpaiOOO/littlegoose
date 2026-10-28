extends SceneTree
# Separate connected silhouettes, preserving authored pixels/alpha and the source.
func _initialize() -> void:
 var source := Image.load_from_file("res://assets/spider171/poses_source.png")
 var w := source.get_width();var h := source.get_height()
 var visited := PackedByteArray();visited.resize(w*h)
 var groups: Array=[]
 for y in h:
  for x in w:
   var seed := y*w+x
   if visited[seed] or source.get_pixel(x,y).a<.1: continue
   var queue := PackedInt32Array([seed]);visited[seed]=1;var cursor := 0
   while cursor<queue.size():
    var p := queue[cursor];cursor+=1;var px := p%w;var py := p/w
    for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
     var nx: int=px+d.x;var ny: int=py+d.y
     if nx<0 or ny<0 or nx>=w or ny>=h: continue
     var n: int=ny*w+nx
     if not visited[n] and source.get_pixel(nx,ny).a>=.1: visited[n]=1;queue.append(n)
   if queue.size()>10000: groups.append(queue)
 if groups.size()!=4: push_error("Expected four silhouettes, got "+str(groups.size()));quit(1);return
 var metadata := {}
 for group: PackedInt32Array in groups:
  var lo := Vector2i(w,h);var hi := Vector2i.ZERO
  for p in group: lo=lo.min(Vector2i(p%w,p/w));hi=hi.max(Vector2i(p%w,p/w))
  var center := (lo+hi)/2
  var key := ("winding" if center.x<w/2 else "push") if center.y<h/2 else ("sit" if center.x<w/2 else "ball")
  var image := Image.create(hi.x-lo.x+9,hi.y-lo.y+9,false,Image.FORMAT_RGBA8)
  for p in group: image.set_pixel(p%w-lo.x+4,p/w-lo.y+4,source.get_pixel(p%w,p/w))
  image.save_png("res://assets/spider171/"+key+".png")
  metadata[key]={"foot":[image.get_width()*.5,image.get_height()-5],"scale":24.*1.8/float(image.get_width()-8),"visible_width":float(image.get_width()-8)/float(image.get_width()-8)*43.2,"visible_height":float(image.get_height()-8)*1.8/float(image.get_width()-8)*24.}
 FileAccess.open("res://assets/spider171/poses.json",FileAccess.WRITE).store_string(JSON.stringify(metadata," "))
 print("SPIDER171_ART_READY ",metadata.keys());quit()
