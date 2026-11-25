extends Control

const INK=preload("res://scripts/art/workshop_diary_hand432.gdshader")
var hand: TextureRect
var shadow: TextureRect
var clock:=0.
var reach:=0.
var tap_amount:=0.
var tone:=Color.WHITE

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 var art:Texture2D=load("res://assets/workshop432/journal-pov-planted.png")
 shadow=make_sprite(art,true)
 hand=make_sprite(art,false)
 hide()

func make_sprite(art:Texture2D,is_shadow:bool) -> TextureRect:
 var sprite:=TextureRect.new()
 sprite.texture=art
 sprite.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 sprite.mouse_filter=Control.MOUSE_FILTER_IGNORE
 sprite.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 var ink:=ShaderMaterial.new()
 ink.shader=INK
 ink.set_shader_parameter("shadow_pass",is_shadow)
 sprite.material=ink
 add_child(sprite)
 return sprite

func reset() -> void:
 clock=0.
 reach=0.
 tap_amount=0.
 hide()

func update_pose(delta:float,paper:Rect2,scale_on_table:float,active:bool) -> void:
 visible=active
 if not active:return
 clock+=delta
 var beat:=fmod(clock,5.7)
 var lift:=exp(-pow((beat-1.95)/.090,2.))+exp(-pow((beat-2.24)/.090,2.))
 tap_amount=lift*(1.-reach)
 var viewport:=get_viewport_rect().size
 var art_size:=Vector2(viewport.x,viewport.x*2./3.)
 var origin:=Vector2(paper.end.x+26.*scale_on_table-art_size.x*.644,viewport.y-art_size.y*.965)
 hand.size=art_size
 hand.position=origin
 hand.modulate=tone
 shadow.size=hand.size
 shadow.position=origin+Vector2(2.5,5.5+tap_amount*2.1)*scale_on_table
 shadow.modulate=Color(.24,.15,.10,lerpf(.40,.24,maxf(reach,tap_amount)))
 hand.material.set_shader_parameter("tap",tap_amount)
 shadow.material.set_shader_parameter("tap",tap_amount)
 hand.material.set_shader_parameter("reach",reach)
 shadow.material.set_shader_parameter("reach",reach)
