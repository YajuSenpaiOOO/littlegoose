extends Node
var world: Node3D
var enabled := true
var stage_enabled := true
var lamps: Array[OmniLight3D]=[]
var casters: Array[MeshInstance3D]=[]
var stage_level := 0.
var regional_level := 0.
var elapsed := 0.
func core(visual: Sprite3D,uv: Vector2) -> Vector3:
 var texture: Texture2D=visual.texture
 var full: Texture2D=texture.atlas if texture is AtlasTexture else texture
 var bounds: Rect2i=world.forest188.opaque_bounds181(full)
 var pixel := Vector2(bounds.position)+Vector2(bounds.size)*uv
 var dx := (pixel.x-full.get_width()*.5+visual.offset.x)*visual.pixel_size
 var up := (texture.get_height()*.5-pixel.y+visual.offset.y)*visual.pixel_size
 return visual.global_position+world.camera.global_basis.x*dx+world.camera.global_basis.y*up
func lamp(at: Vector3,energy: float,radius: float) -> OmniLight3D:
 var light := OmniLight3D.new();light.name="WarmReceiver191"
 light.position=at;light.light_color=Color("ffd39b");light.light_energy=energy;light.omni_range=radius
 light.omni_attenuation=1.4;light.shadow_enabled=false;light.light_cull_mask=3;light.shadow_caster_mask=2
 light.shadow_bias=.12;light.shadow_normal_bias=1.5;light.shadow_opacity=.6
 light.set_meta("energy191",energy);add_child(light);lamps.append(light);return light
func caster(at: Vector3,radius: float,height: float) -> void:
 var mesh := CylinderMesh.new();mesh.top_radius=radius*.8;mesh.bottom_radius=radius;mesh.height=height;mesh.radial_segments=10
 var node := MeshInstance3D.new();node.mesh=mesh;node.position=at+Vector3.UP*height*.5
 node.layers=2;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
 add_child(node);casters.append(node)
func _ready() -> void:
 process_priority=100
 var art: Node3D=world.forest188
 for old in art.lights181+art.hanging_lights184: old.light_energy=0.;old.visible=false
 for prop in art.props181:
  if prop.texture==preload("res://assets/forest188/post_top_nightlight_pixel.png"):
   lamp(core(prop,Vector2(.56,.23))+world.camera.global_basis.z*.35,.9,5.2)
   caster(prop.global_position,.13,1.7)
  elif prop.texture==preload("res://assets/forest184/hanging_lantern.png"):
   lamp(core(prop,Vector2(.5,.78))+world.camera.global_basis.z*.4,.75,5.)
  elif prop!=art.stage_tree185 and prop.material_override==null:
   prop.shaded=true
 # The three authored windows and front porch spill actual light into the lane.
 for uv in [Vector2(.22,.62),Vector2(.73,.62),Vector2(.53,.25)]:
  lamp(core(art.cottage_sprite,uv)+world.camera.global_basis.z*.8,.6,5.8)
 lamp(art.cottage_sprite.global_position+Vector3(0,1.8,1.6),.8,5.5)
 # Convert existing custom foliage materials while preserving UVs and animation.
 for entry in art.flowers189:
  var material: ShaderMaterial=entry.visual.material_override
  var shader := Shader.new();shader.code=material.shader.code.replace("unshaded,","").replace("ALBEDO=tex.rgb;","ALBEDO=tex.rgb*.78;ROUGHNESS=1.;SPECULAR=0.;")
  material.shader=shader
 # Retain the split tree card's sorting and fade, but let its painted bark
 # receive the same native lights as the props around its roots.
 var tree_material: ShaderMaterial=art.stage_tree185.material_override
 var tree_shader := Shader.new()
 tree_shader.code=tree_material.shader.code.replace("unshaded,","shadows_disabled,").replace("ALBEDO=tex.rgb*tint.rgb;", "NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);ALBEDO=tex.rgb*tint.rgb*.72;ROUGHNESS=1.;SPECULAR=0.;")
 tree_material.shader=tree_shader
 var roots: ShaderMaterial=art.grounded187[0].material_override
 var root_shader := Shader.new();root_shader.code=roots.shader.code.replace("unshaded,","").replace("ALBEDO=tex.rgb*tint.rgb;","ALBEDO=tex.rgb*tint.rgb*.72;ROUGHNESS=1.;SPECULAR=0.;")
 roots.shader=root_shader
 # The house remains the authored warm source in this sample. It now has
 # actual window/porch spill, independent from its painted surface brightness.
 for prop in art.craft_props183: caster(prop.global_position,.38,.65)
 art.hammock_cat189.modulate*=Color(.6,.6,.6,1.)
 caster(art.stage_tree185.global_position,.65,4.)
 for body in art.rack_bodies182: caster(body.global_position-Vector3.UP*1.6,.1,3.2)
 # Put a compact house blocker behind the front windows, never across the lane.
 var house := MeshInstance3D.new();var box := BoxMesh.new();box.size=Vector3(3.8,3.2,1.3)
 house.mesh=box;house.position=art.cottage_sprite.global_position+Vector3(0,1.6,-1.1);house.layers=2
 house.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY;add_child(house);casters.append(house)
 # Native hero material is atlas-safe. No emission or screen-space actor gain.
 world.hero.visual.shaded=true
 var surface := SurfaceTool.new();surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for uv in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]:
  surface.set_uv(uv)
  surface.add_vertex(Vector3(-.65,5.5,1.4).lerp(Vector3(0,.06,0),uv.y)+world.camera.global_basis.x*(uv.x-.5)*lerpf(.15,4.8,uv.y))
 world.time55.accents57.stage_beam.mesh=surface.commit()
 _process(0.)
