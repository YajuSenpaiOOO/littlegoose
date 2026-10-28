extends Node3D
## Attack packets contain values only: no pooled nodes, callbacks or recursive recording.
var battle: Node3D
var flights146: Array[Dictionary]=[]
var pages146: Array[Dictionary]=[]
var pending146: Array[Dictionary]=[]
var bursts146: Array[Dictionary]=[]
var writing146 := false
var write_age146 := 0.
var replay_wait146 := 0.
var planes_launched146 := 0
var deliveries146 := 0
var records146 := 0
var replayed146 := 0
var cancelled146 := 0
var max_live146 := 0
var last_origin146 := Vector3.ZERO
var regions146: Dictionary
var plane_texture146: Texture2D
var book_texture146: Texture2D
var book146: Sprite3D
var hud146: Label
var art146: Node2D
var flight_rng146 := RandomNumberGenerator.new()
var last_side146 := 1.
func texture146(label: String) -> Texture2D:
 var image := preload("res://scripts/combat/imported_image172.gd").read("res://assets/paper_memories146/"+label+".png")
 var box: Array=regions146[label];var cut := image.get_region(Rect2i(box[0],box[1],box[2],box[3]));cut.generate_mipmaps()
 return ImageTexture.create_from_image(cut)
func sprite146(texture: Texture2D,width: float) -> Sprite3D:
 var sprite := Sprite3D.new();sprite.texture=texture;sprite.pixel_size=width/texture.get_width()
 sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;sprite.alpha_scissor_threshold=.86
 sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;sprite.shaded=true
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(sprite);return sprite
func _ready() -> void:
 name="PaperPlanesAndClassNotes146"
 flight_rng146.randomize()
 regions146=JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper_memories146/regions.json"))
 plane_texture146=texture146("plane");book_texture146=texture146("book")
 book146=sprite146(book_texture146,.65);book146.hide()
 var layer := CanvasLayer.new();layer.layer=19;add_child(layer)
 hud146=Label.new();hud146.add_theme_font_size_override("font_size",19);hud146.add_theme_color_override("font_color",Color("fff0cb"));hud146.add_theme_color_override("font_outline_color",Color("302834"));hud146.add_theme_constant_override("outline_size",4);hud146.mouse_filter=Control.MOUSE_FILTER_IGNORE;layer.add_child(hud146)
 art146=Node2D.new();layer.add_child(art146);art146.draw.connect(draw146)
func reset146() -> void:
 for flight in flights146:
  if is_instance_valid(flight.node): flight.node.queue_free()
 flights146.clear();pages146.clear();pending146.clear();bursts146.clear();writing146=false;write_age146=0.
 if is_instance_valid(book146): book146.hide()
func record146(packet: Dictionary) -> void:
 if battle.buffs.level("homework")<=0: return
 pages146.append(packet.duplicate(true));records146+=1
 while pages146.size()>3: pages146.pop_front()
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 var toward := target-origin;var flat := Vector3(toward.x,0.,toward.z)
 if flat.length_squared()<.01: flat=Vector3.FORWARD
 var distance := clampf(flat.length(),1.1,8.);var direction := flat.normalized();var side := direction.cross(Vector3.UP)
 var lock := origin+direction*distance;lock.y=target.y
 lock.y=clampf(lock.y,battle.floor_height(Vector2(lock.x,lock.z))+.45,battle.floor_height(Vector2(lock.x,lock.z))+3.)
 # Prefer a fresh turn without making left/right a metronomic alternating pattern.
 if flight_rng146.randf()<.65: last_side146=-last_side146
 var bend := last_side146*flight_rng146.randf_range(.45,1.45)
 var arrival := lock-direction*flight_rng146.randf_range(.65,1.05)+side*last_side146*flight_rng146.randf_range(.45,.85)
 arrival.y=maxf(lock.y+.12,battle.floor_height(Vector2(arrival.x,arrival.z))+.7)
 var sprite := sprite146(plane_texture146,.90 if not replay else .72);sprite.position=origin
 flights146.append({"packet":packet.duplicate(true),"start":origin,"lock":lock,"arrival":arrival,"dir":direction,"side":side,"time":0.,"duration":(.48+distance*.045)*flight_rng146.randf_range(.88,1.12),"height":flight_rng146.randf_range(.65,1.65),"bend":bend,"sway":flight_rng146.randf_range(-.24,.24),"pace":flight_rng146.randf_range(.72,1.28),"bank":flight_rng146.randf_range(.04,.13),"sent":false,"node":sprite,"gain":gain,"replay":replay})
 planes_launched146+=1;max_live146=maxi(max_live146,flights146.size())
