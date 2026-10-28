extends Node3D
## Authored broken ribbons, not a uniform ring. Three GPU batches, no plant nodes.
var world: Node3D
var batches107: Array[MultiMeshInstance3D]=[]
var grass_count107 := 0
var fern_count107 := 0
var update_wait107 := 0.
var grove107: Vector2
const GROUPS107=[Vector4(-11.6,3.4,2.6,1.2),Vector4(-10.5,8.5,2.8,1.3),Vector4(-5.4,11.8,2.5,1.2),Vector4(1.7,10.9,2.5,1.4),Vector4(8.7,8.0,2.1,1.1),Vector4(11.3,3.5,2.7,1.4),Vector4(13.,-2.5,2.3,1.0),Vector4(7.0,-8.2,2.5,1.4),Vector4(.2,-8.9,3.1,1.3),Vector4(-4.0,-7.9,2.3,1.2),Vector4(-3.1,-2.6,1.6,.75),Vector4(3.1,-3.9,1.5,.8)]
func supported107(at: Vector2) -> bool:
 var p := at-grove107
 if world.PARK99.path_distance99(p)<1.18 or world.PARK99.on_stairs99(p) or p.distance_to(world.PARK99.DECK)<2.9: return false
 if p.distance_to(world.PARK99.LOG)<2.1 or p.distance_to(world.PARK99.BENCH)<1.65 or world.meadow.route_distance(at)<1.6: return false
 if absf(p.x)<1.25 and p.y> -4.5 and p.y<5.: return false
 if absf(p.y-1.)<1.0 and absf(p.x)<5.: return false
 if world.meadow.normal_at(at.x,at.y,true).y<.95: return false
 for rock in world.forest87.rocks87:
  if ((at-rock.at)/Vector2(rock.width*.52+.1,rock.width*.28+.1)).length()<1.: return false
 return true
func batch107(mesh: Mesh,poses: Array[Transform3D],material: Material,cast: bool) -> void:
 var multi := MultiMesh.new();multi.transform_format=MultiMesh.TRANSFORM_3D;multi.use_custom_data=true;multi.mesh=mesh;multi.instance_count=poses.size()
 for i in poses.size():
  multi.set_instance_transform(i,poses[i]);multi.set_instance_custom_data(i,Color(fposmod(float(i)*.618,1.),.5,.95,1.))
 var batch := MultiMeshInstance3D.new();batch.multimesh=multi;batch.material_override=material
 batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 batch.visibility_range_end=40.;batch.extra_cull_margin=.5;add_child(batch);batches107.append(batch)
func _ready() -> void:
 name="BrokenUnderstoryRibbons107";grove107=world.meadow.landmarks.grove
 var rng := RandomNumberGenerator.new();rng.seed=107173
 var grass: Array[Transform3D]=[];var fern: Array[Array]=[[],[]]
 for group in GROUPS107:
  var centre := Vector2(group.x,group.y)
  for i in 72:
   var a := rng.randf()*TAU;var r := sqrt(rng.randf())
   var local := centre+Vector2(cos(a)*group.z,sin(a)*group.w)*r
   var at := grove107+local
   if not supported107(at) or sin(local.x*3.1+local.y*2.3)>.87: continue
   var h := rng.randf_range(.65,1.5)*(1.-r*.38)
   var basis := Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3(.85,h,.85))
   grass.append(Transform3D(basis,Vector3(at.x,world.floor_height(at)-.025,at.y)))
  for i in 7:
   var at := grove107+centre+Vector2(rng.randf_range(-group.z*.8,group.z*.8),rng.randf_range(-group.w*.6,group.w*.6))
   if not supported107(at): continue
   var close := false
   for plant in world.forest87.plants87:
    if Vector2(plant.position.x,plant.position.z).distance_to(at)<.7: close=true;break
   if close: continue
   var height := rng.randf_range(.70,1.15) if centre.y< -5. or absf(centre.x)>8. else rng.randf_range(.55,.80)
   var basis := Basis.IDENTITY.scaled(Vector3(height*(1. if i%2 else -1.),height,height))
   fern[i%2].append(Transform3D(basis,Vector3(at.x,world.floor_height(at)-.045,at.y)))
 grass_count107=grass.size();batch107(world.meadow.blades(2),grass,world.grass_material,false)
 var atlas: Array=world.forest87._textures87("woodland_plants87")
 for index in 2:
  var texture: Texture2D=atlas[index*2]
  var profile := {"foot":[texture.get_width()*.5,texture.get_height()-2.],"height":texture.get_height()-2.}
  var material: ShaderMaterial=world.forest87._plant_material94(texture)
  material.set_shader_parameter("field94",true)
  material.set_shader_parameter("tint",Vector3(.84,.91,.85))
  var poses: Array[Transform3D]=[];poses.assign(fern[index]);fern_count107+=poses.size()
  batch107(world.forest87._flower_mesh94(texture,profile),poses,material,true)
func _process(delta: float) -> void:
 update_wait107-=delta
 if update_wait107>0.: return
 update_wait107=.05
 if not visible or not is_instance_valid(world.hero) or world.hero.position.distance_to(Vector3(grove107.x,2.1,grove107.y))>32.: return
 for batch in batches107:
  if batch.material_override==world.grass_material: continue
  batch.material_override.set_shader_parameter("walker",world.hero.get_global_transform_interpolated().origin)
  batch.material_override.set_shader_parameter("clock",world.clock)
  batch.material_override.set_shader_parameter("trail",world.trail)
