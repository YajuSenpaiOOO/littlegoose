extends Control
# Shared screen-space renderer. World adapters own gameplay and skill timers.
var battle: Node3D
var tracks342: Dictionary={}
var bars342: Array[Dictionary]=[]
var boss342: Dictionary={}
var slot342: Dictionary={}
var boss_rect342:=Rect2()
var slot_rect342:=Rect2()
var cream342:=Color("f0dfbf")
var gold342:=Color("dcb975")
var ink342:=Color(.12,.10,.16,.92)
var rose342:=Color("bf797e")
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 process_priority=110
func track342(key: String, ratio: float, delta: float) -> Dictionary:
 if not tracks342.has(key):tracks342[key]={"ratio":ratio,"trail":ratio,"hold":0.,"seen":0.}
 var item: Dictionary=tracks342[key]
 if ratio<item.ratio:item.hold=.22;item.seen=1.8
 elif ratio>item.ratio:item.trail=ratio
 item.ratio=ratio
 item.seen=maxf(0.,item.seen-delta)
 item.hold=maxf(0.,item.hold-delta)
 if item.hold<=0.:item.trail=move_toward(float(item.trail),ratio,delta*.7)
 return item
func anchor342(sprite: Sprite3D) -> Vector2:
 var camera:=get_viewport().get_camera_3d()
 if not is_instance_valid(sprite) or camera.is_position_behind(sprite.global_position):return Vector2(-9999,-9999)
 var bounds:=sprite.get_aabb()
 var top:=Vector2(INF,INF)
 var left:=INF
 var right:=-INF
 for x in [0.,1.]:
  for y in [0.,1.]:
   var at: Vector3=sprite.global_transform*(bounds.position+bounds.size*Vector3(x,y,.5))
   var screen:=camera.unproject_position(at)
   top.y=minf(top.y,screen.y);left=minf(left,screen.x);right=maxf(right,screen.x)
 return Vector2((left+right)*.5,top.y-12.)
func _process(delta: float) -> void:
 bars342.clear();boss342.clear()
 if is_instance_valid(battle.boss_bar326):battle.boss_bar326.hide()
 if is_instance_valid(battle.phase_label326):battle.phase_label326.hide()
 if is_instance_valid(battle.state_hud288):battle.state_hud288.hide()
 if is_instance_valid(battle.moment161) and is_instance_valid(battle.moment161.label161):battle.moment161.label161.hide()
 if int(battle.levels226.get("homework",0))>0 and is_instance_valid(battle.paper_memories146.hud146):battle.paper_memories146.hud146.hide()
 slot342=battle.active_slot342()
 var live: Dictionary={}
 for enemy in battle.enemies:
  if not is_instance_valid(enemy):continue
  # Suppress only the old actor's bar, not its sprite or hit region.
  if is_instance_valid(enemy.health_fill):enemy.health_fill.layers=0
  if enemy.dead or not enemy.is_visible_in_tree() or enemy.hit_area.collision_layer==0:continue
  var key:=str(enemy.get_instance_id())
  live[key]=true
  var ratio:=clampf(float(enemy.hp)/maxf(.001,float(enemy.max_hp110)),0.,1.)
  var item:=track342(key,ratio,delta)
  var selected: bool=battle.target114==enemy
  var timer:=maxf(float(enemy.health_time),float(item.seen))
  if not selected and timer<=0.:continue
  bars342.append({"at":anchor342(enemy.visual),"ratio":ratio,"trail":item.trail,"alpha":1. if selected else clampf(timer/.35,0.,1.),"repair":false})
 if is_instance_valid(battle.theatre314) and battle.mode264=="paper301" and battle.active114 and not battle.waiting_intro314:
  live["castle"]=true
  var hp:=maxf(0.,float(battle.fastener_hp321))
  var item:=track342("castle",hp/float(battle.CASTLE334),delta)
  if hp>0. and battle.core_phase326:boss342={"name":"妹妹的山顶纸剧场","ratio":hp/float(battle.CASTLE334),"trail":item.trail,"phase":battle.phase_label326.text}
  for i in 2:
   var key:="cannon"+str(i)
   live[key]=true
   var ratio:=clampf(float(battle.cannon_hp326[i])/float(battle.CANNON334),0.,1.)
   var gun:=track342(key,ratio,delta)
   var selected: bool=not battle.structure335.is_empty() and battle.structure335.collider==battle.theatre314.cannon_areas326[i]
   var repair: bool=battle.cannon_hp326[i]<=0.
   if repair or selected or gun.seen>0.:
    var at:=anchor342(battle.theatre314.cannons326[i])
    var progress:=clampf(battle.rebuild_age334/7.,0.,1.) if battle.rebuild_index334==i else 0.
    bars342.append({"at":at,"ratio":progress if repair else ratio,"trail":progress if repair else gun.trail,"alpha":1. if repair or selected else clampf(float(gun.seen)/.35,0.,1.),"repair":repair,"waiting":battle.rebuild_index334!=i})
 for key in tracks342.keys():
  if not live.has(key):tracks342.erase(key)
 visible=not battle.combat_paused and not (is_instance_valid(battle.memory_ui116) and battle.memory_ui116.visible)
 queue_redraw()
