extends Node
class_name StateMachine

## Generic state machine orchestrator
## Manages state transitions and lifecycle

signal state_changed(old_state: String, new_state: String)

var current_state: Node = null
var states: Dictionary = {}

# Injected dependencies (set by Player.gd)
var movement_component: MovementComponent = null
var animation_component: AnimationComponent = null


func init(movement: MovementComponent, animation: AnimationComponent) -> void:
	"""Initialize with component dependencies (called from Player.gd)"""
	movement_component = movement
	animation_component = animation
	
	# Collect all state children and inject dependencies
	for child in get_children():
		if child is Node:
			states[child.name] = child
			# Inject dependencies into each state
			if child.has_method("init"):
				child.init(movement_component, animation_component)
	
	# Start with Idle state
	if states.has("Idle"):
		_transition_to("Idle")
	else:
		push_error("StateMachine requires an 'Idle' state as starting state")


func _ready() -> void:
	# Wait for init() to be called from Player.gd
	pass


func _physics_process(delta: float) -> void:
	if current_state and current_state.has_method("update"):
		var next_state = current_state.update(delta)
		if next_state and next_state != current_state.name:
			_transition_to(next_state)


func _transition_to(state_name: String) -> void:
	"""Transition to a new state"""
	if not states.has(state_name):
		push_error("State '%s' does not exist" % state_name)
		return
	
	var old_state_name := ""
	if current_state:
		old_state_name = current_state.name
		if current_state.has_method("exit"):
			current_state.exit()
	
	current_state = states[state_name]
	
	if current_state.has_method("enter"):
		current_state.enter()
	
	state_changed.emit(old_state_name, state_name)


func force_transition(state_name: String) -> void:
	"""Force a transition from external code (e.g., for Saree states later)"""
	_transition_to(state_name)