func flight_point146(f: Dictionary,t: float) -> Vector3:
 var u := pow(clampf(t,0.,1.),float(f.pace))
 return Vector3(f.start).lerp(f.arrival,smoothstep(0.,1.,u))+Vector3.UP*sin(u*PI)*float(f.height)+Vector3(f.side)*(sin(u*PI)*float(f.bend)+sin(u*TAU)*sin(u*PI)*float(f.sway))
func delivery_target146(origin: Vector3,lock: Vector3) -> Vector3:
 # Correct only near the chosen landing point, never seek enemies across the arena.
 var result := lock;var best := 2.4*2.4
 for enemy in battle.enemies:
  if not is_instance_valid(enemy) or enemy.dead or not enemy.is_visible_in_tree(): continue
  var centre: Vector3=enemy.hit_area.global_position
  var distance := lock.distance_squared_to(centre)
  if distance>=best: continue
  var query := PhysicsRayQueryParameters3D.create(origin,centre,1|2,[battle.hero.get_rid()])
  if not battle.get_world_3d().direct_space_state.intersect_ray(query).is_empty(): continue
  best=distance;result=centre
 return result
func send146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.) -> void:
 if packet.get("stream",false):
  battle.stream_generation110+=1
  bursts146.append({"packet":packet,"origin":origin,"target":target,"gain":gain,"age":0.,"tick":0.,"generation":battle.stream_generation110})
 else: battle.emit_packet146(packet,origin,target,gain)
 last_origin146=origin
func request146() -> bool:
 if writing146 or pages146.is_empty() or battle.buffs.level("homework")==0 or not battle.active114 or battle.combat_paused or battle.result_open or battle.hero.dash_left>0. or battle.hero.guarding109 or battle.hero.knocked_down or battle.player_hp<=0.: return false
 writing146=true;write_age146=0.;battle._cancel_charge();battle.fire_needs_release=true;return true
func cancel146() -> void:
 if writing146: writing146=false;write_age146=0.;cancelled146+=1
func can_replay146(_packet: Dictionary) -> bool: return true
func step146(delta: float) -> void:
 if not battle.active114 or battle.player_hp<=0.:
  if not flights146.is_empty() or not pages146.is_empty() or writing146 or not pending146.is_empty() or not bursts146.is_empty(): reset146()
  return
 if battle.combat_paused: return
 if writing146:
  if battle.hero.dash_left>0. or battle.hero.knocked_down or battle.hero.guarding109: cancel146()
  else:
   write_age146+=delta
   if write_age146>=.65:
    pending146.assign(pages146.duplicate(true));pages146.clear();writing146=false;write_age146=0.;replay_wait146=0.
 replay_wait146-=delta
 if not pending146.is_empty() and replay_wait146<=0. and can_replay146(pending146[0]):
  var packet: Dictionary=pending146.pop_front();var target: Vector3=battle.paper_aim146();var origin: Vector3=battle.projectile_origin()
  if packet.plane: launch146(packet,origin,target,.45,true)
  else: send146(packet,origin,target,.45)
  replayed146+=1;replay_wait146=.18
 for i in range(flights146.size()-1,-1,-1):
  var f: Dictionary=flights146[i];f.time+=delta;var t := minf(1.,f.time/f.duration)
  var at := flight_point146(f,t)
  if f.time>=f.duration:
   if not f.sent:
    f.sent=true;deliveries146+=1;send146(f.packet,f.arrival,delivery_target146(f.arrival,f.lock),f.gain)
    f.exit=(Vector3(f.arrival)-flight_point146(f,.98)).normalized()
    f.exit.y=maxf(float(f.exit.y),-.25);f.exit=Vector3(f.exit).normalized()
   var leave: float=f.time-f.duration;at=Vector3(f.arrival)+Vector3(f.exit)*leave*3.
   f.node.modulate.a=1.-smoothstep(.08,.38,leave)
   if leave>.38: f.node.queue_free();flights146.remove_at(i);continue
  var motion: Vector3=at-f.node.position
  f.node.position=at;f.node.basis=battle.camera.global_basis
  var screen_dir: Vector2=battle.camera.unproject_position(at+(motion.normalized() if motion.length_squared()>.00001 else Vector3(f.dir))*.2)-battle.camera.unproject_position(at)
  f.node.rotate_object_local(Vector3.FORWARD,screen_dir.angle());f.node.rotate_object_local(Vector3.FORWARD,sin(t*PI*2.)*float(f.bank))
 for i in range(bursts146.size()-1,-1,-1):
  var burst: Dictionary=bursts146[i];burst.age+=delta;burst.tick-=delta
  var pulses := 0
  while burst.tick<=0. and pulses<6:
   battle.emit_packet146(burst.packet,burst.origin,burst.target,burst.gain,burst.generation);burst.tick+=burst.packet.pulse_interval;pulses+=1
  if burst.age>=burst.packet.burst_time: bursts146.remove_at(i)