func text342(at: Vector2, text: String, size: int, color: Color, width: float=-1., align: int=HORIZONTAL_ALIGNMENT_LEFT) -> void:
 draw_string_outline(ThemeDB.fallback_font,at,text,align,width,size,3,ink342)
 draw_string(ThemeDB.fallback_font,at,text,align,width,size,color)
func bar342(rect: Rect2, ratio: float, trail: float, color: Color, alpha: float=1.) -> void:
 draw_rect(rect.grow(2.),Color(ink342,alpha*.9))
 draw_rect(rect,Color(.28,.23,.27,alpha))
 draw_rect(Rect2(rect.position,Vector2(rect.size.x*clampf(trail,0.,1.),rect.size.y)),Color(gold342,alpha*.7))
 draw_rect(Rect2(rect.position,Vector2(rect.size.x*clampf(ratio,0.,1.),rect.size.y)),Color(color,alpha))
func _draw() -> void:
 boss_rect342=Rect2();slot_rect342=Rect2()
 var viewport:=get_viewport_rect()
 var scale:=clampf(viewport.size.x/1600.,.75,1.25)
 for entry in bars342:
  if not viewport.grow(-12.).has_point(entry.at):continue
  var width:=54.*scale
  bar342(Rect2(entry.at-Vector2(width*.5,0),Vector2(width,4.*scale)),entry.ratio,entry.trail,gold342 if entry.repair else rose342,entry.alpha)
  if entry.repair:text342(entry.at+Vector2(-width*.5,-5),"等待重建" if entry.waiting else "重建中",11,cream342)
 if not boss342.is_empty():
  var width:=minf(620.*scale,viewport.size.x*.46)
  var at:=Vector2((viewport.size.x-width)*.5,viewport.size.y-65.*scale)
  boss_rect342=Rect2(at-Vector2(6,30),Vector2(width+12,46))
  text342(at+Vector2(0,-34),boss342.phase,roundi(12.*scale),gold342,width,HORIZONTAL_ALIGNMENT_CENTER)
  text342(at+Vector2(0,-12),boss342.name,roundi(17.*scale),cream342,width,HORIZONTAL_ALIGNMENT_CENTER)
  bar342(Rect2(at,Vector2(width,9.*scale)),boss342.ratio,boss342.trail,rose342)
  for side in [-1.,1.]:
   var end:=at+Vector2(width*.5+side*(width*.5+8),4.*scale)
   draw_colored_polygon(PackedVector2Array([end+Vector2(0,-4),end+Vector2(4,0),end+Vector2(0,4),end+Vector2(-4,0)]),gold342)
 if slot342.is_empty() or slot342.state=="empty":return
 var at:=Vector2(viewport.size.x-236.*scale,viewport.size.y-96.*scale)
 slot_rect342=Rect2(at,Vector2(212,65)*scale)
 var panel:=StyleBoxFlat.new();panel.bg_color=Color(ink342,.78);panel.set_corner_radius_all(6)
 draw_style_box(panel,slot_rect342)
 var color:=Color("c95866") if slot342.state=="red" else gold342
 if slot342.state in ["cooldown","collect","unavailable"]:color=Color("a397a3")
 var center:=at+Vector2(31,31)*scale
 draw_arc(center,22.*scale,-PI*.5,PI*1.5,40,Color(.34,.29,.34),3.*scale,true)
 draw_arc(center,22.*scale,-PI*.5,-PI*.5+TAU*clampf(float(slot342.ratio),.001,1.),40,color,3.*scale,true)
 # Simple shared slot glyph: torch / star / notebook.
 if slot342.id=="flashlight":
  draw_line(center+Vector2(-4,7)*scale,center+Vector2(3,-7)*scale,color,5.*scale,true)
  draw_line(center+Vector2(0,-8)*scale,center+Vector2(8,-4)*scale,color,7.*scale,true)
 elif slot342.id=="hero_moment":
  var points:=PackedVector2Array()
  for i in 10:points.append(center+Vector2.from_angle(-PI*.5+i*PI/5.)*(11. if i%2==0 else 5.)*scale)
  draw_colored_polygon(points,color)
 else:
  draw_rect(Rect2(center-Vector2(8,10)*scale,Vector2(16,20)*scale),color,false,2.)
  for y in [-4.,1.,6.]:draw_line(center+Vector2(-4,y)*scale,center+Vector2(5,y)*scale,color,1.)
 text342(at+Vector2(20,62)*scale,"Q",roundi(12.*scale),cream342)
 text342(at+Vector2(64,25)*scale,slot342.name,roundi(16.*scale),cream342)
 var status: String={"ready":"可以使用","cooldown":"%.1f 秒"%slot342.seconds,"active":"持续 %.1f 秒"%slot342.seconds,"red":"余光 %.1f 秒"%slot342.seconds,"intro":"正在变身","collect":"等待记录","unavailable":"战斗中使用"}.get(slot342.state,"")
 if slot342.id=="homework" and slot342.state=="active":status="正在翻阅"
 text342(at+Vector2(64,48)*scale,status,roundi(13.*scale),color)
