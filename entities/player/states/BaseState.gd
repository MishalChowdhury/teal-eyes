extends Node
class_name BaseState

## Base class for all player states
## Provides virtual methods for state lifecycle

var movement: MovementComponent = null
var animation: AnimationComponent = null


func init(movement_component: MovementComponent, animation_component: AnimationComponent) -> void:
	"""Called by StateMachine to inject dependencies"""
	movement = movement_component
	animation = animation_component


func enter() -> void:
	"""Called when entering this state"""
	pass


func exit() -> void:
	"""Called when exiting this state"""
	pass


func update(_delta: float) -> String:
	"""Called every physics frame. Return state name to transition, or empty string to stay"""
	return ""
