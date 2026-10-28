extends "res://scripts/art/meadow_lab12.gd"
## Small clearing: a level cottage pad, shallow path, low forested banks.
func height_at(x: float,z: float,enabled: bool) -> float:
	if not enabled: return 0.
	var road := .10*sin(z*.16)
	var bank := .48*exp(-((x+10.)*(x+10.)+(z+7.)*(z+7.))/43.)
	bank += .7*exp(-((x-10.)*(x-10.)+(z+12.)*(z+12.))/54.)
	bank -= .14*exp(-((x-7.)*(x-7.)+(z-5.)*(z-5.))/32.)
	bank += noise.get_noise_2d(x,z)*.07
	var h := road+bank*smoothstep(1.1,5.,absf(x-sin(z*.25)*.9))
	var pad := (1.-smoothstep(3.7,5.0,absf(x+4.7)))*(1.-smoothstep(2.4,3.8,absf(z+6.7)))
	h = lerpf(h,.12,pad)
	return h*(1.-smoothstep(22.,30.,maxf(absf(x),absf(z))))
