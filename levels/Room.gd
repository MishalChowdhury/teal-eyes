extends Node2D
class_name Room

## Base class for all room scenes
## Manages room properties and camera configuration

@export var room_id: String = "room_default"
@export var default_camera_zoom: float = 1.0
@export var camera_priority: int = 0

@onready var phantom_camera: Node = get_node_or_null("PhantomCamera2D")

func _ready() -> void:
	# Auto-find and assign Player as follow target
	if phantom_camera:
		# Find Player in the scene tree (it's a sibling of Rooms node)
		var player = get_tree().get_first_node_in_group("player")
		if not player:
			# Fallback: navigate up to MainLevel and find Player
			var main_level = get_parent().get_parent()  # Rooms -> MainLevel
			if main_level:
				player = main_level.get_node_or_null("Player")
		
		if player and phantom_camera.has_method("set_follow_target"):
			phantom_camera.set_follow_target(player)
			print("[Room] %s: Assigned Player as follow target" % room_id)
		
		# Set camera priority
		if phantom_camera.has_method("set_priority"):
			phantom_camera.set_priority(camera_priority)
			print("[Room] %s: Set camera priority to %d" % [room_id, camera_priority])
	
	# Emit room ready event (for async loading systems)
	if Events.has_signal("room_loaded"):
		Events.room_loaded.emit(room_id)
