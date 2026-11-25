extends Control

const TIN = preload("res://scripts/combat/workshop_tin_stock432.gd")
const THOUGHT = preload("res://scripts/room/interaction_cloud432.gd")
const BRACELET = preload("res://scripts/combat/workshop_bracelet432.gd")
const AQUA_GLASS := preload("res://assets/workshop432/marble-glass-aqua.png")
const PAPER_PLANE := preload("res://assets/workshop432/fragment-paper-plane.png")
const FRAGMENT_ART := preload("res://scripts/combat/workshop_fragment_art432.gd")
const PAPER_SIZE := Vector2(360,342)
const MARBLE_RADIUS := 24.3
const LAYERED_MARBLE_ART_SCALE := .89
enum GlassColor { AQUA, HONEY, ROSE, VIOLET, LEAF }
const GLASS_HUE_SHIFTS := [0.,-.35,.44,.22,-.20]
const GLASS_COLORS := {
 "balloon_sword":GlassColor.ROSE,"bouncy_ball":GlassColor.VIOLET,
 "cup_phone":GlassColor.HONEY,"exercise":GlassColor.LEAF,
 "eye_exercise":GlassColor.HONEY,"flashlight":GlassColor.LEAF,
 "forest_fireboy":GlassColor.VIOLET,"hero_moment":GlassColor.HONEY,
 "homework":GlassColor.HONEY,
 "music_class":GlassColor.AQUA,"paper_plane":GlassColor.AQUA,
 "pillow_hut":GlassColor.LEAF,"red_banner":GlassColor.ROSE,"snack":GlassColor.ROSE
}
const CREAM := Color("fff0ce")
const INK := Color("4d3228")
const HAND_BOX := Rect2(0,19,1000,667)
const PALM := Rect2(622,217,158,139)
const TRAYS_SETTLE := .23
const LID_SEATS := .49
const EXIT_TIME := .54
var world: Node3D
var hand_art: Texture2D
var closed_hand_art: Texture2D
var foreground: TextureRect
var foreground_light: ShaderMaterial
var lid_mask: ShaderMaterial
var font: Font
var thought: THOUGHT
var bracelet: BRACELET
var thought_id: String
var thought_copy: String
var hovered_slot:=-1
var idle_phase:=0.
var closing:=false
var exit_elapsed:=0.
var lid_open:=0.
var exit_lid_from:=0.
var lid_hint:=Vector2.ZERO
var ripple_phase:=0.
var open_amount:=0.
var box_center:=Vector2.ZERO
var page:=0
var layers: Array=[]
var paper_art: Texture2D
var marble_art: Array[AtlasTexture]=[]
var aqua_glass: AtlasTexture
var glass_palette: Array[Texture2D]=[]
var paper_light:=Color.WHITE
var marble_light:=Color.WHITE
var paper_plane: AtlasTexture
var fragment_art: Dictionary
var lift:=0.
var page_turn:=0.
var turn_direction:=0
var page_tween: Tween
var dragged:=""
var dragged_slot:=-1
var dragged_bead:=-1
var throw_velocity:=Vector2.ZERO
var last_motion_ms:=0
var hover:=Vector2.ZERO
var drag_from:=Vector2.ZERO
var snap_from:=Vector2.ZERO
var snap_to:=Vector2.ZERO
var snap_id:=""
var snap_slot:=-1

var snap_tween: Tween
var snap_progress:=1.
var taught_drag := false
var craft_water_marble: Texture2D

