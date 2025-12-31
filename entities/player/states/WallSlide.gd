extends BaseState

## WallSlide State
## Player is sliding down a wall

var _wall_normal: Vector2 = Vector2.ZERO


func enter() -> void:
	if movement:
		_wall_normal = movement.get_wall_normal()


func update(delta: float) -> String:
	if not movement:
		return ""
	
	# Apply wall slide friction
	movement.apply_wall_slide()
	
	# Still apply horizontal movement (can move away from wall)
	movement.apply_movement(delta, true)
	
	# Check for wall jump
	if movement._jump_buffered:
		movement.apply_wall_jump(_wall_normal)
		return "Jump"
	
	# Check if no longer on wall
	if not movement.is_on_wall():
		return "Fall"
	
	# Check if landed
	if movement.is_grounded():
		if movement._move_direction.x != 0:
			return "Run"
		else:
			return "Idle"
	
	return ""  # Stay in WallSlide
