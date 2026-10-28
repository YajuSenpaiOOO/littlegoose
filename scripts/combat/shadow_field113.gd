extends RefCounted
# Encode the actual cached collider vertices, including adaptive chunk divisions.
# The shader uses the same triangle diagonal/barycentric interpolation as floor_height.
var height_texture: ImageTexture
var tile_texture: ImageTexture
var rect_texture: ImageTexture
var heights: Image
var tiles: Image
var rects: Image
var origin := Vector2.ZERO
var bounds := Rect2()
var bridge := Rect2()
var bridge_ends := Vector2.ZERO
var revision := 0
var supports: Array[Dictionary]=[]
var support_points := PackedVector2Array()
var support_spans := PackedVector4Array()
var support_bounds := PackedVector4Array()
var support_center := Vector2.ZERO
func rebuild(world: Node3D) -> void:
 bounds=world.meadow.world_bounds.grow(6.);origin=bounds.position;bridge=world.meadow.bridge_rect
 bridge_ends=Vector2(world.meadow.height_at(bridge.position.x-.2,bridge.get_center().y,true),world.meadow.height_at(bridge.end.x+.2,bridge.get_center().y,true))
 supports.clear();support_points.clear();support_spans.clear();support_bounds.clear()
 support_center=Vector2(world.meadow.landmarks.grove)+world.PARK99.DECK
 for item in world.park99.treads102:
  var mesh: MeshInstance3D=item.mesh;var inverse := mesh.global_transform.affine_inverse()
  var transform := Transform2D(Vector2(inverse.basis.x.x,inverse.basis.x.z),Vector2(inverse.basis.z.x,inverse.basis.z.z),Vector2(inverse.origin.x,inverse.origin.z)+Vector2(inverse.basis.y.x,inverse.basis.y.z)*mesh.global_position.y)
  var world_polygon: PackedVector2Array=transform.affine_inverse()*PackedVector2Array(item.polygon)
  var rect := Rect2(world_polygon[0],Vector2.ZERO)
  for point in world_polygon: rect=rect.expand(point)
  rect=rect.grow(.00001)
  supports.append({"bounds":rect,"transform":transform,"polygon":item.polygon,"height":mesh.global_position.y})
  support_spans.append(Vector4(support_points.size(),world_polygon.size(),mesh.global_position.y,0.));support_points.append_array(world_polygon)
  support_bounds.append(Vector4(rect.position.x,rect.position.y,rect.end.x,rect.end.y))
 var maximum := 0;var count: int=world.floor_tiles.size();var columns := ceili(sqrt(float(count)))
 for tile in world.floor_tiles.values(): maximum=maxi(maximum,int(tile.width))
 var width := columns*maximum;var height := ceili(float(count)/columns)*maximum
 var data := PackedFloat32Array();data.resize(width*height)
 tiles=Image.create_empty(ceili(bounds.size.x/16.),ceili(bounds.size.y/16.),false,Image.FORMAT_RGBAF)
 rects=Image.create_empty(tiles.get_width(),tiles.get_height(),false,Image.FORMAT_RGBAF)
 var index := 0
 for key: Vector2i in world.floor_tiles:
  var tile: Dictionary=world.floor_tiles[key];var w: int=tile.width;var offset := Vector2i(index%columns,index/columns)*maximum
  var vertices: PackedVector3Array=tile.vertices
  for y in w:
   for x in w: data[(offset.y+y)*width+offset.x+x]=vertices[y*w+x].y
  tiles.set_pixelv(key,Color(offset.x,offset.y,w,1.))
  var rect: Rect2=tile.rect;rects.set_pixelv(key,Color(rect.position.x,rect.position.y,rect.size.x,rect.size.y));index+=1
 heights=Image.create_from_data(width,height,false,Image.FORMAT_RF,data.to_byte_array())
 height_texture=ImageTexture.create_from_image(heights);tile_texture=ImageTexture.create_from_image(tiles);rect_texture=ImageTexture.create_from_image(rects);revision+=1
func bind_shader(ink: ShaderMaterial) -> void:
 ink.set_shader_parameter("terrain_heights113",height_texture);ink.set_shader_parameter("terrain_tiles113",tile_texture);ink.set_shader_parameter("terrain_rects113",rect_texture)
 ink.set_shader_parameter("terrain_origin113",origin);ink.set_shader_parameter("bridge_rect113",Vector4(bridge.position.x,bridge.position.y,bridge.size.x,bridge.size.y));ink.set_shader_parameter("bridge_ends113",bridge_ends)
 ink.set_shader_parameter("support_center113",support_center);ink.set_shader_parameter("support_count113",supports.size())
 var points := support_points.duplicate();points.resize(64);var spans := support_spans.duplicate();spans.resize(8);var boxes := support_bounds.duplicate();boxes.resize(8)
 ink.set_shader_parameter("support_points113",points);ink.set_shader_parameter("support_spans113",spans);ink.set_shader_parameter("support_bounds113",boxes)
func support(at: Vector2,base: float) -> float:
 if at.distance_squared_to(support_center)>=64.: return base
 for item in supports:
  if item.bounds.has_point(at) and Geometry2D.is_point_in_polygon(item.transform*at,item.polygon): base=maxf(base,float(item.height))
 return base
func sample(at: Vector2) -> float:
 if bridge.has_point(at): return support(at,lerpf(lerpf(bridge_ends.x,.24,smoothstep(0.,1.3,at.x-bridge.position.x)),bridge_ends.y,smoothstep(0.,1.3,at.x-bridge.end.x+1.3)))
 var key := Vector2i(((at-origin)/16.).floor())
 var tile := tiles.get_pixelv(key);var rect := rects.get_pixelv(key);var w := int(tile.b)
 var uv := (at-Vector2(rect.r,rect.g))/Vector2(rect.b,rect.a)*(w-1)
 var cell := Vector2i(clampi(floori(uv.x),0,w-2),clampi(floori(uv.y),0,w-2));var f := uv-Vector2(cell);var base := Vector2i(tile.r,tile.g)+cell
 var a := heights.get_pixelv(base).r;var b := heights.get_pixelv(base+Vector2i(1,0)).r;var c := heights.get_pixelv(base+Vector2i(1,1)).r;var d := heights.get_pixelv(base+Vector2i(0,1)).r
 return support(at,a+(b-a)*f.x+(c-b)*f.y if f.x>=f.y else a+(c-d)*f.x+(d-a)*f.y)