func _ready() -> void:
 font=ThemeDB.fallback_font
 lid_mask=ShaderMaterial.new()
 lid_mask.shader=preload("res://scripts/combat/workshop_lid_occlusion432.gdshader")
 material=lid_mask
 hand_art=preload("res://assets/workshop432/assembly-pov-b.png")
 closed_hand_art=load("res://assets/workshop432/assembly-pov-b-closed.png")
 paper_art=load("res://assets/workshop432/tin-paper-tray.png")
 aqua_glass=crop_texture(AQUA_GLASS,Rect2(13,18,1224,1222))
 glass_palette=make_glass_palette()
 paper_plane=crop_texture(PAPER_PLANE,Rect2(192,100,1154,835))
 fragment_art=FRAGMENT_ART.load_icons()
 var sheet: Texture2D=load("res://assets/workshop432/tin-marble-atlas.png")
 if sheet:
  var image:=sheet.get_image()
  var half:=Vector2i(image.get_size())/2
  for index in 4:
   var corner:=Vector2i(index%2,index/2)*half
   var used:=image.get_region(Rect2i(corner,half)).get_used_rect()
   marble_art.append(crop_texture(sheet,Rect2(Vector2(corner+used.position),Vector2(used.size))))
 foreground=TextureRect.new()
 foreground.mouse_filter=Control.MOUSE_FILTER_IGNORE
 foreground.show_behind_parent=true
 foreground.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 foreground.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 foreground.texture=hand_art
 foreground_light=ShaderMaterial.new()
 foreground_light.shader=preload("res://scripts/art/workshop_pov_light432.gdshader")
 foreground.material=foreground_light
 add_child(foreground)
 bracelet=BRACELET.new()
 bracelet.size=HAND_BOX.size
 bracelet.z_index=1
 foreground.add_child(bracelet)
 bracelet.attach_behind(foreground)
 foreground_light.set_shader_parameter("art_size",HAND_BOX.size)
 foreground_light.set_shader_parameter("cord_depth",bracelet.WRAP_DEPTH)
 thought=THOUGHT.new()
 thought.z_index=2
 thought.body_size=Vector2(400,80)
 add_child(thought)
 hide()

func crop_texture(source:Texture2D,region:Rect2) -> AtlasTexture:
 var art:=AtlasTexture.new()
 art.atlas=source
 art.region=region
 art.filter_clip=true
 return art

func make_glass_palette() -> Array[Texture2D]:
 var palette:Array[Texture2D]=[aqua_glass]
 var thumbnail:=AQUA_GLASS.get_image().get_region(Rect2i(aqua_glass.region))
 thumbnail.resize(144,144,Image.INTERPOLATE_LANCZOS)
 for i in range(1,GLASS_HUE_SHIFTS.size()):
  var tint:Image=thumbnail.duplicate()
  var shift:float=GLASS_HUE_SHIFTS[i]
  for y in tint.get_height():
   for x in tint.get_width():
    var base:=thumbnail.get_pixel(x,y)
    if base.a<=0.:continue
    var hue:=fposmod(base.h+shift,1.)
    tint.set_pixel(x,y,Color.from_hsv(hue,base.s,base.v,base.a))
  palette.append(ImageTexture.create_from_image(tint))
 return palette

func shade_for(look:Dictionary,light_fraction:float) -> Color:
 var shadow:Vector3=look.shadow
 var tone:=shadow.lerp(look.highlight,light_fraction)*float(look.exposure)
 return Color(tone.x,tone.y,tone.z)

func begin() -> void:
 page=0
 dragged=""
 dragged_slot=-1
 dragged_bead=-1
 throw_velocity=Vector2.ZERO
 closing=false
 exit_elapsed=0.
 lid_open=0.
 ripple_phase=0.
 idle_phase=0.
 foreground.texture=hand_art
 layers=world.memory_kit116.reconcile(world.memory_kit116.tin_layers)
 lift=0.
 page_turn=0.
 turn_direction=0
 if page_tween:page_tween.kill()
 snap_progress=1.
 if snap_tween:snap_tween.kill()

