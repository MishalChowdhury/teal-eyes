extends BaseState

## Dash State
## Omnidirectional dash that moves player 400px in 0.2s
## Works in all directions including diagonals, on ground and in air

var dash_direction: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0

func enter() -> void:
	if not movement or not movement.movement_data:
		return
	
	# Store the dash direction (passed from input)
	# This will be set by the state machine when transitioning
	dash_timer = movement.movement_data.dash_duration
	
	# Start the dash
	movement.start_dash(dash_direction)
	
	# Start visual effect
	var player = movement._character_body
	if player and player.has_node("DashEffect"):
		var dash_effect = player.get_node("DashEffect")
		if dash_effect.has_method("start_dash_effect"):
			dash_effect.start_dash_effect()
	
	# Play run animation as placeholder
	if animation:
		animation.play_animation("RunFloaty")


func update(delta: float) -> String:
	if not movement:
		return ""
	
	# Count down dash timer
	dash_timer -= delta
	
	# End dash when timer expires
	if dash_timer <= 0:
		movement.end_dash()
		
		# Transition to appropriate state
		if movement.is_grounded():
			if movement._move_direction.x != 0:
				return "Walk"
			else:
				return "Idle"
		else:
			return "Fall"
	
	# Check for wall collision during dash (interrupt dash)
	if movement.is_on_wall():
		movement.end_dash()
		return "WallSlide"
	
	return ""  # Stay in Dash


func exit() -> void:
	# Ensure dash is ended when leaving state
	if movement:
		movement.end_dash()
		
		# Stop visual effect
		var player = movement._character_body
		if player and player.has_node("DashEffect"):
			var dash_effect = player.get_node("DashEffect")
			if dash_effect.has_method("stop_dash_effect"):
				dash_effect.stop_dash_effect()


func set_dash_direction(direction: Vector2) -> void:
	"""Called by state machine to set dash direction before entering"""
	dash_direction = direction.normalized()
