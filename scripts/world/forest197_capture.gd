extends "res://scripts/world/forest194_capture.gd"
class Walker197:
 extends "res://scripts/combat/hero197.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
class Trial197:
 extends "res://scripts/world/woodland_world197.gd"
 func _hero_script() -> Script: return Walker197
func result_prefix192() -> String: return "forest197"
func ratio197() -> float:
 var v: Sprite3D=sample.hero.visual;var p: Vector3=v.global_position
 var origin: Vector2=sample.camera.unproject_position(p)
 return (sample.camera.unproject_position(p+v.global_basis.y)-origin).length()/(sample.camera.unproject_position(p+v.global_basis.x)-origin).length()
func run() -> void:
 root.size=Vector2i(1600,1000)
 sample=Trial197.new();sample.memory_save116="user://forest197_validation_tmp.cfg";root.add_child(sample)
 while not is_instance_valid(sample.lighting191): await physics_frame
 await settle(120)
 sample.hero.controls_enabled=false;sample.hero.set_physics_process(false);sample.hero.body_clock=0.;sample.hero.facing="down";sample.hero.moving=false
 sample._teleport15(Vector2(-4.7,-2.6));await hour(12.);sample.hero.render_pose()
 var v: Sprite3D=sample.hero.visual
 var body_transform: Transform3D=sample.hero.global_transform
 var shapes: Array=[]
 for collider in sample.hero.find_children("*","CollisionShape3D",true,false): shapes.append({"node":collider,"transform":collider.global_transform,"shape":collider.shape})
 var anchor: Vector3=v.global_position;var source: Texture2D=v.texture;var pixel_size: float=v.pixel_size
 metrics.camera_ratio=ratio197()
 verify(absf(metrics.camera_ratio-1.)<.002,"camera-facing plane preserves image-axis proportions")
 verify(v.global_basis.z.normalized().dot(sample.camera.global_basis.z.normalized())>.999,"visual plane aligns with actual camera while physical body stays upright")
 verify(not sample.hero.receiver192.normal_enabled,"camera-facing geometry does not double the old lighting-normal tilt")
 await picture("home_facing")
 sample.hero.set_camera_facing197(false);metrics.upright_ratio=ratio197();await picture("home_upright")
 verify(absf(metrics.upright_ratio-.910154442294115)<.002,"F1 baseline restores the 169 and 192 display ratio")
 verify(sample.hero.receiver192.normal_enabled,"upright comparison restores its dedicated lighting normal")
 verify(v.global_position.is_equal_approx(anchor) and v.texture==source and is_equal_approx(v.pixel_size,pixel_size),"switch preserves foot anchor, source texture and pixel scale")
 sample.hero.set_camera_facing197(true)
 var collisions_same: bool=sample.hero.global_transform.is_equal_approx(body_transform)
 for entry in shapes: collisions_same=collisions_same and entry.node.global_transform.is_equal_approx(entry.transform) and entry.node.shape==entry.shape
 verify(not shapes.is_empty() and collisions_same,"physical body and collision shapes remain unchanged across display switch")
 for facing in ["up","left","right","down"]:
  sample.hero.facing=facing;sample.hero.moving=true;sample.hero.phase=.2;sample.hero.render_pose()
  verify(sample.hero.receiver192.albedo_texture==(v.texture.atlas if v.texture is AtlasTexture else v.texture),"atlas sheet remains correctly bound for "+facing)
  verify(absf(v.basis.x.normalized().dot(sample.camera.global_basis.y.normalized()))>.001,"walking roll survives plane alignment for "+facing)
  await picture("walk_"+facing)
 sample.hero.moving=false;sample.hero.facing="down";sample.hero.dash_left=.1;sample.hero.dash_pose="down";sample.hero.render_pose()
 verify(v.global_basis.z.normalized().dot(sample.camera.global_basis.z.normalized())>.999,"dash keeps the same display plane")
 sample.hero._spawn_ghost()
 var ghost: Sprite3D=sample.hero.ghosts.back().node
 verify(ghost.global_basis.is_equal_approx(v.global_basis) and ghost.texture==v.texture,"dash afterimage copies aligned artwork and transform")
 await picture("dash");sample.hero.dash_left=0.;sample.hero.render_pose()
 for hour_value in [12.,22.]:
  sample._teleport15(Vector2(-58.,16.8));await hour(hour_value)
  var image := await picture("cottage_"+str(int(hour_value)))
  var white := white_fraction(image);metrics["white_"+str(int(hour_value))]=white
  verify(white<.06,"camera-facing white hair retains detail at cottage hour "+str(hour_value))
 sample._teleport15(Vector2(-4.7,-2.6));await hour(22.)
 var lit := hero_color(await picture("night_stage"))
 sample.lighting191.stage_enabled=false;await settle(160)
 var unlit := hero_color(await picture("night_no_stage"));metrics.stage_lit=str(lit);metrics.stage_unlit=str(unlit)
 verify(lit.r>unlit.r*1.1,"native stage still brightens camera-facing hero")
 verify(lit.r/maxf(lit.b,.001)>unlit.r/maxf(unlit.b,.001),"native stage retains amber rather than white response")
 sample.lighting191.stage_enabled=true
 var shadow_found := false
 for shadow in sample.actor_shadows:
  if is_instance_valid(shadow) and shadow.get("visual")==v:
   shadow_found=true
   verify(shadow.enabled and shadow.visual==v,"existing actor projection remains bound to aligned hero artwork")
 verify(shadow_found,"hero still owns its projected shadow")
 sample._teleport15(sample.meadow.landmarks.station+Vector2(0,5.));await hour(12.);await picture("station")
 sample._teleport15(Vector2(-52.,28.));await hour(12.);await picture("forest_day")
 sample.hero.set_physics_process(true);sample.hero.controls_enabled=true
 sample._teleport15(sample.forest188.PLAN.CENTER+Vector2(33.,-3.));await settle(30)
 var route: Array[Vector2]=[]
 for p in [Vector2(28.,-3.),Vector2(23.,3.),Vector2(18.,3.),Vector2(14.,7.),Vector2(10.,8.),Vector2(6.,6.5)]: route.append(sample.forest188.PLAN.CENTER+p)
 verify(await walk(sample,route),"camera-facing hero physically walks existing entrance steps and forest lane")
 sample.hero.command=Vector2.ZERO
 FileAccess.open("res://docs/forest197-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"metrics":metrics,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(sample.memory_save116));print("FOREST197_DONE ",failures);quit(0 if failures.is_empty() else 1)