func update_view(blend: float,active: bool) -> void:
 open_amount=smoothstep(.55,1.,blend)
 visible=blend>.55
 var shed=world.workshop_shed432
 var delta:=get_process_delta_time()
 if closing and active:
  exit_elapsed=minf(exit_elapsed+delta,EXIT_TIME)
  if exit_elapsed>=EXIT_TIME:
   if world.close_memory116(true):
    active=false
   else:
    closing=false
    exit_elapsed=0.
    world.say_tin432(world.memory_ui116.feedback.text)
 if closing:
  lid_open=exit_lid_from*(1.-smoothstep(TRAYS_SETTLE-.05,LID_SEATS,exit_elapsed))
 elif active:
  lid_open=move_toward(lid_open,smoothstep(.20,.87,blend),delta*4.)
 else:
  lid_open=0.
 shed.props.set_lid_open(lid_open)
 if not visible:
  shed.pov_ink.set_shader_parameter("strength",0.)
  return
 idle_phase=fmod(idle_phase+delta*1.5,TAU*20.)
 mouse_filter=Control.MOUSE_FILTER_STOP if active else Control.MOUSE_FILTER_IGNORE
 var lens: Camera3D=shed.lens
 var props: Node3D=shed.props
 box_center=design(lens.unproject_position(props.to_global(props.TIN_AT+Vector3.UP*.1)))
 lid_hint=design(lens.unproject_position(props.lid.to_global(Vector3(0,.020,.192))))
 update_lid_mask(lens,props.lid)
 ripple_phase=fmod(ripple_phase+delta/1.18,1.)
 lift=move_toward(lift,float(not closing and dragged.is_empty() and page+1<layers.size() and notch_area().has_point(hover)),delta*7.)
 if not closing and turn_direction==0 and not layers.is_empty():step_marbles(delta)
 if active and can_use_tin() and not taught_drag:
  taught_drag=true
  world.say_tin432("把盒里的碎片拖进掌心，就能带走啦。")
 update_thought(delta,active and can_use_tin())
 var gripping: bool=closing and exit_elapsed>=.27 and not world.memory_ui116.working.is_empty()
 foreground.texture=closed_hand_art if gripping and closed_hand_art else hand_art
 var art:=foreground_rect()
 var scale_to_screen:=size/Vector2(1000,625)
 foreground.position=art.position*scale_to_screen
 foreground.size=art.size*scale_to_screen
 var look: Dictionary=world.time55.palette.sample(world.time55.visual_hour)
 var daylight: float=look.daylight
 paper_light=shed.worktop_tone(shade_for(look,.79),daylight)
 marble_light=shed.worktop_tone(shade_for(look,.60),daylight)
 var indoor_weight:=lerpf(.78,.18,daylight)
 foreground_light.set_shader_parameter("saturation",look.saturation)
 foreground_light.set_shader_parameter("exposure",lerpf(float(look.exposure)*.91,.99,indoor_weight))
 foreground_light.set_shader_parameter("shadows",Vector3(look.shadow).lerp(Vector3(.84,.69,.57),indoor_weight))
 foreground_light.set_shader_parameter("highlights",Vector3(look.highlight).lerp(Vector3(1.05,.97,.91),indoor_weight))
 foreground_light.set_shader_parameter("reveal",open_amount)
 var working: Array=world.memory_ui116.working
 bracelet.scale=scale_to_screen
 bracelet.capacity=world.memory_kit116.CAPACITY
 bracelet.used=world.memory_kit116.used(working)
 bracelet.preview=bracelet.used
 if not closing and dragged_bead>=0 and over_palm() and can_take(dragged):
  bracelet.preview+=cost(dragged)
 bracelet.flash_start=hovered_slot if hovered_slot>=0 else bracelet.used
 bracelet.flash_end=mini(bracelet.capacity,bracelet.flash_start+cost(thought_id)) if not thought_id.is_empty() else 0
 bracelet.shimmer=Time.get_ticks_msec()*.009
 bracelet.swing=sin(idle_phase-.7)*.055
 var light:=Color(.94,.81,.67).lerp(Color.WHITE,daylight)
 bracelet.tone=Color(light,open_amount)
 bracelet.put_on(gripping)
 foreground_light.set_shader_parameter("wrist_start",bracelet.wrist_start)
 foreground_light.set_shader_parameter("wrist_end",bracelet.wrist_end)
 foreground_light.set_shader_parameter("cord_shadow",lerpf(.54,.72,daylight))
 foreground_light.set_shader_parameter("charm_count",ceili(bracelet.capacity/2.))
 foreground_light.set_shader_parameter("finger_phase",idle_phase)
 foreground_light.set_shader_parameter("finger_motion",0. if closing else open_amount)
 var breath:=idle_phase*.8
 foreground_light.set_shader_parameter("breath_offset",Vector2(1.15*sin(breath-.4),3.0*sin(breath))*open_amount)
 shed.pov_ink.set_shader_parameter("strength",open_amount*lerpf(.25,.46,daylight))
 shed.pov_ink.set_shader_parameter("displacement",Vector2(-.04,-.025).lerp(Vector2(.025,.025),daylight))
 shed.pov_ink.set_shader_parameter("tint",Vector3(.077,.079,.128).lerp(Vector3(.155,.088,.048),daylight))
 queue_redraw()

func design(point: Vector2) -> Vector2:
 return point*Vector2(1000,625)/size

func can_use_tin() -> bool:
 return not closing and open_amount>=.92 and lid_open>.90

