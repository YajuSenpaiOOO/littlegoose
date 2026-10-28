extends Node
## Personal imaginary stage. Its overlay never changes the world's day/night clock.
const DURATION := 7.
const COOLDOWN := 20.
const RATE := 1.4
var battle: Node3D
var left161 := 0.
var cooldown161 := 0.
var age161 := 0.
var tail161 := 1.
var ghost_clock161 := 0.
var ghosts161: Array[Dictionary]=[]
var last_foot161 := Vector3.INF
var activations161 := 0
var art161: Node2D
var shade161: ColorRect
var label161: Label
var shader161: ShaderMaterial
var stage_follow162=preload("res://scripts/combat/float_follow162.gd").new()
var stars162: Array[RefCounted]=[]
var float_age162 := 0.
var foot162 := Vector3.ZERO
var body162 := Vector3.ZERO
func equipped161() -> bool: return battle.buffs.level("hero_moment")>0
func running161() -> bool: return left161>0. and equipped161() and battle.active114 and battle.player_hp>0.
func _ready() -> void:
 name="CardboardSunAndCrayonStars161"
 process_priority=90
 for i in 14: stars162.append(preload("res://scripts/combat/float_follow162.gd").new())
 var layer := CanvasLayer.new();layer.layer=18;add_child(layer)
 shade161=ColorRect.new();shade161.mouse_filter=Control.MOUSE_FILTER_IGNORE
 shader161=ShaderMaterial.new();shader161.shader=preload("res://scripts/combat/hero_stage161.gdshader");shade161.material=shader161;layer.add_child(shade161)
 art161=Node2D.new();art161.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;layer.add_child(art161);art161.draw.connect(draw161)
 label161=Label.new();label161.add_theme_font_size_override("font_size",19);label161.add_theme_color_override("font_color",Color("fff0b9"));label161.add_theme_color_override("font_outline_color",Color("49384b"));label161.add_theme_constant_override("outline_size",4);label161.mouse_filter=Control.MOUSE_FILTER_IGNORE;layer.add_child(label161)
func reset161() -> void:
 left161=0.;cooldown161=0.;age161=0.;tail161=1.;ghosts161.clear();last_foot161=Vector3.INF
 reset_float162()
 battle.buffs.moment_rate161=1.
func reset_float162() -> void:
 stage_follow162.reset();float_age162=0.
 for star in stars162: star.reset()
func request161() -> bool:
 if not equipped161() or not battle.active114 or battle.combat_paused or battle.result_open or battle.wave_state!="fighting" or battle.player_hp<=0. or battle.hero.knocked_down or battle.hero.story_knocked or battle.hero.dash_left>0. or left161>0. or cooldown161>0.: return false
 left161=DURATION;age161=0.;tail161=1.;ghost_clock161=0.;last_foot161=battle.hero.position;activations161+=1
 reset_float162()
 battle.buffs.moment_rate161=RATE
 battle.cooldown=minf(battle.cooldown,battle.attack_cooldown())
 battle.encounter_hud.respond("都看好了，这次我是主角！",Color("ffe6a3"))
 return true
func finish161() -> void:
 left161=0.;cooldown161=COOLDOWN;tail161=0.;battle.buffs.moment_rate161=1.
func step161(delta: float) -> void:
 if not equipped161() or not battle.active114 or battle.result_open or battle.player_hp<=0.: reset161();return
 if battle.combat_paused: return
 cooldown161=maxf(0.,cooldown161-delta);tail161+=delta
 for i in range(ghosts161.size()-1,-1,-1):
  ghosts161[i].age+=delta
  if ghosts161[i].age>.24: ghosts161.remove_at(i)
 if left161<=0.: return
 if battle.hero.knocked_down or battle.hero.story_knocked: finish161();return
 left161=maxf(0.,left161-delta);age161+=delta
 if left161<=0.: finish161();return
 ghost_clock161+=delta
 if ghost_clock161>=.075 and battle.hero.position.distance_squared_to(last_foot161)>.018:
  ghost_clock161=0.;last_foot161=battle.hero.position
  var v: Sprite3D=battle.hero.visual
  ghosts161.append({"at":v.global_position,"texture":v.texture,"offset":v.offset,"pixel":v.pixel_size,"scale":Vector2(v.scale.x,v.scale.y),"flip":v.flip_h,"age":0.})
  while ghosts161.size()>4: ghosts161.pop_front()