func _process(_delta: float) -> void:
 if not is_instance_valid(battle.hero): return
 var active: bool=battle.active114 and not battle.result_open
 hud146.visible=active and (battle.buffs.level("paper_plane")>0 or battle.buffs.level("homework")>0)
 var page_text := ""
 for page in pages146: page_text+="〔"+str(page.label)+"〕"
 hud146.text=("纸飞机 · 到点投递" if battle.buffs.level("paper_plane")>0 else "直接射击")+"\n笔记 %d/3  %s\n%s"%[pages146.size(),page_text,"翻阅笔记… %.0f%% · Shift中止，保留笔记"%(write_age146/.65*100.) if writing146 else ("Q 翻阅并运用笔记" if not pages146.is_empty() else "直接攻击会留下笔记")]
 hud146.position=Vector2(28,battle.get_viewport().get_visible_rect().size.y-118)
 book146.visible=active and battle.buffs.level("homework")>0 and (writing146 or not pages146.is_empty() or not pending146.is_empty())
 if book146.visible:
  update_book_pose146(_delta)
 art146.queue_redraw()
func update_book_pose146(_delta: float) -> void:
 book146.position=(battle.goose.global_position+Vector3(.32,.48,-.08)) if writing146 else battle.hero.global_position+Vector3(.62,.95,.12)
 book146.basis=battle.camera.global_basis;book146.rotate_object_local(Vector3.FORWARD,sin(battle.clock*(19. if writing146 else 2.))*(.07 if writing146 else .025))
func draw146() -> void:
 for f in flights146:
  if f.sent: continue
  var ground := Vector3(f.lock);ground.y=battle.floor_height(Vector2(ground.x,ground.z))+.05
  var p: Vector2=battle.camera.unproject_position(ground)
  art146.draw_arc(p,8.,0.,TAU,20,Color(.97,.91,.72,.36),1.5)
  var last: Vector2=battle.camera.unproject_position(f.start)
  for j in range(1,13):
   var t := float(j)/12.;var point := flight_point146(f,t)
   var screen: Vector2=battle.camera.unproject_position(point)
   if j%2==0: art146.draw_line(last,screen,Color(.9,.92,.85,.23),1.)
   last=screen
 if book146.visible:
  var base: Vector2=battle.camera.unproject_position(book146.position)
  for i in pages146.size():
   var offset := Vector2(-11+i*10,1.)
   if pages146[i].plane:
    art146.draw_colored_polygon(PackedVector2Array([base+offset+Vector2(-3,-3),base+offset+Vector2(5,0),base+offset+Vector2(-3,3),base+offset]),Color("756081"))
   else: art146.draw_circle(base+offset,2.,Color("756081"))
  if writing146:
   var phase := fmod(write_age146/.65*3.,1.)
   var edge := cos(phase*PI)*16.
   var lift := sin(phase*PI)*5.
   art146.draw_colored_polygon(PackedVector2Array([base+Vector2(0,-12),base+Vector2(edge,-12-lift),base+Vector2(edge,11-lift),base+Vector2(0,11)]),Color("fff2cc"))
   for row in 3:
    art146.draw_line(base+Vector2(0,-6+row*5),base+Vector2(edge*.85,-6+row*5-lift),Color("9cb9c7"),1.)
