extends Resource
## Shared art direction. Hours are ordered; intermediate values are continuous.
@export_range(1.,120.) var day_minutes := 24.
@export var wake_hour := 6.5
@export var start_hour := 7.5
@export var stop_hour := 24.
@export var keys: Array[Dictionary] = [
	{"hour":6.,"sun":Color("ffdbad"),"energy":.40,"ambient":Color("a6b9cc"),"air":.29,"fog":Color("a1b9b6"),"shadow":Vector3(.88,.96,1.06),"highlight":Vector3(1.06,1.02,.92),"exposure":.92,"saturation":.91,"daylight":.65,"rays":.10,"dust":.70,"lamps":.6},
	{"hour":8.,"sun":Color("fff0cc"),"energy":.82,"ambient":Color("b0c5cb"),"air":.33,"fog":Color("aac4bb"),"shadow":Vector3(.92,.99,1.04),"highlight":Vector3(1.04,1.02,.96),"exposure":1.,"saturation":.98,"daylight":1.,"rays":.27,"dust":1.,"lamps":.25},
	{"hour":12.,"sun":Color("fff9ec"),"energy":1.06,"ambient":Color("bfcbd0"),"air":.40,"fog":Color("abc4ba"),"shadow":Vector3(.96,1.,1.02),"highlight":Vector3(1.02,1.015,.99),"exposure":1.05,"saturation":1.04,"daylight":1.,"rays":.015,"dust":.48,"lamps":.12},
	{"hour":16.,"sun":Color("ffe1a4"),"energy":.80,"ambient":Color("b5b5c6"),"air":.31,"fog":Color("c5bc9f"),"shadow":Vector3(.94,.96,1.02),"highlight":Vector3(1.12,1.035,.85),"exposure":.98,"saturation":.99,"daylight":.92,"rays":.025,"dust":.72,"lamps":.40},
	{"hour":18.,"sun":Color("ffac68"),"energy":.68,"ambient":Color("9b9fbc"),"air":.27,"fog":Color("c49383"),"shadow":Vector3(.91,.91,1.045),"highlight":Vector3(1.20,1.015,.76),"exposure":.87,"saturation":.94,"daylight":.70,"rays":.02,"dust":.55,"lamps":.85},
	{"hour":19.5,"sun":Color("c1b4e5"),"energy":.19,"ambient":Color("7e96c6"),"air":.30,"fog":Color("7c8fae"),"shadow":Vector3(.77,.85,1.12),"highlight":Vector3(.94,.96,1.09),"exposure":.77,"saturation":.80,"daylight":.12,"rays":0.,"dust":.04,"lamps":1.},
	{"hour":22.,"sun":Color("a4c5ff"),"energy":.16,"ambient":Color("7798d0"),"air":.28,"fog":Color("526d97"),"shadow":Vector3(.68,.81,1.16),"highlight":Vector3(.84,.94,1.14),"exposure":.70,"saturation":.78,"daylight":0.,"rays":0.,"dust":0.,"lamps":1.},
	{"hour":24.,"sun":Color("a4c5ff"),"energy":.14,"ambient":Color("7798d0"),"air":.26,"fog":Color("4e668c"),"shadow":Vector3(.68,.81,1.16),"highlight":Vector3(.84,.94,1.14),"exposure":.68,"saturation":.78,"daylight":0.,"rays":0.,"dust":0.,"lamps":1.}
]

func sample(hour: float) -> Dictionary:
	if hour<=float(keys[0].hour): return keys[0].duplicate()
	for i in range(1,keys.size()):
		var right: Dictionary=keys[i]
		if hour>float(right.hour): continue
		var left: Dictionary=keys[i-1]
		var weight := smoothstep(float(left.hour),float(right.hour),hour)
		var result := {}
		for key in left:
			if left[key] is Color: result[key]=left[key].lerp(right[key],weight)
			elif left[key] is Vector3: result[key]=left[key].lerp(right[key],weight)
			else: result[key]=lerpf(float(left[key]),float(right[key]),weight)
		return result
	return keys[-1].duplicate()
