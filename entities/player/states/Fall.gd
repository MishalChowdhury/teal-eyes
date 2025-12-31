extends BaseState

## Fall State
## Player is airborne and falling (includes coyote time)

func update(delta: float) -> String:
	if not movement:
		return ""
	
	# Apply air control
	movement.apply_movement(delta, true)
	
	# Check for wall slide
	if movement.is_on_wall():
		# Check if moving toward wall
		var wall_normal := movement.get_wall_normal()
		if movement._move_direction.x != 0:
			# If pressing toward wall, transition to wall slide
			if (wall_normal.x > 0 and movement._move_direction.x < 0) or \
			   (wall_normal.x < 0 and movement._move_direction.x > 0):
				return "WallSlide"
	
	# Coyote time jump (can still jump shortly after leaving ground)
	if movement.can_jump():
		if movement._jump_buffered:
			movement.apply_jump()
			return "Jump"
	
	# Check if landed
	if movement.is_grounded():
		if movement._move_direction.x != 0:
			return "Run"
		else:
			return "Idle"
	
	return ""  # Stay in Fall
