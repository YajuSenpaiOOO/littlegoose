extends "res://scripts/art/forest_art188a.gd"
var hanging_lamps184: Array[Sprite3D]=[]
var hanging_lights184: Array[OmniLight3D]=[]
var grounding_on184 := true
var ground_layers184: Array[MeshInstance3D]=[]
var native_casters184: Array[MeshInstance3D]=[]
func silhouette182(visual: Sprite3D) -> void:
 var shadow := preload("res://scripts/art/forest_shadow184.gd").new()
 shadow.battle=world;shadow.visual=visual;shadow.enabled=world.silhouettes_enabled;shadow.opacity_scale=1.5
 visual.add_child(shadow);world.actor_shadows.append(shadow);prop_shadows182.append(shadow)
func contact182(at: Vector2,width: float,depth: float) -> void:
 # Dense conforming receiver avoids sinking a broad flat ellipse into uneven terrain.
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var size := Vector2(width,depth)
 for iz in 8:
  for ix in 12:
   for offset in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
    var uv: Vector2=(Vector2(ix,iz)+offset)/Vector2(12,8);var p: Vector2=at+(uv-Vector2(.5,.5))*size
    st.set_uv(uv);st.set_normal(Vector3.UP);st.add_vertex(Vector3(p.x,world.floor_height(PLAN.CENTER+p)+.075,p.y))
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_contact184.gdshader")
 var mark := mesh(st.commit(),Vector3.ZERO,material);mark.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;contacts182.append(mark)
func tree(at: Vector2,height: float,index: int) -> void:
 if index!=21: super.tree(at,height,index);return
 var n := cutout181(preload("res://assets/forest184/ribbon_oak.png"),Vector3(at.x,PLAN.BASE+.025,at.y+1.15),11.,Vector2(.52,1.))
 n.name="CentralOak184";n.modulate=Color(.74,.85,1.)
 trees.append(n);fading.append({"node":n,"at":at,"radius":3.5,"height":11.})
func _ready() -> void:
 super._ready();name="GroundedForest184"
 # A real low stone island and a broad shadow sit beneath the painted roots.
 var poly := PackedVector2Array()
 for i in 14:
  var angle := TAU*i/14.;poly.append(Vector2(cos(angle)*2.15,sin(angle)*1.45))
 var island: MeshInstance3D=world.park99._prism99(poly,Vector3(PLAN.CENTER.x-1.,PLAN.BASE+.025,PLAN.CENTER.y),.12)
 island.name="RootStoneIsland184";ground_layers184.append(island)
 for child in island.get_children():
  if child is CollisionObject3D: child.collision_layer=0
 contact182(Vector2(-1.,.6),5.4,4.)
 # A second apron contact anchors the visible front foundation, outside its footprint.
 contact182(Vector2(-11.,-8.9),6.5,2.5)
 var old_foundation := world.find_child("CottageFoundation183",true,false)
 if is_instance_valid(old_foundation): old_foundation.hide()
 var apron := PackedVector2Array([Vector2(-2.9,-.75),Vector2(2.8,-.75),Vector2(3.1,.65),Vector2(2.6,1.05),Vector2(-2.8,.9)])
 var plinth: MeshInstance3D=world.park99._prism99(apron,Vector3(PLAN.CENTER.x-11.,PLAN.BASE+.055,PLAN.CENTER.y-9.6),.22)
 plinth.name="CottagePlinth184";ground_layers184.append(plinth)
 for child in plinth.get_children():
  if child is CollisionObject3D: child.collision_layer=0
 native_shadows184()
 for spec in [Vector3(-2.2,3.65,.1),Vector3(.9,3.9,.1)]:
  var lamp := cutout181(preload("res://assets/forest184/hanging_lantern.png"),Vector3(spec.x,PLAN.BASE+spec.y,spec.z),1.05,Vector2(.5,0.))
  lamp.name="HangingLantern184";hanging_lamps184.append(lamp);silhouette182(lamp)
  var light := OmniLight3D.new();light.position=lamp.position+Vector3(0,-.75,.2);light.light_color=Color("ffd194");light.light_energy=1.2;light.omni_range=4.;add_child(light);hanging_lights184.append(light)
func set_grounding184(on: bool) -> void:
 grounding_on184=on
 for shadow in prop_shadows182: shadow.enabled=on
 for contact in contacts182: contact.visible=on
 for caster in native_casters184: caster.visible=on
func caster184(shape: Mesh,at: Vector3) -> MeshInstance3D:
 var n := mesh(shape,at,ink("59645b"));n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY;native_casters184.append(n);return n
func native_shadows184() -> void:
 # Simple volumes cast real directional shadows while the painted cards remain visible.
 var walls := BoxMesh.new();walls.size=Vector3(5.1,2.8,3.5)
 caster184(walls,Vector3(-11.,PLAN.BASE+1.4,-11.))
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var a := Vector3(-2.9,0,-1.95);var b := Vector3(2.9,0,-1.95);var c := Vector3(0,1.8,-1.95)
 var d := a+Vector3(0,0,3.9);var e := b+Vector3(0,0,3.9);var f := c+Vector3(0,0,3.9)
 for p in [a,c,b,d,e,f,a,d,f,a,f,c,b,c,f,b,f,e,a,b,e,a,e,d]: st.add_vertex(p)
 st.generate_normals();caster184(st.commit(),Vector3(-11.,PLAN.BASE+2.8,-11.))
 var trunk := CylinderMesh.new();trunk.top_radius=.6;trunk.bottom_radius=1.05;trunk.height=4.2
 caster184(trunk,Vector3(-1.,PLAN.BASE+2.1,0.))
 for spec in [Vector3(-3.2,7.2,0.),Vector3(.9,7.4,0.),Vector3(-1.,9.,0.)]:
  var crown := SphereMesh.new();crown.radius=2.3;crown.height=3.3
  var n := caster184(crown,Vector3(spec.x,PLAN.BASE+spec.y,spec.z));n.scale.z=.65
