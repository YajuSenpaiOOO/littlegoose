extends Node3D
var world: Node3D
var entries118: Array[Dictionary]=[]
var clock118 := 0.
func _ready() -> void:
 name="GroundedPaintedFeet118"
 build118(world.house_art,.85,false)
 build118(world.workshop116.pot.visual,.42,true)
 build118(world.workshop116.tin.visual,.30,true)
func build118(sprite: Sprite3D,blend: float,projected: bool) -> void:
 var image: Image=sprite.texture.get_image()
 if image.is_compressed(): image.decompress()
 var size := image.get_size();var columns := 80;var rows := 40
 var profile := Image.create(columns+1,1,false,Image.FORMAT_RGBAF)
 var feet: Array[Vector3]=[];var valid: Array[bool]=[]
 var gaps: Array[float]=[];var lows: Array[float]=[]
 for x in columns+1:
  var pixel_x := clampi(roundi(float(x)/columns*(size.x-1)),0,size.x-1);var bottom := -1
  for y in range(size.y-1,int(size.y*.68),-1):
   if image.get_pixel(pixel_x,y).a>.5: bottom=y;break
  var local := Vector3((pixel_x-size.x*.5+sprite.offset.x)*sprite.pixel_size,(size.y*.5-maxi(0,bottom)+sprite.offset.y)*sprite.pixel_size,0.)
  var point := sprite.to_global(local);var floor_y: float=world.floor_height(Vector2(point.x,point.z))+.009
  var gap := clampf(point.y-floor_y,0.,.6) if bottom>=0 else 0.
  gaps.append(gap);lows.append(local.y);profile.set_pixel(x,0,Color(local.y,gap,0.,1.))
  feet.append(Vector3(point.x,floor_y,point.z));valid.append(bottom>=0 and point.y-floor_y<.6)
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var region := Rect2(Vector2.ZERO,Vector2.ONE)
 if sprite.texture is AtlasTexture:
  var source: AtlasTexture=sprite.texture;region=Rect2(source.region.position/Vector2(source.atlas.get_size()),source.region.size/Vector2(source.atlas.get_size()))
 for y in rows:
  for x in columns:
   for corner in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
    var at: Vector2i=Vector2i(x,y)+corner;var uv := Vector2(float(at.x)/columns,float(at.y)/rows)
    var local := Vector3((uv.x*size.x-size.x*.5+sprite.offset.x)*sprite.pixel_size,(size.y*.5-uv.y*size.y+sprite.offset.y)*sprite.pixel_size,0.)
    var point := sprite.to_global(local);point.y-=gaps[at.x]*(1.-smoothstep(lows[at.x],lows[at.x]+blend,local.y))
    st.set_uv(region.position+uv*region.size);st.set_normal(Vector3.UP);st.add_vertex(sprite.get_parent().to_local(point))
 var mesh := MeshInstance3D.new();mesh.name="TerrainSeatedPaint118";mesh.mesh=st.commit();mesh.material_override=sprite.material_override
 mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON if projected else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 sprite.get_parent().add_child(mesh)
 # Keep the Sprite3D as an anchor for existing light/fade/shadow systems; draw its fitted mesh.
 sprite.layers=0;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var texture := ImageTexture.create_from_image(profile)
 entries118.append({"sprite":sprite,"mesh":mesh,"profile":texture,"blend":blend,"gaps":gaps,"feet":feet,"valid":valid,"projected":projected})
 contact118(sprite.get_parent(),feet,valid,.20 if not projected else .13)
func contact118(parent: Node3D,feet: Array[Vector3],valid: Array[bool],depth: float) -> void:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in feet.size()-1:
  if not valid[i] or not valid[i+1]: continue
  for side in [-1.,1.]:
   for corner in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
    var p: Vector3=feet[i+corner.x];p.z+=side*depth*corner.y;p.y=world.floor_height(Vector2(p.x,p.z))+.012
    st.set_color(Color(.10,.14,.085,.26 if corner.y==0 else 0.));st.set_normal(Vector3.UP);st.add_vertex(parent.to_local(p))
 var patch := MeshInstance3D.new();patch.name="TightFootContact118";patch.mesh=st.commit();patch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := StandardMaterial3D.new();ink.vertex_color_use_as_albedo=true;ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;ink.cull_mode=BaseMaterial3D.CULL_DISABLED;ink.no_depth_test=false
 patch.material_override=ink;parent.add_child(patch)
func _process(delta: float) -> void:
 clock118-=delta
 if clock118>0.: return
 clock118=.25
 for entry in entries118:
  entry.mesh.visible=entry.sprite.is_visible_in_tree()
  if not entry.projected: continue
  for shadow in world.actor_shadows:
   if not is_instance_valid(shadow) or shadow.visual!=entry.sprite or not shadow.gpu113: continue
   var shader := preload("res://scripts/art/actor_shadow118.gdshader")
   if shadow.ink.shader==shader: continue
   shadow.ink.shader=shader;world.shadow_field113.bind_shader(shadow.ink)
   shadow.ink.set_shader_parameter("foot_profile118",entry.profile);shadow.ink.set_shader_parameter("foot_blend118",entry.blend)
