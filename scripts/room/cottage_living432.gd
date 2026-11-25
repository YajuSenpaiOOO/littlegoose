extends Node3D

const HOUSE = preload("res://scripts/room/cottage_facade432.gd")
const DECOR = preload("res://scripts/room/cottage_decor432.gd")
const COMPANION = preload("res://scripts/combat/cottage_companion.gd")
const MESH_BATCHES = preload("res://scripts/room/cottage_mesh_batches.gd")
const FURNITURE_CONTACTS = preload("res://scripts/room/cottage_furniture_contacts.gd")
const LOCAL_SHADOWS = preload("res://scripts/room/cottage_local_shadows.gd")
const ROOM = preload("res://scripts/room/room_shell432.gd")
const THOUGHT = preload("res://scripts/room/interaction_cloud432.gd")
const CUT_SHADERS = [
 preload("res://scripts/room/cutaway423.gdshader"),
 preload("res://scripts/room/interior_roof423.gdshader"),
 preload("res://scripts/room/plaster429.gdshader"),
 preload("res://scripts/room/glass427.gdshader"),
]

var world: Node3D
var companion: COMPANION
var hero: CharacterBody3D:
 get:return world.hero
var sleeping362: bool:
 get:return sleeping
var leaving371: bool:
 get:return world.active114
var house: HOUSE
var room: ROOM
var decor: DECOR
var camera: Camera3D
var environment: Environment
var prompt: Label
var inside := false
var cut := 0.
var camera_move: Tween
var follow := Vector3.ZERO
var sleeping := false
var companion_sleeping := false
var sleep_view := 0.
var sleep_roof_layers: Dictionary={}
var thought: THOUGHT
var bed_return := Vector3.ZERO
var stair_lifts := 0
var approach_body: StaticBody3D
var outdoor_sun_casters := 0
var window_light: SpotLight3D
var front_daylight: Array[SpotLight3D]=[]
var shades: Array[StandardMaterial3D]=[]
var flower_shade: StandardMaterial3D
var last_lighting_hour := -100.
var furniture_contacts: FURNITURE_CONTACTS
var furniture_contacts_enabled:=false
var local_shadows: LOCAL_SHADOWS
var pendant: SpotLight3D
var miniature_card: ColorRect
var miniature_ink: ShaderMaterial
var lamp_warmth:=0.
var room_lamps: Array[Dictionary]=[]

func _ready() -> void:
 process_priority=world.process_priority+1
 process_physics_priority=-1
 environment=world.atmosphere41.environment
 outdoor_sun_casters=world.sun.shadow_caster_mask
 house=HOUSE.new()
 add_child(house)
 var materials: Dictionary={}
 for node in house.find_children("*","GeometryInstance3D",true,false):
  materials[node.material_override]=true
 for entry in house.front_cut+house.roof_cut:
  materials[entry.ink]=true
 for material in materials:
  if material is ShaderMaterial and material.shader in CUT_SHADERS:
   material.set_shader_parameter("house_origin",global_position)
 camera=Camera3D.new()
 camera.fov=42.
 camera.far=world.camera.far
 add_child(camera)
 camera.global_transform=world.camera.global_transform
 room=ROOM.new()
 room.world=self
 add_child(room)
 decor=DECOR.new()
 decor.name="CottageDecor432"
 add_child(decor)
 decor.build(self)
 furniture_contacts=FURNITURE_CONTACTS.new()
 furniture_contacts.name="SoftFurnitureContacts"
 furniture_contacts.build(room)
 room.add_child(furniture_contacts)
 apply_furniture_contacts()
 configure_room_light()
 batch_house_meshes()
 build_approach()
 add_companion()
 local_shadows=LOCAL_SHADOWS.new()
 add_child(local_shadows)
 local_shadows.build(self)
 local_shadows.configure(pendant,.82)
 for light in front_daylight:local_shadows.configure(light,.88)
 build_miniature_view()
 var canvas:=CanvasLayer.new()
 canvas.layer=28
 add_child(canvas)
 prompt=Label.new()
 canvas.add_child(prompt)
 prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 prompt.offset_left=-250
 prompt.offset_right=250
 prompt.offset_top=-72
 prompt.offset_bottom=-35
 prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 prompt.add_theme_font_size_override("font_size",22)
 prompt.add_theme_constant_override("outline_size",6)
 prompt.mouse_filter=Control.MOUSE_FILTER_IGNORE
 thought=THOUGHT.new()
 canvas.add_child(thought)