func _process(delta: float) -> void:
 if not is_instance_valid(world.forest_mood188): return
 elapsed+=delta
 var at := Vector2(world.hero.position.x,world.hero.position.z)
 var mood: Node=world.forest_mood188
 var target: float=maxf(mood.weight188(at),mood.route_weight189(at))
 regional_level=lerpf(regional_level,target,1.-exp(-delta*3.)) if delta>0. else target
 var hour: float=world.time55.visual_hour
 var night: float=maxf(smoothstep(17.5,20.,hour),1.-smoothstep(5.,7.,hour))
 var desired: float=maxf(night,regional_level*.68) if enabled and stage_enabled else 0.
 stage_level=lerpf(stage_level,desired,1.-exp(-delta*4.)) if delta>0. else desired
 var accent: Node3D=world.time55.accents57
 var spot: SpotLight3D=accent.stage_light
 spot.position=Vector3(-.65,5.5,1.4);spot.look_at(world.hero.global_position+Vector3.UP*.35,Vector3.UP)
 spot.light_color=Color("fff0d8");spot.light_energy=1.25*stage_level;spot.spot_range=9.;spot.spot_angle=24.;spot.spot_attenuation=1.15
 spot.light_cull_mask=3;spot.shadow_caster_mask=2;spot.shadow_enabled=true;spot.shadow_bias=.12;spot.shadow_opacity=.6;spot.visible=stage_level>.005
 accent.stage_beam.visible=stage_level>.01
 accent.stage_beam.material_override.set_shader_parameter("strength57",stage_level*.035)
 var ordered: Array=lamps.duplicate()
 ordered.sort_custom(func(a,b): return a.global_position.distance_squared_to(world.hero.global_position)<b.global_position.distance_squared_to(world.hero.global_position))
 var rank := {}
 for i in ordered.size(): rank[ordered[i].get_instance_id()]=i
 var upload := PackedVector4Array()
 var hero_at: Vector3=world.hero.global_position
 for light in lamps:
  # Real per-object lights only pay off inside their own reach; distant
  # fixtures keep their shader-side pools (uploaded below and by 201) instead
  # of costing light evaluation and shadow cubes on every frame.
  var near: bool=enabled and light.global_position.distance_squared_to(hero_at)<24.*24.
  light.visible=near
  light.light_energy=float(light.get_meta("energy191")) if near else 0.
  light.shadow_enabled=near and light.global_position.distance_squared_to(hero_at)<12.*12. and int(rank[light.get_instance_id()])<3
  if near and upload.size()<20:
   var p := light.global_position;upload.append(Vector4(p.x,p.y,p.z,light.omni_range))
 var focus: ShaderMaterial=world.atmosphere41.focus_material
 focus.set_shader_parameter("light_count191",upload.size());upload.resize(20);focus.set_shader_parameter("lights191",upload)
 focus.set_shader_parameter("stage191",Vector4(at.x,at.y,stage_level,world.hero.global_position.y))
