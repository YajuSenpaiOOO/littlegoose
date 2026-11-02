extends RefCounted
## Sprite frame in world space; weapons own attachment lifetime and effects.
static func frame(art: Sprite3D) -> Dictionary:
 var size=art.texture.get_size()
 var scale=art.global_basis.get_scale()
 var axes=art.global_basis.orthonormalized()
 var bottom=Vector3(art.offset.x,art.offset.y-size.y*.5,0.)*art.pixel_size
 return {"origin":art.global_position+art.global_basis*bottom,"basis":axes,"width":size.x*art.pixel_size*absf(scale.x),"height":size.y*art.pixel_size*absf(scale.y)}
