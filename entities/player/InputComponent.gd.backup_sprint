extends Node
class_name InputComponent

## Handles input detection and emits generic signals
## NO game logic - pure input translation

# Signals
signal move_input_changed(direction: Vector2)
signal jump_pressed()
signal jump_released()
signal sprint_started()
signal sprint_stopped()

var _last_move_direction: Vector2 = Vector2.ZERO
var _is_sprinting: bool = false


func _process(_delta: float) -> void:
	_handle_movement_input()
	_handle_jump_input()
	_handle_sprint_input()


func _handle_movement_input() -> void:
	var move_direction := Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		move_direction.x -= 1.0
	if Input.is_action_pressed("move_right"):
		move_direction.x += 1.0
	
	# Only emit signal if direction changed
	if move_direction != _last_move_direction:
		move_input_changed.emit(move_direction)
		_last_move_direction = move_direction


func _handle_jump_input() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_pressed.emit()
	
	if Input.is_action_just_released("jump"):
		jump_released.emit()


func _handle_sprint_input() -> void:
	var is_sprint_held = Input.is_action_pressed("ui_shift")  # Using Shift key
	
	if is_sprint_held and not _is_sprinting:
		_is_sprinting = true
		sprint_started.emit()
	elif not is_sprint_held and _is_sprinting:
		_is_sprinting = false
		sprint_stopped.emit()
