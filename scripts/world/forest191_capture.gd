extends "res://scripts/world/forest180_probe.gd"
var sample: Node3D
var metrics := {}
func picture(tag: String) -> Image:
 await process_frame;await RenderingServer.frame_post_draw
 var result := root.get_texture().get_image()
 result.save_png("res://docs/captures/world_restart/forest191_"+tag+".png")
 return result
func hero_color(image: Image) -> Color:
 var p: Vector2=sample.camera.unproject_position(sample.hero.global_position+Vector3.UP*.95)
 var result := Color(0,0,0,0)
 for y in range(-10,11):
  for x in range(-10,11): result+=image.get_pixel(clampi(int(p.x)+x,0,image.get_width()-1),clampi(int(p.y)+y,0,image.get_height()-1))
 return result/441.
func hour(value: float) -> void:
 sample.time55.preview_at(value);sample.time55.visual_hour=value;sample.time55.apply_look();await settle(80)
func run() -> void:
 root.size=Vector2i(1600,1000)
 sample=preload("res://scripts/world/woodland_world191.gd").new();sample.memory_save116="user://forest191_validation_tmp.cfg";root.add_child(sample)
 while not is_instance_valid(sample.lighting191): await physics_frame
 sample.hero.controls_enabled=false;sample.hero.facing="down";sample.hero.render_pose()
 var rig: Node=sample.lighting191
 verify(rig.lamps.size()>=12,"native post, hanging and house spill lamps registered")
 verify(rig.casters.size()>=10,"compact native shadow blockers registered")
 rig.stage_enabled=false
 sample._teleport15(Vector2(-58.,16.8));await hour(22.)
 var on := hero_color(await picture("window_night"))
 rig.enabled=false;await settle(100)
 var off := hero_color(await picture("window_no_lights"))
 metrics.window_on=str(on);metrics.window_off=str(off)
 verify(on.r>off.r*1.15,"window lamps alone actually brighten rendered hero pixels")
 verify(on.r/maxf(on.b,.001)>off.r/maxf(off.b,.001)+.05,"rendered hero becomes warmer in native light")
 rig.enabled=true;rig.stage_enabled=true;sample._teleport15(Vector2(-37.8,29.4));await hour(22.);await picture("post_night")
 sample._teleport15(Vector2(-52.,28.));await hour(12.);await picture("forest_day_stage")
 verify(rig.stage_level>.60,"forest stage available during exterior daytime")
 sample._teleport15(Vector2(-4.7,-2.6));await hour(12.);await settle(100);await picture("home_day")
 metrics.home_day_stage=rig.stage_level;metrics.home_day_region=rig.regional_level;metrics.home_day_hour=sample.time55.visual_hour
 verify(rig.stage_level<.02,"outside daytime stage fades out")
 await hour(22.);await picture("home_night_stage")
 verify(rig.stage_level>.9 and sample.time55.accents57.stage_light.visible,"outside night stage restored")
 var shadows := 0
 for light in rig.lamps:
  if light.shadow_enabled: shadows+=1
 verify(shadows==3,"only three nearest local lamps cast native shadows")
 verify(not sample.porch49.warm_light.visible,"body-following fill remains disabled")
 FileAccess.open("res://docs/forest191-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"metrics":metrics,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(sample.memory_save116));print("FOREST191_DONE ",failures);quit(0 if failures.is_empty() else 1)