func strength161() -> float:
 return smoothstep(0.,.15,age161) if left161>0. else 1.-smoothstep(0.,.65,tail161)
func _process(_delta: float) -> void:
 update_float162(_delta)
 var size: Vector2=battle.get_viewport().get_visible_rect().size
 shade161.size=size;shade161.visible=(left161>0. or tail161<.65) and battle.active114
 var centre: Vector2=battle.camera.unproject_position(body162)
 shader161.set_shader_parameter("hero_uv",centre/size);shader161.set_shader_parameter("screen_size",size);shader161.set_shader_parameter("strength",strength161())
 label161.visible=equipped161() and battle.active114
 label161.position=Vector2(22.,size.y-222.)
 if left161>0.: label161.text="主角时刻！ %.1f秒\n伤害＋30%% · 射速＋40%%"%left161
 elif cooldown161>0.: label161.text="Q 主角时刻 · %.1f秒后就绪"%cooldown161
 else: label161.text="Q 主角时刻 · 准备登场！\n伤害＋30% · 射速＋40% · 持续7秒"
 art161.visible=shade161.visible;art161.queue_redraw()
func pixel161(p: Vector2) -> Vector2: return (p/2.).round()*2.
func entrance_strength161() -> float:
 return 1.-smoothstep(.25,.95,age161) if left161>0. else 0.
func cone_strength161() -> float: return 1.
func draw_stage_extras161() -> void: pass
func update_float162(delta: float) -> void:
 foot162=battle.hero.get_global_transform_interpolated().origin
 var dt := 0. if battle.combat_paused else delta
 if left161>0. or tail161<.65: float_age162+=dt
 body162=stage_follow162.advance(foot162+Vector3.UP*.8,dt,10.)
 var camera: Camera3D=battle.camera
 var screen := camera.unproject_position(foot162)
 var pixels := maxf(1.,camera.unproject_position(foot162+camera.global_basis.x).distance_to(screen))
 for i in stars162.size():
  var phase := float_age162*(.55+float(i%3)*.09)+float(i)*.79
  var a := float(i)*2.39996
  var radius := 83.+float((i*31)%92)
  var offset := Vector2(cos(a)*radius+sin(phase)*10.,sin(a)*radius*.62-35.+cos(phase*1.2)*8.)
  var target := foot162+Vector3.UP*.8+camera.global_basis.x*(offset.x/pixels)-camera.global_basis.y*(offset.y/pixels)
  stars162[i].advance(target,dt,7.+float(i%4))
func star161(at: Vector2,radius: float,color: Color,turn: float=0.) -> void:
 var points := PackedVector2Array()
 for i in 10:
  var a := turn-PI*.5+TAU*float(i)/10.
  points.append(at+pixel161(Vector2(cos(a),sin(a))*radius*(1. if i%2==0 else .42)))
 art161.draw_colored_polygon(points,color)
 points.append(points[0]);art161.draw_polyline(points,Color(.39,.28,.33,color.a),2.,false)
 # Off-centre crayon stroke keeps the star imperfect and handmade.
 art161.draw_line(at+pixel161(Vector2(-radius*.3,0.)),at+pixel161(Vector2(radius*.25,-radius*.25)),Color(1.,.98,.79,color.a*.7),2.,false)
