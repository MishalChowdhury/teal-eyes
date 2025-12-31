extends CharacterBody2D

## Player Coordinator Script
## Minimal orchestrator - delegates all logic to components
## NO input handling, NO movement calculations, NO animation logic

# Component references
@onready var input_component: InputComponent = $Components/InputComponent
@onready var movement_component: MovementComponent = $Components/MovementComponent
@onready var animation_component: AnimationComponent = $Components/AnimationComponent
@onready var state_machine: StateMachine = $Components/StateMachine


func _ready() -> void:
	# Add to player group for debug tracking
	add_to_group("player")
	
	# Inject dependencies into state machine (Refinement #3: Dependency Injection)
	state_machine.init(movement_component, animation_component)
	
	# Wire up signals from InputComponent to MovementComponent
	input_component.move_input_changed.connect(movement_component._on_move_input_changed)
	input_component.jump_pressed.connect(movement_component._on_jump_pressed)
	input_component.jump_released.connect(movement_component._on_jump_released)
	
	# Wire up state machine to animation component
	state_machine.state_changed.connect(animation_component._on_state_changed)
	
	# Also listen to jump released for variable jump height
	input_component.jump_released.connect(_on_jump_released)


func _on_jump_released() -> void:
	"""Handle variable jump height"""
	movement_component.reduce_jump_velocity()
