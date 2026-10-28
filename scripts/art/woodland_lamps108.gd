extends "res://scripts/art/woodland_lamps107.gd"
var shadows_enabled108 := true
var active_shadows108 := 0
func update106() -> void:
 super.update106();active_shadows108=0
 var best := -1;var distance := 10.*10.
 if shadows_enabled108 and enabled106 and world.time55.visual_hour>18.5:
  for i in lamps106.size():
   var lamp: Dictionary=lamps106[i]
   var gap: float=world.hero.position.distance_squared_to(lamp.root.global_position)
   if lamp.light.visible and gap<distance: best=i;distance=gap
 for i in lamps106.size():
  var light: OmniLight3D=lamps106[i].light
  light.shadow_enabled=i==best
  light.shadow_bias=.035;light.shadow_normal_bias=.20;light.shadow_opacity=.85
  if light.shadow_enabled: active_shadows108+=1
