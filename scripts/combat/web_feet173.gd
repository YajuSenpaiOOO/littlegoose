extends MeshInstance3D
var hero: CharacterBody3D
var battle: Node3D
var threads173: ImmediateMesh
var anchor173 := Vector3.ZERO
var attached173 := false
func _ready() -> void:
 threads173=ImmediateMesh.new();mesh=threads173;cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.vertex_color_use_as_albedo=true;ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 material_override=ink;process_priority=95;hide()
func _process(_delta: float) -> void:
 if not is_instance_valid(hero): queue_free();return
 if battle.combat_paused: return
 var active: bool=battle.active114 and battle.player_hp>0. and hero.web_left172>0. and hero.dash_left<=0.
 visible=active
 if not active: attached173=false;threads173.clear_surfaces();return
 var foot: Vector3=hero.get_global_transform_interpolated().origin
 if not attached173 or foot.distance_to(anchor173)>.7:
  anchor173=foot;attached173=true
 var right: Vector3=battle.camera.global_basis.x;right.y=0.;right=right.normalized()
 var phase: float=hero.body_clock
 var alpha: float=clampf(hero.web_left172/.3,0.,1.)
 threads173.clear_surfaces();threads173.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 4:
  var side := float(i)-1.5
  var start := anchor173+right*side*.13+Vector3(0.,0.,.16 if i%2 else -.16)
  var end := foot+right*(.12 if i%2 else -.12)
  var points: Array[Vector3]=[]
  for j in 7:
   var t := float(j)/6.;var point := start.lerp(end,t)
   point.y=battle.floor_height(Vector2(point.x,point.z))+.055+.18*t+sin(t*PI)*(.06+.025*sin(phase*14.+i))
   points.append(point)
  for j in 6:
   var a: Vector3=points[j];var b: Vector3=points[j+1]
   for layer in 2:
    var width := right*(.022 if layer==0 else .010)
    var raise := Vector3.UP*float(layer)*.003
    var color := Color(.48,.36,.52,alpha*.70) if layer==0 else Color(1.,.94,.80,alpha*.95)
    for point: Vector3 in [a-width,a+width,b+width,a-width,b+width,b-width]:
     threads173.surface_set_color(color);threads173.surface_add_vertex(point+raise)
 threads173.surface_end()
