extends RefCounted
static func curve(t: float,keys: Array) -> float:
 if t<=keys[0][0]:return keys[0][1]
 for i in range(1,keys.size()):
  if t<=keys[i][0]:
   var u: float=(t-keys[i-1][0])/(keys[i][0]-keys[i-1][0]);u=u*u*(3.-2.*u)
   return lerpf(keys[i-1][1],keys[i][1],u)
 return keys[-1][1]
static func sample(t: float) -> Dictionary:
 var x:=curve(t,[[0.,0.],[.10,-2.],[.20,2.],[.28,13.],[.40,5.],[.53,-2.],[.66,0.]])
 return {"body_x":x,"lean":x*.002,"upper":curve(t,[[0.,0.],[.10,.10],[.18,-.10],[.28,-.08],[.42,.025],[.58,0.]]),"elbow":curve(t,[[0.,0.],[.10,.15],[.18,-.14],[.28,-.08],[.43,.06],[.58,0.]]),"reach":curve(t,[[0.,0.],[.10,20.],[.18,-40.],[.28,-25.],[.43,5.],[.58,0.]])}
