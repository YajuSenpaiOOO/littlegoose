extends SceneTree
const FOLDER="res://art/concepts/black_goose_south_attack_20261116/"
class Board:
 extends Node2D
 var sheet: Texture2D
 var feather: Texture2D
 var feather_region: Rect2
 var factor:=.42
 var foot:=885.
 var time:=0.0
 const ForceCurve=preload("res://scripts/art/attack_force_curve_20261116.gd")
 func _draw() -> void:
  var font:=ThemeDB.fallback_font;draw_rect(Rect2(0,0,960,600),Color("171d2b"))
  draw_string(font,Vector2(20,34),"FULL DRAWN POSES / SOUTH-FACING RELEASE",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("f4e8d1"))
  for mode in 2:
   var x:=mode*480.;draw_rect(Rect2(x+10,55,460,500),Color("262b40"))
   draw_string(font,Vector2(x+25,88),"Due south / single shot" if mode==0 else "South +/-45 deg / aiming examples",HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("f4e8d1"))
   var cycle:=int(time/1.6);var t:=fmod(time,1.6)-.35
   var cell:=0
   if t>=.14 and t<.34:cell=1
   elif t>=.34 and t<.64:cell=2
   var force: Dictionary=ForceCurve.sample(t)
   # Project northward recoil along -Z into screen-up, not screen-right.
   var center:=Vector2(x+240,460-force.body_x*.6)
   draw_texture_rect_region(sheet,Rect2(center-Vector2(256,foot)*factor,Vector2(512,1024)*factor),Rect2(cell*512,0,512,1024))
   var hand:=Vector2(x+200,318-force.body_x*.6)
   if mode==1:
    for a in [-PI/4.,PI/4.]:
     var endpoint:=hand+Vector2(sin(a),cos(a)*sin(deg_to_rad(25.)))*185.
     draw_line(hand,endpoint,Color(.75,.75,.9,.22),1.)
   var age:=t-.14
   if age>=0. and age<1.02:
    var angle: float=0. if mode==0 else [-PI/4.,0.,PI/4.][cycle%3]
    var velocity:=Vector2(sin(angle),cos(angle)*sin(deg_to_rad(25.)))*210.
    var pos:=hand+velocity*age
    draw_set_transform(pos,velocity.angle())
    var size:=feather_region.size*(52./feather_region.size.x)
    draw_texture_rect_region(feather,Rect2(-size*.5,size),feather_region);draw_set_transform(Vector2.ZERO)
   draw_string(font,Vector2(x+25,536),["draw in / open eyes","release / happy exertion","follow through / relax"][cell],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("c4c3d6"))
  draw_string(font,Vector2(20,584),"World south = +Z; 90-degree aiming sector projected by 25-degree camera. One projectile per attack.",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("a7acc0"))
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(960,600);root.content_scale_size=Vector2i(960,600)
 var b:=Board.new();root.add_child(b);b.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 b.sheet=ImageTexture.create_from_image(Image.load_from_file(FOLDER+"poses.png"))
 b.feather=ImageTexture.create_from_image(Image.load_from_file("res://art/concepts/black_goose_feather_B_simple_20261114/feather-pixel.png"))
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(FOLDER+"layout.json"));b.foot=data.bottom;b.factor=360./(data.bottom-data.top)
 var r: Array=data.feather_region;b.feather_region=Rect2(r[0],r[1],r[2],r[3])
 for i in 120:
  b.time=i*.04;b.queue_redraw()
  for j in 2:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(FOLDER+"frame-"+str(i).pad_zeros(3)+".png")
 print("SOUTH_PREVIEW_DONE");quit()
