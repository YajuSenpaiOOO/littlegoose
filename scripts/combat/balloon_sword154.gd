extends "res://scripts/combat/balloon_sword153.gd"
var mesh154: PlaneMesh
var proxy154: ShaderMaterial
var tip154 := Vector2.ZERO
var flights154 := {}
var shadow_cleanup154 := 0.
func art_paths154() -> Dictionary:
 return {"geometry":"res://assets/balloon_sword154/geometry.json","normal":"res://assets/balloon_sword154/sword.png"}
func shadow_script154() -> Script: return preload("res://scripts/combat/balloon_shadow154.gd")
func _ready() -> void:
 name="ElasticBalloonSwords154";process_priority=90
 var paths := art_paths154()
 var geometry: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(paths.geometry))
 var rect: Array=geometry.region
 var image := preload("res://scripts/combat/imported_image172.gd").read(paths.normal).get_region(Rect2i(rect[0],rect[1],rect[2],rect[3]))
 image.generate_mipmaps();texture153=ImageTexture.create_from_image(image)
 var pixel := 1.05/image.get_height()
 tip154=Vector2((float(geometry.tip[0])-image.get_width()*.5)*pixel,.525)
 mesh154=PlaneMesh.new();mesh154.orientation=PlaneMesh.FACE_Z
 mesh154.size=Vector2(image.get_width()*pixel,1.05);mesh154.subdivide_width=4;mesh154.subdivide_depth=28
 proxy154=ShaderMaterial.new();proxy154.shader=preload("res://scripts/combat/balloon_proxy154.gdshader")
func sprite153() -> Sprite3D:
 var node := Sprite3D.new();node.texture=texture153;node.pixel_size=1.05/texture153.get_height();node.material_override=proxy154
 node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(node)
 var body := MeshInstance3D.new();body.mesh=mesh154;body.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/combat/balloon_sword154.gdshader")
 ink.set_shader_parameter("art153",texture153);ink.set_shader_parameter("tip154",tip154)
 for param in ["bend154","squash154","collapse154"]: ink.set_shader_parameter(param,0.)
 ink.set_shader_parameter("fade154",1.)
 body.extra_cull_margin=.35
 body.material_override=ink;node.add_child(body);node.set_meta("mesh154",body)
 var shadow: MeshInstance3D=shadow_script154().new()
 shadow.battle=battle;shadow.visual=node;shadow.enabled=battle.silhouettes_enabled;node.add_child(shadow)
 battle.actor_shadows.append(shadow)
 return node
func ink154(node: Sprite3D) -> ShaderMaterial:
 var body: MeshInstance3D=node.get_meta("mesh154");return body.material_override
func orient153(node: Sprite3D,tip: Vector3,direction: Vector3,length_gain := 1.) -> void:
 var screen: Vector2=battle.screen_direction(tip,direction)
 node.basis=battle.camera.global_basis*Basis(Vector3.BACK,-screen.angle()-PI*.5)
 node.scale=Vector3.ONE*length_gain
 node.position=tip-node.basis*Vector3(tip154.x,tip154.y,0.)
func frame154(enemy: Node3D) -> Dictionary:
 if enemy.has_method("attachment_frame154"):return enemy.attachment_frame154()
 var art: Sprite3D=enemy.visual
 var selected: Dictionary=enemy.poses.idle
 for key in enemy.textures:
  if enemy.textures[key]==art.texture: selected=enemy.poses[key];break
 var right := Vector3(battle.camera.global_basis.x.x,0.,battle.camera.global_basis.x.z).normalized()
 var basis := Basis(right,Vector3.UP,right.cross(Vector3.UP))*Basis(Vector3.BACK,art.rotation.z)
 var width: float=float(selected.visible_width)/24.*enemy.body_scale110*art.scale.x
 var height: float=float(selected.visible_height)/24.*enemy.body_scale110*art.scale.y
 return {"origin":art.global_position,"basis":basis,"width":width,"height":height}
func bind154(enemy: Node3D,tip: Vector3) -> Vector3:
 var frame := frame154(enemy);var local: Vector3=frame.basis.inverse()*(tip-Vector3(frame.origin))
 return Vector3(clampf(local.x/maxf(.01,frame.width),-.44,.44),clampf(local.y/maxf(.01,frame.height),.12,.92),clampf(local.z,-.3,.3))