func over_lid() -> bool:
 var shed=world.workshop_shed432
 var lid: Node3D=shed.props.lid
 var screen:=hover*size/Vector2(1000,625)
 var camera: Camera3D=shed.lens
 var hit: Variant=Plane(lid.global_basis.y,lid.to_global(Vector3(0,.018,0))).intersects_ray(
  camera.project_ray_origin(screen),camera.project_ray_normal(screen))
 if hit==null:return false
 var local:=lid.to_local(hit)
 return Vector2(local.x,local.z).length_squared()<=.312*.312

func update_lid_mask(camera: Camera3D,lid: Node3D) -> void:
 var occlude:=closing and exit_elapsed>TRAYS_SETTLE-.05 and exit_elapsed<LID_SEATS
 lid_mask.set_shader_parameter("occlude",occlude)
 if not occlude:return
 var outline:=PackedVector2Array()
 for i in 20:
  var at:=Vector2.from_angle(TAU*float(i)/20.)*.315
  outline.append(camera.unproject_position(lid.to_global(Vector3(at.x,.019,at.y)))/size)
 lid_mask.set_shader_parameter("lid_outline",outline)

func begin_exit() -> void:
 if closing or not world.assembling432:return
 world.speech112.dismiss()
 if turn_direction!=0:
  page_tween.kill()
  page+=turn_direction
  turn_direction=0
  page_turn=0.
 if snap_tween:snap_tween.kill()
 snap_progress=1.
 dragged=""
 dragged_slot=-1
 dragged_bead=-1
 exit_lid_from=lid_open
 closing=true
 exit_elapsed=0.

func notch_area() -> Rect2:
 return Rect2(box_center+Vector2(131.,-33.),Vector2(57,66))

func side_center(index:int) -> Vector2:
 return Vector2(-8.,box_center.y-18.)+Vector2(-8.,-7.)*clampi(page-1-index,0,5)

func over_side_tray() -> bool:
 return page>0 and ((hover-side_center(page-1))/(PAPER_SIZE*.5)).length_squared()<=1.

func palm_point(index: int) -> Vector2:
 return Vector2(685.+(index%2)*50.,260.+(index/2)*50.)+foreground_rect().position-HAND_BOX.position

func over_palm() -> bool:
 return PALM.has_point(hover-foreground_rect().position+HAND_BOX.position)

func marble_hit(points: Array,origin: Vector2) -> int:
 for i in range(points.size()-1,-1,-1):
  if hover.distance_squared_to(origin+points[i].at)<=MARBLE_RADIUS*MARBLE_RADIUS:return i
 return -1

func update_thought(delta: float,active: bool) -> void:
 var id:=""
 var anchor:=Vector2.ZERO
 hovered_slot=-1
 var working: Array=world.memory_ui116.working
 if active and turn_direction==0 and dragged.is_empty() and snap_progress>=1. and not layers.is_empty():
  var occupied:=0
  for i in working.size():
   if hover.distance_squared_to(palm_point(i))<=MARBLE_RADIUS*MARBLE_RADIUS:
    id=working[i]
    anchor=palm_point(i)
    hovered_slot=occupied
    break
   occupied+=cost(working[i])
  if id.is_empty():
   var tray:=page-1 if over_side_tray() else page
   var origin:=box_center if tray==page else side_center(tray)
   var i:=marble_hit(layers[tray],origin)
   if i>=0:
    id=layers[tray][i].id
    anchor=origin+layers[tray][i].at
 if id!=thought_id:
  thought_id=id
  thought_copy="" if id.is_empty() else "%s · %d 格\n%s"%[
   world.memory_kit116.card(id).name,cost(id),world.memory_kit116.tin_line(id)]
 thought.present(delta,thought_copy,(anchor-Vector2(0,10.))*size/Vector2(1000,625))

func cost(id: String) -> int:
 return world.memory_kit116.used([id])

func can_take(id:String) -> bool:
 var proposal: Array=world.memory_ui116.working.duplicate()
 proposal.append(id)
 return world.memory_kit116.valid(proposal,world.memory_ui116.working_owned)

func foreground_rect() -> Rect2:
 var art:=HAND_BOX
 art.position+=Vector2(35,132)*(1.-open_amount)
 if closing:
  art.position+=Vector2(18,49)*smoothstep(.22,EXIT_TIME,exit_elapsed)
 return art

