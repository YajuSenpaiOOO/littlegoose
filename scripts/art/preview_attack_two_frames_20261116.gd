extends SceneTree
const FOLDER="res://art/concepts/black_goose_attack_two_frames_20261116/"
class Board:
 extends Node2D
 var textures: Array[Texture2D]=[]
 var regions: Array[Rect2]=[]
 var states: Array=[]
 var shots: Array=[[],[],[]]
 var time:=0.0
 func sprite(index: int,center: Vector2,limit: Vector2) -> void:
  var region: Rect2=regions[index];var size:=region.size*minf(limit.x/region.size.x,limit.y/region.size.y)
  draw_texture_rect_region(textures[index],Rect2(center-size*.5,size),region)
 func _draw() -> void:
  var font:=ThemeDB.fallback_font;draw_rect(Rect2(0,0,960,540),Color("171d2b"))
  draw_string(font,Vector2(18,32),"IDLE > READY > RELEASE > RECOVER / CADENCE PROTOTYPE",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("f4e8d1"))
  for mode in 3:
   var x:=mode*320.
   draw_rect(Rect2(x+8,50,304,447),Color("262b40"))
   draw_string(font,Vector2(x+20,82),["Normal / 1.54 shots/s","Rapid / 10 shots/s","Beam / hold to fire"][mode],HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("f4e8d1"))
   var state=states[mode];var kick: float=state.kick
   draw_set_transform(Vector2(x+160+kick*8,277+sin(time*TAU*.65)*4),kick*.012,Vector2.ONE)
   var pose: int=2 if state.phase=="release" else (1 if state.phase=="ready" else 0)
   var factor:=318./1281.
   draw_texture_rect_region(textures[pose],Rect2(Vector2(-550.*factor,-1378.*factor+159.),Vector2(1086,1448)*factor),regions[pose])
   draw_set_transform(Vector2.ZERO)
   var hand:=Vector2(x+(98 if state.phase=="release" else 128)+kick*8,300)
   if mode==2 and time>=1. and time<3.2:
    draw_line(hand,Vector2(x+12,245),Color("b693db"),12.)
    draw_line(hand,Vector2(x+12,245),Color("fff1d0"),5.)
   for born in shots[mode]:
    var age: float=time-born
    if age<0. or age>.55:continue
    draw_set_transform(hand+Vector2(-age*260,-age*12),PI)
    sprite(3,Vector2.ZERO,Vector2(52,32));draw_set_transform(Vector2.ZERO)
   draw_string(font,Vector2(x+20,477),str(state.phase).to_upper(),HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("c4c3d6"))
  draw_string(font,Vector2(18,523),"Two attack poses / common head scale and foot anchor / no whole-body squash. Game stays 385.",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("a7acc0"))
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(960,540);root.content_scale_size=Vector2i(960,540)
 var b:=Board.new();b.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;root.add_child(b)
 var inputs: Array=JSON.parse_string(FileAccess.get_file_as_string(FOLDER+"preview-inputs.json"))
 for input in inputs:
  b.textures.append(ImageTexture.create_from_image(Image.load_from_file(input.file)))
  var r: Array=input.region;b.regions.append(Rect2(r[0],r[1],r[2],r[3]))
 for i in 3:b.states.append(preload("res://scripts/art/fire_pose_two_frames_20261116.gd").new())
 var next: Array=[1.12,1.12,1.12]
 for frame in 100:
  b.time=float(frame)*.05
  for mode in 3:
   var trigger: bool=b.time>=1. and b.time<3.2;var shot:=false
   if trigger and mode!=2 and b.time+.0001>=next[mode]:
    shot=true;b.shots[mode].append(b.time);next[mode]+=.1 if mode==1 else .65
   var prep: bool=trigger and (mode>0 or (next[mode]-b.time<=.12))
   b.states[mode].advance(.05,trigger,10. if mode==1 else 1.54,mode==2,shot,prep)
  b.queue_redraw()
  for i in 2:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(FOLDER+"frame-"+str(frame).pad_zeros(3)+".png")
 print("CONTINUITY_PREVIEW_DONE");quit()
