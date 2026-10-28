extends MeshInstance3D
var battle: Node3D
var visual: Sprite3D
var enabled := true
var opacity_scale := 1.
var light_direction := Vector3(.4,-1.,.4)
var ink: ShaderMaterial
var key186: Array=[]
var next186 := 0
func _ready() -> void:
 cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 ink=ShaderMaterial.new();ink.shader=preload("res://scripts/art/forest_projection186.gdshader");material_override=ink
 process_priority=110;physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
func _process(_delta: float) -> void:
 visible=enabled and is_instance_valid(visual) and visual.is_visible_in_tree() and battle.contact_enabled
 if not visible: return
 ink.set_shader_parameter("opacity",.20*clampf(opacity_scale,.55,1.)*(1.-visual.transparency*.55))
 var sun: Vector3=-battle.sun.global_basis.z.normalized()
 var quantized := sun.snapped(Vector3.ONE*.025)
 var basis186: Basis=battle.camera.global_basis
 var key := [visual.global_position,visual.texture,visual.offset,visual.pixel_size,basis186,quantized]
 if key==key186 or Time.get_ticks_msec()<next186: return
 key186=key;next186=Time.get_ticks_msec()+160
 ink.set_shader_parameter("paint",visual.texture)
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var dimensions := visual.texture.get_size();var projected := PackedVector3Array()
 var count := 16
 for y in count+1:
  for x in count+1:
   var uv := Vector2(x,y)/float(count)
   var local := Vector2((uv.x-.5)*dimensions.x+visual.offset.x,(.5-uv.y)*dimensions.y+visual.offset.y)*visual.pixel_size
   # Sprite3D's rendered billboard basis is the camera plane, not its Node3D basis.
   var point := visual.global_position+basis186.x*local.x+basis186.y*local.y
   var landing := point
   var base: float=battle.floor_height(Vector2(point.x,point.z))
   var direction := sun
   if absf(direction.y)<.25: direction.y=-.25
   for i in 3:
    landing=point+direction*((base-point.y)/direction.y)
    base=battle.floor_height(Vector2(landing.x,landing.z))
   landing.y=base+.055;projected.append(to_local(landing))
 for y in count:
  for x in count:
   for delta in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
    var cell: Vector2i=Vector2i(x,y)+delta
    st.set_uv(Vector2(cell)/float(count));st.add_vertex(projected[cell.y*(count+1)+cell.x])
 mesh=st.commit();custom_aabb=mesh.get_aabb().grow(.1)
