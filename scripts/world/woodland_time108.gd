extends "res://scripts/world/woodland_time107.gd"
var depth_enabled108 := true
func apply_look() -> void:
 super.apply_look()
 if not effects_ready86: return
 var look: Dictionary=palette.sample(visual_hour)
 var g: Vector2=world.meadow.landmarks.grove
 var area := 1.-smoothstep(24.,37.,Vector2(world.hero.position.x,world.hero.position.z).distance_to(g))
 var strength := area if depth_enabled108 else 0.
 var noon := smoothstep(8.5,11.,visual_hour)*(1.-smoothstep(13.,16.,visual_hour))*strength
 var night := smoothstep(18.5,20.5,visual_hour)*strength
 var env: Environment=world.atmosphere41.environment
 env.ambient_light_energy=lerpf(env.ambient_light_energy,.28,noon)
 env.ambient_light_energy=lerpf(env.ambient_light_energy,.27,night)
 env.ambient_light_color=env.ambient_light_color.lerp(Color("8095bd"),night*.65)
 world.sun.light_energy=lerpf(world.sun.light_energy,1.,noon)
 # The inherited sun caches opacity; always derive this value from the palette.
 world.sun.shadow_opacity=lerpf(float(look.shadow_opacity56),.67,night)
 var focus: ShaderMaterial=world.atmosphere41.focus_material
 var original_contrast := lerpf(1.025,.96,1.-float(look.daylight))
 focus.set_shader_parameter("tone_contrast",lerpf(lerpf(original_contrast,1.07,noon),1.10,night))
 focus.set_shader_parameter("tone_saturation",lerpf(float(look.saturation),.96,noon))
 focus.set_shader_parameter("day_exposure55",lerpf(float(look.exposure),1.,noon))
 focus.set_shader_parameter("tone_shadows",Vector3(look.shadow).lerp(Vector3(.70,.82,1.10),night))
 focus.set_shader_parameter("tone_highlights",Vector3(look.highlight).lerp(Vector3(.97,.99,1.04),night))
 focus.set_shader_parameter("night_mix56",(1.-float(look.daylight))*(1.-night*.48))
 focus.set_shader_parameter("haze_strength57",lerpf(lerpf(.035,.085,1.-float(look.daylight)),.035,night) if haze_enabled57 else 0.)
 for shadow in world.actor_shadows:
  if is_instance_valid(shadow): shadow.opacity_scale=lerpf(float(look.shadow_opacity56)*lerpf(1.,.4,1.-float(look.daylight)),.40,night)
 world.porch49.apply_grade104()
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("107：","108：")+"\nCtrl+Alt+F9 昼夜明暗 · F10 夜灯投影"
func handle_input(event: InputEvent) -> bool:
 if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed:
  if event.physical_keycode==KEY_F9:
   depth_enabled108=not depth_enabled108;apply_look();return true
  if event.physical_keycode==KEY_F10 and is_instance_valid(world.lamps106):
   world.lamps106.shadows_enabled108=not world.lamps106.shadows_enabled108;world.lamps106.update106();return true
 return super.handle_input(event)
