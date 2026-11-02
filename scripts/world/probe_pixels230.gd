extends SceneTree
func _initialize() -> void:
 var a=load("res://assets/fat_cat220/roll_sheet.png").get_image()
 var b=load("res://assets/fat_cat230/roll_sheet.png").get_image()
 print("PIXFORMAT ",a.get_format()," ",b.get_format())
 for i in 6:
  var count=0;var first=Vector2i(-1,-1)
  for y in range((i/3)*512,(i/3)*512+512):
   for x in range((i%3)*512,(i%3)*512+512):
    if a.get_pixel(x,y)!=b.get_pixel(x,y):
     count+=1
     if first.x<0:first=Vector2i(x,y)
  print("PIXDIFF ",i," ",count," first=",first," colors=",a.get_pixelv(first) if first.x>=0 else Color.WHITE," ",b.get_pixelv(first) if first.x>=0 else Color.WHITE)
 quit()