func configure_room_light() -> void:
 # Keep the fixtures warm through the outdoor day/night postprocess.
 for label in ["bedside","desk"]:
  var furniture: Node3D=room.item356(label).root
  for mesh in furniture.find_children("*","MeshInstance3D",true,false):
   if mesh.name=="FlowerBudShade432":
    flower_shade=warm_shade(mesh)
    flower_shade.emission_operator=BaseMaterial3D.EMISSION_OP_MULTIPLY
    flower_shade.emission_texture=flower_shade.albedo_texture
   elif mesh.name=="WovenLampShade":
    shades.append(warm_shade(mesh))
  for lamp in furniture.find_children("*","OmniLight3D",true,false):
   lamp.shadow_enabled=false
   lamp.omni_range=3.4
   lamp.light_color=Color("ffae62")
   room_lamps.append({"node":lamp,"day":.48,"night":2.15,"range":lamp.omni_range})
 var fixture:=Node3D.new()
 fixture.name="HallPendant432"
 fixture.position=Vector3(0,3.24,-1.55)
 room.add_child(fixture)
 room.cylinder(fixture,Vector3(0,.25,0),.024,.52,"62452f")
 room.cylinder(fixture,Vector3(0,.02,0),.28,.16,"765134",.18)
 var shade:=room.cylinder(fixture,Vector3(0,-.10,0),.245,.16,"e7be7d",.19)
 shades.append(warm_shade(shade))
 pendant=SpotLight3D.new()
 pendant.position=Vector3(0,-.26,0)
 pendant.light_color=Color("ffae67")
 pendant.spot_range=6.0
 pendant.spot_angle=60.
 pendant.spot_attenuation=1.2
 pendant.spot_angle_attenuation=1.05
 fixture.add_child(pendant)
 pendant.look_at(to_global(Vector3(.18,.06,.10)),Vector3.UP)
 room_lamps.append({"node":pendant,"day":1.35,"night":2.55,"range":pendant.spot_range})
 room_lamps.append({"node":decor.egg_glow,"day":.04,"night":1.35,"range":decor.egg_glow.omni_range})
 window_light=SpotLight3D.new()
 window_light.name="DaylightThroughRearWindow"
 window_light.position=Vector3(0,2.12,-3.48)
 window_light.light_color=Color("ffe4b8")
 window_light.spot_range=6.2
 window_light.spot_angle=37.
 window_light.spot_attenuation=1.55
 window_light.light_energy=0.
 room.add_child(window_light)
 window_light.look_at(window_light.global_position+Vector3(0,-.55,1),Vector3.UP)
 for side in [-1.,1.]:
  var spill:=SpotLight3D.new()
  spill.name="FrontWindowSun432"
  spill.position=Vector3(side*4.58,2.15,2.7)
  spill.light_color=Color("ffe5b4")
  spill.spot_range=4.2
  spill.spot_angle=29.
  spill.spot_attenuation=1.55
  spill.light_energy=0.
  room.add_child(spill)
  front_daylight.append(spill)

 var positions:=PackedVector4Array()
 for lamp in room_lamps:
  var p: Vector3=lamp.node.global_position
  positions.append(Vector4(p.x,p.y,p.z,lamp.range))
 var focus: ShaderMaterial=world.atmosphere41.focus_material
 focus.set_shader_parameter("cottage_origin",global_position)
 focus.set_shader_parameter("cottage_lamps",positions)

func warm_shade(mesh: MeshInstance3D) -> StandardMaterial3D:
 var glow:=mesh.material_override.duplicate() as StandardMaterial3D
 glow.emission_enabled=true
 glow.emission=Color("ffb16b")
 mesh.material_override=glow
 return glow

