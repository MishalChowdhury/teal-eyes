extends Node
class_name MovementComponent

## Handles all physics calculations and movement
## Uses PlayerMovementData resource for configuration

@export var movement_data: PlayerMovementData

var _character_body: CharacterBody2D
var _velocity: Vector2 = Vector2.ZERO
var _move_direction: Vector2 = Vector2.ZERO
var _was_grounded: bool = false

# Game feel timers
var _coyote_timer: Timer
var _jump_buffer_timer: Timer
var _jump_buffered: bool = false


func _ready() -> void:
	# Get CharacterBody2D (MovementComponent is under Components node, so we need grandparent)
	var parent: Node = get_parent()  # Components node
	if parent:
		_character_body = parent.get_parent() as CharacterBody2D  # Player (CharacterBody2D)
	
	if not _character_body or not _character_body is CharacterBody2D:
		push_error("MovementComponent must be descendant of CharacterBody2D")
		return
	
	# Create coyote timer
	_coyote_timer = Timer.new()
	_coyote_timer.name = "CoyoteTimer"
	_coyote_timer.one_shot = true
	_coyote_timer.wait_time = movement_data.coyote_time if movement_data else 0.1
	add_child(_coyote_timer)
	
	# Create jump buffer timer
	_jump_buffer_timer = Timer.new()
	_jump_buffer_timer.name = "JumpBufferTimer"
	_jump_buffer_timer.one_shot = true
	_jump_buffer_timer.wait_time = movement_data.jump_buffer_time if movement_data else 0.1
	add_child(_jump_buffer_timer)
	_jump_buffer_timer.timeout.connect(_on_jump_buffer_timeout)


func _physics_process(delta: float) -> void:
	if not movement_data or not _character_body:
		return
	
	# Track grounded state changes for coyote time
	var is_currently_grounded := _character_body.is_on_floor()
	if _was_grounded and not is_currently_grounded:
		# Just left ground - start coyote timer
		_coyote_timer.start()
	_was_grounded = is_currently_grounded
	
	# Apply gravity
	if not is_currently_grounded:
		_velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * movement_data.gravity_scale * delta
	
	# Apply movement from state machine
	_character_body.velocity = _velocity
	_character_body.move_and_slide()
	_velocity = _character_body.velocity


# ========== Public Interface ==========

func apply_movement(delta: float, use_air_acceleration: bool = false) -> void:
	"""Apply horizontal movement based on current move direction"""
	var accel := movement_data.air_acceleration if use_air_acceleration else movement_data.acceleration
	
	if _move_direction.x != 0:
		_velocity.x = move_toward(_velocity.x, _move_direction.x * movement_data.speed, accel * delta)
	else:
		_velocity.x = move_toward(_velocity.x, 0, movement_data.friction * delta)


func apply_jump() -> void:
	"""Apply standard jump velocity"""
	_velocity.y = movement_data.jump_velocity
	_jump_buffered = false
	_jump_buffer_timer.stop()


func apply_wall_jump(wall_normal: Vector2) -> void:
	"""Apply wall jump with horizontal pushback away from wall"""
	# Push UP and AWAY from wall
	_velocity.y = movement_data.jump_velocity
	_velocity.x = wall_normal.x * movement_data.wall_jump_push_back
	_jump_buffered = false
	_jump_buffer_timer.stop()


func reduce_jump_velocity() -> void:
	"""Reduce upward velocity for variable jump height"""
	if _velocity.y < 0:
		_velocity.y *= 0.5


func apply_wall_slide() -> void:
	"""Apply wall slide physics to reduce fall speed"""
	if _velocity.y > 0:
		_velocity.y = min(_velocity.y * movement_data.wall_slide_friction, movement_data.wall_slide_max_speed)


func is_grounded() -> bool:
	"""Check if player is on floor (includes coyote time)"""
	return _character_body.is_on_floor() or not _coyote_timer.is_stopped()


func can_jump() -> bool:
	"""Check if jump is allowed (grounded or buffered)"""
	return is_grounded() or _jump_buffered


func is_on_wall() -> bool:
	"""Check if touching a wall"""
	return _character_body.is_on_wall()


func get_wall_normal() -> Vector2:
	"""Get the normal vector of the wall we're touching"""
	return _character_body.get_wall_normal()


func get_velocity() -> Vector2:
	"""Get current velocity"""
	return _velocity


func set_velocity(new_velocity: Vector2) -> void:
	"""Set velocity directly"""
	_velocity = new_velocity


# ========== Input Handlers (Connected from Player.gd) ==========

func _on_move_input_changed(direction: Vector2) -> void:
	"""Handle movement input from InputComponent"""
	_move_direction = direction


func _on_jump_pressed() -> void:
	"""Handle jump press - start buffer timer"""
	_jump_buffered = true
	_jump_buffer_timer.start()


func _on_jump_released() -> void:
	"""Handle jump release - clear buffer"""
	_jump_buffered = false
	_jump_buffer_timer.stop()


func _on_jump_buffer_timeout() -> void:
	"""Jump buffer expired"""
	_jump_buffered = false
