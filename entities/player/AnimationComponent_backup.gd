extends Node

## Wraps AnimationPlayer for state-driven animations
## Listens to StateMachine state changes

@onready var _animation_player: AnimationPlayer = null  # Will be set when AnimationPlayer is added


func _ready() -> void:
	# Try to find AnimationPlayer in parent hierarchy
	var parent := get_parent()
	if parent:
		_animation_player = parent.get_node_or_null("AnimationPlayer")


func _on_state_changed(old_state: String, new_state: String) -> void:
	"""Handle state transitions and play appropriate animations"""
	# Animation logic goes here when AnimationPlayer is set up
	
	# TODO: When AnimationPlayer is set up, play animations based on state
	# Example:
	# match new_state:
	#     "Idle":
	#         _animation_player.play("idle")
	#     "Run":
	#         _animation_player.play("run")
	#     "Jump":
	#         _animation_player.play("jump")
	#     "Fall":
	#         _animation_player.play("fall")
	#     "WallSlide":
	#         _animation_player.play("wall_slide")
