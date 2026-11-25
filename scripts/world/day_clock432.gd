extends "res://scripts/world/day_clock55.gd"

const SECONDS_PER_HOUR := 105.
const DAWN := 7.

func advance(seconds: float, blocked := false) -> void:
 if not blocked and not paused and seconds>0.:
  set_total(total_hours()+seconds*speed/SECONDS_PER_HOUR)

func total_hours() -> float:
 return (day-1)*24.+hour

func set_total(hours: float) -> void:
 day=floori(hours/24.)+1
 hour=fposmod(hours,24.)

func next_dawn() -> float:
 return (day-1)*24.+DAWN+(24. if hour>=DAWN else 0.)

func at_deep_night() -> bool:
 return hour>=22. or hour<6.

func period() -> String:
 return "深夜" if hour<6. else super.period()

func sleep_to_morning() -> void:
 set_total(next_dawn())