func update_room_light() -> void:
 var time: Node=world.time55
 var hour: float=time.visual_hour
 if absf(hour-last_lighting_hour)>.025:
  last_lighting_hour=hour
  var daylight: float=float(time.palette.sample(hour).daylight)
  lamp_warmth=1.-daylight
  if is_instance_valid(world.life432) and is_instance_valid(world.life432.bath_shed):
   world.life432.bath_shed.update_lamp(daylight)
  if is_instance_valid(world.workshop_shed432):
   world.workshop_shed432.update_lamp(daylight)
  for lamp in room_lamps:
   lamp.node.light_energy=lerpf(lamp.night,lamp.day,daylight)
  for shade in shades:
   shade.emission_energy_multiplier=lerpf(1.15,.22,daylight)
  if flower_shade!=null:
   flower_shade.emission_energy_multiplier=lerpf(.62,.075,daylight)
  decor.egg_shell.emission_energy_multiplier=lerpf(.76,.035,daylight)
  var ray: Vector3=-world.sun.global_basis.z
  window_light.light_energy=.54*daylight
  var reaches_front:=smoothstep(.10,.48,-ray.z)*smoothstep(.12,.65,-ray.y)
  for i in front_daylight.size():
   var spill:=front_daylight[i]
   var weight:=smoothstep(-.4,.4,ray.x*(1. if i==0 else -1.))
   spill.set_meta("incident_energy",1.8*daylight*reaches_front*weight)
   if reaches_front>.001:
    var aperture:=to_global(Vector3((-1. if i==0 else 1.)*4.58,1.94,2.13))
    spill.global_position=aperture-ray*.92
    spill.look_at(aperture,Vector3.UP)
 var local_strength:=smoothstep(.30,.84,cut) if not furniture_contacts_enabled else 0.
 local_shadows.apply(local_strength>.005)
 pendant.shadow_enabled=local_shadows.active
 pendant.shadow_opacity=local_strength*.82
 var window_strength:=smoothstep(.35,.84,cut)
 for spill in front_daylight:
  spill.light_energy=window_strength*float(spill.get_meta("incident_energy",0.))
  spill.shadow_enabled=local_shadows.active and spill.light_energy>.025
  spill.shadow_opacity=local_strength*.88
 var open_view:=smoothstep(.23,.80,cut)
 # Empty the global pass after its fade without switching the directional
 # light's shadow shader variant on every threshold crossing.
 var sun_opacity:=maxf(0.,time.last_opacity57)*(1.-open_view)
 if not is_equal_approx(world.sun.shadow_opacity,sun_opacity):world.sun.shadow_opacity=sun_opacity
 var sun_casters:=outdoor_sun_casters if open_view<.999 else 0
 if world.sun.shadow_caster_mask!=sun_casters:world.sun.shadow_caster_mask=sun_casters
 var focus: ShaderMaterial=world.atmosphere41.focus_material
 var room_view:=smoothstep(.38,.95,cut)
 var focus_card: MeshInstance3D=world.atmosphere41.focus_card
 var bath_view:bool=world.bath_focus_blend432>.001
 var shed=world.workshop_shed432
 var workshop_view:bool=is_instance_valid(shed) and shed.lens.current
 var lens:Camera3D=camera if camera.current else world.camera
 if bath_view:lens=world.life432.bath_shed.lens
 elif workshop_view:lens=shed.lens
 if focus_card.get_parent()!=lens:
  focus_card.reparent(lens,false)
 var atmosphere: Node=world.atmosphere41
 var forest_grade: bool=world.forest_mood188.enabled and world.forest_mood188.amount>.005
 focus_card.visible=bath_view or workshop_view or room_view>.001 or (atmosphere.enabled and (forest_grade or (not world.smooth_view432 and (atmosphere.focus_enabled or atmosphere.stage_level>0))))
 focus.set_shader_parameter("workshop_focus_blend",shed.focus_blend if workshop_view else 0.)
 if workshop_view:
  focus.set_shader_parameter("workshop_focus_far",shed.focus_far)
 if bath_view or workshop_view:
  var lamp:Vector3=shed.tabletop_fill.global_position if workshop_view else world.life432.bath_shed.bath_lamp_fill.global_position
  focus.set_shader_parameter("yard_lamp_center",lamp)
 focus.set_shader_parameter("yard_lamp_warmth",lamp_warmth if (bath_view or workshop_view) else 0.)
 var face:float=world.life432.bath_shed.peek_amount if bath_view else 0.
 focus.set_shader_parameter("bath_portrait_protection",face*.82)
 focus.set_shader_parameter("cottage_blend",room_view)
 update_miniature_view(room_view)
 focus.set_shader_parameter("cottage_lamp_warmth",lamp_warmth)

