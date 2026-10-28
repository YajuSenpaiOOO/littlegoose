extends "res://scripts/world/woodland_world202.gd"
const SPIDER203=preload("res://scripts/combat/spider203.gd")
var fluff203: Node3D
var ready203 := false
func _init() -> void:
 super._init();memory_save116="user://forest203_preview.cfg"
func _enemy_script() -> Script:
 return preload("res://scripts/combat/spider203.gd") if context202 else super._enemy_script()
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 203 · 毛絮受击 / 软软幽灵猫")
func _ready() -> void:
 await super._ready()
 fluff203=preload("res://scripts/combat/spider_fluff203.gd").new();fluff203.world=self;combat_effect_root159().add_child(fluff203)
 var old_contact: Node2D=swords153.contact158
 for voice in old_contact.voices158: voice.queue_free()
 old_contact.queue_free()
 var contact := preload("res://scripts/combat/spider_sword_contact203.gd").new();contact.battle=self;fx_layer.add_child(contact);swords153.contact158=contact
 for spec in [[forest188.kitten181,Vector2(.5,0.)],[forest188.pop_board194,Vector2(.5,1.)]]:
  var card: Sprite3D=spec[0]
  var old_bounds: Rect2i=forest188.opaque_bounds181(card.texture)
  var units: float=old_bounds.size.y*card.pixel_size
  card.texture=preload("res://assets/forest203/ghost_kitten.png")
  var bounds: Rect2i=forest188.opaque_bounds181(card.texture)
  card.pixel_size=units/bounds.size.y
  var foot: Vector2=Vector2(bounds.position)+Vector2(bounds.size)*spec[1]
  card.offset=Vector2(card.texture.get_width()*.5-foot.x,foot.y-card.texture.get_height()*.5)
  if card.material_override is StandardMaterial3D: card.material_override.albedo_texture=card.texture
 ready203=true
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("202 "): child.text=child.text.replace("202 林间蜘蛛试演 / 去除柱状树影","203 毛絮受击 / 软软幽灵猫")
func on_legacy_contact(actor: CharacterBody3D,at: Vector3,direction: Vector3,juice: bool) -> void:
 if not actor is SPIDER203:
  super.on_legacy_contact(actor,at,direction,juice);return
 feedback_count+=1
 if is_instance_valid(feedback): feedback.marker=.13
 if is_instance_valid(fluff203) and actor.fluff_gate203<=0.:
  fluff203.burst(at,direction,actor.dead);actor.fluff_gate203=.11
 if not cup_contact_active: notify_hit()
func _clear_combat_shots() -> void:
 super._clear_combat_shots()
 if is_instance_valid(fluff203): fluff203.clear203()
