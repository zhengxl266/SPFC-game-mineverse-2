extends CanvasModulate

const Minutes_per_day = 1440
const Minutes_per_hour = 60
const Ingame_to_real_min_duration = (2 * PI)/ Minutes_per_day

signal time_tick(day:int, hour:int, minute:int)

@export var gradient: GradientTexture1D
@export var Ingame_speed = 10.0
@export var Initial_hour = 12:
	set(h):
		Initial_hour = h
		time = Ingame_to_real_min_duration * Initial_hour * Minutes_per_hour

var time:float = 0.0
var past_minute: float = -1.0

func _ready() -> void:
	if Global.ingame_time > 0:
		time = Global.ingame_time
	else:
		time = Ingame_to_real_min_duration * Initial_hour * Minutes_per_hour

func _process(delta:float) -> void:
	time += delta *Ingame_to_real_min_duration * Ingame_speed
	var value = (sin(time-PI/2)+1.0)/2.0
	self.color = gradient.gradient.sample(value)
	_recalculate_time()
	Global.ingame_time = time
	
func _recalculate_time() -> void:
	var total_minutes = int(time/ Ingame_to_real_min_duration)
	var day = int(total_minutes/ Minutes_per_day)
	var current_day_minutes = total_minutes % Minutes_per_day
	var hour = int(current_day_minutes/ Minutes_per_hour)
	var minute = int(current_day_minutes % Minutes_per_hour)
	
	if past_minute != minute:
		past_minute = minute
		time_tick.emit(day,hour,minute)
