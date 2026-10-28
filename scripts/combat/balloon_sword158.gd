extends "res://scripts/combat/balloon_sword154.gd"
var pad_texture158: Texture2D
var pad_anchor158 := Vector2.ZERO
var cut158 := .09
var contact158: Node2D
func body_shader158() -> Shader: return preload("res://scripts/combat/balloon_sword158.gdshader")
func art_paths154() -> Dictionary:
 return {"geometry":"res://assets/balloon_sword158/geometry.json","normal":"res://assets/balloon_sword155_candidates/A_straight.png"}
func shadow_script154() -> Script: return preload("res://scripts/combat/balloon_shadow158.gd")
func _ready() -> void:
 super._ready();name="A_BalloonSwordAndSurfaceGel158"
 var geometry: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(art_paths154().geometry))
 var region: Array=geometry.pad_region
 var image := preload("res://scripts/combat/imported_image172.gd").read("res://assets/balloon_sword156_adhesion/A_stuck_surface_v3.png").get_region(Rect2i(region[0],region[1],region[2],region[3]))
 image.generate_mipmaps();pad_texture158=ImageTexture.create_from_image(image)
 var pixel := 1.05/texture153.get_height();var anchor: Array=geometry.pad_anchor
 pad_anchor158=Vector2((float(anchor[0])-image.get_width()*.5)*pixel,(image.get_height()*.5-float(anchor[1]))*pixel)
 cut158=geometry.body_cut
 contact158=preload("res://scripts/combat/balloon_contact158.gd").new();contact158.battle=battle;battle.fx_layer.add_child(contact158)
func sprite153() -> Sprite3D:
 var node := super.sprite153();var ink := ink154(node)
 ink.shader=body_shader158()
 ink.set_shader_parameter("art153",texture153);ink.set_shader_parameter("tip154",tip154)
 ink.set_shader_parameter("clip_tip158",0.);ink.set_shader_parameter("fade154",1.)
 for param in ["bend154","squash154","collapse154"]: ink.set_shader_parameter(param,0.)
 return node
func attach153(enemy: Variant,tip: Vector3,direction: Vector3,gain := 1.,surface: Dictionary={}) -> void:
 super.attach153(enemy,tip,direction,gain,surface)
 var entry: Dictionary=resting153[-1];var pad := Sprite3D.new()
 pad.texture=pad_texture158;pad.pixel_size=1.05/texture153.get_height()
 pad.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 pad.alpha_cut=SpriteBase3D.ALPHA_CUT_DISABLED
 pad.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(pad);entry.pad158=pad
 ink154(entry.node).set_shader_parameter("clip_tip158",cut158)
 battle._add_actor_shadow(pad,pad)
 var collider: Variant=surface.get("collider")
 var key: int=enemy.get_instance_id() if is_instance_valid(enemy) else (collider.get_instance_id() if is_instance_valid(collider) else 0)
 contact158.pop158(anchor154(entry),direction,key,gain)
func remove153(index: int) -> void:
 var entry: Dictionary=resting153[index]
 if entry.has("pad158") and is_instance_valid(entry.pad158): entry.pad158.queue_free()
 super.remove153(index)
func reset153() -> void:
 super.reset153()
 if is_instance_valid(contact158): contact158.reset158()
func step153(delta: float) -> void:
 super.step153(delta)
 if is_instance_valid(contact158): contact158.step158(delta)
func _process(delta: float) -> void:
 super._process(delta)
 for entry in resting153:
  var pad: Sprite3D=entry.pad158
  var expansion: float=lerpf(.65,1.,smoothstep(0.,.07,entry.age))
  pad.basis=entry.node.basis.orthonormalized().scaled(Vector3(expansion*entry.gain,entry.gain,entry.gain))
  pad.position=anchor154(entry)-pad.basis*Vector3(pad_anchor158.x,pad_anchor158.y,0.)
  pad.modulate.a=1.-smoothstep(2.65,3.,entry.age)
func _exit_tree() -> void:
 if is_instance_valid(contact158):
  for voice in contact158.voices158: if is_instance_valid(voice): voice.queue_free()
  contact158.queue_free()
