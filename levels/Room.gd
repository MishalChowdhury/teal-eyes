extends Node2D
class_name Room

## Base class for all room scenes
## Manages room properties and camera configuration

@export var room_id: String = "room_default"
@export var default_camera_zoom: float = 1.0
@export var camera_priority: int = 0
@export var room_bounds: Vector2 = Vector2(1920, 1080)  # Width × Height for trigger area

@onready var phantom_camera: Node = get_node_or_null("PhantomCamera2D")
var trigger_area: Area2D

func _ready() -> void:
	# Auto-find and assign Player as follow target
	if phantom_camera:
		# Find Player in the scene tree (it's in the "player" group)
		var player = get_tree().get_first_node_in_group("player")
		if not player:
			# Fallback: navigate up to Level and find Player
			var level = get_parent().get_parent()  # Rooms -> Level01
			if level:
				player = level.get_node_or_null("Player")
		
		if player:
			# PhantomCamera2D uses properties, not methods
			phantom_camera.follow_target = player
		
		# Set initial camera priority
		phantom_camera.priority = camera_priority
		print("🎬 Room initialized: ", room_id, " | Priority: ", camera_priority, " | Zoom: ", phantom_camera.zoom, " | Pos: ", phantom_camera.position)
	
	# Connect to existing trigger area
	trigger_area = get_node_or_null("CameraTrigger")
	if trigger_area:
		trigger_area.body_entered.connect(_on_player_entered)
		print("📍 Trigger connected for room: ", room_id)

func _on_player_entered(body: Node) -> void:
	"""Activate this room's camera when player enters"""
	if body.is_in_group("player"):
		activate_camera()

func activate_camera() -> void:
	"""Set this camera as active and deactivate others"""
	if not phantom_camera:
		return
	
	# Deactivate all other room cameras
	var rooms_container = get_parent()  # The "Rooms" node
	if rooms_container:
		for room in rooms_container.get_children():
			if room != self and room is Room:
				var other_camera = room.get_node_or_null("PhantomCamera2D")
				if other_camera:
					other_camera.priority = 0
	
	# Activate this camera
	phantom_camera.priority = 10
	
	# Emit event for other systems
	Events.room_entered.emit(room_id)
