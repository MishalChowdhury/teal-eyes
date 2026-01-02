extends BaseState

## Idle State
## Player is on ground with no movement input

func update(delta: float) -> String:
	if not movement:
		return ""
	
	# Apply minimal movement (friction will handling stopping)
	movement.apply_movement(delta, false)
	
	# Check transitions
	if not movement.is_grounded():
		return "Fall"
	
	if movement.can_jump():
		# Check if jump is buffered
		if movement._jump_buffered:
			movement.apply_jump()
			return "Jump"
	
	# Check for movement input (MovementComponent tracks this)
	if movement._move_direction.x != 0:
		return "Walk"
	
	return ""  # Stay in Idle
