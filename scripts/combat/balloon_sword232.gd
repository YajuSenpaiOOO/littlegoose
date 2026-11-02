extends "res://scripts/combat/balloon_sword226.gd"
## Physics shots/layers remain independent; four shared submissions draw the toys.
const CAP232 := 768
var bodies232: MultiMeshInstance3D
var pads232: MultiMeshInstance3D
var body_shadows232: MultiMeshInstance3D
var pad_shadows232: MultiMeshInstance3D
var field232 := -1
func batch232(mesh: Mesh,texture: Texture2D,pad: bool,projection: bool) -> MultiMeshInstance3D:
 var node=MultiMeshInstance3D.new();node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 node.multimesh=MultiMesh.new();node.multimesh.transform_format=MultiMesh.TRANSFORM_3D
 node.multimesh.use_colors=true;node.multimesh.use_custom_data=true;node.multimesh.mesh=mesh
 node.multimesh.instance_count=CAP232;node.multimesh.visible_instance_count=0
 var ink=ShaderMaterial.new();ink.shader=preload("res://scripts/combat/sword_shadow232.gdshader") if projection else preload("res://scripts/combat/sword_batch232.gdshader")
 ink.set_shader_parameter("art232",texture);ink.set_shader_parameter("tip232",pad_anchor158 if pad else tip154);ink.set_shader_parameter("pad232",pad)
 node.material_override=ink;node.custom_aabb=AABB(Vector3(-150,-40,-150),Vector3(350,100,350));add_child(node)
 return node
func _ready() -> void:
 super._ready();name="BatchedBalloonSwords232"
 var quad=PlaneMesh.new();quad.orientation=PlaneMesh.FACE_Z
 quad.size=Vector2(pad_texture158.get_width(),pad_texture158.get_height())*(1.05/texture153.get_height())
 # Match the old nine-point silhouette grid. The visible blade keeps its full
 # soft mesh; terrain projection does not need all of those deformation rows.
 var body_shadow=PlaneMesh.new();body_shadow.orientation=PlaneMesh.FACE_Z;body_shadow.size=mesh154.size
 body_shadow.subdivide_width=1;body_shadow.subdivide_depth=1
 var pad_shadow=PlaneMesh.new();pad_shadow.orientation=PlaneMesh.FACE_Z;pad_shadow.size=quad.size
 pad_shadow.subdivide_width=1;pad_shadow.subdivide_depth=1
 bodies232=batch232(mesh154,texture153,false,false);pads232=batch232(quad,pad_texture158,true,false)
 body_shadows232=batch232(body_shadow,texture153,false,true);pad_shadows232=batch232(pad_shadow,pad_texture158,true,true)
func attach153(enemy: Variant,tip: Vector3,direction: Vector3,gain := 1.,surface: Dictionary={}) -> void:
 var collider: Variant=surface.get("collider")
 var entry={"node":null,"enemy":weakref(enemy) if is_instance_valid(enemy) else null,"enemy_id":enemy.get_instance_id() if is_instance_valid(enemy) else 0,"offset":tip,"direction":direction.normalized(),"age":0.,"life":LIFETIME,"gain":gain,
 "anchor154":bind154(enemy,tip) if is_instance_valid(enemy) else Vector3.ZERO,"surface154":weakref(collider) if collider is Node3D else null,"surface_point154":collider.to_local(tip) if collider is Node3D else tip,"surface_dir154":collider.global_basis.inverse()*direction if collider is Node3D else direction,
 "bend154":.16*(-1. if serial153%2 else 1.),"bend_speed154":0.,"squash154":.24,"squash_speed154":0.,"last_tip154":tip}
 entry.depth232=is_instance_valid(enemy) and enemy.has_method("attachment_frame154")
 entry.last_tip154=anchor154(entry)
 serial153+=1;landed153+=1
 if is_instance_valid(enemy):
  var id: int=entry.enemy_id
  if not layers153.has(id):layers153[id]=[]
  var list: Array=layers153[id]
  if list.size()>=LIMIT:
   var old: Dictionary=list.pop_front();old.age=old.life
  list.append(entry);enemy.set_meta("locomotion_scale153",1.-SLOW*list.size())
 resting153.append(entry)
 while resting153.size()>RESIDUE_LIMIT:remove153(0)
 var key: int=enemy.get_instance_id() if is_instance_valid(enemy) else collider.get_instance_id() if is_instance_valid(collider) else 0
 contact158.pop158(anchor154(entry),direction,key,gain)
func basis232(tip: Vector3,direction: Vector3,gain: float) -> Transform3D:
 var screen: Vector2=battle.screen_direction(tip,direction)
 var axes=battle.camera.global_basis*Basis(Vector3.BACK,-screen.angle()-PI*.5)
 axes=axes.scaled(Vector3.ONE*gain)
 return Transform3D(axes,tip-axes*Vector3(tip154.x,tip154.y,0.))
func anchor154(entry: Dictionary) -> Vector3:
 var point=super.anchor154(entry)
 if not entry.get("depth232",false):return point
 var enemy: Variant=entry.enemy.get_ref()
 if not is_instance_valid(enemy) or not enemy.visual.material_override is ShaderMaterial:return point
 var ink: ShaderMaterial=enemy.visual.material_override
 var foot: Variant=ink.get_shader_parameter("foot199");var normal: Variant=ink.get_shader_parameter("plane_normal199")
 if not foot is Vector3 or not normal is Vector3:return point
 var camera: Vector3=battle.camera.global_position;var ray=point-camera
 var divisor=ray.dot(normal)
 if absf(divisor)<.00001:return point
 # Match the actor's foot-depth proxy, then place the adhesive just in front.
 return camera+ray*((Vector3(foot)-camera).dot(normal)/divisor)+Vector3(normal)*.025
