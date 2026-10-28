extends Node3D
const BUILD := .45
const LIFE := 3.
const COOLDOWN := 10.
const END_WARNING := .6
const WIDTH := 3.6
const OPEN_HALF := Vector2(.60,.42)
var battle: Node3D
var visual160: Sprite3D
var hud160: Label
var guide160: Node2D
var ready160 := false
var build160 := 0.
var cooldown160 := 0.
var life160 := 0.
var age160 := 0.
var collapse160 := 1.
var anchor160 := Vector3.ZERO
var armed160 := true
var hit160 := 1.
var absorbed160 := 0.
var builds160 := 0
var hits160 := 0
var reason160 := ""
func _ready() -> void:
 name="PillowSafeNook160";process_priority=95
 var geometry: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/pillow_hut160/geometry.json"))
 var r: Array=geometry.region
 var image := preload("res://scripts/combat/imported_image172.gd").read("res://assets/pillow_hut160/fort.png").get_region(Rect2i(r[0],r[1],r[2],r[3]));image.generate_mipmaps()
 visual160=Sprite3D.new();visual160.texture=ImageTexture.create_from_image(image);visual160.pixel_size=WIDTH/image.get_width()
 visual160.offset.y=image.get_height()*.5
 visual160.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;visual160.shaded=false
 visual160.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;visual160.hide();add_child(visual160)
 battle._add_actor_shadow(visual160,visual160)
 var layer := CanvasLayer.new();layer.layer=20;add_child(layer)
 hud160=Label.new();hud160.add_theme_font_size_override("font_size",18);hud160.add_theme_color_override("font_color",Color("fff0cd"));hud160.add_theme_color_override("font_outline_color",Color("3e344b"));hud160.add_theme_constant_override("outline_size",4);hud160.mouse_filter=Control.MOUSE_FILTER_IGNORE;layer.add_child(hud160)
 guide160=Node2D.new();layer.add_child(guide160);guide160.draw.connect(draw160)
func enabled160() -> bool:
 return battle.active114 and battle.buffs.level("pillow_hut")>0 and battle.player_hp>0. and not battle.result_open
func reset160() -> void:
 ready160=false;build160=0.;cooldown160=0.;life160=0.;collapse160=1.;armed160=true;reason160=""
 if is_instance_valid(visual160): visual160.hide()
func opening_basis160() -> Vector2:
 return Vector2(battle.camera.global_basis.x.x,battle.camera.global_basis.x.z).normalized()
func inside160() -> bool:
 var right := opening_basis160()
 var depth := Vector2(-right.y,right.x)
 var offset := Vector2(battle.hero.position.x-anchor160.x,battle.hero.position.z-anchor160.z)
 var local := Vector2(offset.dot(right)/OPEN_HALF.x,offset.dot(depth)/OPEN_HALF.y)
 return local.length_squared()<=1. and absf(battle.hero.position.y-anchor160.y)<.5
func protects160() -> bool:
 return ready160 and life160>0. and enabled160() and inside160() and battle.hero.dash_left<=0. and not battle.hero.knocked_down and not battle.hero.story_knocked
func fold160(reason: String) -> void:
 if not ready160: return
 ready160=false;build160=0.;cooldown160=COOLDOWN;collapse160=0.;reason160=reason
 if reason=="时间到了": collapse160=1.
func absorb160(damage: float) -> float:
 if not protects160() or damage<=0.: return 0.
 absorbed160+=damage;hits160+=1
 if hit160>.08: hit160=0.
 return damage
func step160(delta: float) -> void:
 if not enabled160(): reset160();return
 if battle.combat_paused: return
 hit160+=delta;collapse160+=delta
 cooldown160=maxf(0.,cooldown160-delta)
 var hero: CharacterBody3D=battle.hero
 if not hero.guarding109: armed160=true
 if ready160:
  life160=maxf(0.,life160-delta);age160+=delta
  if hero.knocked_down or hero.story_knocked: fold160("暂时收起")
  elif life160<=0.: fold160("时间到了")
  return
 if cooldown160>0.: return
 var speed := Vector2(hero.velocity.x,hero.velocity.z).length()
 var can_build: bool=armed160 and hero.guarding109 and hero.controls_enabled and hero.dash_left<=0. and not hero.knocked_down and not hero.story_knocked and speed<.35
 if not can_build: build160=0.;return
 if build160<=0.: anchor160=hero.position
 if Vector2(hero.position.x-anchor160.x,hero.position.z-anchor160.z).length()>.18: build160=0.;return
 build160+=delta
 if build160>=BUILD:
  ready160=true;armed160=false;life160=LIFE;age160=0.;hit160=1.;build160=0.;builds160+=1
func _process(_delta: float) -> void:
 var enabled := enabled160()
 hud160.visible=enabled
 var size: Vector2=battle.get_viewport().get_visible_rect().size
 hud160.position=Vector2(size.x-392,size.y-132)
 if ready160:
  var state := "快塌啦，准备离开" if life160<=END_WARNING else ("窝内无敌" if protects160() else "窝外无保护，可返回")
  hud160.text="枕头小屋 · %s · %.1f秒\n松开右键可以攻击／Q笔记\n离开不会拆窝；倒计时不会刷新"%[state,life160]
 elif cooldown160>0.: hud160.text="枕头小屋 · %s\n%.1f秒后可重搭\n右键蹲防搭建 · 不占Q"%[reason160,cooldown160]
 elif build160>0.: hud160.text="枕头小屋 · 搭建 %.0f%%\n继续蹲防一小会儿…"%(build160/BUILD*100.)
 else: hud160.text="枕头小屋 · 存在3秒／冷却10秒\n右键蹲防0.45秒搭窝\n开口内无敌；可离开再返回"
 var visible_fort := enabled and (ready160 or build160>0. or collapse160<.28)
 visual160.visible=visible_fort
 if visible_fort:
  var progress: float=smoothstep(0.,.16,age160) if ready160 else (clampf(build160/BUILD,0.,1.) if build160>0. else 1.-smoothstep(0.,.28,collapse160))
  var bump := sin(minf(hit160/.22,1.)*TAU)*exp(-hit160*14.)*.10
  var ending := 1.-smoothstep(0.,END_WARNING,life160) if ready160 else 0.
  visual160.basis=battle.camera.global_basis
  var sway := sin(minf(hit160/.38,1.)*TAU*2.)*exp(-hit160*8.)
  visual160.rotate_object_local(Vector3.BACK,sway*.075)
  visual160.scale=Vector3(1.+bump+ending*.10,maxf(.08,progress-bump-ending*.38),1.)
  visual160.position=anchor160-battle.camera.global_basis.z*.20+battle.camera.global_basis.x*sway*.045
  visual160.modulate.a=progress*(smoothstep(0.,.12,life160) if ready160 else 1.)
 guide160.queue_redraw()
func draw160() -> void:
 if not enabled160() or (not ready160 and build160<=0.): return
 var points := PackedVector2Array()
 var right := opening_basis160()
 var depth := Vector2(-right.y,right.x)
 for i in 33:
  var a := TAU*float(i)/32.
  var offset := right*cos(a)*OPEN_HALF.x+depth*sin(a)*OPEN_HALF.y
  var at := anchor160+Vector3(offset.x,.04,offset.y)
  points.append(battle.camera.unproject_position(at))
 var color := Color(1.,.78,.43,.6) if ready160 and life160<=END_WARNING else Color(.83,.9,.75,.42)
 guide160.draw_polyline(points,color,1.5,true)
