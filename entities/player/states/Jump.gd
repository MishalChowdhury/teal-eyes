extends BaseState

## Jump State
## Player has jumped and is moving upward

func enter() -> void:
	# Apply jump velocity on enter (if not already applied by buffer)
	if movement and not movement._jump_buffered:
		movement.apply_jump()


func update(delta: float) -> String:
	if not movement:
		return ""
	
	# Apply air control
	movement.apply_movement(delta, true)
	
	# Variable jump height - reduce velocity if jump released early
	if movement.get_velocity().y < 0:
		# Still moving up - check if jump was released
		# MovementComponent tracks this via _on_jump_released
		# For now, we check if vertical velocity is slowing
		pass
	
	# Transition to Fall when apex reached or moving downward
	if movement.get_velocity().y >= 0:
		return "Fall"
	
	return ""  # Stay in Jump