func transform232(entry: Dictionary) -> Transform3D:
 var direction: Vector3=entry.direction;var surface: Variant=entry.surface154.get_ref() if entry.surface154!=null else null
 if is_instance_valid(surface):direction=surface.global_basis*Vector3(entry.surface_dir154)
 return basis232(anchor154(entry),direction,entry.gain)
func step153(delta: float) -> void:
 if not battle.active114 or battle.player_hp<=0.:reset153();return
 if battle.combat_paused:return
 contact158.step158(delta)
 for i in range(resting153.size()-1,-1,-1):
  var entry: Dictionary=resting153[i];entry.age+=delta
  var enemy: Variant=entry.enemy.get_ref() if entry.enemy!=null else null
  if entry.age>=entry.life or (entry.enemy!=null and (not is_instance_valid(enemy) or enemy.dead)):
   remove153(i);continue
  var tip=anchor154(entry);var change: Vector3=tip-entry.last_tip154;entry.last_tip154=tip
  var side=transform232(entry).basis.x.normalized()
  entry.bend_speed154=clampf(entry.bend_speed154-change.dot(side)*18.,-3.,3.)
  var remaining=minf(delta,.1)
  while remaining>0.:
   var dt=minf(remaining,1./120.);remaining-=dt
   entry.bend_speed154+=(-125.*entry.bend154-9.*entry.bend_speed154)*dt
   entry.bend154=clampf(entry.bend154+entry.bend_speed154*dt,-.24,.24)
   entry.squash_speed154+=(-190.*entry.squash154-11.*entry.squash_speed154)*dt
   entry.squash154=clampf(entry.squash154+entry.squash_speed154*dt,-.12,.3)
func reset153() -> void:
 for i in range(resting153.size()-1,-1,-1):remove153(i)
 layers153.clear();flying153.clear();flights154.clear()
 if is_instance_valid(contact158):contact158.reset158()
 for node in [bodies232,pads232,body_shadows232,pad_shadows232]:
  if is_instance_valid(node):node.multimesh.visible_instance_count=0
func submit232(node: MultiMeshInstance3D,index: int,pose: Transform3D,shape: Color,clip: float,proxy := false) -> void:
 node.multimesh.set_instance_transform(index,global_transform.affine_inverse()*pose)
 node.multimesh.set_instance_custom_data(index,shape);node.multimesh.set_instance_color(index,Color(clip,1. if proxy else 0.,0.,1.))
func _process(delta: float) -> void:
 if not is_instance_valid(battle.camera):return
 var seen={};var index=0;var pads=0
 for shot in battle.shots:
  if not shot.get("sword153",false) or index>=CAP232:continue
  var id: int=shot.serial153;seen[id]=true
  if not flights154.has(id):flights154[id]={"age":0.};flying153[id]=null
  var flight: Dictionary=flights154[id]
  if not battle.combat_paused:flight.age+=delta
  var tip: Vector3=shot.node.get_global_transform_interpolated().origin
  var pose=basis232(tip,shot.velocity,float(shot.get("sword_gain153",1.)))
  var shape=Color(sin(flight.age*11.+id)*.025,0.,0.,1.)
  submit232(bodies232,index,pose,shape,0.);submit232(body_shadows232,index,pose,shape,0.);index+=1
 for id in flights154.keys():
  if not seen.has(id):flights154.erase(id);flying153.erase(id)
 for entry in resting153:
  if index>=CAP232 or pads>=CAP232:break
  var pose=transform232(entry)
  var fade=1.-smoothstep(2.65,3.,entry.age)
  var shape=Color(entry.bend154,entry.squash154,smoothstep(2.35,3.,entry.age),fade)
  submit232(bodies232,index,pose,shape,cut158,entry.depth232);submit232(body_shadows232,index,pose,shape,cut158);index+=1
  var expansion=lerpf(.65,1.,smoothstep(0.,.07,entry.age))
  var axes=pose.basis.orthonormalized().scaled(Vector3(expansion*entry.gain,entry.gain,entry.gain))
  var pad_pose=Transform3D(axes,anchor154(entry)-axes*Vector3(pad_anchor158.x,pad_anchor158.y,0.))
  var pad_shape=Color(0.,0.,0.,fade)
  submit232(pads232,pads,pad_pose,pad_shape,0.,entry.depth232);submit232(pad_shadows232,pads,pad_pose,pad_shape,0.);pads+=1
 bodies232.multimesh.visible_instance_count=index;pads232.multimesh.visible_instance_count=pads
 body_shadows232.multimesh.visible_instance_count=index;pad_shadows232.multimesh.visible_instance_count=pads
 var shadows: bool=battle.silhouettes_enabled and battle.contact_enabled
 body_shadows232.visible=shadows;pad_shadows232.visible=shadows
 if field232!=battle.shadow_field113.revision:
  for node in [body_shadows232,pad_shadows232]:battle.shadow_field113.bind_shader(node.material_override)
  field232=battle.shadow_field113.revision
 var light=-battle.sun.global_basis.z.normalized()
 var look: Dictionary=battle.time55.palette.sample(battle.time55.visual_hour)
 body_shadows232.material_override.set_shader_parameter("opacity232",.30*lerpf(.18,.8,float(look.daylight)))
 pad_shadows232.material_override.set_shader_parameter("opacity232",.27)
 for node in [body_shadows232,pad_shadows232]:node.material_override.set_shader_parameter("light232",light)
