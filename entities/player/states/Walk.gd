extends BaseState

## Walk State  
## Player is walking on the ground (default movement)
## Press Shift to transition to Run for faster movement

var _is_sprinting: bool = false

func enter() -> void:
	_is_sprinting = false
	# Connect to sprint signals from InputComponent
	var input_component = movement.get_parent().get_parent().get_node("Components/InputComponent")
	if input_component:
		if not input_component.sprint_started.is_connected(_on_sprint_started):
			input_component.sprint_started.connect(_on_sprint_started)
		if not input_component.sprint_stopped.is_connected(_on_sprint_stopped):
			input_component.sprint_stopped.connect(_on_sprint_stopped)

func exit() -> void:
	# Disconnect sprint signals
	var input_component = movement.get_parent().get_parent().get_node("Components/InputComponent")
	if input_component:
		if input_component.sprint_started.is_connected(_on_sprint_started):
			input_component.sprint_started.disconnect(_on_sprint_started)
		if input_component.sprint_stopped.is_connected(_on_sprint_stopped):
			input_component.sprint_stopped.disconnect(_on_sprint_stopped)

func update(delta: float) -> String:
	if not movement:
		return ""
	
	# Apply ground acceleration (walk speed)
	movement.apply_movement(delta, false)
	
	# Check transitions
	if not movement.is_grounded():
		return "Fall"
	
	if movement.can_jump():
		# Check if jump is buffered
		if movement._jump_buffered:
			movement.apply_jump()
			return "Jump"
	
	# Transition to Run if sprinting
	if _is_sprinting:
		return "Run"
	
	# Return to idle if no input
	if movement._move_direction.x == 0:
		return "Idle"
	
	return ""  # Stay in Walk

func _on_sprint_started() -> void:
	_is_sprinting = true

func _on_sprint_stopped() -> void:
	_is_sprinting = false
