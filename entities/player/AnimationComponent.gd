extends Node
class_name AnimationComponent

## Bridges StateMachine state changes to AnimationPlayer in instanced PlayerRig
## Follows Art-First approach: AnimationPlayer drives bone rotations via keyframes

signal animation_finished(anim_name: String)

@onready var state_machine = get_parent().get_node("StateMachine")
@onready var animation_player: AnimationPlayer = _find_animation_player()

## Cache the AnimationPlayer from the instanced PlayerRig
func _find_animation_player() -> AnimationPlayer:
	# Path: Player/Visuals/PlayerRig/AnimationPlayer
	var player_rig = owner.get_node_or_null("Visuals/PlayerRig")
	if not player_rig:
		push_error("AnimationComponent: Could not find Visuals/PlayerRig")
		return null
	
	var anim_player = player_rig.get_node_or_null("AnimationPlayer")
	if not anim_player:
		push_error("AnimationComponent: PlayerRig has no AnimationPlayer")
		return null
	
	return anim_player

func _ready() -> void:
	if not animation_player:
		push_error("AnimationComponent: AnimationPlayer not found. Disabling.")
		set_process(false)
		return
	
	# Connect to state machine
	state_machine.state_changed.connect(_on_state_changed)
	
	# Connect to AnimationPlayer for finish signals
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_state_changed(old_state: String, new_state: String) -> void:
	# Map state names to animation names
	# State names are capitalized (e.g., "Run"), animation names are lowercase (e.g., "run")
	var anim_name = new_state.to_lower()
	
	print("[AnimationComponent] State changed: %s → %s (anim: %s)" % [old_state, new_state, anim_name])
	
	# Verify animation exists
	if not animation_player.has_animation(anim_name):
		push_warning("AnimationComponent: No animation '%s' for state '%s'" % [anim_name, new_state])
		return
	
	# Play the animation
	print("[AnimationComponent] Playing animation: %s" % anim_name)
	animation_player.play(anim_name)

func _on_animation_finished(anim_name: String) -> void:
	# Emit signal for any systems that need to know
	animation_finished.emit(anim_name)

## Optional: Manual animation control (for special cases)
func play_animation(anim_name: String, custom_speed: float = 1.0) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name, -1, custom_speed)

func stop_animation() -> void:
	if animation_player:
		animation_player.stop()