func anchor154(entry: Dictionary) -> Vector3:
 var enemy: Variant=entry.enemy.get_ref() if entry.enemy!=null else null
 if is_instance_valid(enemy):
  var frame := frame154(enemy);var uv: Vector3=entry.anchor154
  var point := Vector3(uv.x*frame.width,uv.y*frame.height,uv.z)
  if enemy.get("tuft")!=null: point.x+=float(enemy.tuft)*frame.width*smoothstep(.62,.94,uv.y)
  return Vector3(frame.origin)+frame.basis*point
 var surface: Variant=entry.surface154.get_ref() if entry.surface154!=null else null
 return surface.to_global(entry.surface_point154) if is_instance_valid(surface) else Vector3(entry.offset)
func attach153(enemy: Variant,tip: Vector3,direction: Vector3,gain := 1.,surface: Dictionary={}) -> void:
 super.attach153(enemy,tip,direction,gain,surface)
 var entry: Dictionary=resting153[-1]
 entry.anchor154=bind154(enemy,tip) if is_instance_valid(enemy) else Vector3.ZERO
 var collider: Variant=surface.get("collider")
 entry.surface154=weakref(collider) if collider is Node3D else null
 entry.surface_point154=collider.to_local(tip) if collider is Node3D else tip
 entry.surface_dir154=collider.global_basis.inverse()*direction if collider is Node3D else direction
 entry.offset=tip;entry.bend154=.16*(-1. if serial153%2 else 1.);entry.bend_speed154=0.
 entry.squash154=.24;entry.squash_speed154=0.;entry.last_tip154=anchor154(entry)
func step153(delta: float) -> void:
 super.step153(delta)
 shadow_cleanup154+=delta
 if shadow_cleanup154>=1.: shadow_cleanup154=0.;battle._prune_actor_shadows()
 if not battle.active114 or battle.combat_paused: return
 for entry in resting153:
  var tip := anchor154(entry);var change: Vector3=tip-entry.last_tip154;entry.last_tip154=tip
  var screen_side: Vector3=entry.node.basis.x.normalized()
  entry.bend_speed154=clampf(entry.bend_speed154-change.dot(screen_side)*18.,-3.,3.)
  # Stable damped springs; substeps retain their feel during a slow frame.
  var remaining := minf(delta,.1)
  while remaining>0.:
   var dt := minf(remaining,1./120.);remaining-=dt
   entry.bend_speed154+=(-125.*entry.bend154-9.*entry.bend_speed154)*dt
   entry.bend154=clampf(entry.bend154+entry.bend_speed154*dt,-.24,.24)
   entry.squash_speed154+=(-190.*entry.squash154-11.*entry.squash_speed154)*dt
   entry.squash154=clampf(entry.squash154+entry.squash_speed154*dt,-.12,.3)
func reset153() -> void:
 super.reset153();flights154.clear()
func _process(delta: float) -> void:
 if not is_instance_valid(battle.camera): return
 var seen := {}
 for shot in battle.shots:
  if not shot.get("sword153",false): continue
  var id: int=shot.serial153;seen[id]=true
  if not flying153.has(id): flying153[id]=sprite153();flights154[id]={"age":0.}
  var flight: Dictionary=flights154[id]
  if not battle.combat_paused: flight.age+=delta
  var node: Sprite3D=flying153[id]
  orient153(node,shot.node.get_global_transform_interpolated().origin,shot.velocity,float(shot.get("sword_gain153",1.)))
  var ink := ink154(node);ink.set_shader_parameter("bend154",sin(flight.age*11.+id)*.025)
 for id in flying153.keys():
  if not seen.has(id): release_sprite153(flying153[id]);flying153.erase(id);flights154.erase(id)
 for entry in resting153:
  var direction: Vector3=entry.direction
  var surface: Variant=entry.surface154.get_ref() if entry.surface154!=null else null
  if is_instance_valid(surface): direction=surface.global_basis*Vector3(entry.surface_dir154)
  orient153(entry.node,anchor154(entry),direction,entry.gain)
  var ink := ink154(entry.node)
  ink.set_shader_parameter("bend154",entry.bend154);ink.set_shader_parameter("squash154",entry.squash154)
  ink.set_shader_parameter("collapse154",smoothstep(2.35,3.,entry.age));ink.set_shader_parameter("fade154",1.-smoothstep(2.65,3.,entry.age))
