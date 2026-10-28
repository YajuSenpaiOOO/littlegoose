extends "res://scripts/art/forest_art188d.gd"
var grounded187: Array[MeshInstance3D]=[]
var joins187: Array=[]
var tree_image187: Image
var tree_fade187 := 1.
var lamps_fixed188 := false
func silhouette182(visual: Sprite3D) -> void:
 if visual!=cottage_sprite and visual!=stage_tree185: super.silhouette182(visual);return
 var shadow := preload("res://scripts/art/forest_projection187.gd").new();shadow.battle=world;shadow.visual=visual;shadow.enabled=world.silhouettes_enabled
 visual.add_child(shadow);world.actor_shadows.append(shadow);prop_shadows182.append(shadow)
func lane181(st: SurfaceTool,points: Array) -> void:
 var offsets: Array[Vector2]=[]
 for i in points.size():
  var before: Vector2=(points[i]-points[maxi(i-1,0)]).normalized() if i>0 else (points[1]-points[0]).normalized()
  var after: Vector2=(points[mini(i+1,points.size()-1)]-points[i]).normalized() if i<points.size()-1 else before
  var normal := (before.orthogonal()+after.orthogonal()).normalized()
  var width: float=.82+.08*sin((points[i].x+points[i].y)*1.3)
  offsets.append(normal*width/maxf(.55,normal.dot(before.orthogonal())))
 var passed := 0.
 for segment in range(1,points.size()):
  var a: Vector2=points[segment-1];var b: Vector2=points[segment];var length := a.distance_to(b);var count := ceili(length/.3)
  # Both adjacent segments share these exact corner cross-sections.
  joins187.append([a-offsets[segment-1],a+offsets[segment-1],b-offsets[segment],b+offsets[segment]])
  for i in count:
   var t := float(i)/count;var u := float(i+1)/count
   if PLAN.in_flight(a.lerp(b,(t+u)*.5)): continue
   for spec in [Vector2(0,0),Vector2(1,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),Vector2(0,1)]:
    var along := lerpf(t,u,spec.y);var centre := a.lerp(b,along)
    var offset := offsets[segment-1].lerp(offsets[segment],along)
    var p: Vector2=centre+offset*(spec.x*2.-1.)
    st.set_uv(Vector2(spec.x,passed+length*along));st.set_normal(Vector3.UP);st.add_vertex(Vector3(p.x,world.floor_height(PLAN.CENTER+p)+.055,p.y))
  passed+=length
func _ready() -> void:
 super._ready();name="GroundedBases187"
 split_ground187(stage_tree185,.91,Vector3(-1.,PLAN.BASE+.045,0.))
 split_ground187(cottage_sprite,.88,Vector3(-11.,PLAN.BASE+.045,-9.7))
 house_contact186.hide();attach_lamps185()
 lamps_fixed188=true
 tree_image187=stage_tree185.texture.get_image()
 # The 187 shader only quantized a detailed illustration and produced crawling
 # pseudo-pixels.  The 188 props are redrawn at the intended logical density.
 for prop in props181:
  if prop!=stage_tree185: prop.material_override=null
 for light in lights181+hanging_lights184:
  light.light_energy=minf(light.light_energy,.62)
  light.omni_range=minf(light.omni_range,3.35)
func split_ground187(visual: Sprite3D,fraction: float,anchor: Vector3) -> void:
 var source: Texture2D=visual.texture;var bounds := opaque_bounds181(source)
 var cut := roundi(bounds.position.y+bounds.size.y*fraction)
 var offset_x := visual.offset.x;var scale187 := visual.pixel_size
 var cropped := AtlasTexture.new();cropped.atlas=source;cropped.region=Rect2(0,0,source.get_width(),cut)
 visual.texture=cropped;visual.offset=Vector2(offset_x,cut*.5);visual.position=anchor
 var upper := ShaderMaterial.new();upper.shader=preload("res://scripts/art/forest_upper187.gdshader");upper.set_shader_parameter("paint",source);upper.set_shader_parameter("tint",visual.modulate);upper.set_shader_parameter("cut_y",float(cut)/source.get_height());visual.material_override=upper
 var camera: Camera3D=world.camera;var right := camera.global_basis.x
 var forward := Vector3(camera.global_basis.z.x,0,camera.global_basis.z.z).normalized()
 var descent := maxf(absf(camera.global_basis.z.y),.25)
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var count := Vector2i(24,8)
 for y in count.y:
  for x in count.x:
   var vertices187: Array[Vector3]=[];var uvs187: Array[Vector2]=[];var safe187 := true
   for delta in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
    var grid: Vector2=(Vector2(x,y)+delta)/Vector2(count)
    var uv := Vector2(grid.x,lerpf(float(cut)/source.get_height()-.018,1.,grid.y))
    var dx := ((uv.x-.5)*source.get_width()+offset_x)*scale187
    var drop := (uv.y*source.get_height()-cut)*scale187
    var at := visual.global_position+right*dx+forward*(drop/descent)
    at.y=world.floor_height(Vector2(at.x,at.z))+.045
    safe187=safe187 and at.y<PLAN.BASE+.3;vertices187.append(to_local(at));uvs187.append(uv)
   if safe187:
    for i in vertices187.size(): st.set_uv(uvs187[i]);st.set_normal(Vector3.UP);st.add_vertex(vertices187[i])
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_ground187.gdshader");material.set_shader_parameter("paint",source);material.set_shader_parameter("tint",visual.modulate);material.set_shader_parameter("cut_y",float(cut)/source.get_height())
 var base := mesh(st.commit(),Vector3.ZERO,material);base.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;base.name="GroundLayer187";grounded187.append(base)