func build_miniature_view() -> void:
 var layer:=CanvasLayer.new()
 layer.layer=-1
 add_child(layer)
 miniature_card=ColorRect.new()
 miniature_card.mouse_filter=Control.MOUSE_FILTER_IGNORE
 miniature_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 miniature_ink=ShaderMaterial.new()
 miniature_ink.shader=preload("res://scripts/room/cottage_miniature.gdshader")
 miniature_card.material=miniature_ink
 layer.add_child(miniature_card)
 miniature_card.hide()

func update_miniature_view(amount: float) -> void:
 amount*=1.-smoothstep(.10,.52,sleep_view)
 miniature_card.visible=amount>.001 and world.miniature_view432
 if not miniature_card.visible:return
 miniature_ink.set_shader_parameter("strength",amount)
 miniature_ink.set_shader_parameter("roof_peak",lens_point(Vector3(0,6.60,3.03)))
 miniature_ink.set_shader_parameter("left_eave",lens_point(Vector3(-3.60,3.31,3.03)))
 miniature_ink.set_shader_parameter("right_eave",lens_point(Vector3(3.60,3.31,3.03)))
 miniature_ink.set_shader_parameter("doorstep",lens_point(Vector3(0,.015,3.43)).y)
 var upper:=lens_point(Vector3(-.58,2.48,-3.78))
 var lower:=lens_point(Vector3(.58,1.38,-3.78))
 miniature_ink.set_shader_parameter("rear_view",Vector4(upper.x,upper.y,lower.x,lower.y))

func lens_point(at: Vector3) -> Vector2:
 return camera.unproject_position(to_global(at))/get_viewport().get_visible_rect().size

func batch_house_meshes() -> void:
 var batcher:=MESH_BATCHES.new()
 var excluded: Dictionary={}
 for entry in house.roof_cut+house.front_cut:
  excluded[entry.node]=true
 for pane in house.front_glass:
  excluded[pane]=true
 for trough in house.painted_troughs:
  excluded[trough]=true
 var static_meshes: Array=[]
 for part in [house.shell,house.roof,house.terrace,room.timbers]:
  static_meshes.append_array(part.find_children("*","MeshInstance3D",true,false))
 var saved:=batcher.merge(static_meshes,[],excluded,house.pivot)
 # Cut groups keep their existing materials and transition, with one entry
 # per merged material. Painted facade entries share their cut uniforms.
 saved+=batcher.merge([],house.roof_cut,{},house.pivot)
 saved+=batcher.merge([],house.front_cut,{},house.pivot)
 print("COTTAGE432_BATCHES removed_draw_nodes=",saved)

func add_companion() -> void:
 companion=COMPANION.new()
 companion.host=self
 companion.collision_layer=1<<21
 companion.collision_mask=1|2|16
 var at:=to_global(Vector3(1.58,0,5.8))
 companion.position=to_local(Vector3(at.x,world.floor_height(Vector2(at.x,at.z))+.05,at.z))
 add_child(companion)
 var sprite:=Sprite3D.new()
 sprite.texture=room.source356("res://assets/black_goose_human_v2/idle_front.png")
 sprite.pixel_size=1.44/1281.
 sprite.offset=Vector2(-7.,654.)
 sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 var ink=preload("res://scripts/combat/hero192.gd").make_receiver192()
 ink.albedo_texture=sprite.texture
 sprite.material_override=ink
 sprite.shaded=true
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 companion.add_child(sprite)
 companion.visual=sprite
 var hit:=CollisionShape3D.new()
 var capsule:=CapsuleShape3D.new()
 capsule.radius=.19
 capsule.height=.70
 hit.shape=capsule
 hit.position.y=.35
 companion.add_child(hit)
 companion.add_collision_exception_with(hero)
 world._add_actor_shadow(companion,sprite)
 companion.visible=false
 companion.set_physics_process(false)
 companion.setup373()

