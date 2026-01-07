extends StaticBody2D
class_name DisappearingPlatform

## Placeholder for timer-based disappearing platform
## TODO: Implement timer logic with visual feedback (blinking, fading)

@export var visible_duration: float = 3.0  ## Time platform stays solid (seconds)
@export var invisible_duration: float = 2.0  ## Time platform stays gone (seconds)
@export var warning_time: float = 0.5  ## Time to blink before disappearing (seconds)
@export var auto_start: bool = true  ## Start timer automatically

var _timer: Timer
var _is_solid: bool = true

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	
	if auto_start:
		_timer.wait_time = visible_duration
		_timer.start()

func _on_timer_timeout() -> void:
	# TODO: Implement disappearing/reappearing logic
	# Toggle between solid and ghost states
	if _is_solid:
		_disappear()
	else:
		_reappear()

func _disappear() -> void:
	"""Make platform intangible"""
	# TODO: Disable collision, fade out visual
	_is_solid = false
	_timer.wait_time = invisible_duration
	collision_layer = 0
	modulate.a = 0.3  # Temporary visual feedback

func _reappear() -> void:
	"""Make platform solid again"""
	# TODO: Enable collision, fade in visual
	_is_solid = true
	_timer.wait_time = visible_duration
	collision_layer = 1
	modulate.a = 1.0

func pause_timer() -> void:
	"""Pause the disappearing timer"""
	_timer.stop()

func resume_timer() -> void:
	"""Resume the disappearing timer"""
	_timer.start()
