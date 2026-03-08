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

	var vel_y := movement.get_velocity().y

	# Velocity-based animation speed: slow near apex for GRIS "hang time" feel.
	# At launch (vel_y = jump_velocity): speed_scale = 1.0 (full speed, explosive)
	# At apex   (vel_y = 0):            speed_scale = 0.2 (suspended in air)
	if vel_y < 0.0 and animation:
		var jump_vel: float = movement.movement_data.jump_velocity if movement.movement_data else -600.0
		var apex_factor := remap(vel_y, jump_vel, 0.0, 1.0, 0.2)
		animation.set_speed_scale(clampf(apex_factor, 0.2, 1.0))

	# Transition to Fall when apex reached or moving downward
	if vel_y >= 0.0:
		return "Fall"

	return ""  # Stay in Jump