func sync_companion() -> void:
 if is_instance_valid(world.life432) and is_instance_valid(world.life432.bath_scene) and world.life432.bath_scene.active:return
 var on_foot: bool=inside and not world.active114
 var flyer: Node3D=world.goose
 if companion_sleeping and on_foot:
  flyer.hide()
  return
 if companion.visible!=on_foot:
  if on_foot:
   var feet:=to_local(flyer.global_position)
   var floor:=local_floor(Vector2(feet.x,feet.z))
   if not is_finite(floor) or feet.z>2.94:
    feet=Vector3(clampf(feet.x,-.42,.42),0,2.86)
   else:feet.y=floor
   companion.position=feet+Vector3.UP*.025
   companion.resume373()
   companion.reset_physics_interpolation()
  elif not world.active114:
   flyer.global_position=companion.global_position+Vector3.UP*.09
   flyer.velocity385=Vector3.UP*1.25
   flyer.reset_physics_interpolation()
  companion.visible=on_foot
  companion.set_physics_process(on_foot)
  companion.velocity=Vector3.ZERO
 flyer.visible=not on_foot

func toggle_companion_follow() -> bool:
 if not companion.visible or not companion.ready373:return false
 if companion.mode373=="follow":companion.hold373()
 else:companion.resume373()
 return true

func build_approach() -> void:
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 6:
  var a:=lerpf(4.32,5.34,i/6.)
  var b:=lerpf(4.32,5.34,(i+1)/6.)
  house.cap_quad(surface,approach_point(-1.18,a),approach_point(1.18,a),approach_point(1.18,b),approach_point(-1.18,b))
 surface.generate_normals()
 var approach:=house.mesh_at(self,surface.commit(),Vector3.ZERO,house.stone)
 approach.create_trimesh_collision()
 approach_body=approach.get_child(0)
 approach_body.get_child(0).shape.backface_collision=true
 approach.hide()
 for pad in [HOUSE.HALL,HOUSE.LEFT,HOUSE.RIGHT]:
  var center: Vector2=pad.get_center()
  house.block(self,Vector3(center.x,-.28,center.y),Vector3(pad.size.x,.52,pad.size.y),house.stone)

func approach_point(x: float,z: float) -> Vector3:
 var pos:=to_global(Vector3(x,0,z))
 var level: float=world.open_ground432(Vector2(pos.x,pos.z))-global_position.y
 return Vector3(x,lerpf(-.22,level+.015,smoothstep(4.32,5.34,z)),z)

func local_floor(point: Vector2) -> float:
 if absf(point.x)<house.STEP_HALF_WIDTH and point.y>=3.2 and point.y<=4.36:
  return house.stair_top(point.y)
 for pad in [HOUSE.HALL,HOUSE.LEFT,HOUSE.RIGHT]:
  if pad.has_point(point):return 0.
 return -INF

func hero_point() -> Vector2:
 var p:=to_local(world.hero.global_position)
 return Vector2(p.x,p.z)

func _physics_process(delta: float) -> void:
 if world.warming_room432:return
 if not sleeping and world.hero.controls_enabled and not world.active114:
  if house.try_step(world.hero,delta,world.hero.movement_input()):stair_lifts+=1
 if companion.visible and companion.ready373 and not companion.route373.is_empty():
  var target: Vector2=companion.route373[0]
  var feet:=companion.global_position
  var heading: Vector2=(target-Vector2(feet.x,feet.z)).normalized()
  house.try_step(companion,delta,heading)

