extends "res://scripts/combat/battle_skills110.gd"
func build_chains110() -> void:
 super.build_chains110()
 # Width must not jump when the oldest/farthest particle expires or hits a wall.
 var scale_at_player := pixels110(battle.hero.position+Vector3.UP*.8)
 for chain in chains110: chain.pixel=scale_at_player
func draw_ribbons110() -> void:
 for chain in chains110:
  var points: PackedVector2Array=chain.points
  if points.size()<2: continue
  var width: float=(4.4 if chain.heavy else 3.2)*chain.pixel
  var vertices := PackedVector2Array();var uvs := PackedVector2Array();var indices := PackedInt32Array();var distance := 0.
  for i in points.size():
   var before: Vector2=(points[i]-points[maxi(0,i-1)]).normalized()
   var after: Vector2=(points[mini(points.size()-1,i+1)]-points[i]).normalized()
   if i==0: before=after
   if i==points.size()-1: after=before
   var normal := (before+after).normalized().orthogonal()
   if normal.length_squared()<.01: normal=after.orthogonal()
   var miter := minf(1.2,1./maxf(.2,absf(normal.dot(after.orthogonal()))))
   if i>0: distance+=points[i].distance_to(points[i-1])
   var u: float= distance/(24.*chain.pixel)
   vertices.append(points[i]-normal*width*miter);vertices.append(points[i]+normal*width*miter)
   uvs.append(Vector2(u,0));uvs.append(Vector2(u,1))
   if i>0:
    var at := i*2
    indices.append_array(PackedInt32Array([at-2,at,at+1,at-2,at+1,at-1]))
  RenderingServer.canvas_item_add_triangle_array(ribbon110.get_canvas_item(),indices,vertices,PackedColorArray([Color.WHITE]),uvs,PackedInt32Array(),PackedFloat32Array(),Stream.art.flow.get_rid())
