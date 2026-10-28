extends "res://scripts/art/woodland_layers107.gd"
const PLAN142=preload("res://scripts/world/hill_layout142.gd")
var clusters142 := 0
func supported107(at: Vector2) -> bool:
 var p := at-grove107
 return PLAN142.path_distance(p)>1.6 and PLAN142.view_radius(p)>1.25 and world.HILL136.stair136(p).x>2.8 and world.meadow.normal_at(at.x,at.y,true).y>.90
func _ready() -> void:
 name="SummitPlantPockets142";grove107=world.meadow.landmarks.grove
 var rng := RandomNumberGenerator.new();rng.seed=142072
 var grass: Array[Transform3D]=[];var fern: Array[Array]=[[],[]]
 for group in [Vector4(-28.,-12.,1.8,1.0),Vector4(-31.,-19.4,1.5,1.8),Vector4(-29.,-25.,1.7,1.0),Vector4(-21.,-26.,1.5,1.0),Vector4(-16.1,-28.7,1.8,1.0),Vector4(-18.3,-18.5,1.0,1.8)]:
  clusters142+=1
  for i in 45:
   var angle := rng.randf()*TAU;var radius := sqrt(rng.randf());var p := Vector2(group.x,group.y)+Vector2(cos(angle)*group.z,sin(angle)*group.w)*radius
   var at := grove107+p
   if not supported107(at): continue
   var size := rng.randf_range(.65,1.05)*(1.-radius*.3)
   grass.append(Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3(.85,size,.85)),Vector3(at.x,world.floor_height(at)-.02,at.y)))
  for i in 5:
   var at := grove107+Vector2(group.x,group.y)+Vector2(rng.randf_range(-group.z*.8,group.z*.8),rng.randf_range(-group.w*.7,group.w*.7))
   if not supported107(at): continue
   var size := rng.randf_range(.55,.90)
   fern[i%2].append(Transform3D(Basis.IDENTITY.scaled(Vector3(size*(1. if i%2 else -1.),size,size)),Vector3(at.x,world.floor_height(at)-.04,at.y)))
 grass_count107=grass.size();batch107(world.meadow.blades(2),grass,world.grass_material,false)
 var atlas: Array=world.forest87._textures87("woodland_plants87")
 for index in 2:
  var texture: Texture2D=atlas[index*2]
  var profile := {"foot":[texture.get_width()*.5,texture.get_height()-2.],"height":texture.get_height()-2.}
  var material: ShaderMaterial=world.forest87._plant_material94(texture);material.set_shader_parameter("field94",true);material.set_shader_parameter("tint",Vector3(.89,.96,.85))
  var poses: Array[Transform3D]=[];poses.assign(fern[index]);fern_count107+=poses.size()
  batch107(world.forest87._flower_mesh94(texture,profile),poses,material,true)