func draw161() -> void:
 var strength := strength161()
 if strength<=0. or not battle.active114: return
 var camera: Camera3D=battle.camera
 var foot: Vector3=foot162
 if camera.is_position_behind(foot): return
 var screen := camera.unproject_position(foot)
 var pixels := camera.unproject_position(foot+camera.global_basis.x).distance_to(screen)
 var body := camera.unproject_position(body162)
 # A golden theatre light, rather than changing the real sun or sky.
 var cone := PackedVector2Array([body+Vector2(-190,-420),body+Vector2(-95,-420),screen+Vector2(100,20),screen+Vector2(-90,20)])
 art161.draw_colored_polygon(cone,Color(1.,.86,.48,.065*strength*cone_strength161()))
 for ghost in ghosts161:
  if camera.is_position_behind(ghost.at): continue
  if camera.unproject_position(ghost.at).distance_to(screen)<pixels*.5: continue
  var texture: Texture2D=ghost.texture
  if texture==null: continue
  var scale: Vector2=ghost.scale*float(ghost.pixel)*pixels
  var size: Vector2=texture.get_size()*scale
  var centre := camera.unproject_position(ghost.at)+Vector2(ghost.offset.x*scale.x,-ghost.offset.y*scale.y)
  var rect := Rect2(pixel161(centre-size*.5),size)
  if ghost.flip: rect.position.x+=rect.size.x;rect.size.x=-rect.size.x
  art161.draw_texture_rect(texture,rect,false,Color(1.,.80,.46,.20*(1.-float(ghost.age)/.24)*strength))
 # Floor star is projected on the actual ground, without implying a fixed safe area.
 var floor_star := PackedVector2Array()
 for i in 10:
  var a := TAU*float(i)/10.-PI*.5
  var r := (.85 if i%2==0 else .38)*(1.+.035*sin(age161*3.))
  floor_star.append(pixel161(camera.unproject_position(foot+Vector3(cos(a)*r,.035,sin(a)*r))))
 floor_star.append(floor_star[0]);art161.draw_polyline(floor_star,Color(1.,.85,.46,.55*strength),3.,false)
 # Jagged cut cardboard sunburst: crisp rays around the character, not over the face.
 var entrance := entrance_strength161()
 if entrance>0.:
  for i in 11:
   var a := PI+PI*float(i)/10.
   var direction := Vector2(cos(a),sin(a));var side := Vector2(-direction.y,direction.x)
   var reach := (110.+float((i*37)%49))*pixels/100.*(.72+.28*smoothstep(0.,.18,age161))
   var start := body+direction*65.*pixels/100.
   var end := body+direction*reach
   var poly := PackedVector2Array([pixel161(start-side*5.),pixel161(end-side*10.),pixel161(end+direction*9.+side*3.),pixel161(end+side*9.),pixel161(start+side*4.)])
   art161.draw_colored_polygon(poly,Color(.96,.72,.30,entrance*.72))
   poly.append(poly[0]);art161.draw_polyline(poly,Color(.44,.30,.32,entrance*.7),2.,false)
   art161.draw_line(pixel161(start),pixel161(end),Color(1.,.91,.61,entrance*.85),3.,false)
 # Bounded crayon stars drift; at exit they all fall like paper confetti.
 for i in 14:
  var phase := float_age162*(.55+float(i%3)*.09)+float(i)*.79
  var a := float(i)*2.39996
  var pos := camera.unproject_position(stars162[i].position)
  if left161<=0.: pos+=Vector2(sin(a)*tail161*25.,tail161*tail161*145.)
  star161(pos,(5.+float(i%3)*2.)*(.9+.1*sin(phase)),Color(1.,.87,.47,(.5+.2*sin(phase))*strength),sin(phase)*.15)
 # Two restrained muzzle accents; existing projectile art remains readable.
 if left161>0. and not battle.hero.guarding109 and battle.cooldown>battle.attack_cooldown()*.75:
  var muzzle := camera.unproject_position(battle.projectile_origin())
  star161(muzzle+Vector2(18.,-5.),7.,Color(1.,.95,.7,.65*strength),age161)
 draw_stage_extras161()
