extends "res://scripts/world/cottage_world430.gd"

const WORLD_PITCH := 25.
const WORLD_FOV := 42.
const WORLD_FOCUS_HEIGHT := .85
var world_distance:=15.
var walking_focus:=Vector3.ZERO
var walking_look:=Vector2.ZERO
var follow_ready:=false
var close_comparison:=false
var plant_materials: Array[ShaderMaterial]=[]
var trail_materials: Array[ShaderMaterial]=[]

func _ready() -> void:
 await super._ready()
 # The nested map has the same camera inheritance as the committed 349
 # at the yard. Its 405 overview camera is a separate authored shot.
 world_distance=landscape.camera_distance
 walking_focus=hero.global_position+Vector3.UP*WORLD_FOCUS_HEIGHT
 collect_plant_materials()
 follow_ready=true
 camera.fov=WORLD_FOV
 apply_camera()
 camera.reset_physics_interpolation()
 help367="431 · 大世界行走镜头\nWASD 行走 / 推门 · F3 进出 · F9 小屋特写对照 · F2 昼夜"
 DisplayServer.window_set_title("小白鹅 · 431 · 大世界行走镜头")
 refresh367()
 if "--capture431" in OS.get_cmdline_user_args():call_deferred("verify431")

func camera_pose(value: bool) -> Transform3D:
 if value or close_comparison or not follow_ready:return super.camera_pose(value)
 var basis:=Basis.from_euler(Vector3(deg_to_rad(-WORLD_PITCH),0,0))
 return Transform3D(basis,walking_focus+basis.z*world_distance)

func _process(delta: float) -> void:
 if follow_ready:
  if not inside:
   var movement:=Vector2(hero.velocity.x,hero.velocity.z)*.22
   walking_look=walking_look.lerp(movement,minf(1.,delta*4.)).limit_length(48./preload("res://scripts/combat/legacy_profile24.gd").PPM)
   var desired:=hero.get_global_transform_interpolated().origin+Vector3(walking_look.x,WORLD_FOCUS_HEIGHT,walking_look.y)
   walking_focus=walking_focus.lerp(desired,minf(1.,delta*7.))
  update_vegetation(delta)
 super._process(delta)
 if follow_ready and not inside and not crossing:
  follow_label363.text="小屋特写 · 对照" if close_comparison else "大世界 · 行走镜头"

func collect_plant_materials() -> void:
 for node in landscape.find_children("*","GeometryInstance3D",true,false):
  var ink:=node.material_override as ShaderMaterial
  if ink==null or ink.shader==null or ink in plant_materials:continue
  if ink==landscape.grass_material:continue
  # The porch lighting wraps plant shaders at runtime. The generated
  # shader keeps its uniforms but no longer has the original file path.
  var code:=ink.shader.code
  if not "uniform vec3 walker" in code:continue
  plant_materials.append(ink)
  if "uniform vec4 trail[" in code:trail_materials.append(ink)

func update_vegetation(delta: float) -> void:
 # Call only the map's authored grass update, with the actual walking actor.
 # The preserved legacy actor and the rest of the map loop stay parked.
 var parked: CharacterBody3D=landscape.hero
 landscape.hero=hero
 landscape.clock+=delta
 landscape._update_grass()
 landscape.hero=parked
 var walker:=hero.get_global_transform_interpolated().origin
 for ink in plant_materials:
  ink.set_shader_parameter("walker",walker)
  ink.set_shader_parameter("clock",landscape.clock)
 for ink in trail_materials:ink.set_shader_parameter("trail",landscape.trail)
 for plant in landscape.forest87.plants94:
  var visual: Sprite3D=plant.visual
  if not is_instance_valid(visual) or not visual.is_visible_in_tree():continue
  var offset:=visual.global_position-walker
  var away:=Vector2(offset.x,offset.z)
  var touch: float=(1.-smoothstep(.12,plant.radius,away.length()))*(1.-smoothstep(.55,1.15,absf(offset.y)))
  var direction:=away.normalized()
  var target:=Vector3(direction.x,-.25,direction.y)*touch*.25
  plant.push=Vector3(plant.push).lerp(target,1.-exp(-delta*(12. if touch>.01 else 5.)))
  visual.material_override.set_shader_parameter("push94",plant.push)

func _input(event: InputEvent) -> void:
 if follow_ready and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F9:
  close_comparison=not close_comparison
  apply_camera()
  camera.reset_physics_interpolation()
  get_viewport().set_input_as_handled()
  return
 super._input(event)

func verify431() -> void:
 await get_tree().create_timer(.55).timeout
 assert(is_equal_approx(world_distance,15.) and absf(camera.rotation_degrees.x+25.)<.05)
 assert(is_equal_approx(camera.fov,42.))
 assert(camera.global_position.distance_to(hero.global_position+Vector3.UP*.85+camera.basis.z*world_distance)<.10)
 assert(landscape.process_mode==Node.PROCESS_MODE_DISABLED and plant_materials.size()>3)
 await shot431("walk")
 close_comparison=true
 await shot431("close")
 close_comparison=false
 var start: Vector3=hero.position
 drive426(KEY_D,true)
 for i in 35:await get_tree().physics_frame
 drive426(KEY_D,false)
 await get_tree().process_frame
 var walker: Vector3=landscape.grass_material.get_shader_parameter("walker")
 assert(hero.position.x>start.x+.50 and walker.distance_to(hero.global_position)<.20)
 for mat in plant_materials:assert(Vector3(mat.get_shader_parameter("walker")).distance_to(hero.global_position)<.20)
 var recorded:=false
 for stamp in landscape.trail:
  if Vector2(stamp.x,stamp.y).distance_to(Vector2(walker.x,walker.z))<.65:recorded=true
 assert(recorded)
 await shot431("plant-walk")
 reset355()
 drive426(KEY_W,true)
 var end:=Time.get_ticks_msec()+5000
 while not inside and Time.get_ticks_msec()<end:await get_tree().physics_frame
 drive426(KEY_W,false)
 assert(inside and hero_steps==2)
 await get_tree().create_timer(1.05).timeout
 assert(absf(camera.rotation_degrees.x+12.)<.05)
 await shot431("inside")
 print("COTTAGE431_DONE distance=",world_distance," flower materials=",plant_materials.size())
 get_tree().quit()

func shot431(tag: String) -> void:
 await get_tree().process_frame
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://docs/cottage431-"+tag+".png")
