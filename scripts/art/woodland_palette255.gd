extends "res://scripts/art/woodland_palette190.gd"
## The same environment-only tint used by the hero chain, sampled at each actor.
## Hurt/dodge feedback is deliberately excluded from this sample.
func actor_tint255(at: Vector2) -> Color:
 var shelter=(1.-smoothstep(7.,13.,(at+Vector2(4.7,2.8)).length())) if profile==2 else 0.
 var tint=Color(lerpf(1.,.96,shelter),lerpf(1.,.95,shelter),lerpf(1.,.91,shelter),1.)
 if field_image!=null:
  var field=sample_field(at)
  var weight=field.a*_route_strength()*palette.actor_response
  tint*=Color.WHITE.lerp(Color(field.r*1.25,field.g*1.25,field.b*1.25),weight)
 var strength=fill_strength if fill_enabled else 0.
 tint*=Color(1.+strength*fill_gains.x,1.+strength*fill_gains.y,1.+strength*fill_gains.z)
 # Reproduce 190 exactly. The active 58 chain already omits 57's gain,
 # but 190 still divides it out at night; retain this for a fair comparison.
 var old_gain=Color(1.+stage_strength57*.20,1.+stage_strength57*.10,1.+stage_strength57*.015)
 return tint*Color(.72/old_gain.r,.72/old_gain.g,.72/old_gain.b,1.)
