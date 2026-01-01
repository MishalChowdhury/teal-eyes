extends Area2D
class_name RoomTransitionTrigger

## Triggers seamless camera transitions between rooms via priority switching
## Auto-detects which room cameras to switch based on player movement direction

enum Direction { RIGHT, LEFT, UP, DOWN }

@export var transition_direction: Direction = Direction.RIGHT  ## Which direction triggers the transition

var source_room_camera: Node = null
var target_room_camera: Node = null

func _ready() -> void:
	# CRITICAL: System Redundancy Fix
	# This trigger system is disabled in favor of RoomTransitionManager.gd
	# to prevent double-triggering events.
	print("[RoomTransitionTrigger] DISABLED: Redundant system. Using RoomTransitionManager instead.")
	set_process(false)
	set_physics_process(false)
	monitoring = false
	monitorable = false
	return

	# ORIGINALLY:
	# Enable Area2D monitoring

	# Enable Area2D monitoring
	monitoring = true
	monitorable = false  # Trigger doesn't need to be detected by others
	
	# Connect to the body_entered signal
	body_entered.connect(_on_body_entered)
	
	# Set collision layers for player detection only
	collision_layer = 0  # Trigger doesn't exist on any layer
	collision_mask = 2   # Detects Layer 2 (Player)
	
	print("[RoomTransitionTrigger] Trigger initialized - monitoring=%s, mask=%d" % [monitoring, collision_mask])
	
	# Auto-find cameras based on room structure
	_auto_detect_cameras()

	print("[RoomTransitionTrigger] === Camera detection complete ===")

func _auto_detect_cameras() -> void:
	print("[RoomTransitionTrigger] === Starting camera detection ===")
	
	# Get parent room (this trigger is a child of a Room node)
	var current_room = get_parent()
	if not current_room:
		push_error("[RoomTransitionTrigger] No parent room found!")
		return
	
	print("[RoomTransitionTrigger] Current room: %s" % current_room.name)
	print("[RoomTransitionTrigger] Transition direction: %s" % transition_direction)
	
	# Get source camera (in the same room as this trigger)
	source_room_camera = current_room.get_node_or_null("PhantomCamera2D")
	if source_room_camera:
		print("[RoomTransitionTrigger] ✓ Found source camera in %s" % current_room.name)
	else:
		print("[RoomTransitionTrigger] ✗ No source camera found!")
	
	# Get sibling room based on direction
	var rooms_container = current_room.get_parent()  # Should be "Rooms" node
	if not rooms_container:
		print("[RoomTransitionTrigger] ✗ No rooms container found!")
		return
	
	print("[RoomTransitionTrigger] Rooms container: %s" % rooms_container.name)
	print("[RoomTransitionTrigger] Available rooms: %s" % rooms_container.get_children().map(func(n): return n.name))
	
	# Find target room based on direction
	var target_room_name = ""
	match transition_direction:
		Direction.RIGHT:
			# If we're in Room1, target is Room2
			if "Room1" in current_room.name:
				target_room_name = "Room2"
		Direction.LEFT:
			# If we're in Room2, target is Room1
			if "Room2" in current_room.name:
				target_room_name = "Room1"
	
	print("[RoomTransitionTrigger] Looking for target room: '%s'" % target_room_name)
	
	if target_room_name:
		var target_room = rooms_container.get_node_or_null(target_room_name)
		if target_room:
			target_room_camera = target_room.get_node_or_null("PhantomCamera2D")
			if target_room_camera:
				print("[RoomTransitionTrigger] ✓ %s → %s transition ready" % [current_room.name, target_room_name])
			else:
				print("[RoomTransitionTrigger] ✗ Found room '%s' but no PhantomCamera2D inside!" % target_room_name)
		else:
			push_warning("[RoomTransitionTrigger] ✗ Target room '%s' not found in container" % target_room_name)
	else:
		print("[RoomTransitionTrigger] ✗ No target room name determined (direction/room name mismatch?)")
	
	print("[RoomTransitionTrigger] === Camera detection complete ===")

func _on_body_entered(body: Node2D) -> void:
	return # DISABLED
	
	# Check if it's the player

	if body.name != "Player":
		return
	
	print("[RoomTransitionTrigger] Player entered trigger in %s" % get_parent().name)
	
	# Swap camera priorities for seamless transition
	if target_room_camera and target_room_camera.has_method("set_priority"):
		var old_priority = target_room_camera.get_priority() if target_room_camera.has_method("get_priority") else "unknown"
		target_room_camera.set_priority(10)  # Activate target camera
		print("[RoomTransitionTrigger] ✓ Activated %s camera (priority %s → 10)" % [target_room_camera.get_parent().name, old_priority])
	else:
		print("[RoomTransitionTrigger] ✗ Failed to activate target camera!")
	
	if source_room_camera and source_room_camera.has_method("set_priority"):
		var old_priority = source_room_camera.get_priority() if source_room_camera.has_method("get_priority") else "unknown"
		source_room_camera.set_priority(0)   # Deactivate source camera
		print("[RoomTransitionTrigger] ✓ Deactivated %s camera (priority %s → 0)" % [source_room_camera.get_parent().name, old_priority])
	else:
		print("[RoomTransitionTrigger] ✗ Failed to deactivate source camera!")
	
	# Emit event for other systems (optional)
	if Events.has_signal("room_transition_triggered"):
		var from_id = source_room_camera.get_parent().room_id if source_room_camera else ""
		var to_id = target_room_camera.get_parent().room_id if target_room_camera else ""
		Events.room_transition_triggered.emit(from_id, to_id)