func _process(delta: float) -> void:
 if world.warming_room432:return
 var point:=hero_point()
 var mouth:=absf(point.x)<1.12
 var offset:=point.y-house.THRESHOLD
 var face:=1 if offset>=0. else -1
 if mouth and absf(offset)<.68 and world.hero.velocity.z*face<-.10:
  if house.swing_side==0 or absf(offset)>.28:house.swing(face)
 elif not mouth or absf(offset)>1.83:
  var goose_at:=to_local(companion.global_position)
  var goose_offset:=goose_at.z-house.THRESHOLD
  if companion.visible and absf(goose_at.x)<1.10 and absf(goose_offset)<.78:
   if house.swing_side==0 and absf(companion.velocity.z)>.10:house.swing(1 if goose_offset>0. else -1)
  else:house.swing(0)
 if not inside and mouth and point.y<3.04 and point.y>2.10 and not world.active114:
  switch_room(true)
 elif inside and (point.y>3.55 or local_floor(point)==-INF or world.active114):
  if sleeping:set_sleep(false,false)
  switch_room(false)
 sync_companion()
 update_room_light()
 update_camera_pose(delta,point)
 var item:=nearby_item(point)
 var copy: String=item.get("thought","")
 if item.get("id")=="desk":copy="E · 记下今天"
 elif item.get("id")=="bed":copy="E · 在床上歇一会儿"
 var can_think: bool=not copy.is_empty() and not sleeping and cut>.8 and not world.combat_paused
 var thought_anchor:=Vector2.ZERO
 if can_think:
  var anchor: Vector3=item.root.to_global(item.get("thought_anchor",Vector3(0,1.35,0)))
  can_think=not camera.is_position_behind(anchor)
  thought_anchor=camera.unproject_position(anchor)
 elif not inside and not world.combat_paused and world.can_open_memory116():
  var shed=world.workshop_shed432
  var journal: bool=shed.at_journal(world.hero.global_position)
  var anchor: Vector3=shed.to_global(Vector3(-.63 if journal else .28,1.82,-.38))
  var yard_camera: Camera3D=get_viewport().get_camera_3d()
  can_think=not yard_camera.is_position_behind(anchor)
  thought_anchor=yard_camera.unproject_position(anchor)
  if journal:
   copy="制作完成" if shed.props.finished else "E · 翻开小鹅日记"
  else:
   copy="E · 打开曲奇铁盒，\n把记忆碎片拼在一起。"
 thought.present(delta,copy if can_think else "",thought_anchor)
 if sleeping:
  prompt.text="E · 起床"
 elif not item.is_empty():
  prompt.text=str(item.title) if copy.is_empty() else ""
 else:
  prompt.text="WASD · 推门进屋" if not inside and mouth and offset>0. and offset<2.5 and not world.active114 else ""

func update_camera_pose(delta: float,point: Vector2) -> void:
 sleep_view=move_toward(sleep_view,float(sleeping),delta/(1.05 if sleeping else .85))
 update_sleep_roof((inside or cut>0.) and sleep_view>.30)
 var aim:=Vector3(clampf(point.x*.15,-.75,.75),0,clampf((point.y-.4)*.09,-.31,.30)) if inside and not sleeping else Vector3.ZERO
 follow=follow.lerp(aim,1.-exp(-delta*5.5))
 var native: Camera3D=world.camera
 if inside or cut>0.:
  var size:=get_viewport().get_visible_rect().size
  var distance:=10.50*maxf(1.,1.68*size.y/maxf(size.x,1.))
  var basis:=Basis.from_euler(Vector3(deg_to_rad(-12.),0,0))
  var pose:=Transform3D(basis,to_global(Vector3(0,1.22,-1.58)+follow+basis.z*distance))
  camera.global_transform=native.global_transform.interpolate_with(pose,cut)
  camera.fov=lerpf(native.fov,42.,cut)
  camera.v_offset=lerpf(native.v_offset,0.,cut)
  if sleep_view>0.:
   var angle:=deg_to_rad(36.)
   var orbit:=Vector3(0,sin(angle),cos(angle))
   var bed: Node3D=room.item356("bed").root
   var target:=bed.to_global(Vector3(0,.78,-.12))
   var radius:=3.65*maxf(1.,1.40*size.y/maxf(size.x,1.))
   var bed_view:=Transform3D(Basis.from_euler(Vector3(-angle,0,0)),target+orbit*radius)
   var approach:=smoothstep(0.,1.,sleep_view)
   camera.global_transform=camera.global_transform.interpolate_with(bed_view,approach)
   camera.fov=lerpf(camera.fov,54.,approach)
 else:
  camera.global_transform=native.global_transform

