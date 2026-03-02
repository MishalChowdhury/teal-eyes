extends BaseState

## LassoPull State
## Hook attached to anchor point, pulling player toward it
## Phase 1: Pull-to-point mechanic (no swinging)

func enter() -> void:
	print("[LassoPull] Entered - pulling to anchor")
	
	if not grapple:
		push_error("[LassoPull] GrappleController not injected!")


func update(delta: float) -> String:
	if not movement or not grapple:
		return "Fall"
	
	# Check if grapple is still active
	if not grapple.is_active():
		# Grapple ended (reached anchor or auto-released)
		return "Fall"
	
	# Check if pull button is being held
	if Input.is_action_pressed("saree_pull"):
		# Apply pull force toward anchor
		grapple.apply_pull_force(delta)
	
	# Apply reduced gravity during pull (lighter feel)
	if not movement.is_grounded():
		var current_vel: Vector2 = movement.get_velocity()
		current_vel.y += ProjectSettings.get_setting("physics/2d/default_gravity") * 0.5 * delta
		movement.set_velocity(current_vel)
	
	# Allow slight directional control while pulling
	movement.apply_movement(delta * 0.3, true)
	
	# Check for manual release (only on explicit release button, not release of pull)
	if Input.is_action_just_pressed("saree_release"):
		print("[LassoPull] Manual release requested")
		_exit_pull()
		return "Fall"
	
	return "" # Stay in LassoPull


func _exit_pull() -> void:
	"""Helper to release hook and clean up"""
	if grapple:
		grapple.release_hook()


func exit() -> void:
	print("[LassoPull] Exited")
	# Ensure hook is released when leaving state
	_exit_pull()
