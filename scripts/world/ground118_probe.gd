extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world117.gd"
 func _hero_script() -> Script: return Fighter
func run() -> void:
 var s := Sample.new();root.add_child(s)
 while not s.woodland_ready117: await physics_frame
 await settle72(4)
 for sprite in [s.house_art,s.workshop116.pot.visual,s.workshop116.tin.visual]:
  var img: Image=sprite.texture.get_image();if img.is_compressed(): img.decompress()
  var data := []
  for f in [.15,.3,.5,.7,.85]:
   var x := int(img.get_width()*f);var bottom := 0
   for y in range(img.get_height()-1,0,-1):
    if img.get_pixel(x,y).a>.5: bottom=y;break
   var foot: Vector3=s._pixel_world(sprite,Vector2(x,bottom));data.append([f,foot.y-s.floor_height(Vector2(foot.x,foot.z)),foot])
  print("GROUND118 ",sprite.get_parent().name," ",data)
 for foot in s.house_contacts: print("CONTACT118 ",foot.mark.position, " ",foot.mark.visible)
 quit()