func update_sleep_roof(clear_roof: bool) -> void:
 if clear_roof==not sleep_roof_layers.is_empty():return
 # The indoor lights retain their roof casters while this lens omits the roof lining.
 camera.set_cull_mask_value(11,not clear_roof)
 if clear_roof:
  for mesh in house.joinery.find_children("*","GeometryInstance3D",true,false):
   sleep_roof_layers[mesh]=mesh.layers
   mesh.layers=LOCAL_SHADOWS.ROOM_LAYER
 else:
  for mesh in sleep_roof_layers:
   mesh.layers=sleep_roof_layers[mesh]
  sleep_roof_layers.clear()

func warm_rendering() -> void:
 camera.make_current()
 var saved_companion:=companion.position
 var time: Node=world.time55
 var saved_hour: float=time.visual_hour
 var saved_processing:=time.is_processing()
 time.set_process(false)
 time.visual_hour=11.
 time.apply_look()
 companion.position=Vector3(.65,.025,1.1)
 companion.show()
 for amount in [.16,.38,.54,.75,1.]:
  update_cut(amount)
  update_camera_pose(0.,hero_point())
  update_room_light()
  await get_tree().process_frame
 time.visual_hour=22.
 time.apply_look()
 update_room_light()
 await get_tree().process_frame
 time.visual_hour=saved_hour
 time.apply_look()
 time.set_process(saved_processing)
 companion.hide()
 companion.position=saved_companion
 update_cut(0.)
 world.camera.make_current()
 update_room_light()
 await get_tree().process_frame

func switch_room(value: bool) -> void:
 inside=value
 if is_instance_valid(camera_move):camera_move.kill()
 if value and not camera.current:
  camera.global_transform=world.camera.global_transform
  camera.fov=world.camera.fov
  camera.v_offset=world.camera.v_offset
  camera.make_current()
  camera.reset_physics_interpolation()
 var target:=float(value)
 camera_move=create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
 camera_move.tween_method(update_cut,cut,target,maxf(.02,.95*absf(cut-target)))
 if not value:camera_move.tween_callback(world.camera.make_current)

func update_cut(value: float) -> void:
 cut=value
 house.set_cut(value)
 apply_furniture_contacts()


func apply_furniture_contacts() -> void:
 furniture_contacts.visible=furniture_contacts_enabled and cut>.12
 room.contact362.hide()
 for old in room.foot_contacts363:old.hide()

func nearby_item(point: Vector2) -> Dictionary:
 var best: Dictionary={}
 if not inside:return best
 var distance:=1.0
 for item in room.footprints:
  if not item.root.is_visible_in_tree():continue
  var gap:=point.distance_to(item.approach)
  if gap<distance:
   distance=gap
   best=item
 return best

func interact() -> bool:
 if not inside or world.active114 or world.combat_paused:return false
 if sleeping:
  set_sleep(false)
  return true
 var item:=nearby_item(hero_point())
 if item.get("id")=="sand_lamp":
  decor.light_sand_lamp()
  return true
 match item.get("id"):
  "desk":world.life432.save_at_desk()
  "bed":world.life432.open_bed()
  _:return false
 return true

func set_sleep(value: bool,restore_position:=true) -> void:
 var actor: CharacterBody3D=world.hero
 sleeping=value
 if value:bed_return=actor.global_position
 actor.visible=not value
 actor.set_physics_process(not value)
 actor.set_process(not value)
 actor.velocity=Vector3.ZERO
 actor.locomotion=Vector2.ZERO
 actor.combat_impulse=Vector2.ZERO
 if not value and restore_position:
  actor.global_position=bed_return
  actor.reset_physics_interpolation()
 room.use_layers362=true
 room.set_art356(true)
 room.set_mode362(int(value))
 room.set_occupied368(value)
 if value and companion.visible and companion.mode373=="follow":
  companion_sleeping=true
  companion.hide()
  companion.process_mode=Node.PROCESS_MODE_DISABLED
 elif not value and companion_sleeping:
  companion_sleeping=false
  companion.process_mode=Node.PROCESS_MODE_INHERIT
  companion.show()
  companion.reset_physics_interpolation()
 room.set_companion_sleep(companion_sleeping)
 apply_furniture_contacts()
