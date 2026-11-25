extends SceneTree
const FOLDER="res://art/concepts/black_goose_attack_force_20261116/"
class Board:
 extends Node2D
 var sheet: Texture2D
 var time:=0.0
 var meshes: Array=[]
 const ForceCurve=preload("res://scripts/art/attack_force_curve_20261116.gd")
 func deform_point(src: Vector2,pose: Dictionary) -> Vector2:
  var p:=src-Vector2(228,85);var elbow:=Vector2(145,155)-Vector2(228,85)
  var weight:=1.-smoothstep(145.,200.,src.x)
  return (p.lerp((p-elbow).rotated(pose.elbow)+elbow,weight)+Vector2(pose.reach*weight,0)).rotated(pose.upper)
 func arm_mesh(pose: Dictionary) -> ArrayMesh:
  var vertices:=PackedVector3Array();var uvs:=PackedVector2Array()
  for y in 12:
   for x in 15:
    for off in [Vector2i.ZERO,Vector2i(1,0),Vector2i(1,1),Vector2i.ZERO,Vector2i(1,1),Vector2i(0,1)]:
     var src:=Vector2(x+off.x,y+off.y)*Vector2(20,20)
     var p:=deform_point(src,pose)
     vertices.append(Vector3(p.x,p.y,0));uvs.append((src+Vector2(1000,400))/Vector2(1536,1024))
  var arrays:=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uvs
  var m:=ArrayMesh.new();m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);return m
 func _draw() -> void:
  var font:=ThemeDB.fallback_font;draw_rect(Rect2(0,0,960,600),Color("171d2b"))
  draw_string(font,Vector2(20,35),"ONE ATTACK / CONTINUOUS ARM + DELAYED BODY RECOIL",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("f4e8d1"))
  for mode in 2:
   var x:=mode*480.
   draw_rect(Rect2(x+10,55,460,500),Color("262b40"))
   draw_string(font,Vector2(x+28,90),"Normal speed" if mode==0 else "Half speed / inspect force",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("f4e8d1"))
   var t: float=fmod(time*(1. if mode==0 else .5),2.)-.6
   var p: Dictionary=ForceCurve.sample(t)
   draw_set_transform(Vector2(x+240+p.body_x,360),p.lean,Vector2.ONE*.42)
   draw_texture_rect_region(sheet,Rect2(-427,-650,768,1024),Rect2(0,0,768,1024))
   draw_mesh(meshes[mode],sheet,Transform2D(0,Vector2(-52,-100)))
   draw_set_transform(Vector2.ZERO)
   var stage: String="READY"
   if t>=0. and t<.10:stage="1 / draw in"
   elif t>=.10 and t<.20:stage="2 / push wrist"
   elif t>=.20 and t<.40:stage="3 / body recoil"
   elif t>=.40 and t<.66:stage="4 / settle + overshoot"
   draw_string(font,Vector2(x+28,534),stage,HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("c4c3d6"))
  draw_string(font,Vector2(20,585),"Fixed expression / no bullets / constant head scale / shoulder-elbow deformation. Game remains 385.",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a7acc0"))
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(960,600);root.content_scale_size=Vector2i(960,600)
 var b:=Board.new();root.add_child(b);b.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 b.sheet=ImageTexture.create_from_image(Image.load_from_file(FOLDER+"parts.png"))
 for i in 100:
  b.time=i*.04;b.meshes.clear()
  for mode in 2:b.meshes.append(b.arm_mesh(Board.ForceCurve.sample(fmod(b.time*(1. if mode==0 else .5),2.)-.6)))
  b.queue_redraw()
  for j in 2:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(FOLDER+"frame-"+str(i).pad_zeros(3)+".png")
 print("FORCE_PREVIEW_DONE");quit()
