extends "res://scripts/art/forest_art189.gd"
var ropes193: Array[MeshInstance3D]=[]
var anchors193: Array[Vector3]=[]
var rope_ends193: Array[Vector3]=[]
func painted_point193(visual: Sprite3D,uv: Vector2) -> Vector3:
 var source: Texture2D=visual.texture.atlas if visual.texture is AtlasTexture else visual.texture
 var bounds := opaque_bounds181(source)
 var pixel := Vector2(bounds.position)+Vector2(bounds.size)*uv
 var dx := (pixel.x-source.get_width()*.5+visual.offset.x)*visual.pixel_size
 var up := (visual.texture.get_height()*.5-pixel.y+visual.offset.y)*visual.pixel_size
 return visual.global_position+world.camera.global_basis.x*dx+world.camera.global_basis.y*up
func _ready() -> void:
 super._ready()
 var material := StandardMaterial3D.new();material.albedo_color=Color("ad8870");material.roughness=1.;material.metallic_specular=0.
 for uv in [Vector2(.405,.695),Vector2(.69,.625)]:
  anchors193.append(painted_point193(stage_tree185,uv)+world.camera.global_basis.z*.1)
  for i in 6:
   var cylinder := CylinderMesh.new();cylinder.top_radius=.019;cylinder.bottom_radius=.019;cylinder.height=.1;cylinder.radial_segments=6
   var node := MeshInstance3D.new();node.mesh=cylinder;node.material_override=material;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
   add_child(node);ropes193.append(node)
 update_ropes193()
func _process(delta: float) -> void:
 super._process(delta)
 if not ropes193.is_empty(): update_ropes193()
func update_ropes193() -> void:
 rope_ends193.clear()
 for side in 2:
  var end: Vector3=painted_point193(hammock_cat189,Vector2(.065 if side==0 else .94,.20))+world.camera.global_basis.z*.02
  rope_ends193.append(end)
  var start: Vector3=anchors193[side]
  for i in 6:
   var t := float(i)/6.;var u := float(i+1)/6.
   var a := start.lerp(end,t)-Vector3.UP*(sin(t*PI)*.035)
   var b := start.lerp(end,u)-Vector3.UP*(sin(u*PI)*.035)
   var node := ropes193[side*6+i];var direction := b-a
   node.mesh.height=direction.length()+.004
   node.global_transform=Transform3D(Basis(Quaternion(Vector3.UP,direction.normalized())),(a+b)*.5)
