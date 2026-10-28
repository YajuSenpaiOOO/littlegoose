extends "res://scripts/art/forest_graybox177.gd"
var cottage_sprite: Sprite3D
var alpha_bounds := Rect2i()
func _ready() -> void:
 super._ready()
 # Replace only the cottage's placeholder visuals; retain its physical footprint.
 for child in get_children():
  if child is MeshInstance3D and child.position.x> -12. and child.position.x< -4. and child.position.z< -6.8 and child.position.z> -11.:
   child.hide();fading.erase(child)
  if child is Label3D and child.text.contains("蜘蛛姐姐"): child.text="蜘蛛姐姐的小屋 · 侧向贴图试摆";child.position.y=5.1
 var texture: Texture2D=preload("res://assets/cottage178/cottage_side.png")
 var image := texture.get_image();var low := Vector2i(image.get_width(),image.get_height());var high := Vector2i.ZERO
 # Use opaque house pixels for scale/feet, ignoring translucent generated glow.
 for y in image.get_height():
  for x in image.get_width():
   if image.get_pixel(x,y).a<.65: continue
   low.x=mini(low.x,x);low.y=mini(low.y,y);high.x=maxi(high.x,x);high.y=maxi(high.y,y)
 alpha_bounds=Rect2i(low,high-low+Vector2i.ONE)
 cottage_sprite=Sprite3D.new();cottage_sprite.texture=texture;cottage_sprite.pixel_size=6.7/float(alpha_bounds.size.x)
 cottage_sprite.position=Vector3(-8.,PLAN.BASE,-6.85);cottage_sprite.offset=Vector2(image.get_width()*.5-float(low.x+high.x)*.5,float(high.y)-image.get_height()*.5)
 cottage_sprite.shaded=false;cottage_sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;cottage_sprite.alpha_scissor_threshold=.65;cottage_sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;cottage_sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(cottage_sprite)
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(cottage_sprite) or not is_instance_valid(world.hero): return
 # The rendered side wall belongs to the drawing, not the collision footprint.
 # Fade the complete prototype card when passing behind it; later layers can
 # separately fade the roof/porch once the art direction has been approved.
 var p: Vector3=world.hero.position-position
 var hidden_by_house := p.z< -6.85 and p.z> -13. and absf(p.x+8.)<3.7
 cottage_sprite.transparency=lerpf(cottage_sprite.transparency,.8 if hidden_by_house and not world.overview else 0.,1.-exp(-delta*10.))
