extends BaseState

## Run State (Sprint)
## Player is running fast on the ground
## Release Shift to return to Walk

var _is_sprinting: bool = true

func enter() -> void:
	_is_sprinting = true
	# Connect to sprint signals from InputComponent
	var input_component = movement.get_parent().get_parent().get_node("Components/InputComponent")
	if input_component:
		if not input_component.sprint_stopped.is_connected(_on_sprint_stopped):
			input_component.sprint_stopped.connect(_on_sprint_stopped)

func exit() -> void:
	# Disconnect sprint signals
	var input_component = movement.get_parent().get_parent().get_node("Components/InputComponent")
	if input_component:
		if input_component.sprint_stopped.is_connected(_on_sprint_stopped):
			input_component.sprint_stopped.disconnect(_on_sprint_stopped)

func update(delta: float) -> String:
	if not movement:
		return ""
	
	# Apply ground acceleration (run speed - faster than walk)
	movement.apply_movement(delta, false)
	
	# Check transitions
	if not movement.is_grounded():
		return "Fall"
	
	if movement.can_jump():
		# Check if jump is buffered
		if movement._jump_buffered:
			movement.apply_jump()
			return "Jump"
	
	# Transition back to Walk if sprint released
	if not _is_sprinting:
		return "Walk"
	
	# Return to idle if no input
	if movement._move_direction.x == 0:
		return "Idle"
	
	return ""  # Stay in Run

func _on_sprint_stopped() -> void:
	_is_sprinting = false