func _draw() -> void:
 if open_amount<=0. or not is_instance_valid(world):return
 draw_set_transform(Vector2.ZERO,0.,size/Vector2(1000,625))
 if not world.assembling432:return
 var working: Array=world.memory_ui116.working
 if closing:
  draw_returning_trays()
  var gather:=smoothstep(.10,.27,exit_elapsed)
  var opacity:=open_amount*(1.-smoothstep(.22,.29,exit_elapsed))
  for i in working.size():
   token(palm_point(i).lerp(palm_point(0),gather)+Vector2(10,15)*gather,working[i],opacity)
  return
 if can_use_tin() and dragged.is_empty() and bracelet.is_over(hover-foreground_rect().position):
  caption(Vector2(800,347),"已用 %d / %d 格"%[bracelet.used,bracelet.capacity],17,CREAM)
 draw_stack()
 for i in working.size():
  if dragged_slot==i or (snap_progress<1. and snap_slot==i):continue
  token(palm_point(i),working[i],open_amount)
 if snap_progress<1.:
  token(snap_from.lerp(snap_to,snap_progress),snap_id,open_amount)
 if not dragged.is_empty():token(hover,dragged,open_amount)
 if can_use_tin():draw_lid_hint()

func draw_lid_hint() -> void:
 for offset in [0.,.5]:
  var pulse:=fmod(ripple_phase+offset,1.)
  draw_arc(lid_hint,lerpf(9.,29.,pulse),0.,TAU,40,Color(CREAM,(1.-pulse)*.78),1.7,true)
 if dragged.is_empty() and over_lid():
  caption(lid_hint+Vector2(31,6),"合盖离开",15,CREAM)

func draw_returning_trays() -> void:
 var opacity:=1.-smoothstep(LID_SEATS-.055,LID_SEATS,exit_elapsed)
 draw_tray(page,box_center,false,opacity)
 var count:=mini(page,3)
 for i in count:
  var index:=page-1-i if i<count-1 else 0
  var t:=smoothstep(.035*i,TRAYS_SETTLE,exit_elapsed)
  var center:=side_center(index).lerp(box_center,t)-Vector2(0.,38.*sin(t*PI))
  draw_tray(index,center,true,opacity)

func caption(at: Vector2,words: String,height: int,color: Color) -> void:
 draw_string(font,at+Vector2(1,2),words,HORIZONTAL_ALIGNMENT_LEFT,-1,height,Color(.17,.10,.08,open_amount))
 draw_string(font,at,words,HORIZONTAL_ALIGNMENT_LEFT,-1,height,Color(color,open_amount))

func draw_stack() -> void:
 if layers.is_empty():return
 for i in range(maxi(0,page-3),page):
  if turn_direction<0 and i==page-1:continue
  draw_tray(i,side_center(i),true)
 if turn_direction==0:
  draw_tray(page,box_center)
 elif turn_direction>0:
  draw_tray(page+1,box_center)
  moving_tray(page,box_center,side_center(page))
 else:
  draw_tray(page,box_center)
  moving_tray(page-1,side_center(page-1),box_center)
 if turn_direction!=0:return
 if page+1<layers.size() and lift>.1:
  var edge:=box_center+Vector2(150,-2-lift*12.)
  draw_arc(edge,13.,-1.1,1.05,14,Color(CREAM,open_amount*lift),2.,true)
  caption(edge+Vector2(-26.,32.),"提起纸托",14,CREAM)
 if over_side_tray() and thought_id.is_empty():
  caption(Vector2(25.,side_center(page-1).y+147.),"放回纸托",14,CREAM)
 caption(box_center+Vector2(-36.,-135.),"%d / %d 层"%[page+1,layers.size()],14,CREAM)

func moving_tray(index:int,from:Vector2,to:Vector2) -> void:
 var mid:=sin(page_turn*PI)
 var center:=from.lerp(to,page_turn)-Vector2(0,54.*mid)
 draw_tray(index,center,true)

func draw_tray(index:int,center:Vector2,on_table:=false,opacity:=1.) -> void:
 var alpha:=open_amount*opacity*(1. if closing else smoothstep(.28,.73,lid_open))
 if alpha<=.001:return
 var region:=Rect2(center-PAPER_SIZE*.5,PAPER_SIZE)
 if paper_art:
  if on_table:
   var shadow:=Rect2(region.position+Vector2(3.,6.),region.size)
   draw_texture_rect(paper_art,shadow,false,Color(.15,.09,.06,alpha*.28))
  draw_texture_rect(paper_art,region,false,Color(paper_light,alpha))
 for i in layers[index].size():
  if index==page and i==dragged_bead:continue
  var bead: Dictionary=layers[index][i]
  token(center+bead.at,bead.id,alpha,bead.get("roll",0.))

