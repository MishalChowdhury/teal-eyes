extends AnimatableBody2D
class_name MovingPlatform

## Moving platform with smooth back-and-forth movement
## Uses Tween for smooth interpolation

@export var move_direction: Vector2 = Vector2(1, 0)  ## Direction of movement (normalized)
@export var move_distance: float = 400.0  ## Total distance to move
@export var move_speed: float = 100.0  ## Speed in pixels/second
@export var auto_start: bool = true  ## Start moving automatically

var _start_position: Vector2
var _target_position: Vector2
var _tween: Tween
var _moving_forward: bool = true

func _ready() -> void:
	_start_position = position
	_target_position = _start_position + move_direction.normalized() * move_distance
	
	if auto_start:
		_start_movement()

func _start_movement() -> void:
	"""Initialize the back-and-forth movement"""
	_move_to_target()

func _move_to_target() -> void:
	"""Move to the current target position"""
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	
	var target = _target_position if _moving_forward else _start_position
	var distance = position.distance_to(target)
	var duration = distance / move_speed
	
	_tween.tween_property(self, "position", target, duration)
	_tween.tween_callback(_on_reached_target)

func _on_reached_target() -> void:
	"""Called when platform reaches its target - reverse direction"""
	_moving_forward = !_moving_forward
	_move_to_target()

func start_moving() -> void:
	"""Start the platform movement"""
	if not _tween or not _tween.is_running():
		_start_movement()

func stop_moving() -> void:
	"""Stop the platform movement"""
	if _tween:
		_tween.kill()
