extends "res://scripts/world/forest191_capture.gd"
func world_script192() -> Script: return preload("res://scripts/world/woodland_world192.gd")
func result_prefix192() -> String: return "forest192"
func extra_checks192() -> void: pass
func picture(tag: String) -> Image:
 await process_frame;await RenderingServer.frame_post_draw
 var result := root.get_texture().get_image();result.save_png("res://docs/captures/world_restart/"+result_prefix192()+"_"+tag+".png");return result
func white_fraction(image: Image) -> float:
 var centre: Vector2=sample.camera.unproject_position(sample.hero.global_position+Vector3.UP*1.25)
 var hot := 0
 for y in range(-18,19):
  for x in range(-22,23):
   var c := image.get_pixel(clampi(roundi(centre.x)+x,0,image.get_width()-1),clampi(roundi(centre.y)+y,0,image.get_height()-1))
   if maxf(c.r,maxf(c.g,c.b))>.99: hot+=1
 return float(hot)/(37.*45.)
func run() -> void:
 root.size=Vector2i(1600,1000)
 sample=world_script192().new();sample.memory_save116="user://"+result_prefix192()+"_validation_tmp.cfg";root.add_child(sample)
 while not is_instance_valid(sample.lighting191): await physics_frame
 sample.hero.controls_enabled=false;sample.hero.set_physics_process(false);sample.hero.facing="down";sample.hero.body_clock=0.;sample.hero.render_pose()
 sample._teleport15(Vector2(-4.7,-2.6));await hour(12.);await settle(100)
 var v: Sprite3D=sample.hero.visual;var p: Vector3=v.global_position;var origin: Vector2=sample.camera.unproject_position(p)
 var ratio: float=(sample.camera.unproject_position(p+v.global_basis.y)-origin).length()/(sample.camera.unproject_position(p+v.global_basis.x)-origin).length()
 metrics.projection_ratio=ratio
 verify(absf(ratio-.910154442294115)<.001 and absf(v.rotation.x)<.00001,"169 projected proportions restored without geometry tilt")
 verify(v.material_override is StandardMaterial3D and v.material_override.normal_enabled,"standard native material adjusts lighting normal only")
 await picture("home_day")
 sample._teleport15(Vector2(-58.,16.8));await hour(12.)
 var image := await picture("cottage_noon");metrics.noon_white=white_fraction(image)
 verify(metrics.noon_white<.06,"noon window plus stage keeps white hair below clipping limit")
 await hour(22.);image=await picture("cottage_night");metrics.night_white=white_fraction(image)
 verify(metrics.night_white<.06,"night window plus stage keeps white hair below clipping limit")
 sample.lighting191.stage_enabled=false;await settle(160)
 var on := hero_color(await picture("local_only"))
 sample.lighting191.enabled=false;await settle(160)
 var off := hero_color(await picture("lights_off"));metrics.local_on=str(on);metrics.local_off=str(off)
 verify(on.r>off.r*1.1 and on.r/maxf(on.b,.001)>off.r/maxf(off.b,.001),"local native light warms and brightens upright hero")
 sample.lighting191.enabled=true;sample.lighting191.stage_enabled=true
 for facing in ["up","left","right"]:
  sample.hero.facing=facing;sample.hero.moving=true;sample.hero.phase=.35;sample.hero.render_pose();await picture("walk_"+facing)
  verify(v.material_override.albedo_texture==(v.texture.atlas if v.texture is AtlasTexture else v.texture),"atlas binding preserved for "+facing)
 sample.hero.facing="down";sample.hero.moving=false;sample.hero.dash_left=.1;sample.hero.dash_pose="down";sample.hero.render_pose();await picture("dash")
 verify(absf(v.rotation.x)<.00001,"dash preserves original geometry angle")
 sample.hero.dash_left=0.;sample.hero.render_pose()
 sample._teleport15(Vector2(-52.,28.));await hour(12.);await picture("forest_day")
 sample._teleport15(Vector2(-4.7,-2.6));await hour(22.)
 var stage_on := hero_color(await picture("home_night"))
 sample.lighting191.stage_enabled=false;await settle(180)
 var stage_off := hero_color(await picture("home_no_stage"))
 metrics.stage_on=str(stage_on);metrics.stage_off=str(stage_off)
 verify(stage_on.r>stage_off.r*1.1,"native stage actually brightens upright hero in exterior night")
 verify(stage_on.r/maxf(stage_on.b,.001)>stage_off.r/maxf(stage_off.b,.001),"native stage gives rendered hero an amber response")
 sample.lighting191.stage_enabled=true;await settle(180)
 var spot: SpotLight3D=sample.time55.accents57.stage_light
 verify(spot.light_color.r>spot.light_color.b*1.3 and spot.shadow_enabled,"amber stage retains real native shadow reception")
 await extra_checks192()
 FileAccess.open("res://docs/"+result_prefix192()+"-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"metrics":metrics,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(sample.memory_save116));print("FOREST192_DONE ",failures);quit(0 if failures.is_empty() else 1)