func token(at: Vector2,id: String,alpha: float,roll:=0.) -> void:
 if marble_art.size()!=4:return
 var index:=3
 match id:
  "paper_plane":index=0
  "slingshot":index=1
  "three_player":index=2
 var motif: Texture2D=paper_plane if id=="paper_plane" else fragment_art.get(id)
 var composed:=aqua_glass!=null and motif!=null
 var radius:=MARBLE_RADIUS*(LAYERED_MARBLE_ART_SCALE if composed else 1.)
 var shadow:=at+Vector2(1.35,2.7)
 for i in 3:
  draw_circle(shadow,radius*(1.03-i*.10),Color(.14,.12,.15,alpha*.12),true,-1,true)
 var unit:=size/Vector2(1000,625)
 if composed:
  var index_in_palette:int=GLASS_COLORS.get(id,int(id.hash()%glass_palette.size()))
  draw_layered_marble(at*unit,unit,glass_palette[index_in_palette],motif,radius,alpha,roll)
  draw_set_transform(Vector2.ZERO,0.,unit)
  return
 draw_set_transform_matrix(Transform2D(roll,unit,0.,at*unit))
 draw_texture_rect(marble_art[index],Rect2(Vector2.ONE*-radius,Vector2.ONE*radius*2.),false,Color(marble_light,alpha))
 if index==3:
  var name: String=world.memory_kit116.card(id).name
  var letters:=name.left(2)
  var font_size:=14
  var width:=font.get_string_size(letters,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
  draw_string(font,Vector2(-width*.5,5),letters,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color(INK,alpha))
 draw_set_transform(Vector2.ZERO,0.,unit)

func draw_layered_marble(origin:Vector2,unit:Vector2,shell:Texture2D,motif:Texture2D,radius:float,alpha:float,roll:float) -> void:
 var diameter:=radius*2.
 var glass_area:=Rect2(Vector2.ONE*-radius,Vector2.ONE*diameter)
 var still:=Transform2D(0.,unit,0.,origin)
 draw_set_transform_matrix(still)
 draw_texture_rect(shell,glass_area,false,Color(marble_light,alpha))
 # Keep the reflected light fixed while the object inside turns.
 var art_size:=motif.get_size()
 var fit:=minf(diameter*.67/art_size.x,diameter*.70/art_size.y)
 var face_size:=art_size*fit*Vector2(.94+.06*cos(roll*.83),1.)
 draw_set_transform_matrix(Transform2D(roll,unit,0.,origin))
 draw_texture_rect(motif,Rect2(-face_size*.5,face_size),false,Color(marble_light*Color(.91,.97,.94),alpha*.94))
 draw_set_transform_matrix(still)
 draw_texture_rect(shell,glass_area,false,Color(marble_light,alpha*.15))

func craft_marble(id:String) -> Texture2D:
 if id=="paper_plane":return marble_art[0]
 if id=="slingshot":return marble_art[1]
 if id!="snack":return null
 if craft_water_marble==null:
  var shell:=glass_palette[GLASS_COLORS[id]].get_image()
  var icon:AtlasTexture=fragment_art[id]
  var source:=icon.atlas.get_image()
  if source.is_compressed():source.decompress()
  var motif:=source.get_region(Rect2i(icon.region))
  motif.convert(shell.get_format())
  var extent:=Vector2(shell.get_size())
  var target:=Vector2i(Vector2(motif.get_size())*minf(extent.x*.67/motif.get_width(),extent.y*.70/motif.get_height()))
  motif.resize(target.x,target.y,Image.INTERPOLATE_LANCZOS)
  shell.blend_rect(motif,Rect2i(Vector2i.ZERO,target),(shell.get_size()-target)/2)
  craft_water_marble=ImageTexture.create_from_image(shell)
 return craft_water_marble

func step_marbles(delta:float) -> void:
 var layer: Array=layers[page]
 var dt:=minf(delta,.035)
 for i in layer.size():
  var marble:Dictionary=layer[i]
  var speed:Vector2=marble.get("speed",Vector2.ZERO)
  if i==dragged_bead or speed.length_squared()<2.:continue
  var next:Vector2=marble.at+speed*dt
  if next.length()>TIN.RADIUS:
   next=next.limit_length(TIN.RADIUS)
   speed=speed.bounce(next.normalized())*.48
  var travel:Vector2=next-marble.at
  marble.at=next
  marble.roll=float(marble.get("roll",0.))+travel.length()*signf(travel.dot(Vector2(1.,.35)))/23.
  marble.speed=speed*exp(-dt*5.2)
 for i in layer.size():
  for j in range(i+1,layer.size()):
   if i==dragged_bead or j==dragged_bead:continue
   var a:Dictionary=layer[i]
   var b:Dictionary=layer[j]
   var span:Vector2=b.at-a.at
   var distance:=span.length()
   if distance>=46.:continue
   var axis:=span/distance if distance>.01 else Vector2.RIGHT
   var spread:=axis*(46.-distance)*.50
   a.at=(a.at-spread).limit_length(TIN.RADIUS)
   b.at=(b.at+spread).limit_length(TIN.RADIUS)
   var va:Vector2=a.get("speed",Vector2.ZERO)
   var vb:Vector2=b.get("speed",Vector2.ZERO)
   var impact:=maxf(0.,(va-vb).dot(axis))*.65
   a.speed=va-axis*impact
   b.speed=vb+axis*impact

func _gui_input(event: InputEvent) -> void:
 if not world.assembling432 or not can_use_tin():return
 if event is InputEventMouseMotion:
  hover=design(event.position)
  throw_velocity=(event.relative*Vector2(1000,625)/size*11.).limit_length(230.)
  last_motion_ms=Time.get_ticks_msec()
 if not event is InputEventMouseButton or event.button_index!=MOUSE_BUTTON_LEFT:return
 hover=design(event.position)
 accept_event()
 if event.pressed:pick()
 elif dragged!="":drop()

func pick() -> void:
 if turn_direction!=0:return
 if over_lid():
  begin_exit()
  return
 if over_side_tray():
  flip_page(-1)
  return
 if page+1<layers.size() and notch_area().has_point(hover):
  flip_page(1)
  return
 var working: Array=world.memory_ui116.working
 for i in working.size():
  if hover.distance_squared_to(palm_point(i))<=MARBLE_RADIUS*MARBLE_RADIUS:
   dragged=working[i]
   dragged_slot=i
   drag_from=palm_point(i)
   return
 var i:=marble_hit(layers[page],box_center)
 if i>=0:
  dragged=layers[page][i].id
  dragged_bead=i
  drag_from=box_center+layers[page][i].at

func flip_page(direction: int) -> void:
 turn_direction=direction
 page_turn=0.
 page_tween=create_tween()
 page_tween.tween_property(self,"page_turn",1.,.36).set_trans(Tween.TRANS_SINE)
 page_tween.tween_callback(func():
  page+=direction
  turn_direction=0
  page_turn=0.)

func drop() -> void:
 var working: Array=world.memory_ui116.working
 var layer: Array=layers[page]
 var at:Vector2=hover-box_center
 var momentum:=throw_velocity*clampf(1.-float(Time.get_ticks_msec()-last_motion_ms)/150.,0.,1.)
 var target:=drag_from
 var placed:=false
 snap_slot=-1
 if dragged_bead>=0 and over_palm():
  if can_take(dragged):
   target=palm_point(working.size())
   snap_slot=working.size()
   working.append(dragged)
   layer.remove_at(dragged_bead)
  else:
   var excess: int=world.memory_kit116.used(working)+cost(dragged)-world.memory_kit116.CAPACITY
   world.say_tin432("掌心还差 %d 格。"%excess if excess>0 else "这颗和你手里的记忆不能一起带走呢。")
 elif at.length()<=168.:
  if dragged_bead>=0:
   var bead: Dictionary=layer[dragged_bead]
   bead.at=at.limit_length(TIN.RADIUS)
   bead.speed=momentum
   placed=true
  elif layer.size()<TIN.LAYER_LIMIT:
   working.remove_at(dragged_slot)
   layer.append({"id":dragged,"at":at.limit_length(TIN.RADIUS),"speed":momentum})
   placed=true
  else:world.say_tin432("这张纸托放满啦，换一层试试？")
 if snap_tween:snap_tween.kill()
 snap_progress=1.
 if not placed:
  snap_from=hover
  snap_to=target
  snap_id=dragged
  snap_progress=0.
  snap_tween=create_tween()
  snap_tween.tween_property(self,"snap_progress",1.,.19).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 dragged=""
 dragged_slot=-1
 dragged_bead=-1
 throw_velocity=Vector2.ZERO