func update_house_contact186() -> void: pass
func set_grounding184(on: bool) -> void:
 super.set_grounding184(on)
 if is_instance_valid(house_contact186): house_contact186.hide()
func attach_lamps185() -> void:
 if lamps_fixed188: return
 if not is_instance_valid(stage_tree185) or not stage_tree185.texture is AtlasTexture:
  super.attach_lamps185();return
 var tile: AtlasTexture=stage_tree185.texture;var original: Texture2D=tile.atlas
 var bounds := opaque_bounds181(original);var targets := [Vector2(.405,.695),Vector2(.69,.625)]
 for i in 2:
  var uv: Vector2=targets[i];var pixel := Vector2(bounds.position)+Vector2(bounds.size)*uv
  var dx := (pixel.x-original.get_width()*.5+stage_tree185.offset.x)*stage_tree185.pixel_size
  var up := (tile.region.size.y-pixel.y)*stage_tree185.pixel_size
  var at: Vector3=stage_tree185.global_position+world.camera.global_basis.x*dx+world.camera.global_basis.y*up
  hanging_lamps184[i].global_position=at;hanging_lights184[i].global_position=at-world.camera.global_basis.y*.72+Vector3(0,0,.2)
func _process(delta: float) -> void:
 super._process(delta)
 if tree_image187==null: return
 var camera: Camera3D=world.camera;var n := stage_tree185;var size := n.texture.get_size()
 var top := n.global_position+camera.global_basis.x*((-size.x*.5+n.offset.x)*n.pixel_size)+camera.global_basis.y*((size.y*.5+n.offset.y)*n.pixel_size)
 var bottom := n.global_position+camera.global_basis.x*((size.x*.5+n.offset.x)*n.pixel_size)+camera.global_basis.y*((-size.y*.5+n.offset.y)*n.pixel_size)
 var a := camera.unproject_position(top);var b := camera.unproject_position(bottom)
 var actor: Vector3=world.hero.position+Vector3.UP*.8;var screen := camera.unproject_position(actor)
 var uv := (screen-a)/(b-a);var blocked := false
 if uv.x>=0. and uv.x<1. and uv.y>=0. and uv.y<1. and camera.global_position.distance_to(actor)>camera.global_position.distance_to(n.global_position):
  blocked=tree_image187.get_pixel(clampi(int(uv.x*tree_image187.get_width()),0,tree_image187.get_width()-1),clampi(int(uv.y*tree_image187.get_height()),0,tree_image187.get_height()-1)).a>.6
 tree_fade187=lerpf(tree_fade187,.18 if blocked else 1.,1.-exp(-delta*10.))
 n.transparency=0.;n.material_override.set_shader_parameter("fade",tree_fade187)

func route181() -> void:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);var joined := PLAN.PATH.duplicate();joined.append_array(DRESS.TRAIL.slice(1));lane181(st,joined)
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_trail181.gdshader");material.set_shader_parameter("soil",preload("res://assets/woodland103/painted_soil103.png"));world.porch49.shade_material(material)
 terrain_trail181=mesh(st.commit(),Vector3.ZERO,material)
 for p in [Vector2(9.9,7.9),Vector2(8.8,7.4),Vector2(6.6,6.9),Vector2(3.2,4.2),Vector2(-4.4,3.3),Vector2(-5.7,.8),Vector2(-5.5,-3.4),Vector2(-6.5,-5.5),Vector2(-8.,-7.),Vector2(-9.2,-7.6),Vector2(-10.4,-8.1)]:
  var poly := PackedVector2Array([Vector2(-.28,-.13),Vector2(-.12,-.23),Vector2(.23,-.16),Vector2(.31,.04),Vector2(.13,.22),Vector2(-.22,.16)])
  var at: Vector2=PLAN.CENTER+p;var node: MeshInstance3D=world.park99._prism99(poly,Vector3(at.x,world.floor_height(at)+.025,at.y),.045)
  node.rotation.y=p.x*1.7
  for child in node.get_children():
   if child is CollisionObject3D: child.collision_layer=0
  thin_stones181.append(node)
