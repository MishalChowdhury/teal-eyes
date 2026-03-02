extends BaseState

## LassoAim State
## Player is aiming the grappling hook with right stick or mouse
## Entered when aim input is detected

func enter() -> void:
	print("[LassoAim] Entered - aiming grappling hook")
	
	if not grapple:
		push_error("[LassoAim] GrappleController not injected!")


func update(delta: float) -> String:
	if not movement or not grapple:
		return "Idle"
	
	# Allow normal movement while aiming
	movement.apply_movement(delta, not movement.is_grounded())
	
	# Check for cast input
	if Input.is_action_just_pressed("saree_cast"):
		if grapple.try_cast_hook():
			# Hook hit a target - transition to pull state
			return "LassoPull"
		else:
			# No valid target - stay in aim mode
			print("[LassoAim] No valid target")
	
	# Exit aim mode if stick released (no aim direction)
	if not grapple.is_aiming:
		# Return to appropriate state based on movement
		if movement.is_grounded():
			if movement._move_direction.x != 0:
				return "Run"
			else:
				return "Idle"
		else:
			if movement.get_velocity().y < 0:
				return "Jump"
			else:
				return "Fall"
	
	return "" # Stay in LassoAim


func exit() -> void:
	print("[LassoAim] Exited")
