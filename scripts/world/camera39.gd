extends "res://scripts/world/world38.gd"
const FRAMING_TIME := .85
var framing_target := -1.
var framing_from := 1.3
var framing_value := 1.3
var framing_started := 0.

func _base_zoom_delta() -> float:
	return 1.6 if super._base_zoom_delta()>LEGACY_BATTLE_ZOOM else LEGACY_BATTLE_ZOOM

func _camera_time() -> float:
	return Time.get_ticks_msec()/1000.

func _framing_gain(_delta: float) -> float:
	var target := (LEGACY_BASE_ZOOM+_base_zoom_delta())/LEGACY_BASE_ZOOM
	var now := _camera_time()
	if framing_target<0.:
		framing_value=target; framing_from=target; framing_target=target
	if not is_equal_approx(target,framing_target):
		framing_from=framing_value; framing_target=target; framing_started=now
	var t := clampf((now-framing_started)/FRAMING_TIME,0.,1.)
	var eased := t*t*t*(t*(t*6.-15.)+10.)
	framing_value=lerpf(framing_from,framing_target,eased)
	return framing_value

func _reset_impact_state() -> void:
	var look := camera_look
	super._reset_impact_state()
	# Auto-entering combat must not discard the current walking lookahead.
	if feel_ready and _preserve_framing_on_reset(): camera_look=look
