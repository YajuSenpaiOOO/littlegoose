extends Node2D
const Art=preload("res://scripts/combat/legacy/candy_bullet_art.gd")
var battle: Node3D
var had_shots105 := false
func _ready() -> void: texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;process_priority=110
func _process(delta: float) -> void:
 var active := false
 for shot in battle.shots:
  if not shot.has("art") or not is_instance_valid(shot.art) or not shot.art.get_meta("batched105",false): continue
  shot.art.age+=delta;active=true
 if active or had_shots105: queue_redraw()
 had_shots105=active
func _draw() -> void:
 Art._load_art()
 var entry: Dictionary=Art.art.pearl_core if Art.particle_trail_enabled else Art.art.pearl
 var texture: Texture2D=entry.textures[0];var anchor: Array=entry.anchor
 for shot in battle.shots:
  if not shot.has("art") or not is_instance_valid(shot.art) or not shot.art.get_meta("batched105",false): continue
  var at: Vector3=shot.node.get_global_transform_interpolated().origin
  if battle.camera.is_position_behind(at): continue
  var screen: Vector2=battle.camera.unproject_position(at)
  var pixels: float=(battle.camera.unproject_position(at+battle.camera.global_basis.x)-screen).length()/battle.Profile.PPM
  var facing: Vector2=battle.screen_direction(at,shot.velocity.normalized())
  var gain: float=float(entry.core_world)/float(entry.core_pixels)*shot.art.scale_gain*(1.+.035*sin(shot.art.age*15.))
  draw_set_transform(screen,facing.angle(),Vector2.ONE*pixels)
  draw_texture_rect(texture,Rect2(-Vector2(anchor[0],anchor[1])*gain,texture.get_size()*gain),false)
 draw_set_transform(Vector2.ZERO,0.,Vector2.ONE)
