extends Control

const IMPRINT := .32
const STAR_BURST := .59
const DURATION := .92
var finished_shell: Texture2D
var motif: Texture2D
var picture: TextureRect
var position_on_page: Vector2
var ui_unit := 1.
var elapsed := DURATION
var tone := Color.WHITE
var chime: AudioStreamPlayer

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 chime=AudioStreamPlayer.new()
 chime.stream=preload("res://assets/music235/67_perfect.wav")
 chime.volume_db=-16.
 add_child(chime)

func busy() -> bool:
 return elapsed<DURATION

func start(print_image:TextureRect,finished:Texture2D) -> void:
 picture=print_image
 finished_shell=finished
 motif=picture.texture
 elapsed=0.

func finish() -> void:
 elapsed=DURATION
 chime.stop()
 queue_redraw()

func advance(delta:float) -> void:
 if busy():
  var before:=elapsed
  elapsed=minf(DURATION,elapsed+delta)
  if before<STAR_BURST and elapsed>=STAR_BURST:chime.play()
 queue_redraw()

func place(photo:Vector2,book_scale:float,light:Color) -> void:
 position_on_page=photo
 ui_unit=book_scale
 tone=light
 if busy() and is_instance_valid(picture):
  picture.self_modulate.a=1.-smoothstep(0.,.10,elapsed)*(1.-smoothstep(STAR_BURST+.06,DURATION,elapsed))

func _draw() -> void:
 if not busy():return
 var page:=position_on_page
 var gathered:=smoothstep(0.,IMPRINT,elapsed)
 var formed:=smoothstep(.23,IMPRINT,elapsed)
 var burst:=smoothstep(STAR_BURST,DURATION,elapsed)
 if elapsed<IMPRINT:
  var art_size:=motif.get_size()
  var fit:=minf(picture.size.x/art_size.x,picture.size.y/art_size.y)
  var art:=art_size*fit*ui_unit*lerpf(1.,.24,gathered)
  var ink_alpha:=smoothstep(0.,.10,elapsed)*(1.-formed)
  draw_texture_rect(motif,Rect2(page-art*.5,art),false,Color(tone,ink_alpha*.92))
  var glow:=sin(gathered*PI)
  draw_arc(page,lerpf(76.,35.,gathered)*ui_unit,0.,TAU,56,Color(1.,.84,.54,glow*.60),1.7*ui_unit,true)
 var glass_alpha:=formed*(1.-smoothstep(0.,.40,burst))
 var radius:=32.*ui_unit*lerpf(1.,.64,burst)
 if glass_alpha>0.:
  draw_circle(page+Vector2(2.,4.)*ui_unit,radius*.90,Color(.23,.12,.07,.23*glass_alpha),true,-1,true)
  var diameter:=Vector2.ONE*radius*2.
  draw_texture_rect(finished_shell,Rect2(page-diameter*.5,diameter),false,Color(tone,glass_alpha))
 if burst>0.:draw_stars(page,burst)

func draw_stars(center:Vector2,burst:float) -> void:
 for i in 8:
  var angle:=TAU*float(i)/8.+.29
  var distance:float=lerpf(13.,48.+float(i%3)*10.,burst)*ui_unit
  var at:=center+Vector2.from_angle(angle)*distance+Vector2.UP*16.*burst*ui_unit
  var alpha:=smoothstep(0.,.15,burst)*(1.-burst)*.94
  var radius:float=(7.+float(i%3)*1.7)*ui_unit*(1.-.55*burst)
  var outline:=PackedVector2Array()
  for j in 8:
   var direction:=Vector2.from_angle(angle+TAU*float(j)/8.)
   outline.append(at+direction*radius*(.31 if j%2 else 1.))
  draw_circle(at,radius*.95,Color(1.,.63,.25,alpha*.13),true,-1,true)
  draw_colored_polygon(outline,Color(1.,.89,.60,alpha))

