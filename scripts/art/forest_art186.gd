extends "res://scripts/art/forest_art185.gd"
var final186 := false
var house_contact186: MeshInstance3D
var contact_tick186 := 0
func silhouette182(visual: Sprite3D) -> void:
 if visual!=cottage_sprite and visual!=stage_tree185: super.silhouette182(visual);return
 var shadow := preload("res://scripts/art/forest_projection186.gd").new();shadow.battle=world;shadow.visual=visual;shadow.enabled=world.silhouettes_enabled
 visual.add_child(shadow);world.actor_shadows.append(shadow);prop_shadows182.append(shadow)
func contact182(at: Vector2,width: float,depth: float) -> void:
 if not final186 and ((absf(at.x+11.)<.1 and width>5.) or (absf(at.x+1.)<.1 and width>3.)): return
 super.contact182(at,width,depth)
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_foot186.gdshader");contacts182[-1].material_override=material
func _ready() -> void:
 super._ready();name="ForestSilhouettes186"
 for tree186 in trees:
  if tree186.material_override is ShaderMaterial:
   tree186.material_override.shader=preload("res://scripts/art/forest_cutout186.gdshader")
 stage_tree185.alpha_cut=SpriteBase3D.ALPHA_CUT_DISABLED
 for caster in native_casters184: caster.hide();caster.queue_free()
 native_casters184.clear()
 for id in ["CottagePlinth184","CottageFoundation183","RootStoneIsland184"]:
  var node := world.find_child(id,true,false)
  if is_instance_valid(node): node.hide()
 for stone186 in thin_stones181: stone186.position.y+=.05
 final186=true;contact182(Vector2(-1.,.5),4.1,2.5)
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_foot186.gdshader");material.set_shader_parameter("strip",true)
 house_contact186=mesh(PlaneMesh.new(),Vector3.ZERO,material);house_contact186.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;contacts182.append(house_contact186)
 update_house_contact186()
func update_house_contact186() -> void:
 var camera: Camera3D=world.camera;var bounds := opaque_bounds181(cottage_sprite.texture)
 var width := bounds.size.x*cottage_sprite.pixel_size;var height := bounds.size.y*cottage_sprite.pixel_size
 var line: Array[Vector2]=[]
 # Trace the painted left wall and front porch rather than an axis-aligned slab.
 for uv in [Vector2(.055,.81),Vector2(.40,.985),Vector2(.95,.89)]:
  var pixel: Vector2=uv
  var point := cottage_sprite.global_position+camera.global_basis.x*((pixel.x-.5)*width)+camera.global_basis.y*((1.-pixel.y)*height)
  var direction := (point-camera.global_position).normalized()
  var t := (PLAN.BASE+.065-camera.global_position.y)/direction.y
  var hit := camera.global_position+direction*t
  line.append(Vector2(hit.x,hit.z)-PLAN.CENTER)
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(1,line.size()):
  var a: Vector2=line[i-1];var b: Vector2=line[i]
  for spec in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
   var p: Vector2=a.lerp(b,spec.x)+Vector2(0,.65)*spec.y
   st.set_uv(spec);st.add_vertex(Vector3(p.x,world.floor_height(PLAN.CENTER+p)+.07,p.y))
 house_contact186.mesh=st.commit()
func _process(delta: float) -> void:
 super._process(delta)
 if final186 and Time.get_ticks_msec()>contact_tick186:
  contact_tick186=Time.get_ticks_msec()+160;update_house_contact186()

func lane181(st: SurfaceTool,points: Array) -> void:
 for segment in range(1,points.size()):
  var a: Vector2=points[segment-1];var b: Vector2=points[segment];var tangent := (b-a).normalized();var side := tangent.orthogonal();var count := ceili(a.distance_to(b)/.35)
  for i in count:
   var t := float(i)/count;var u := float(i+1)/count;var p := a.lerp(b,t);var q := a.lerp(b,u)
   if PLAN.in_flight((p+q)*.5): continue
   var width := .82+.08*sin((p.x+p.y)*1.3)
   for spec in [Vector3(0,0,0),Vector3(1,0,1),Vector3(0,1,0),Vector3(1,0,1),Vector3(1,1,1),Vector3(0,1,0)]:
    var centre: Vector2=p if spec.y<.5 else q;var at: Vector2=centre+side*((spec.x*2.-1.)*width)
    st.set_uv(Vector2(spec.x,centre.distance_to(a)));st.set_normal(Vector3.UP)
    st.add_vertex(Vector3(at.x,world.floor_height(PLAN.CENTER+at)+.055,at.y))
