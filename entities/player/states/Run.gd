extends BaseState

## Run State
## Player is moving on the ground

func update(delta: float) -> String:
	if not movement:
		return ""
	
	# Apply ground acceleration
	movement.apply_movement(delta, false)
	
	# Check transitions
	if not movement.is_grounded():
		return "Fall"
	
	if movement.can_jump():
		# Check if jump is buffered
		if movement._jump_buffered:
			movement.apply_jump()
			return "Jump"
	
	# Return to idle if no input
	if movement._move_direction.x == 0:
		return "Idle"
	
	return ""  # Stay in Run
