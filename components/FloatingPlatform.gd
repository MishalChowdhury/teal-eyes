extends StaticBody2D
class_name FloatingPlatform

## Makes a StaticBody2D bob up and down with a sine wave.

@export var amplitude: float = 20.0 ## Pixels up/down from origin
@export var frequency: float = 0.8 ## Oscillations per second
@export var phase_offset: float = 0.0 ## Radians, so nearby platforms can be out of sync

var _origin_y: float
var _time: float = 0.0


func _ready() -> void:
	_origin_y = position.y
	_time = phase_offset


func _physics_process(delta: float) -> void:
	_time += delta
	position.y = _origin_y + sin(_time * frequency * TAU) * amplitude
