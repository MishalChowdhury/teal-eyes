extends CanvasLayer

## Debug HUD - FPS, player state, and performance tracking
## Toggle with F12 key
## Optimized: Updates at 10Hz instead of 60Hz to prevent performance impact

@onready var debug_label: Label = $DebugLabel

var player: CharacterBody2D = null
var visible_state: bool = true

# Cached references (avoids repeated get_node calls)
var movement_comp: Node = null
var state_machine: Node = null

# Update throttling
var update_timer: Timer = null
const UPDATE_RATE: float = 0.1  # Update every 100ms (10 times per second)


func _ready() -> void:
	# Find player in scene
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		# Cache component references once
		movement_comp = player.get_node_or_null("Components/MovementComponent")
		state_machine = player.get_node_or_null("Components/StateMachine")
	
	# Create update timer to throttle expensive operations
	update_timer = Timer.new()
	update_timer.name = "UpdateTimer"
	update_timer.wait_time = UPDATE_RATE
	update_timer.one_shot = false
	update_timer.timeout.connect(_update_debug_display)
	add_child(update_timer)
	update_timer.start()


func _unhandled_input(event: InputEvent) -> void:
	# Event-driven input handling - only runs when input occurs
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		visible_state = !visible_state
		debug_label.visible = visible_state
		# Start/stop timer based on visibility
		if visible_state:
			update_timer.start()
		else:
			update_timer.stop()
		get_viewport().set_input_as_handled()


func _update_debug_display() -> void:
	"""Called by timer at UPDATE_RATE frequency"""
	if not visible_state or not debug_label:
		return
	
	# Use PackedStringArray for efficient string building
	var lines: PackedStringArray = []
	
	lines.append("=== DEBUG INFO ===")
	lines.append("FPS: %d" % Engine.get_frames_per_second())
	lines.append("Physics FPS: %d" % Engine.physics_ticks_per_second)
	lines.append("Nodes: %d" % get_tree().get_node_count())
	lines.append("")
	
	# Player info
	if player:
		lines.append("=== PLAYER ===")
		lines.append("Position: (%.0f, %.0f)" % [player.position.x, player.position.y])
		
		if movement_comp:
			var velocity = movement_comp.get_velocity()
			lines.append("Velocity: (%.0f, %.0f)" % [velocity.x, velocity.y])
			lines.append("Grounded: %s" % str(movement_comp.is_grounded()))
			lines.append("On Wall: %s" % str(movement_comp.is_on_wall()))
		
		if state_machine and state_machine.current_state:
			lines.append("State: %s" % state_machine.current_state.name)
	else:
		lines.append("Player not found!")
	
	lines.append("")
	lines.append("[F12] Toggle Debug")
	
	# Single string assignment is faster than multiple concatenations
	debug_label.text = "\n".join(lines)

